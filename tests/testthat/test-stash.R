test_that("stashing works", {
    expect_error(stash(NULL, NULL), "`var` cannot be NULL")
    expect_error(stash("a", NULL), "`code` cannot be NULL")

    clear_stash()

    expect_null(stash("a", { a <- 1 }))
    expect_true(file.exists(file.path(".mustasher", "a.rds")))
    expect_true(file.exists(file.path(".mustasher", "a.hash")))


    file_time <- function(path) {
         file.info(path)$mtime
    }
    old_rds_time <- file_time(file.path(".mustasher", "a.rds"))
    old_hash_time <- file_time(file.path(".mustasher", "a.hash"))
    Sys.sleep(0.5)

    expect_null(stash("a", { a <- 1 }))
    expect_equal(a, 1)
    expect_equal(file_time(file.path(".mustasher", "a.rds")), old_rds_time)
    expect_equal(file_time(file.path(".mustasher", "a.hash")), old_hash_time)

    expect_null(stash("a", { a <- 2 }))
    expect_equal(a, 2)
    expect_false(file_time(file.path(".mustasher", "a.rds")) == old_rds_time)
    expect_false(file_time(file.path(".mustasher", "a.hash")) == old_hash_time)

    clear_stash()

    assign("b", 1, envir = .GlobalEnv)
    expect_null(stash("a", depends_on = "b", { a <- b + 1 }))
    expect_equal(a, 2)
    expect_true(file.exists(file.path(".mustasher", "a.rds")))
    expect_true(file.exists(file.path(".mustasher", "a.hash")))
    expect_false(file.exists(file.path(".mustasher", "b.rds")))
    expect_false(file.exists(file.path(".mustasher", "b.hash")))

    old_rds_time <- file_time(file.path(".mustasher", "a.rds"))
    old_hash_time <- file_time(file.path(".mustasher", "a.hash"))
    Sys.sleep(0.5)

    expect_null(stash("a", depends_on = "b", { a <- b + 1 }))
    expect_equal(a, 2)
    expect_equal(file_time(file.path(".mustasher", "a.rds")), old_rds_time)
    expect_equal(file_time(file.path(".mustasher", "a.hash")), old_hash_time)

    assign("b", 2, envir = .GlobalEnv)
    expect_null(stash("a", depends_on = "b", { a <- b + 1 }))
    expect_equal(a, 3)
    expect_false(file_time(file.path(".mustasher", "a.rds")) == old_rds_time)
    expect_false(file_time(file.path(".mustasher", "a.hash")) == old_hash_time)

    clear_stash()
    rm(list = c("a", "b"), envir = .GlobalEnv)
    if (dir.exists(".mustasher")) unlink(".mustasher", recursive = TRUE)

})
