assert_read_args = function(
    auth, drop_empty_cols, convert_datetime, datetime_format) {
  assert_class(auth, 'scto_auth')
  assert_flag(drop_empty_cols)
  assert_character(convert_datetime, any.missing = FALSE, null.ok = TRUE)
  assert_string(datetime_format)
  invisible()
}


get_resource = function(auth, type, request_url, private_key) {
  res = if (type == 'form' && !is.null(private_key)) {
    POST(request_url, body = list(private_key = httr::upload_file(private_key)))
  } else {
    curl::curl_fetch_memory(request_url, handle = auth$handle)
  }
  res
}


get_resource_retry = function(auth, type, request_url, private_key) {
  res = get_resource(auth, type, request_url, private_key)
  if (res$status_code == 409L) { # rejected due to parallel requests
    cli::cli_alert_info('Waiting for a parallel request to finish.')
    n_retry = 10
    while (n_retry > 0) {
      Sys.sleep(3)
      res = get_resource(auth, type, request_url, private_key)
      n_retry = if (res$status_code == 200L) 0 else n_retry - 1
    }
  }
  res
}


get_scto_data = function(
    auth, type, request_url, drop_empty_cols, convert_datetime, datetime_format,
    private_key = NULL) {

  res = get_resource_retry(auth, type, request_url, private_key)
  status = res$status_code
  content = rawToChar(res$content)

  if (status != 200L) {
    cli_alert_warning('Response content:\n{content}')
    scto_abort('Non-200 response: {status}')
  }

  scto_data = if (content == '') {
    data.table()
  } else if (type == 'form') {
    data.table(jsonlite::fromJSON(content, flatten = TRUE))
  } else {
    fread(text = content, na.strings = '')
  }
  setattr(scto_data, 'scto_type', type)

  if (drop_empty_cols) {
    drop_empties(scto_data)
  } else if (nrow(scto_data) > 0L) {
    idx = sapply(scto_data, \(x) is.logical(x) && all(is.na(x)))
    for (j in colnames(scto_data)[idx]) {
      set(scto_data, j = j, value = as.character(scto_data[[j]]))
    }
  }

  cols = intersect(colnames(scto_data), convert_datetime)
  for (col in cols) {
    set(scto_data, j = col, value = as.POSIXct(
      scto_data[[col]], tz = 'UTC', format = datetime_format))
  }

  scto_data[]
}


scto_read_form = function(
    auth, id, start_date, review_status, private_key, drop_empty_cols,
    convert_datetime, datetime_format) {

  request_url = glue(
    'https://{auth$servername}.surveycto.com/api/v2/forms/',
    'data/wide/json/{id}?date={start_date}&r={review_status}')

  scto_bullets(c(v = 'Reading form {.form {id}}.'))
  get_scto_data(
    auth, 'form', request_url, drop_empty_cols, convert_datetime,
    datetime_format, private_key)
}


scto_read_dataset = function(
    auth, id, drop_empty_cols, convert_datetime, datetime_format) {

  request_url = glue(
    'https://{auth$servername}.surveycto.com/api/v2/datasets/data/csv/{id}')

  scto_bullets(c(v = 'Reading dataset {.dataset {id}}.'))
  get_scto_data(
    auth, 'dataset', request_url, drop_empty_cols, convert_datetime,
    datetime_format)
}
