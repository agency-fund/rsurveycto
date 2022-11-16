if (identical(Sys.getenv('NOT_CRAN'), 'true')) { # !on_cran()
  auth = scto_auth(auth_file = auth_file)
}

test_that('scto_read dataset ok', {
  skip_on_cran()
  d = scto_read(auth, 'enumerators')
  expect_data_table(d)
})

test_that('scto_read dataset not ok', {
  skip_on_cran()
  expect_error(scto_read(auth, 'flux_capacitors'))
})

test_that('scto_read form ok', {
  skip_on_cran()
  d = scto_read(auth, 'hh_listing_example_1')
  expect_data_table(d)
})

test_that('scto_read form not ok', {
  skip_on_cran()
  expect_error(scto_read(auth, 'hh_listing_example_1', start_date = 'coffee'))
})

test_that('scto_read form encrypted no key', {
  skip_on_cran()
  d = scto_read(auth, 'hh_example_encrypted')
  expect_data_table(d, ncols = 7L)
})

test_that('scto_read form encrypted key', {
  skip_on_cran()
  d = scto_read(auth, 'hh_example_encrypted', private_key = private_key)
  expect_data_table(d, ncols = 20L)
})

test_that('scto_read not simplify', {
  skip_on_cran()
  db = scto_read(auth, 'enumerators', simplify = FALSE)
  expect_list(db, min.len = 1L)
  lapply(db, function(d) expect_data_table(d))
})

test_that('scto_read all', {
  skip_on_cran()
  db = scto_read(auth)
  expect_list(db, min.len = 1L)
})
