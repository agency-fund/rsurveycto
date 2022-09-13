if (identical(Sys.getenv('NOT_CRAN'), 'true')) { # !on_cran()
  auth = scto_auth(auth_file = auth_file)}

test_that('scto_meta ok', {
  skip_on_cran()
  metadata = scto_meta(auth)
  expect_type(metadata, 'list')
})
