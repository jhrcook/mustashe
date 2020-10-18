test_that("the correct filenames are retrieved", {
  expect_equal(
    stash_filename("josh"),
    list(
      data_name = file.path(".mustashe/josh.qs"),
      hash_name = file.path(".mustashe/josh.hash")
    )
  )
})
