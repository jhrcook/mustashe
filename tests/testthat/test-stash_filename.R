test_that("the correct filenames are retrieved", {
    expect_equal(
        stash_filename("josh"),
        list(data_name = file.path(".mustasher/josh.rds"),
             hash_name = file.path(".mustasher/josh.hash"))
    )
})
