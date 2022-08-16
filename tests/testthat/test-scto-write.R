auth = scto_auth(auth_file = auth_file)
set.seed(as.integer(Sys.time()))

test_that('scto_write ok', {
  skip_if(Sys.getenv('GITHUB_JOB') == 'R-CMD-check') # avoid concurrent changes
  dataset_id = 'cases'
  dataset_title = 'Cases'

  d0 = scto_read(auth, dataset_id, refresh = TRUE, cache_dir = cache_dir)

  tryCatch({
    d1 = data.table(
      id = 1:2, label = c('Alf', 'Pippy'), rand = round(runif(2), 5))
    res = scto_write(auth, d1, dataset_id, dataset_title)
    d2 = scto_read(auth, dataset_id, refresh = TRUE, cache_dir = cache_dir)},
  error = function(e) e,
  finally = {invisible(scto_write(auth, d0, dataset_id, dataset_title))})

  expect_class(res, 'response')
  expect_identical(d1, d2)
  expect_false(identical(d1, d0))
})
