if (identical(Sys.getenv('NOT_CRAN'), 'true')) { # !on_cran()
  auth = scto_auth(auth_file = auth_file)
  id = 'hh_listing_example_1'
  nms = c(
    'form_id', 'form_version', 'is_deployed', 'survey', 'choices', 'settings')
}

test_that('scto_get_form_definitions one', {
  skip_on_cran()
  defs = scto_get_form_definitions(auth, id)
  expect_data_table(defs)
  expect_names(names(defs), must.include = nms)
})

test_that('scto_get_form_definitions all deployed', {
  skip_on_cran()
  defs = scto_get_form_definitions(auth, deployed_only = TRUE)
  expect_data_table(defs)
  expect_names(names(defs), must.include = nms)
  expect_setequal(defs$is_deployed, 1L)
})

test_that('scto_get_form_definitions not ok', {
  skip_on_cran()
  expect_error(scto_get_form_definitions(auth, 'flux_capacitors'))
})

test_that('scto_unnest_form_definitions', {
  skip_on_cran()
  defs = scto_get_form_definitions(auth, id)
  defs_unnest = scto_unnest_form_definitions(defs)
  expect_data_table(defs_unnest, nrows = 1L)
  expect_names(names(defs_unnest), permutation.of = nms[c(1, 4:6)])
})

test_that('scto_unnest_form_definitions by_form_id false', {
  skip_on_cran()
  defs = scto_get_form_definitions(auth, id)
  defs_unnest = scto_unnest_form_definitions(defs, by_form_id = FALSE)
  expect_list(defs_unnest)
  expect_names(names(defs_unnest), permutation.of = nms[4:6])
})
