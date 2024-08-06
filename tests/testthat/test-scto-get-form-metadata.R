if (identical(Sys.getenv('NOT_CRAN'), 'true')) { # !on_cran()
  auth = scto_auth(auth_file = auth_file)
  id = 'hh_listing_example_1'
  nms = c(
    'form_id', 'form_version', 'is_deployed', 'survey', 'choices', 'settings')
}

test_that('scto_get_form_metadata one', {
  skip_on_cran()
  meta = scto_get_form_metadata(auth, id)
  expect_data_table(meta)
  expect_names(names(meta), must.include = nms)
})

test_that('scto_get_form_metadata all deployed', {
  skip_on_cran()
  meta = scto_get_form_metadata(auth, deployed_only = TRUE)
  expect_data_table(meta)
  expect_names(names(meta), must.include = nms)
  expect_setequal(meta$is_deployed, 1L)
})

test_that('scto_get_form_metadata get_defs false', {
  skip_on_cran()
  meta = scto_get_form_metadata(auth, id, get_defs = FALSE)
  expect_data_table(meta)
  expect_names(names(meta), disjunct.from = nms[4:6])
})

test_that('scto_get_form_metadata not ok', {
  skip_on_cran()
  expect_error(scto_get_form_metadata(auth, 'flux_capacitors'))
})

test_that('scto_unnest_form_definitions', {
  skip_on_cran()
  meta = scto_get_form_metadata(auth, id)
  defs = scto_unnest_form_definitions(meta)
  expect_data_table(defs, nrows = 1L)
  expect_names(names(defs), permutation.of = nms[c(1, 4:6)])
})

test_that('scto_unnest_form_definitions by_form_id false', {
  skip_on_cran()
  meta = scto_get_form_metadata(auth, id)
  defs = scto_unnest_form_definitions(meta, by_form_id = FALSE)
  expect_list(defs)
  expect_names(names(defs), permutation.of = nms[4:6])
})
