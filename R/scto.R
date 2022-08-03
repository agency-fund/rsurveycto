#' Access SurveyCTO data using the API
#'
#' This function pulls data from SurveyCTO using the API.
#'
#' @param id String indicating ID of dataset or form to fetch.
#' @param servername String indicating name of the SurveyCTO server.
#' @param type String indicating type of SurveyCTO data.
#' @param auth_file String indicating path to file containing authorization
#'   credentials, which should contain the username on the first line and the
#'   password on the second.
#' @param start_dt Date, string coercible to a date, or an integer
#'   (corresponding to days since 1970-01-01) indicating earliest date for which
#'   to fetch data.
#' @param drop_empty_cols Logical indicating whether to drop columns that
#'   contain only `NA` or only an empty string.
#' @param refresh Logical indicating whether to fetch fresh data using the API
#'   or to attempt to load locally cached data.
#' @param cache_dir String indicating path to directory in which to cache data.
#'
#' @return A data.table.
#'
#' @examples
#' \dontrun{
#' options(scto_auth_file = 'scto_auth.txt')
#' test_data = scto_get('my_form', 'my_server', 'dataset')
#' }
#' @export
scto_get = function(
    id, servername, type = c('dataset', 'form'),
    auth_file = getOption('scto_auth_file'), start_dt = 0L,
    drop_empty_cols = TRUE, refresh = FALSE, cache_dir = 'scto_data') {

  assert_string(id)
  assert_string(servername)
  assert_file_exists(auth_file)
  type = match.arg(type)
  start_dt = as.integer(data.table::as.IDate(start_dt))
  assert_logical(drop_empty_cols, any.missing = FALSE, len = 1L)
  assert_logical(refresh, any.missing = FALSE, len = 1L)
  assert_string(cache_dir)

  fs::dir_create(cache_dir, recurse = TRUE)
  local_file = fs::path(
    cache_dir, glue('{id}_{type}_{servername}_{start_dt}.qs'))

  if (fs::file_exists(local_file) && !refresh) {
    scto_data = qs::qread(local_file)
    if (drop_empty_cols) drop_empties(scto_data)
    return(scto_data)}

  assert_file_exists(auth_file)
  auth = get_auth(auth_file)

  handle = curl::new_handle()
  curl::handle_setopt(
    handle = handle,
    httpauth = 1,
    userpwd = paste(auth, collapse = ':'))

  base_url = glue('https://{servername}.surveycto.com/api/v2')

  suf = if (type == 'form') {
    glue('forms/data/wide/json/{id}?date={start_dt}')
  } else {
    glue('datasets/data/csv/{id}')}
  request_url = glue('{base_url}/{suf}')

  response = curl::curl_fetch_memory(request_url, handle = handle)
  status = response$status_code
  content = rawToChar(response$content)

  if (status != 200L) {
    message(glue('Response content:\n{content}'))
    stop(glue('Non-200 response: {status}'))}

  scto_data = if (type == 'form') {
    data.table(jsonlite::fromJSON(content, flatten = TRUE))
  } else {
    fread(text = content, na.strings = '')}

  qs::qsave(scto_data, local_file)
  if (drop_empty_cols) drop_empties(scto_data)
  return(scto_data)}


#' Upload data to SurveyCTO
#'
#' This function uploads a csv file to SurveyCTO using web POSTs and GETs to
#' replace data in an existing Server Dataset.
#'
#' @param data data.frame to upload
#' @param dataset_id String indicating existing dataset ID on the server.
#' @param dataset_title String indicating title of dataset.
#' @param servername String indicating name of the SurveyCTO server.
#' @param auth_file String indicating path to file containing authorization
#'   credentials, with the username on the first line and the password on the
#'   second.
#'
#' @return An object of class [httr::response()].
#'
#' @examples
#' \dontrun{
#' options(scto_auth_file = 'scto_auth.txt')
#' scto_upload(data, 'my_dataset', 'My Dataset', 'my_server')
#' }
#'
#' @export
scto_upload = function(
    data, dataset_id, dataset_title, servername,
    auth_file = getOption('scto_auth_file')) {

  path = withr::local_tempfile(fileext = '.csv')
  fwrite(data, path, logical01 = TRUE)

  # don't move these parameters to function arguments until we've had a
  # chance to see what they do and how they work.
  dataset_exists = TRUE
  dataset_upload_mode = 'clear'
  dataset_type = 'SERVER'

  # authentication
  csrf_token = get_csrf_token(servername, auth_file)
  upload_url = glue(
    'https://{servername}.surveycto.com/datasets/{dataset_id}/upload?csrf_token={csrf_token}')

  # data upload
  upload_res = POST(
    upload_url,
    body = list(
      dataset_exists = as.numeric(dataset_exists),
      dataset_id = dataset_id,
      dataset_title = dataset_title,
      dataset_upload_mode = dataset_upload_mode,
      dataset_type = dataset_type,
      dataset_file = httr::upload_file(path)))

  return(upload_res)}
