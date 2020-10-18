test_that("`stash()` uses the `here::here()` function", {
  expect_message(use_here(), "global option \"mustashe.here\" has been set `TRUE`")
  expect_silent(use_here(silent = TRUE))
  expect_true(getOption("mustashe.here"))
})


test_that("`stash()` does not use the `here::here()` function", {
  expect_message(dont_use_here())
  expect_silent(dont_use_here(silent = TRUE))
  expect_false(getOption("mustashe.here"))
})
