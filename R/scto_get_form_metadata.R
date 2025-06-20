#' Fetch form metadata from a SurveyCTO server
#'
#' This function fetches metadata, including form definitions, for deployed and
#' previous versions of one or more forms.
#'
#' @param auth [scto_auth()] object.
#' @param form_ids Character vector indicating the form ids. `NULL` indicates
#'   all forms.
#' @param deployed_only Logical indicating whether to fetch metadata for all
#'   versions of each form, or only for the deployed version.
#' @param get_defs Logical indicating whether to fetch form definitions.
#' @param def_dir String indicating directory in which to save the form
#'   definitions as Excel files.
#'
#' @return A `data.table` with one row per form (and per version, if
#'   `deployed_only` is `FALSE`). Definitions are returned as nested
#'   `data.table`s, which can be unnested using
#'   [scto_unnest_form_definitions()].
#'
#' @examples
#' \dontrun{
#' auth = scto_auth('scto_auth.txt')
#' form_metadata = scto_get_form_metadata(auth, 'my_form')
#' form_defs = scto_unnest_form_definitions(form_metadata)
#' }
#'
#' @export
scto_get_form_metadata = function(
    auth, form_ids = NULL, deployed_only = FALSE, get_defs = TRUE,
    def_dir = NULL) {
  assert_class(auth, 'scto_auth')
  form_ids = assert_form_ids(auth, form_ids)
  assert_flag(deployed_only)
  assert_flag(get_defs)
  if (get_defs) {
    assert_string(def_dir, null.ok = TRUE)
    if (!is.null(def_dir)) {
      assert_path_for_output(def_dir, overwrite = TRUE)
    }
  }

  r = list()
  for (i in seq_len(length(form_ids))) {
    id = form_ids[i]
    cot = tryCatch(
      get_form_meta(auth, id, deployed_only, get_defs, def_dir), error = \(e) e)
    if (inherits(cot, 'error')) scto_abort('Form {.form {id}} was not found.')
    r[[i]] = cot
  }

  d = rbindlist(r, use.names = TRUE, fill = TRUE)
  d
}


get_form_meta = function(auth, id, deployed_only, get_defs, def_dir) {
  unix_ms = as.numeric(Sys.time()) * 1000
  request_url = glue(
    'https://{auth$servername}.surveycto.com/forms/{id}/files?t={unix_ms}')

  scto_bullets(c(v = 'Reading metadata for form {.form {id}}.'))
  content = get_api_response(auth, request_url)

  r = jsonlite::fromJSON(content)
  d = as.data.table(r$deployedGroupFiles$definitionFile)
  if (nrow(d) == 0L) return(d)

  if (!deployed_only) d = rbind(d, as.data.table(r$previousDefinitionFiles))
  set(d, j = 'id', value = NULL)
  set(d, j = 'is_deployed', value = c(TRUE, rep_len(FALSE, nrow(d) - 1L)))
  setnames(
    d, c('formVersion', 'downloadLink', 'dateStr'),
    c('form_version', 'download_link', 'date_str'))
  set(d, j = 'form_id', value = id)
  setcolorder(d, 'form_id')

  if (isFALSE(get_defs)) return(d)

  defs = lapply(seq_len(nrow(d)), \(i) {
    get_form_def_excel(auth, d$download_link[i], d$form_version[i], id, def_dir)
  })
  for (j in names(defs[[1L]])) set(d, j = j, value = lapply(defs, \(x) x[[j]]))
  d
}


get_form_def_excel = function(auth, url, ver, id, def_dir) {
  value = NULL
  path = withr::local_tempfile()
  scto_bullets(
    c(v = 'Fetching definition for form version {.version {ver}}.'))
  curl::curl_download(url, path, handle = auth$handle)

  sheets = c('survey', 'choices', 'settings')
  f = \(...) vctrs::vec_as_names(..., repair = 'unique_quiet')

  r = sapply(sheets, \(sheet) {
    d = readxl::read_excel(path, sheet, col_types = 'text', .name_repair = f)
    setDT(d)
    # with or without col_types = 'text', was sometimes getting 1.0 instead of 1
    if (sheet == 'choices') {
      if ('value' %in% colnames(d)) {
        withr::local_options(list(warn = -1))
        d[, value := fifelse(
          !is.na(as.integer(value)) & endsWith(value, '.0'),
          as.character(as.integer(value)), value)]
      } else {
        d[, value := NA_character_]
      }
    }
    # d = readxl::read_excel(path, sheet, guess_max = 1e4, .name_repair = f)
    # setDT(d)
    # cols = colnames(d)[!sapply(d, is.character)]
    # for (j in cols) set(d, j = j, value = as.character(d[[j]]))
    d
  })

  if (!is.null(def_dir)) {
    ext = if (grepl('\\?file=.+\\.xlsx&', tolower(url))) 'xlsx' else 'xls'
    # file name conflicts are possible, but hopefully pathological
    file.rename(path, file.path(def_dir, glue('{id}__{ver}.{ext}')))
  }

  r
}


#' Unnest previously fetched form definitions
#'
#' This function unnests form definitions, e.g., from multiple versions of a
#' form, which can make it easier to map values to labels in a later step.
#'
#' @param form_metadata `data.table` returned by [scto_get_form_metadata()].
#' @param by_form_id Logical indicating whether to unnest definitions of
#'   multiple versions of a given form (default), or to unnest definitions of
#'   all forms together.
#'
#' @return If `by_form_id` is `TRUE`, a `data.table` of `data.table`s for the
#'   survey, choices, and settings components of the form definitions. Otherwise
#'   a list of `data.table`s.
#'
#' @examples
#' \dontrun{
#' auth = scto_auth('scto_auth.txt')
#' form_metadata = scto_get_form_metadata(auth, 'my_form')
#' form_defs = scto_unnest_form_definitions(form_metadata)
#' }
#'
#' @export
scto_unnest_form_definitions = function(form_metadata, by_form_id = TRUE) {
  assert_data_table(form_metadata)
  assert_flag(by_form_id)
  def_cols = c('survey', 'choices', 'settings')
  assert_names(
    colnames(form_metadata),
    must.include = c('form_id', 'form_version', def_cols))

  . = form_id = form_version = NULL # nolint

  form_versions = form_metadata[
    , .(.id = seq_len(.N), `_form_id` = form_id,
        `_form_version` = form_version)]

  if (isTRUE(by_form_id)) {
    r = lapply(unique(form_metadata$form_id), \(form_id_now) {
      form_metadata_now = form_metadata[form_id == form_id_now]
      unnest_form_defs(
        form_metadata_now, form_versions, def_cols, '_form_version')
    })
    names(r) = unique(form_metadata$form_id)
    r = as.data.table(do.call(rbind, r), keep.rownames = 'form_id')

  } else {
    r = unnest_form_defs(
      form_metadata, form_versions, def_cols, c('_form_id', '_form_version'))
  }
  r
}


unnest_form_defs = function(form_metadata, form_versions, def_cols, form_cols) {
  .id = `_row_num` = NULL # nolint
  r = list()
  for (j in def_cols) {
    r[[j]] = rbindlist(
      form_metadata[[j]], use.names = TRUE, fill = TRUE, idcol = TRUE) |>
      merge(form_versions[, c('.id', form_cols), with = FALSE],
            by = '.id', sort = FALSE)
    r[[j]][, `_row_num` := seq_len(.N), by = .id]
    r[[j]][, .id := NULL]
    setcolorder(r[[j]], form_cols)[]
  }
  r
}
