#' Read metadata from a SurveyCTO server
#'
#' These functions read metadata from a SurveyCTO server.
#'
#' @param auth [scto_auth()] object.
#'
#' @return `scto_meta()` returns a nested list of metadata related to forms,
#'   datasets, groups, and publishing information. `scto_catalog()` returns a
#'   `data.table` with one row per form or dataset.
#'
#' @examples
#' \dontrun{
#' auth = scto_auth('scto_auth.txt')
#' metadata = scto_meta(auth)
#' catalog = scto_catalog(auth)
#' }
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
  m = content(res, 'parsed')
  m
}


#' @rdname scto_meta
#' @export
scto_catalog = function(auth) {
  # surveycto enforces uniqueness of IDs across forms and datasets
  created_at = creationDate = form_version = type = NULL # nolint
  m = scto_meta(auth)

  dataset_cols = c(
    'id', 'title', 'version', 'groupId', 'casesDataset', 'discriminator')
  datasets = rbindlist(
    lapply(m$datasets, \(x) x[dataset_cols]), use.names = TRUE, fill = TRUE)
  setnames(datasets, c('version', 'groupId', 'casesDataset'),
           c('dataset_version', 'group_id', 'is_cases_dataset'))

  form_cols = c('id', 'title', 'version', 'groupId', 'creationDate')
  forms = rbindlist(
    lapply(m$forms, \(x) x[form_cols]), use.names = TRUE, fill = TRUE)
  forms[, created_at := as.POSIXct(creationDate / 1000, tz = 'UTC')]
  forms[, creationDate := NULL]
  setnames(forms, c('version', 'groupId'), c('form_version', 'group_id'))

  d = rbind(forms, datasets, use.names = TRUE, fill = TRUE)
  d[, type := fifelse(is.na(form_version), 'dataset', 'form')]

  g = rbindlist(lapply(m$groups, \(x) x[c('id', 'title')]))
  setnames(g, c('group_id', 'group_title'))
  d = merge(d, g, by = 'group_id', sort = FALSE)
  setcolorder(
    d, c('id', 'title', 'type', 'created_at', 'form_version', 'dataset_version',
         'is_cases_dataset', 'discriminator', 'group_id', 'group_title'))
}
