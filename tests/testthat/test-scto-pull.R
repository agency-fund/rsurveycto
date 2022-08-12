auth = scto_auth(auth_file = auth_file)

test_that('scto_pull dataset fresh', {
  d = scto_pull(auth, 'enumerators', refresh = TRUE, cache_dir = cache_dir)
  expect_data_table(d)
})

test_that('scto_pull dataset stale', {
  d = scto_pull(auth, 'enumerators', refresh = FALSE, cache_dir = cache_dir)
  expect_data_table(d)
})

test_that('scto_pull dataset not ok', {
  expect_error(
    suppressMessages(scto_pull(auth, 'flux_capacitors', cache_dir = cache_dir)))
})

test_that('scto_pull form ok', {
  d = scto_pull(
    auth, 'hh_listing_example_1', 'form', refresh = TRUE, cache_dir = cache_dir)
  expect_data_table(d)
})
