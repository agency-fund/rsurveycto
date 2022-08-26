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
#' @param refresh Logical indicating whether to fetch fresh data using the API
#'   or to attempt to load locally cached data.
#' @param cache_dir String indicating path to directory in which to cache data.
#'
#' @return A `data.table`.
#'
#' @examples
#' \dontrun{
#' auth = scto_auth('scto_auth.txt')
#' scto_data = scto_read(auth, 'my_form', 'form')
#' }
#'
#' @seealso [scto_auth()], [scto_get_attachments()], [scto_write()]
#'
#' @export
scto_read = function(
    auth, id, type = c('dataset', 'form'), start_date = '1900-01-01',
    review_status = 'approved', private_key = NULL, drop_empty_cols = TRUE,
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
    start_date = max(1, as.numeric(start_date))

    review_status = match.arg(
      review_status, c('approved', 'pending', 'rejected'), several.ok = TRUE)
    review_status = paste(review_status, collapse = ',')

    assert_string(private_key, null.ok = TRUE)
    if (!is.null(private_key)) assert_file_exists(private_key)}

  assert_logical(drop_empty_cols, any.missing = FALSE, len = 1L)

  assert_character(convert_datetime, any.missing = FALSE, null.ok = TRUE)
  assert_string(datetime_format)

  assert_logical(refresh, any.missing = FALSE, len = 1L)
  assert_string(cache_dir)
  assert_path_for_output(cache_dir, overwrite = TRUE)

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

  res = if (type == 'form' && !is.null(private_key)) {
    POST(request_url, body = list(private_key = httr::upload_file(private_key)))
  } else {
    curl::curl_fetch_memory(request_url, handle = auth$handle)}

  status = res$status_code
  content = rawToChar(res$content)

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
  if (drop_empty_cols) drop_empties(scto_data)

  cols = intersect(colnames(scto_data), convert_datetime)
  for (col in cols) {
    set(scto_data, j = col, value = as.POSIXct(
      scto_data[[col]], format = datetime_format))}

  return(scto_data)}
