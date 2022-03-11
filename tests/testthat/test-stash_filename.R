test_that("the correct filenames are retrieved", {

  # Without using `here::here()`.
  config_mustashe(use_here = FALSE)

  filenames1 <- stash_filename("josh")
  expect_equal(
    filenames1,
    list(
      data_name = file.path(".mustashe/josh.qs"),
      hash_name = file.path(".mustashe/josh.hash")
    )
  )

  # With using `here::here()`.
  config_mustashe(use_here = TRUE)

  filenames2 <- stash_filename("josh")
  expect_false(filenames1$data_name == filenames2$data_name)
  expect_false(filenames1$hash_name == filenames2$hash_name)

  expect_true(basename(filenames1$data_name) == basename(filenames2$data_name))
  expect_true(basename(filenames1$hash_name) == basename(filenames2$hash_name))

  expect_true(grep(filenames1$data_name, filenames2$data_name) == 1)
  expect_true(grep(filenames1$hash_name, filenames2$hash_name) == 1)
})
