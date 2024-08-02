#' Fetch deployed form definitions from a SurveyCTO server
#'
#' This function fetches definitions for currently deployed forms. For previous
#' form versions and their definitions, please see [scto_get_form_versions()].
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
#' form_def = scto_get_form_definitions(auth, 'my_form')
#' form_defs = scto_get_form_definitions(auth)
#' }
#'
#' @export
scto_get_form_definitions = function(auth, form_ids = NULL, simplify = TRUE) {
  assert_character(form_ids, any.missing = FALSE, unique = TRUE, null.ok = TRUE)
  assert_flag(simplify)
  form_ids = assert_form_ids(auth, form_ids)

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

  r = jsonlite::fromJSON(content)
  idx = which(sapply(r, \(x) inherits(x, 'matrix')))
  for (i in idx) {
    cols = r[[i]][1L, ]
    r[[i]] = as.data.table(r[[i]][-1L, , drop = FALSE])
    setnames(r[[i]], cols)
    for (j in colnames(r[[i]])) {
      set(r[[i]], i = which(r[[i]][[j]] == ''), j = j, value = NA_character_)
    }
  }
  names(r) = sub('RowsAndColumns$', '', names(r))
  r
}
