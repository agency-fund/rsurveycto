test_that('scto_auth file ok', {
  auth = scto_auth(auth_file = auth_file)
  expect_class(auth, 'scto_auth')
})

test_that('scto_auth file not ok', {
  f = withr::local_tempfile()
  writeLines(c('swans', 'elephants'), f)
  expect_error(scto_auth(auth_file = f))
})

test_that('scto_auth args', {
  auth_args = readLines(auth_file)
  auth = scto_auth(
    servername = auth_args[1L], username = auth_args[2L], password = auth_args[3L])
  expect_class(auth, 'scto_auth')
})
