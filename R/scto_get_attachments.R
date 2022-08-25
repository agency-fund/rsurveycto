
#' Download file attachments from a SurveyCTO form
#'
#' This function downloads files in bulk.
#'
#' @param auth [scto_auth()] object.
#' @param scto_data `data.table` from [scto_read()] containing data from a
#'   SurveyCTO form.
#' @param column_name String indicating column in `scto_data` for which to
#'   download file attachments. Should contain URLs, can contain missing values.
#' @param output_dir String indicating path to directory in which to save files.
#' @param private_key String indicating path to private key file. Only needs to
#'   be non-`NULL` to decrypt encrypted file attachments.
#' @param overwrite Logical indicating whether to overwrite existing files.
#'
#' @return A character vector of file names. Each element corresponds to a row
#'   of `scto_data`, with `NA` for rows lacking a valid URL.
#'
#' @examples
#' \dontrun{
#' auth = scto_auth('scto_auth.txt')
#' scto_data = scto_read(auth, 'my_form', 'form')
#' filenames = scto_get_attachments(auth, scto_data, 'my_column')
#' }
#'
#' @seealso [scto_auth()], [scto_read()], [scto_write()]
#'
#' @export
scto_get_attachments = function(
    auth, scto_data, column_name, output_dir = 'scto_data', private_key = NULL,
    overwrite = TRUE) {

  assert_class(auth, 'scto_auth')
  assert_data_table(scto_data, col.names = 'unique')
  assert_string(column_name)
  assert_choice(column_name, colnames(scto_data))
  assert_character(scto_data[[column_name]])
  assert_string(output_dir)
  assert_string(private_key, null.ok = TRUE)
  if (!is.null(private_key)) assert_file_exists(private_key)
  assert_flag(overwrite)

  pat = paste0(
    '^https://[a-z0-9_-]+\\.surveycto\\.com/api/v2/forms/[a-z0-9_-]+/',
    'submissions/uuid:[a-z0-9-]+/attachments/[a-zA-Z0-9_.-]+$')

  r = rep(NA_character_, nrow(scto_data))
  idx = grepl(pat, scto_data[[column_name]])
  if (!any(idx)) return(r)

  urls = scto_data[[column_name]][idx]
  x = strsplit(urls, '/')
  filenames = basename(urls) # depends on SurveyCTO making filenames unique

  # these longer filenames were declared by devtools to be non-portable
  # filenames = paste0(sapply(x, `[[`, 9L), '__', sapply(x, `[[`, 11L))
  # filenames = sub('^uuid:', '', filenames)

  coll = makeAssertCollection()
  for (filename in filenames) {
    assert_path_for_output(
      file.path(output_dir, filename), overwrite = overwrite, add = coll)}
  reportAssertions(coll)

  fs::dir_create(output_dir, recurse = TRUE)
  for (i in seq_along(urls)) {
    path = file.path(output_dir, filenames[i])
    if (is.null(private_key)) {
      res = curl::curl_fetch_disk(urls[i], path = path, handle = auth$handle)
    } else {
      res = POST(
        urls[i], body = list(private_key = httr::upload_file(private_key)))
      writeBin(res$content, path)}}

  r[idx] = filenames
  return(r)}
