if (identical(Sys.getenv('NOT_CRAN'), 'true')) { # !on_cran()
  auth = scto_auth(auth_file = auth_file)}

set.seed(as.integer(Sys.time()))

dataset_id = 'wallahs'
dataset_title = 'Wallahs'
d0 = scto_read(auth, dataset_id)

test_that('scto_write no exist', {
  skip_on_cran()
  # skip_if(Sys.getenv('GITHUB_JOB') == 'R-CMD-check') # avoid concurrent changes
  expect_error(scto_write(auth, 'rhinos'))
})

test_that('scto_write no append', {
  skip_on_cran()
  skip_if(Sys.getenv('GITHUB_JOB') == 'R-CMD-check') # avoid concurrent changes
  withr::defer(scto_write(auth, d0, dataset_id, append = FALSE))

  d1 = copy(d0)
  d1[, mass := round(runif(.N), 5)]
  r = scto_write(auth, d1, dataset_id, append = FALSE)
  d2 = scto_read(auth, dataset_id)

  expect_named(r, c('data_old', 'response'))
  expect_identical(d0, r$data_old)
  expect_identical(d1, d2)
  expect_s3_class(r$response, 'response')
})

test_that('scto_write no fill', {
  skip_on_cran()
  # skip_if(Sys.getenv('GITHUB_JOB') == 'R-CMD-check') # avoid concurrent changes
  d1 = copy(d0)
  d1[, tree := NULL]
  expect_error(scto_write(auth, d1, dataset_id, append = TRUE, fill = FALSE))
})

test_that('scto_write fill', {
  skip_on_cran()
  skip_if(Sys.getenv('GITHUB_JOB') == 'R-CMD-check') # avoid concurrent changes
  withr::defer(scto_write(auth, d0, dataset_id, append = FALSE))

  d1 = copy(d0)
  d1[, tree := NULL]
  r = scto_write(auth, d1, dataset_id, append = TRUE, fill = TRUE)
  d2 = scto_read(auth, dataset_id)

  d3 = rbind(d0, d1, fill = TRUE)
  expect_identical(d2, d3, ignore_attr = 'scto_type')
})
