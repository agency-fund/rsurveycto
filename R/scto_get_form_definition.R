#' Fetch form definitions from a SurveyCTO server
#'
#' This function fetches spreadsheet form definitions corresponding to the xlsx
#' files downloadable in the Design tab of the SurveyCTO console.
#'
#' @param auth [scto_auth()] object.
#' @param form_ids Character vector indicating IDs of the forms. `NULL`
#'   indicates all forms.
#'
#' @return A named list of lists containing the definition for each form.
#'
#' @examples
#' \dontrun{
#' auth = scto_auth('scto_auth.txt')
#' scto_defs = scto_get_form_definitions(auth, 'my_form')
#' }
#'
#' @seealso [scto_auth()], [scto_meta()], [scto_read()],
#'   [scto_get_attachments()], [scto_write()]
#'
#' @export
scto_get_form_definitions = function(auth, form_ids = NULL) {
  catalog = scto_catalog(auth)
  ids = catalog[catalog$type == 'form']$id
  assert_character(form_ids, any.missing = FALSE, unique = TRUE, null.ok = TRUE)

  if (!is.null(form_ids) && !(all(form_ids %in% ids))) {
    bad_forms = form_ids[!(form_ids %in% ids)]
    # backticks aren't exactly right, but let's see if anyone notices
    scto_abort(paste(
      'No form(s) with ID(s) `{.id {bad_forms}}` exist(s)',
      'on the server `{.server {auth$servername}}`.'))}

  if (is.null(form_ids)) form_ids = ids

  # works even if no forms
  r = lapply(form_ids, function(id) get_form_def(auth, id))
  names(r) = form_ids
  return(r)}


get_form_def = function(auth, id) {
  request_url = glue(
    'https://{auth$servername}.surveycto.com/forms/{id}/design')
  res = GET(request_url, add_headers('x-csrf-token' = auth$csrf_token))
  status = res$status_code
  content = rawToChar(res$content)

  if (status != 200L) {
    cli::cli_alert_info('Response content:\n{content}')
    cli::cli_abort('Non-200 response: {status}')}

  d = jsonlite::fromJSON(rawToChar(res$content))
  idx = which(sapply(d, function(x) inherits(x, 'matrix')))
  for (i in idx) {
    cols = d[[i]][1, ]
    d[[i]] = data.table::as.data.table(d[[i]][-1, , drop = FALSE])
    data.table::setnames(d[[i]], cols)}
  names(d) = sub('RowsAndColumns$', '', names(d))

  return(d)}
