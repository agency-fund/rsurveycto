#' Access SurveyCTO data using the API
#'
#' These functions read data from a SurveyCTO server using the API.
#'
#' @param auth [scto_auth()] object.
#' @param id String indicating ID of the dataset or form.
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
#' @return `scto_read()` returns a `data.table`. `scto_read_all()` returns a
#'   named list of `data.table`s, one for each form and dataset, along with a
#'   `data.table` named ".catalog" from `scto_catalog()`.
#'
#' @examples
#' \dontrun{
#' auth = scto_auth('scto_auth.txt')
#' scto_data = scto_read(auth, 'my_form')
#' scto_db = scto_read_all(auth)
#' }
#'
#' @seealso [scto_auth()], [scto_meta()], [scto_get_attachments()],
#'   [scto_write()]
#'
#' @export
scto_read = function(
    auth, id, start_date = '1900-01-01', review_status = 'approved',
    private_key = NULL, drop_empty_cols = TRUE,
    convert_datetime = c(
      'CompletionDate', 'SubmissionDate', 'starttime', 'endtime'),
    datetime_format = '%b %e, %Y %I:%M:%S %p') {

  assert_string(id)
  assert_read_args(auth, drop_empty_cols, convert_datetime, datetime_format)

  catalog = scto_catalog(auth)
  id_now = id
  type = catalog[id_now == id]$type

  if (length(type) == 0L) {
    scto_abort(paste(
      'No form or dataset with ID {.id `{id}`} exists',
      'on the server {.server `{auth$servername}`}.'))
  } else if (type == 'form') {
    scto_data = scto_read_form(
      auth, id, start_date, review_status, private_key, drop_empty_cols,
      convert_datetime, datetime_format)
  } else {
    scto_data = scto_read_dataset(
      auth, id, drop_empty_cols, convert_datetime, datetime_format)}

  return(scto_data)}


#' @rdname scto_read
#' @export
scto_read_all = function(
    auth, start_date = '1900-01-01', review_status = 'approved',
    private_key = NULL, drop_empty_cols = TRUE,
    convert_datetime = c(
      'CompletionDate', 'SubmissionDate', 'starttime', 'endtime'),
    datetime_format = '%b %e, %Y %I:%M:%S %p') {

  assert_read_args(auth, drop_empty_cols, convert_datetime, datetime_format)
  catalog = scto_catalog(auth)

  r = lapply(seq_len(nrow(catalog)), function(i) {
    id = catalog$id[i]
    scto_data = if (catalog$type[i] == 'form') {
      scto_read_form(
        auth, id, start_date, review_status, private_key, drop_empty_cols,
        convert_datetime, datetime_format)
    } else {
      scto_read_dataset(
        auth, id, drop_empty_cols, convert_datetime, datetime_format)}})

  names(r) = catalog$id
  r$.catalog = catalog # surveycto prohibits "." in IDs, so we're safe
  return(r)}
