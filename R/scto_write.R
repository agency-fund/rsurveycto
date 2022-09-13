#' Upload data to SurveyCTO
#'
#' This function uses a web POST request to replace an existing dataset on a
#' SurveyCTO server. The function is in beta, so use with caution.
#'
#' @param auth [scto_auth()] object.
#' @param data `data.frame` to upload.
#' @param dataset_id String indicating ID of existing dataset.
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
#' @seealso [scto_auth()], [scto_meta()], [scto_read()],
#'   [scto_get_attachments()]
#'
#' @export
scto_write = function(auth, data, dataset_id, dataset_title) {
  assert_class(auth, 'scto_auth')
  assert_data_frame(data)
  assert_string(dataset_id)
  assert_string(dataset_title)

  # TODO: potential function arguments that need to be tested/validated before
  # turning into actual function arguments.
  dataset_exists = TRUE # possible to upload to non-existent datasets?
  dataset_upload_mode = 'clear' # append, merge
  dataset_type = 'SERVER' # form dataset updates/uploads?

  path = withr::local_tempfile(fileext = '.csv')
  fwrite(data, path, logical01 = TRUE)

  # authentication
  upload_url = glue(
    'https://{auth$servername}.surveycto.com/',
    'datasets/{dataset_id}/upload?csrf_token={auth$csrf_token}')

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
