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
      'Invalid username or password for server {.server {auth$servername}}.')
  }

  scto_bullets(
    c(v = 'Reading metadata for server {.server {auth$servername}}.'))
  m = content(res, 'parsed')
  m
}


#' @rdname scto_meta
#' @export
scto_catalog = function(auth) {
  # surveycto enforces uniqueness of ids across forms and datasets
  creationDate = last_version_created_at = last_incoming_data_at = # nolint
    lastIncomingDataDate = form_version = type = NULL # nolint
  m = scto_meta(auth)
  common_cols = c('id', 'title', 'version', 'groupId')

  if (length(m$datasets) > 0L) {
    dataset_cols = c(common_cols, 'casesDataset', 'discriminator', 'rows')
    datasets = rbindlist(
      lapply(m$datasets, \(x) x[dataset_cols]), use.names = TRUE, fill = TRUE)
    setnames(datasets, c('casesDataset', 'version', 'rows', 'groupId'),
             c('is_cases_dataset', 'dataset_version', 'num_rows', 'group_id'))
  } else {
    datasets = data.table()
  }

  if (length(m$forms) > 0L) {
    sub_idx = grepl('SubmissionCount$', names(m$forms[[1L]]))
    sub_cols = names(m$forms[[1L]])[sub_idx]
    form_cols = c(
      common_cols, 'creationDate', 'lastIncomingDataDate', 'encrypted',
      'deployed', 'reviewWorkflowEnabled', sub_cols)

    forms = rbindlist(
      lapply(m$forms, \(x) x[form_cols]), use.names = TRUE, fill = TRUE)
    forms[, last_version_created_at := as.POSIXct(
      creationDate / 1000, tz = 'UTC')]
    forms[, last_incoming_data_at := as.POSIXct(
      lastIncomingDataDate / 1000, tz = 'UTC')]
    forms[, `:=`(creationDate = NULL, lastIncomingDataDate = NULL)]

    old = c(
      'version', 'groupId', 'encrypted', 'deployed', 'reviewWorkflowEnabled',
      sub_cols)
    new = c(
      'form_version', 'group_id', 'is_encrypted', 'is_deployed',
      'is_review_workflow_enabled',
      paste0('num_submissions_', gsub('SubmissionCount', '', sub_cols)))
    setnames(forms, old, new)
  } else {
    forms = data.table()
  }

  d = rbind(forms, datasets, use.names = TRUE, fill = TRUE)
  d[, type := fifelse(is.na(form_version), 'dataset', 'form')]

  g = rbindlist(lapply(m$groups, \(x) x[c('id', 'title')]))
  setnames(g, c('group_id', 'group_title'))
  d = merge(d, g, by = 'group_id', sort = FALSE)
  neworder = c(
    'id', 'title', 'type', 'form_version', 'dataset_version',
    'last_version_created_at', 'last_incoming_data_at', 'is_encrypted',
    'is_deployed', 'is_review_workflow_enabled', 'is_cases_dataset',
    'discriminator', 'group_id', 'group_title')
  setcolorder(d, neworder)
  setkey(d)
}
