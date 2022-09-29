#' Read metadata from a SurveyCTO server
#'
#' These functions read metadata from a SurveyCTO server.
#'
#' @param auth [scto_auth()] object.
#'
#' @return `scto_meta()` returns a nested list of metadata related to forms,
#'   datasets, groups, and publishing information. `scto_catalog()` returns a
#'   `data.table` with columns `type` ("form" or "dataset"), `id`, and `title`.
#'
#' @examples
#' \dontrun{
#' auth = scto_auth('scto_auth.txt')
#' metadata = scto_meta(auth)
#' catalog = scto_catalog(auth)
#' }
#'
#' @seealso [scto_auth()], [scto_read()], [scto_write()]
#'
#' @export
scto_meta = function(auth) {
  url = glue(
    'https://{auth$servername}.surveycto.com/console/forms-groups-datasets/get')

  res = GET(url, set_cookies(JSESSIONID = auth$session_id),
            add_headers('x-csrf-token' = auth$csrf_token))

  if (res$status_code != 200L) {
    scto_abort(
      'Invalid username or password for server `{.server {auth$servername}}`.')}

  scto_bullets(
    c(v = 'Reading metadata for server `{.server {auth$servername}}`.'))
  m = content(res, as = 'parsed')
  return(m)}


#' @rdname scto_meta
#' @export
scto_catalog = function(auth) {
  m = scto_meta(auth)
  # surveycto enforces uniqueness of IDs across forms and datasets
  types = c('datasets', 'forms')
  func = function(x) x[c('id', 'title')]
  d = cbind(
    data.table(type = rep(
      substr(types, 1, nchar(types) - 1), times = lengths(m[types]))),
    rbindlist(
      lapply(types, function(type) rbindlist(lapply(m[[type]], func)))))
  data.table::setkey(d)
  return(d)}
