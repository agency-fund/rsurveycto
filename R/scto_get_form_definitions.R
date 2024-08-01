#' Fetch form definitions from a SurveyCTO server
#'
#' This function fetches spreadsheet form definitions corresponding to the xlsx
#' files downloadable in the Design tab of the SurveyCTO console.
#'
#' @param auth [scto_auth()] object.
#' @param form_ids Character vector indicating the form IDs. `NULL` indicates
#'   all forms.
#' @param simplify Logical indicating whether to return the definition for one
#'   form as a simple list instead of a named, nested list.
#'
#' @return If `simplify` is `TRUE` and getting one form definition, a list.
#'   Otherwise a named list of lists containing the definition for each form.
#'
#' @examples
#' \dontrun{
#' auth = scto_auth('scto_auth.txt')
#' scto_def = scto_get_form_definitions(auth, 'my_form')
#' scto_defs = scto_get_form_definitions(auth)
#' }
#'
#' @export
scto_get_form_definitions = function(auth, form_ids = NULL, simplify = TRUE) {
  catalog = scto_catalog(auth)
  assert_character(form_ids, any.missing = FALSE, unique = TRUE, null.ok = TRUE)
  assert_flag(simplify)
  ids = catalog[catalog$type == 'form']$id

  if (!is.null(form_ids) && !(all(form_ids %in% ids))) {
    ids_bad = form_ids[!(form_ids %in% ids)]
    # backticks aren't exactly right, but let's see if anyone notices
    scto_abort(paste(
      'No form(s) with ID(s) `{.id {ids_bad}}` exist(s)',
      'on the server `{.server {auth$servername}}`.'))
    ids_bad # for lintr
  }

  if (is.null(form_ids)) form_ids = ids

  # works even if no forms
  r = lapply(form_ids, \(id) get_form_def(auth, id))
  names(r) = form_ids
  if (length(r) == 1L && simplify) r = r[[1L]]
  r
}


get_form_def = function(auth, id) {
  request_url = glue(
    'https://{auth$servername}.surveycto.com/forms/{id}/design')

  scto_bullets(c(v = 'Fetching definition for form `{.form {id}}`.'))
  content = get_api_response(auth, request_url)

  d = jsonlite::fromJSON(content)
  idx = which(sapply(d, \(x) inherits(x, 'matrix')))
  for (i in idx) {
    cols = d[[i]][1, ]
    d[[i]] = as.data.table(d[[i]][-1, , drop = FALSE])
    setnames(d[[i]], cols)
  }
  names(d) = sub('RowsAndColumns$', '', names(d))
  d
}
