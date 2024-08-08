#' Write data to a SurveyCTO server
#'
#' @description
#' `r lifecycle::badge('experimental')`
#'
#' This function updates an existing dataset using a web POST request, as
#' uploading data is not officially supported by the SurveyCTO API.
#'
#' @param auth [scto_auth()] object.
#' @param data `data.frame` to upload.
#' @param dataset_id String indicating id of existing dataset.
#' @param dataset_title String indicating title of dataset. Will replace the
#'   existing title, regardless of `append`.
#' @param append Logical indicating whether to append or replace the dataset.
#' @param fill Logical indicating whether to implicitly fill missing columns
#'   with `NA`, i.e., whether to allow a mismatch between columns of the
#'   existing dataset and columns of `data`. Only used if `append` is `TRUE`.
#'
#' @return A list with elements:
#'
#' * `data_old`: A `data.table` of the previous version of the dataset.
#' * `response`: An object of class [httr::response()] from the POST request.
#'
#' @examples
#' \dontrun{
#' auth = scto_auth('scto_auth.txt')
#' r = scto_write(auth, data, 'my_dataset', 'My Dataset')
#' }
#'
#' @export
scto_write = function(
    auth, data, dataset_id, dataset_title = dataset_id, append = FALSE,
    fill = FALSE) {
  assert_class(auth, 'scto_auth')
  assert_data_frame(data)
  assert_string(dataset_id)
  assert_string(dataset_title)
  assert_flag(append)

  # check that dataset exists
  data_old = scto_read(auth, dataset_id, drop_empty_cols = FALSE)
  if (attr(data_old, 'scto_type') != 'dataset') {
    scto_abort(
      'The id {.id {dataset_id}} corresponds to a form, not a dataset.')
  }

  if (append) {
    assert_flag(fill)
    if (!fill && !setequal(colnames(data), colnames(data_old))) {
      scto_abort(paste(
        'If `fill` is FALSE, column names of `data` must match',
        'those of the dataset {.dataset {dataset_id}}.'))
    }
  }

  # TODO: potential function arguments that need to be tested/validated before
  # turning into actual function arguments.
  dataset_exists = 1 # possible to upload to non-existent datasets?
  dataset_upload_mode = if (append) 'append' else 'clear' # ignoring merge
  dataset_type = 'SERVER' # form dataset updates/uploads?

  path = withr::local_tempfile(fileext = '.csv')
  fwrite(data, path, logical01 = TRUE)

  # authentication
  upload_url = glue(
    'https://{auth$servername}.surveycto.com/',
    'datasets/{dataset_id}/upload?csrf_token={auth$csrf_token}')

  # data upload
  scto_bullets(c(v = 'Writing dataset {.dataset {dataset_id}}.'))

  upload_res = POST(
    upload_url,
    body = list(
      dataset_exists = dataset_exists,
      dataset_id = dataset_id,
      dataset_title = dataset_title,
      dataset_upload_mode = dataset_upload_mode,
      dataset_type = dataset_type,
      dataset_file = httr::upload_file(path)))

  r = list(data_old = data_old, response = upload_res)
  r
}
