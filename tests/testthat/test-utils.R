test_that('get_session_auth ok', {
  skip_on_cran()
  sess = get_session_auth(auth_args[1L], auth_args[2L], auth_args[3L])
  expect_type(sess, 'list')
})

test_that('get_session_auth not ok', {
  skip_on_cran()
  expect_error(get_session_auth('1', 'nobody@a.io', 'password'))
})

test_that('drop_empties', {
  ob = data.table(w = 3:4, x = c('', 'foo'), y = c(NA, NA), z = c(NA, ''))
  ex = ob[, .(w, x)]
  drop_empties(ob)
  expect_identical(ob, ex)
})
