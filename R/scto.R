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
#' @seealso [scto_read()], [scto_write()]
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
#' This function reads data from SurveyCTO using the API.
#'
#' @param auth [scto_auth()] object.
#' @param id String indicating ID of the resource to fetch.
#' @param type String indicating whether the resource is a server dataset or a
#'   form.
#' @param start_date Date-time or something coercible to a date-time
#'   indicating the earliest date-time for which to fetch data. Only used for
#'   forms.
#' @param review_status String or character vector indicating which submissions
#'   to fetch. Possible values are "approved", "pending", "rejected", or any
#'   combination of the three. Only used for forms.
#' @param drop_empty_cols Logical indicating whether to drop columns that
#'   contain only `NA` or only an empty string.
#' @param convert_datetime Character vector of column names in the data for
#'   which to convert strings to datetimes (POSIXct). Use `NULL` to not convert
#'   any columns to datetimes.
#' @param datetime_format String indicating format of datetimes from SurveyCTO.
#'   See [strptime()].
#' @param refresh Logical indicating whether to fetch fresh data using the API
#'   or to attempt to load locally cached data.
#' @param cache_dir String indicating path to directory in which to cache data.
#'
#' @return A `data.table`.
#'
#' @examples
#' \dontrun{
#' auth = scto_auth('scto_auth.txt')
#' test_data = scto_read(auth, 'my_form', 'dataset')
#' }
#'
#' @seealso [scto_write()]
#'
#' @export
scto_read = function(
    auth, id, type = c('dataset', 'form'), start_date = '1900-01-01',
    review_status = 'approved', drop_empty_cols = TRUE,
    convert_datetime = c(
      'CompletionDate', 'SubmissionDate', 'starttime', 'endtime'),
    datetime_format = '%b %e, %Y %I:%M:%S %p', refresh = TRUE,
    cache_dir = 'scto_data') {

  assert_class(auth, 'scto_auth')
  assert_string(id)
  type = match.arg(type)

  if (type == 'form') {
    start_date = as.POSIXct(start_date)
    assert_posixct(start_date, any.missing = FALSE, len = 1L)
    start_date = as.numeric(start_date)

    review_status = match.arg(
      review_status, c('approved', 'pending', 'rejected'), several.ok = TRUE)
    review_status = paste(review_status, collapse = ',')}

  assert_logical(drop_empty_cols, any.missing = FALSE, len = 1L)

  assert_character(convert_datetime, any.missing = FALSE, null.ok = TRUE)
  assert_string(datetime_format)

  assert_logical(refresh, any.missing = FALSE, len = 1L)
  assert_string(cache_dir)

  fs::dir_create(cache_dir, recurse = TRUE)
  local_file = fs::path(
    cache_dir, glue('{id}_{type}_{auth$servername}_{start_date}.qs'))

  if (fs::file_exists(local_file) && !refresh) {
    scto_data = qs::qread(local_file)
    if (drop_empty_cols) drop_empties(scto_data)
    return(scto_data)}

  base_url = glue('https://{auth$servername}.surveycto.com/api/v2')

  suf = if (type == 'form') {
    glue('forms/data/wide/json/{id}?date={start_date}&r={review_status}')
  } else {
    glue('datasets/data/csv/{id}')}
  request_url = glue('{base_url}/{suf}')

  res = curl::curl_fetch_memory(request_url, handle = auth$handle)
  status = res$status_code
  content = rawToChar(rese$content)

#   if (status == 417L) {
#     x = regexpr('[0-9]+', content)
#     wt = as.numeric(substr(content, x, x + attr(x, 'match.length') - 1L))
#     message(glue('Waiting {wt} seconds for SurveyCTO to hand over the data...'))
#     Sys.sleep(wt + 5)
#
#     res = curl::curl_fetch_memory(request_url, handle = auth$handle)
#     status = res$status_code
#     content = rawToChar(res$content)}

  if (status == 500L) {
    stop(glue('A {type} named `{id}` on `{auth$server}` does not exist.'))
  } else if (status != 200L) {
    message(glue('Response content:\n{content}'))
    stop(glue('Non-200 response: {status}'))}

  scto_data = if (type == 'form') {
    data.table(jsonlite::fromJSON(content, flatten = TRUE))
  } else {
    fread(text = content, na.strings = '')}

  qs::qsave(scto_data, local_file)
  if (drop_empty_cols) drop_empties(scto_data)[]

  cols = intersect(colnames(scto_data), convert_datetime)
  for (col in cols) {
    set(scto_data, j = col, value = as.POSIXct(
      scto_data[[col]], format = datetime_format))}

  return(scto_data)}


#' Upload data to SurveyCTO
#'
#' This function uploads data to SurveyCTO using web POSTs and GETs to
#' replace an existing server dataset.
#'
#' @param auth [scto_auth()] object.
#' @param data `data.frame` to upload.
#' @param dataset_id String indicating ID of existing server dataset.
#' @param dataset_title String indicating title of dataset.
#'
#' @return An object of class [httr::response()].
#'
#' @examples
#' \dontrun{
#' auth = scto_auth('scto_auth.txt')
#' res = scto_write(auth, data, 'my_dataset', 'My Dataset')
#' }
#'
#' @seealso [scto_read()]
#'
#' @export
scto_write = function(auth, data, dataset_id, dataset_title) {
  assert_class(auth, 'scto_auth')
  assert_data_frame(data)
  assert_string(dataset_id)
  assert_string(dataset_title)

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
