test_that('get_csrf_token', {
  csrf_token = get_csrf_token(auth_args[1L], auth_args[2L], auth_args[3L])
  expect_string(csrf_token)
})

test_that('drop_empties', {
  ob = data.table(w = 3:4, x = c('', 'foo'), y = c(NA, NA), z = c(NA, ''))
  ex = ob[, .(w, x)]
  drop_empties(ob)
  expect_identical(ob, ex)
})
