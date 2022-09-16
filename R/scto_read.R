#' Access SurveyCTO data using the API
#'
#' This function reads data from SurveyCTO using the API.
#'
#' @param auth [scto_auth()] object.
#' @param id String indicating ID of the dataset or form.
#' @param type String indicating whether `id` corresponds to a dataset or form.
#' @param start_date Date-time or something coercible to a date-time
#'   indicating the earliest date-time for which to fetch data. Only used for
#'   forms.
#' @param review_status String or character vector indicating which submissions
#'   to fetch. Possible values are "approved", "pending", "rejected", or any
#'   combination of the three. Only used for forms.
#' @param private_key String indicating path to private key file. Only needs to
#'   be non-`NULL` to read encrypted form data.
#' @param drop_empty_cols Logical indicating whether to drop columns that
#'   contain only `NA` or only an empty string.
#' @param convert_datetime Character vector of column names in the data for
#'   which to convert strings to datetimes (POSIXct). Use `NULL` to not convert
#'   any columns to datetimes.
#' @param datetime_format String indicating format of datetimes from SurveyCTO.
#'   See [strptime()].
#'
#' @return A `data.table`.
#'
#' @examples
#' \dontrun{
#' auth = scto_auth('scto_auth.txt')
#' scto_data = scto_read(auth, 'my_form', 'form')
#' }
#'
#' @seealso [scto_auth()], [scto_meta()], [scto_get_attachments()],
#'   [scto_write()]
#'
#' @export
scto_read = function(
    auth, id, type = c('dataset', 'form'), start_date = '1900-01-01',
    review_status = 'approved', private_key = NULL, drop_empty_cols = TRUE,
    convert_datetime = c(
      'CompletionDate', 'SubmissionDate', 'starttime', 'endtime'),
    datetime_format = '%b %e, %Y %I:%M:%S %p') {

  assert_class(auth, 'scto_auth')
  assert_string(id)
  type = match.arg(type)

  if (type == 'form') {
    start_date = as.POSIXct(start_date)
    assert_posixct(start_date, any.missing = FALSE, len = 1L)
    start_date = max(1, as.numeric(start_date))

    review_status = match.arg(
      review_status, c('approved', 'pending', 'rejected'), several.ok = TRUE)
    review_status = paste(review_status, collapse = ',')

    assert_string(private_key, null.ok = TRUE)
    if (!is.null(private_key)) assert_file_exists(private_key)}

  assert_logical(drop_empty_cols, any.missing = FALSE, len = 1L)
  assert_character(convert_datetime, any.missing = FALSE, null.ok = TRUE)
  assert_string(datetime_format)

  suf = if (type == 'form') {
    glue('forms/data/wide/json/{id}?date={start_date}&r={review_status}')
  } else {
    glue('datasets/data/csv/{id}')}
  request_url = glue('https://{auth$servername}.surveycto.com/api/v2/{suf}')

  res = get_resource(type, private_key, request_url, auth)

  if (res$status_code == 409L) { # rejected due to parallel requests
    n_retry = 2
    while (n_retry > 0) {
      message('Waiting for a parallel request to finish...')
      Sys.sleep(3)
      res = get_resource(type, private_key, request_url, auth)
      n_retry = if (res$status_code == 200L) 0 else n_retry - 1}}

  status = res$status_code
  content = rawToChar(res$content)

  if (status == 500L) {
    stop(glue('A {type} named `{id}` on `{auth$server}` does not exist.'))
  } else if (status != 200L) {
    message(glue('Response content:\n{content}'))
    stop(glue('Non-200 response: {status}'))}

  scto_data = if (content == '') {
    data.table()
  } else if (type == 'form') {
    data.table(jsonlite::fromJSON(content, flatten = TRUE))
  } else {
    fread(text = content, na.strings = '')}

  if (drop_empty_cols) drop_empties(scto_data)

  cols = intersect(colnames(scto_data), convert_datetime)
  for (col in cols) {
    set(scto_data, j = col, value = as.POSIXct(
      scto_data[[col]], format = datetime_format))}

  return(scto_data)}


#' Access SurveyCTO metadata
#'
#' This function reads metadata from SurveyCTO related to forms, datasets,
#' groups, and publishing information.
#'
#' @param auth [scto_auth()] object.
#'
#' @return A list.
#'
#' @examples
#' \dontrun{
#' auth = scto_auth('scto_auth.txt')
#' metadata = scto_meta(auth)
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
    stop(glue('Invalid username or password for ',
              'SurveyCTO server `{auth$servername}`.'))}
  m = content(res, as = 'parsed')
  return(m)}
