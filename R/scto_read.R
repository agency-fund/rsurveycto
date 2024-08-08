#' Read data from a SurveyCTO server
#'
#' This function can read datasets and forms.
#'
#' @param auth [scto_auth()] object.
#' @param ids Character vector indicating ids of the datasets and/or forms.
#'   `NULL` indicates all datasets and forms.
#' @param start_date Date-time or something coercible to a date-time
#'   indicating the earliest date-time (UTC timezone) for which to fetch data.
#'   Only used for forms. Use with caution, because fields that are deleted
#'   prior to `start_date` will not show up, even if submissions prior to
#'   `start_date` have data for those fields.
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
#' @param simplify Logical indicating whether to return only a `data.table`
#'   instead of a list of `data.table`s if reading one form or dataset.
#'
#' @return If `simplify` is `TRUE` and reading one form or dataset, a
#'   `data.table`. Otherwise a named list of `data.table`s, one for each form
#'   and dataset, along with a `data.table` named ".catalog" from
#'   `scto_catalog()`.
#'
#' @examples
#' \dontrun{
#' auth = scto_auth('scto_auth.txt')
#' form_data = scto_read(auth, 'my_form')
#' all_data = scto_read(auth)
#' }
#'
#' @export
scto_read = function(
    auth, ids = NULL, start_date = as.POSIXct('1900-01-01', tz = 'UTC'),
    review_status = 'approved', private_key = NULL, drop_empty_cols = TRUE,
    convert_datetime = c(
      'CompletionDate', 'SubmissionDate', 'starttime', 'endtime'),
    datetime_format = '%b %e, %Y %I:%M:%S %p', simplify = TRUE) {

  assert_class(auth, 'scto_auth')
  assert_character(ids, any.missing = FALSE, unique = TRUE, null.ok = TRUE)

  start_date = as.POSIXct(start_date, tz = 'UTC')
  assert_posixct(start_date, any.missing = FALSE, len = 1L)
  start_date = max(1, as.numeric(start_date))

  review_status = match.arg(
    review_status, c('approved', 'pending', 'rejected'), several.ok = TRUE)
  review_status = paste(review_status, collapse = ',')

  assert_string(private_key, null.ok = TRUE)
  if (!is.null(private_key)) assert_file_exists(private_key)

  assert_flag(drop_empty_cols)
  assert_character(convert_datetime, any.missing = FALSE, null.ok = TRUE)
  assert_string(datetime_format)
  assert_flag(simplify)

  catalog = scto_catalog(auth)

  if (!is.null(ids) && !(all(ids %in% catalog$id))) {
    ids_bad = ids[!(ids %in% catalog$id)] # nolint
    scto_abort(paste(
      '{qty(ids_bad)} The id{?s} {.id {ids_bad}} {?was/were}',
      'not found on the server {.server {auth$servername}}.'))
  }

  catalog_now = if (is.null(ids)) catalog else catalog[catalog$id %in% ids]

  r = lapply(seq_len(nrow(catalog_now)), \(i) {
    id = catalog_now$id[i]
    if (catalog_now$type[i] == 'form') {
      scto_read_form(
        auth, id, start_date, review_status, private_key, drop_empty_cols,
        convert_datetime, datetime_format)
    } else {
      scto_read_dataset(
        auth, id, drop_empty_cols, convert_datetime, datetime_format)
    }
  })

  if (length(r) == 1L && simplify) {
    r = r[[1L]]
  } else {
    names(r) = catalog_now$id
    r$.catalog = catalog # surveycto prohibits "." in ids, so we're safe
  }
  r
}
