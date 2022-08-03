test_that('exampleFunction', {
  dObs = exampleFunction(2L, 5L)
  dExp = snapshot(dObs, file.path(dataDir, 'example_output.qs'))

  expect_equal(dObs, dExp)
})
