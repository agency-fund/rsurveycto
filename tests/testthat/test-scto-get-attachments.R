if (identical(Sys.getenv('NOT_CRAN'), 'true')) { # !on_cran()
  auth = scto_auth(auth_file = auth_file)
  d = scto_read(auth, 'hh_listing_example_1')
  d = d[(.N - 2):.N]
  d_enc = scto_read(
    auth, 'hh_example_encrypted', private_key = private_key)
}

test_that('scto_get_attachments ok', {
  skip_on_cran()
  filenames = scto_get_attachments(
    auth, d$household_photo, output_dir = output_dir)
  expect_file_exists(file.path(output_dir, filenames[!is.na(filenames)]))
  expect_error(scto_get_attachments(
    auth, d$household_photo, output_dir = output_dir, overwrite = FALSE))
})

test_that('scto_get_attachments empty', {
  skip_on_cran()
  filenames = scto_get_attachments(auth, d$district, output_dir = output_dir)
  expect_true(allMissing(filenames))
})

test_that('scto_get_attachments encrypted key', {
  skip_on_cran()
  filenames = scto_get_attachments(
    auth, d_enc$household_photo, output_dir = output_dir,
    private_key = private_key)
  expect_file_exists(file.path(output_dir, filenames[!is.na(filenames)]))
  expect_snapshot_file(file.path(output_dir, filenames[1L]))
})

test_that('scto_get_attachments encrypted no key', {
  skip_on_cran()
  filenames = scto_get_attachments(
    auth, d_enc$household_photo, output_dir = output_dir)
  expect_file_exists(file.path(output_dir, filenames[!is.na(filenames)]))
  expect_snapshot_file(file.path(output_dir, filenames[2L]))
})
