#' Read metadata from a SurveyCTO server
#'
#' These functions read metadata from a SurveyCTO server.
#'
#' @param auth [scto_auth()] object.
#'
#' @return `scto_meta()` returns a nested list of metadata related to forms,
#'   datasets, groups, and publishing information. `scto_catalog()` returns a
#'   `data.table` with columns `type` ("form" or "dataset"), `id`, `title`,
#'   `version`, `group_id`, and `group_title`.
#'
#' @examples
#' \dontrun{
#' auth = scto_auth('scto_auth.txt')
#' metadata = scto_meta(auth)
#' catalog = scto_catalog(auth)
#' }
#'
#' @seealso [scto_auth()], [scto_read()], [scto_get_form_definitions()],
#'   [scto_write()]
#'
#' @export
scto_meta = function(auth) {
  assert_class(auth, 'scto_auth')
  url = glue(
    'https://{auth$servername}.surveycto.com/console/forms-groups-datasets/get')

  res = GET(url, set_cookies(JSESSIONID = auth$session_id),
            add_headers('x-csrf-token' = auth$csrf_token))

  if (res$status_code != 200L) {
    scto_abort(
      'Invalid username or password for server `{.server {auth$servername}}`.')
  }

  scto_bullets(
    c(v = 'Reading metadata for server `{.server {auth$servername}}`.'))
  m = content(res, as = 'parsed')
  m
}


#' @rdname scto_meta
#' @export
scto_catalog = function(auth) {
  m = scto_meta(auth)
  # surveycto enforces uniqueness of IDs across forms and datasets
  types = c('datasets', 'forms')
  func = \(x) x[c('id', 'title', 'version', 'groupId')]
  d = cbind(
    data.table(type = rep(
      substr(types, 1, nchar(types) - 1), times = lengths(m[types]))),
    rbindlist(
      lapply(types, \(type) rbindlist(lapply(m[[type]], func)))))
  # form versions come back as string, too big for int, so make numeric
  set(d, j = 'version', value = as.numeric(d$version))
  setnames(d, 'groupId', 'group_id')

  group_cols = c('group_id', 'group_title')
  g = rbindlist(lapply(m$groups, \(x) x[c('id', 'title')]))
  setnames(g, group_cols)
  d = merge(d, g, by = group_cols[1L], sort = FALSE)
  data.table::setcolorder(d, 2:5)
  data.table::setkey(d)
}
