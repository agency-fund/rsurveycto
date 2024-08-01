#' Fetch form versions from a SurveyCTO server
#'
#' This function fetches a form's version history.
#'
#' @param auth [scto_auth()] object.
#' @param form_ids Character vector indicating the form IDs. `NULL` indicates
#'   all forms.
#' @param get_defs Logical indicating whether to fetch form definitions.
#'
#' @return A `data.table` with one row per version per form.
#'
#' @examples
#' \dontrun{
#' auth = scto_auth('scto_auth.txt')
#' form_versions = scto_get_form_versions(auth, 'my_form')
#' }
#'
#' @export
scto_get_form_versions = function(
    auth, form_ids = NULL, get_defs = !is.null(form_ids)) {
  assert_character(form_ids, any.missing = FALSE, unique = TRUE, null.ok = TRUE)
  assert_flag(get_defs)
  form_ids = assert_form_ids(auth, form_ids)
  d = rbindlist(lapply(form_ids, \(id) get_form_versions(auth, id, get_defs)))
  d
}


get_form_versions = function(auth, form_id, definitions) {
  unix_ms = as.numeric(Sys.time()) * 1000
  request_url = glue(
    'https://{auth$servername}.surveycto.com/forms/{form_id}/files?t={unix_ms}')

  scto_bullets(c(v = 'Fetching versions for form `{.form {form_id}}`.'))
  content = get_api_response(auth, request_url)

  r = jsonlite::fromJSON(content)
  d = rbind(
    as.data.table(r$deployedGroupFiles$definitionFile),
    as.data.table(r$previousDefinitionFiles))[, !'id']
  set(d, j = 'is_deployed', value = c(1L, rep_len(0L, nrow(d) - 1L)))
  setnames(
    d, c('formVersion', 'downloadLink', 'dateStr'),
    c('form_version', 'download_link', 'date_str'))
  set(d, j = 'form_id', value = form_id)
  setcolorder(d, 'form_id')

  if (isFALSE(definitions)) return(d)

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
  r = sapply(sheets, \(sheet) {
    # XML definition from API comes as strings anyway
    setDT(readxl::read_excel(path, sheet, col_types = 'text'))
    # d[, (colnames(d)) := lapply(.SD, as.character)]
  })
  r
}


#' Combine form definitions from a SurveyCTO server
#'
#' This function combines form definitions, e.g., from multiple versions of a
#' form, which can make it easier to map values to labels in a later step.
#'
#' @param form_versions `data.table` returned by [scto_get_form_versions()].
#'
#' @return A named list of `data.table`s for the survey, choices, and settings
#'   components of the form definition.
#'
#' @examples
#' \dontrun{
#' auth = scto_auth('scto_auth.txt')
#' form_versions = scto_get_form_versions(auth, 'my_form')
#' form_defs_rbind = scto_rbind_form_definitions(form_versions)
#' }
#'
#' @export
scto_rbind_form_definitions = function(form_versions) {
  assert_data_table(form_versions)
  cols = c('survey', 'choices', 'settings')
  assert_names(colnames(form_versions), must.include = cols)
  . = form_id = form_version = x = `_form_id` = `_form_version` = # nolint
    `_row_num` = NULL # nolint
  r = list()
  for (col in cols) {
    r[[col]] = form_versions[
      , rbindlist(x, use.names = TRUE, fill = TRUE),
      by = .(`_form_id` = form_id, `_form_version` = form_version),
      env = list(x = col)]
    r[[col]][, `_row_num` := seq_len(.N), by = .(`_form_id`, `_form_version`)][]
  }
  r
}
