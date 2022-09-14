if (identical(Sys.getenv('NOT_CRAN'), 'true')) { # !on_cran()
  auth = scto_auth(auth_file = auth_file)}

test_that('scto_meta ok', {
  skip_on_cran()
  meta = scto_meta(auth)

  nms = c('canAddObjectsIntoRoot', 'groups', 'datasets',
          'serverDatasetPublishingInfo', 'forms')

  expect_type(meta, 'list')
  expect_named(meta, nms)
})
