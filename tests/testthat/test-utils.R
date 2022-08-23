test_that('get_csrf_token ok', {
  skip_on_cran()
  csrf_token = get_csrf_token(auth_args[1L], auth_args[2L], auth_args[3L])
  expect_string(csrf_token)
})

test_that('get_csrf_token not ok', {
  skip_on_cran()
  expect_error(get_csrf_token('1', 'nobody@a.io', 'password'))
})

test_that('drop_empties', {
  ob = data.table(w = 3:4, x = c('', 'foo'), y = c(NA, NA), z = c(NA, ''))
  ex = ob[, .(w, x)]
  drop_empties(ob)
  expect_identical(ob, ex)
})
