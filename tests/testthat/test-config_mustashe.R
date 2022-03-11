test_that("mustashe configuration defaults", {
  # Start with defaults.
  expect_equal(mustashe_use_here(), FALSE)
  expect_equal(mustashe_verbose(), TRUE)
  expect_equal(mustashe_functional(), FALSE)

  # Set configuration with no values.
  config_mustashe()

  # Assert nothing changes.
  expect_equal(mustashe_use_here(), FALSE)
  expect_equal(mustashe_verbose(), TRUE)
  expect_equal(mustashe_functional(), FALSE)
})

test_that("configuring use of 'here' package", {
  expect_equal(mustashe_use_here(), FALSE)
  config_mustashe(use_here = TRUE)
  expect_equal(mustashe_use_here(), TRUE)
  config_mustashe()
  expect_equal(mustashe_use_here(), TRUE)
  config_mustashe(use_here = FALSE)
  expect_equal(mustashe_use_here(), FALSE)
})

test_that("configuring default verbosity", {
  expect_equal(mustashe_verbose(), TRUE)
  config_mustashe(verbose = FALSE)
  expect_equal(mustashe_verbose(), FALSE)
  config_mustashe()
  expect_equal(mustashe_verbose(), FALSE)
  config_mustashe(verbose = TRUE)
  expect_equal(mustashe_verbose(), TRUE)
})

test_that("configuring `functional` default", {
  expect_equal(mustashe_functional(), FALSE)
  config_mustashe(functional = TRUE)
  expect_equal(mustashe_functional(), TRUE)
  config_mustashe()
  expect_equal(mustashe_functional(), TRUE)
  config_mustashe(functional = FALSE)
  expect_equal(mustashe_functional(), FALSE)
})

test_that("warning if try to connfigure with positional arguments", {
  expect_warning(config_mustashe(TRUE), regexp = "Positional")
})
