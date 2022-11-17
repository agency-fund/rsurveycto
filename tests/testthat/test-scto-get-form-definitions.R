if (identical(Sys.getenv('NOT_CRAN'), 'true')) { # !on_cran()
  auth = scto_auth(auth_file = auth_file)
  nms = c('settings', 'choices', 'fields', 'formulasConvertedToStaticValues')}

test_that('scto_get_form_definitions one ok', {
  skip_on_cran()
  defs = scto_get_form_definitions(auth, 'hh_listing_example_1')

  expect_type(defs, 'list')
  expect_named(defs, 'hh_listing_example_1')
  expect_type(defs[[1L]], 'list')
  expect_named(defs[[1L]], nms)
})

test_that('scto_get_form_definitions all ok', {
  skip_on_cran()
  defs = scto_get_form_definitions(auth)

  expect_type(defs, 'list')
  expect_named(defs, c('hh_example_encrypted', 'hh_listing_example_1'))
})

test_that('scto_get_form_definitions not ok', {
  skip_on_cran()
  expect_error(scto_get_form_definitions(auth, 'flux_capacitors'))
})

