if (identical(Sys.getenv('NOT_CRAN'), 'true')) { # !on_cran()
  auth = scto_auth(auth_file = auth_file)}

test_that('scto_read dataset fresh', {
  skip_on_cran()
  d = scto_read(auth, 'enumerators', refresh = TRUE, cache_dir = cache_dir)
  expect_data_table(d)
})

test_that('scto_read dataset stale', {
  skip_on_cran()
  d = scto_read(auth, 'enumerators', refresh = FALSE, cache_dir = cache_dir)
  expect_data_table(d)
})

test_that('scto_read dataset not ok', {
  skip_on_cran()
  expect_error(scto_read(auth, 'flux_capacitors', cache_dir = cache_dir))
})

test_that('scto_read form ok', {
  skip_on_cran()
  d = scto_read(
    auth, 'hh_listing_example_1', 'form', refresh = TRUE, cache_dir = cache_dir)
  expect_data_table(d)
})

test_that('scto_read form not ok', {
  skip_on_cran()
  expect_error(scto_read(
    auth, 'hh_listing_example_1', 'form', start_date = 'coffee', refresh = TRUE,
    cache_dir = cache_dir))
})

test_that('scto_read form encrypted no key', {
  skip_on_cran()
  d = scto_read(
    auth, 'hh_example_encrypted', 'form', refresh = TRUE, cache_dir = cache_dir)
  expect_data_table(d, ncols = 7L)
})

test_that('scto_read form encrypted key', {
  skip_on_cran()
  d = scto_read(
    auth, 'hh_example_encrypted', 'form', private_key = private_key,
    refresh = TRUE, cache_dir = cache_dir)
  expect_data_table(d, ncols = 20L)
})