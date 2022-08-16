auth = scto_auth(auth_file = auth_file)

test_that('scto_read dataset fresh', {
  d = scto_read(auth, 'enumerators', refresh = TRUE, cache_dir = cache_dir)
  expect_data_table(d)
})

test_that('scto_read dataset stale', {
  d = scto_read(auth, 'enumerators', refresh = FALSE, cache_dir = cache_dir)
  expect_data_table(d)
})

test_that('scto_read dataset not ok', {
  expect_error(scto_read(auth, 'flux_capacitors', cache_dir = cache_dir))
})

test_that('scto_read form ok', {
  d = scto_read(
    auth, 'hh_listing_example_1', 'form', refresh = TRUE, cache_dir = cache_dir)
  expect_data_table(d)
})

test_that('scto_read form not ok', {
  expect_error(scto_read(
    auth, 'hh_listing_example_1', 'form', start_date = 'coffee', refresh = TRUE,
    cache_dir = cache_dir))
})
