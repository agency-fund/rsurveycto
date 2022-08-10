#' Get a SurveyCTO authentication session object
#'
#' Authenticates with SurveyCTO and fetches corresponding credentials.
#'
#' @param auth_file String indicating path to file containing authorization
#'   information, which should have servername on the first line, username on
#'   the second, and password on the third. If `auth_file` is not `NULL`, other
#'   arguments are ignored. If `auth_file` is `NULL`, other arguments must be
#'   provided.
#' @param servername String indicating name of the SurveyCTO server.
#' @param username String indicating username for the SurveyCTO account.
#' @param password String indicating password for the SurveyCTO account.
#'
#' @return `scto_auth` object for an authenticated SurveyCTO session.
#'
#' @examples
#' \dontrun{
#' # preferred approach, avoids storing any credentials in code
#' auth = scto_auth('scto_auth.txt')
#'
#' # alternate approach
#' auth = scto_auth('my_server', 'my_user', 'my_pw', auth_file = NULL)
#' }
#'
#' @seealso [scto_pull()], [scto_push()]
#'
#' @export
scto_auth = function(
    auth_file = NULL, servername = NULL, username = NULL, password = NULL) {

  if (is.null(auth_file)) {
    assert_string(servername)
    assert_string(username)
    assert_string(password)
  } else {
    assert_string(auth_file)
    assert_file_exists(auth_file)
    auth_char = readLines(auth_file, warn = FALSE)
    if (!test_character(auth_char, any.missing = FALSE, len = 3L)) {
      stop('auth_file must have exactly three lines: servername, username, and password.')}
    servername = auth_char[1L]
    username = auth_char[2L]
    password = auth_char[3L]}

  handle = curl::new_handle()
  curl::handle_setopt(
    handle = handle,
    httpauth = 1,
    userpwd = glue('{username}:{password}'))

  csrf_token = get_csrf_token(servername, username, password)

  auth = list(
    servername = servername,
    hostname = glue('https://{servername}.surveycto.com'),
    handle = handle,
    csrf_token = csrf_token)
  class(auth) = 'scto_auth'
  return(auth)}


#' Access SurveyCTO data using the API
#'
#' This function pulls data from SurveyCTO using the API.
#'
#' @param auth [scto_auth()] object.
#' @param id String indicating ID of dataset or form to fetch.
#' @param type String indicating type of SurveyCTO data.
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
#' auth = scto_auth('scto_auth.txt')
#' test_data = scto_pull(auth, 'my_form', 'dataset')
#' }
#'
#' @seealso [scto_push()]
#'
#' @export
scto_pull = function(
    auth, id, type = c('dataset', 'form'), start_dt = 0L,
    drop_empty_cols = TRUE, refresh = FALSE, cache_dir = 'scto_data') {

  assert_string(id)
  assert_class(auth, 'scto_auth')
  type = match.arg(type)
  start_dt = as.integer(data.table::as.IDate(start_dt))
  assert_logical(drop_empty_cols, any.missing = FALSE, len = 1L)
  assert_logical(refresh, any.missing = FALSE, len = 1L)
  assert_string(cache_dir)

  fs::dir_create(cache_dir, recurse = TRUE)
  local_file = fs::path(
    cache_dir, glue('{id}_{type}_{auth$servername}_{start_dt}.qs'))

  if (fs::file_exists(local_file) && !refresh) {
    scto_data = qs::qread(local_file)
    if (drop_empty_cols) drop_empties(scto_data)
    return(scto_data)}

  base_url = glue('https://{auth$servername}.surveycto.com/api/v2')

  suf = if (type == 'form') {
    glue('forms/data/wide/json/{id}?date={start_dt}')
  } else {
    glue('datasets/data/csv/{id}')}
  request_url = glue('{base_url}/{suf}')

  response = curl::curl_fetch_memory(request_url, handle = auth$handle)
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
#' @param auth [scto_auth()] object.
#' @param data data.frame to upload.
#' @param dataset_id String indicating existing dataset ID on the server.
#' @param dataset_title String indicating title of dataset.
#'
#' @return An object of class [httr::response()].
#'
#' @examples
#' \dontrun{
#' auth = scto_auth('scto_auth.txt')
#' scto_push(auth, data, 'my_dataset', 'My Dataset')
#' }
#'
#' @seealso [scto_pull()]
#'
#' @export
scto_push = function(data, dataset_id, dataset_title, auth) {
  assert_data_frame(data)
  assert_string(dataset_id)
  assert_string(dataset_title)
  assert_class(auth, 'scto_auth')

  # TODO: potential function arguments that need to be tested/validated before
  # turning into actual function arguments.
  dataset_exists = TRUE # possible to upload to non-existant datasets?
  dataset_upload_mode = 'clear' # append, merge
  dataset_type = 'SERVER' # form dataset updates/uploads?

  path = withr::local_tempfile(fileext = '.csv')
  fwrite(data, path, logical01 = TRUE)

  # authentication
  upload_url = glue(
    '{auth$hostname}/datasets/{dataset_id}/upload?csrf_token={auth$csrf_token}')

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
