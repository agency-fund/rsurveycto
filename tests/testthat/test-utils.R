test_that('drop_empties', {
  ob = data.table(w = 3:4, x = c('', 'foo'), y = c(NA, NA), z = c(NA, ''))
  ex = ob[, .(w, x)]
  drop_empties(ob)
  expect_identical(ob, ex)
})
