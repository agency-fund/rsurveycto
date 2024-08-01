#' Fetch form versions from a SurveyCTO server
#'
#' This function fetches a form's version history.
#'
#' @param auth [scto_auth()] object.
#' @param form_id String indicating the form ID.
#' @param definitions Logical indicating whether to fetch form definitions.
#'
#' @return A `data.table` with one row per version.
#'
#' @examples
#' \dontrun{
#' auth = scto_auth('scto_auth.txt')
#' form_versions = scto_get_form_versions(auth, 'my_form')
#' }
#'
#' @export
scto_get_form_versions = function(auth, form_id, definitions = TRUE) {
  assert_class(auth, 'scto_auth')
  assert_string(form_id)
  assert_flag(definitions)

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

  if (isFALSE(definitions)) return(d)

  defs = lapply(seq_len(nrow(d)), \(i) {
    get_form_def_excel(auth, d$download_link[i], d$form_version[i])
  })
  for (j in names(defs[[1L]])) {
    set(d, j = j, value = lapply(defs, \(x) x[[j]]))
  }
  d
}


get_form_def_excel = function(auth, url, ver) {
  path = withr::local_tempfile()
  scto_bullets(
    c(v = 'Fetching definition for form version `{.version {ver}}`.'))
  res = curl::curl_download(url, path, handle = auth$handle)
  sheets = c('survey', 'choices', 'settings')
  r = sapply(sheets, \(sheet) setDT(readxl::read_excel(path, sheet)))
  r
}


#' Combine form versions from a SurveyCTO server
#'
#' This function combines multiple versions of a form definition, which can
#' make it easier to map values to labels in a subsequent step.
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
#' form_defs_rbind = scto_get_form_definitions_rbind(form_versions)
#' }
#'
#' @export
scto_get_form_definitions_rbind = function(form_versions) {
  form_version = row_num = NULL
  r = sapply(c('survey', 'choices', 'settings'), \(j) {
    d = rbindlist(form_versions[[j]])
    d[, form_version := rep.int(
      form_versions$form_version, times = sapply(form_versions[[j]], nrow))]
    d[, row_num := seq_len(.N), by = form_version]
  })
  r
}
