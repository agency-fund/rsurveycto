if (identical(Sys.getenv('NOT_CRAN'), 'true')) { # !on_cran()
  auth = scto_auth(auth_file = auth_file)
  nms = c('survey', 'choices', 'settings')
}

test_that('scto_get_form_versions one', {
  skip_on_cran()
  vers = scto_get_form_versions(auth, 'hh_listing_example_1')
  expect_data_table(vers)
  expect_names(names(vers), must.include = nms)
})

test_that('scto_get_form_versions one no get_defs', {
  skip_on_cran()
  vers = scto_get_form_versions(auth, 'hh_listing_example_1', FALSE)
  expect_data_table(vers)
  expect_names(names(vers), disjunct.from = nms)
})

test_that('scto_get_form_versions all', {
  skip_on_cran()
  vers = scto_get_form_versions(auth)
  expect_data_table(vers)
  expect_names(names(vers), disjunct.from = nms)
})

test_that('scto_get_form_definitions not ok', {
  skip_on_cran()
  expect_error(scto_get_form_versions(auth, 'flux_capacitors'))
})

test_that('scto_rbind_form_definitions', {
  skip_on_cran()
  vers = scto_get_form_versions(auth, 'hh_listing_example_1')
  defs = scto_rbind_form_definitions(vers)
  expect_list(defs)
  expect_names(names(defs), permutation.of = nms)
})
