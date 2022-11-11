#' Fetch file attachments from a SurveyCTO server
#'
#' This function can download encrypted and unencrypted files attached to forms.
#'
#' @param auth [scto_auth()] object.
#' @param urls Character vector of API URLs for file attachments. Will typically
#'   be derived from a column of a `data.table` returned by [scto_read()]. Can
#'   contain missing values.
#' @param output_dir String indicating path to directory in which to save files.
#' @param private_key String indicating path to private key file. Only needs to
#'   be non-`NULL` to decrypt encrypted file attachments.
#' @param overwrite Logical indicating whether to overwrite existing files.
#'
#' @return A character vector of file names of the same length as `urls`, with
#'   `NA` for missing or invalid URLs.
#'
#' @examples
#' \dontrun{
#' auth = scto_auth('scto_auth.txt')
#' scto_data = scto_read(auth, 'my_form', 'form')
#' filenames = scto_get_attachments(auth, scto_data[['my_attachment']])
#' }
#'
#' @seealso [scto_auth()], [scto_read()], [scto_write()]
#'
#' @export
scto_get_attachments = function(
    auth, urls, output_dir, private_key = NULL, overwrite = TRUE) {

  assert_class(auth, 'scto_auth')
  assert_character(urls)
  assert_string(output_dir)
  assert_string(private_key, null.ok = TRUE)
  if (!is.null(private_key)) assert_file_exists(private_key)
  assert_flag(overwrite)

  pat = paste0(
    '^https://[a-z0-9_-]+\\.surveycto\\.com/api/v2/forms/[a-z0-9_-]+/',
    'submissions/uuid:[a-z0-9-]+/attachments/[a-zA-Z0-9_.-]+$')

  r = rep(NA_character_, length(urls))
  idx = grepl(pat, urls)
  if (!any(idx)) return(r)

  urls = urls[idx]
  x = strsplit(urls, '/')
  filenames = basename(urls) # depends on SurveyCTO making filenames unique

  # devtools said these longer filenames were non-portable
  # filenames = paste0(sapply(x, `[[`, 9L), '__', sapply(x, `[[`, 11L))
  # filenames = sub('^uuid:', '', filenames)

  coll = makeAssertCollection()
  for (filename in filenames) {
    assert_path_for_output(
      file.path(output_dir, filename), overwrite = overwrite, add = coll)}
  reportAssertions(coll)

  if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

  for (i in seq_along(urls)) {
    scto_bullets(c(v = 'Downloading `{.filename {filenames[i]}}`.'))
    path = file.path(output_dir, filenames[i])
    if (is.null(private_key)) {
      res = curl::curl_download(urls[i], path, handle = auth$handle)
    } else {
      res = POST(
        urls[i], body = list(private_key = httr::upload_file(private_key)))
      writeBin(res$content, path)}}

  r[idx] = filenames
  return(r)}
