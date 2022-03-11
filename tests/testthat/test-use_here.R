test_that("configure stash to use or not use 'here'", {
  expect_warning(use_here(silent = FALSE), "deprecated")
  expect_true(mustashe_use_here())

  expect_warning(dont_use_here(silent = FALSE), "deprecated")
  expect_false(mustashe_use_here())

  expect_warning(use_here(silent = TRUE), "deprecated")
  expect_true(mustashe_use_here())


  expect_warning(dont_use_here(silent = TRUE), "deprecated")
  expect_false(mustashe_use_here())
})
