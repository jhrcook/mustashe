test_that("stashing works", {
    target_dir <- ".mustashe"

    expect_error(stash(NULL, NULL), "`var` cannot be NULL")
    expect_error(stash("a", NULL), "`code` cannot be NULL")

    clear_stash()

    expect_null(stash("a", { a <- 1 }))
    expect_true(file.exists(file.path(target_dir, "a.qs")))
    expect_true(file.exists(file.path(target_dir, "a.hash")))


    file_time <- function(path) {
         file.info(path)$mtime
    }
  
    old_qs_time <- file_time(file.path(target_dir, "a.qs"))
    old_hash_time <- file_time(file.path(target_dir, "a.hash"))
    Sys.sleep(1.5)

    expect_null(stash("a", { a <- 1 }))
    expect_equal(a, 1)
    expect_equal(file_time(file.path(target_dir, "a.qs")), old_qs_time)
    expect_equal(file_time(file.path(target_dir, "a.hash")), old_hash_time)

    expect_null(stash("a", { a <- 2 }))
    expect_equal(a, 2)
    expect_false(file_time(file.path(target_dir, "a.qs")) == old_qs_time)
    expect_false(file_time(file.path(target_dir, "a.hash")) == old_hash_time)

    clear_stash()

    assign("b", 1, envir = .GlobalEnv)
    expect_null(stash("a", depends_on = "b", { a <- b + 1 }))
    expect_equal(a, 2)
    expect_true(file.exists(file.path(target_dir, "a.qs")))
    expect_true(file.exists(file.path(target_dir, "a.hash")))
    expect_false(file.exists(file.path(target_dir, "b.qs")))
    expect_false(file.exists(file.path(target_dir, "b.hash")))

    old_qs_time <- file_time(file.path(target_dir, "a.qs"))
    old_hash_time <- file_time(file.path(target_dir, "a.hash"))
    Sys.sleep(1.5)

    expect_null(stash("a", depends_on = "b", { a <- b + 1 }))
    expect_equal(a, 2)
    expect_equal(file_time(file.path(target_dir, "a.qs")), old_qs_time)
    expect_equal(file_time(file.path(target_dir, "a.hash")), old_hash_time)

    assign("b", 2, envir = .GlobalEnv)
    expect_null(stash("a", depends_on = "b", { a <- b + 1 }))
    expect_equal(a, 3)
    expect_false(file_time(file.path(target_dir, "a.qs")) == old_qs_time)
    expect_false(file_time(file.path(target_dir, "a.hash")) == old_hash_time)

    clear_stash()
    rm(list = c("a", "b"), envir = .GlobalEnv)
    if (dir.exists(target_dir)) unlink(target_dir, recursive = TRUE)

})
