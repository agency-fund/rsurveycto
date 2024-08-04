#' Fetch form metadata from a SurveyCTO server
#'
#' This function fetches metadata, including form definitions, for deployed and
#' previous versions of one or more forms.
#'
#' @param auth [scto_auth()] object.
#' @param form_ids Character vector indicating the form IDs. `NULL` indicates
#'   all forms.
#' @param deployed_only Logical indicating whether to fetch metadata for all
#'   versions of each form, or only for the deployed version.
#' @param get_defs Logical indicating whether to fetch form definitions.
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
    auth, form_ids = NULL, deployed_only = FALSE, get_defs = TRUE) {
  assert_character(form_ids, any.missing = FALSE, unique = TRUE, null.ok = TRUE)
  assert_flag(deployed_only)
  assert_flag(get_defs)
  form_ids = assert_form_ids(auth, form_ids)
  d = lapply(form_ids, \(id) get_form_meta(auth, id, deployed_only, get_defs))
  d = rbindlist(d)
  d
}


get_form_meta = function(auth, id, deployed_only, get_defs) {
  unix_ms = as.numeric(Sys.time()) * 1000
  request_url = glue(
    'https://{auth$servername}.surveycto.com/forms/{id}/files?t={unix_ms}')

  scto_bullets(c(v = 'Reading metadata for form `{.form {id}}`.'))
  content = get_api_response(auth, request_url)

  r = jsonlite::fromJSON(content)
  d = as.data.table(r$deployedGroupFiles$definitionFile)
  if (!deployed_only) d = rbind(d, as.data.table(r$previousDefinitionFiles))
  set(d, j = 'id', value = NULL)
  set(d, j = 'is_deployed', value = c(1L, rep_len(0L, nrow(d) - 1L)))
  setnames(
    d, c('formVersion', 'downloadLink', 'dateStr'),
    c('form_version', 'download_link', 'date_str'))
  set(d, j = 'form_id', value = id)
  setcolorder(d, 'form_id')

  if (isFALSE(get_defs)) return(d)

  defs = lapply(seq_len(nrow(d)), \(i) {
    get_form_def_excel(auth, d$download_link[i], d$form_version[i])
  })
  for (j in names(defs[[1L]])) set(d, j = j, value = lapply(defs, \(x) x[[j]]))
  d
}


get_form_def_excel = function(auth, url, ver) {
  path = withr::local_tempfile()
  scto_bullets(
    c(v = 'Fetching definition for form version `{.version {ver}}`.'))
  curl::curl_download(url, path, handle = auth$handle)
  sheets = c('survey', 'choices', 'settings')
  r = sapply(sheets, \(sheet) { # strings all the way
    setDT(readxl::read_excel(path, sheet, col_types = 'text'))
  })
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
  form_cols = c('form_id', 'form_version')
  def_cols = c('survey', 'choices', 'settings')
  assert_names(colnames(form_metadata), must.include = c(form_cols, def_cols))

  . = form_id = form_version = x = `_form_id` = `_form_version` = # nolint
    `_row_num` = NULL # nolint

  # ugly and redundant, but struggled long enough
  if (isTRUE(by_form_id)) {
    r = lapply(unique(form_metadata$form_id), \(.id) {
      meta_now = form_metadata[form_id == .id]
      r_now = list()
      for (j in def_cols) {
        r_now[[j]] = meta_now[
          , rbindlist(x, use.names = TRUE, fill = TRUE),
          by = .(`_form_version` = form_version),
          env = list(x = j)]
        r_now[[j]][, `_row_num` := seq_len(.N), by = .(`_form_version`)][]
      }
      r_now
    })
    names(r) = unique(form_metadata$form_id)
    r = as.data.table(do.call(rbind, r), keep.rownames = 'form_id')

  } else {
    r = list()
    for (j in def_cols) {
      r[[j]] = form_metadata[
        , rbindlist(x, use.names = TRUE, fill = TRUE),
        by = .(`_form_id` = form_id, `_form_version` = form_version),
        env = list(x = j)]
      r[[j]][, `_row_num` := seq_len(.N), by = .(`_form_id`, `_form_version`)][]
    }
  }

  r
}