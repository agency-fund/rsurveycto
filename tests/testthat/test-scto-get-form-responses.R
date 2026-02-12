if (identical(Sys.getenv('NOT_CRAN'), 'true')) { # !on_cran()
  auth = scto_auth(auth_file = auth_file)
}

test_that('scto_get_responses ok', {
  skip_on_cran()
  d = scto_get_form_responses(auth, 'hh_listing_example_1')
  expect_data_table(d)
})
