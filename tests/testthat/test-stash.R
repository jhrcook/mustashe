test_that("stashing works", {
  stash_filename("x")
  target_dir <- get_stash_dir()

  expect_error(stash(NULL, NULL), "`var` cannot be NULL")
  expect_error(stash("a", NULL), "`code` cannot be NULL")

  clear_stash()

  expect_null(stash("a", {
    a <- 1
  }))
  expect_true(file.exists(file.path(target_dir, "a.qs")))
  expect_true(file.exists(file.path(target_dir, "a.hash")))


  file_time <- function(path) {
    file.info(path)$mtime
  }

  old_qs_time <- file_time(file.path(target_dir, "a.qs"))
  old_hash_time <- file_time(file.path(target_dir, "a.hash"))
  Sys.sleep(1.5)

  expect_null(stash("a", {
    a <- 1
  }))
  expect_equal(a, 1)
  expect_equal(file_time(file.path(target_dir, "a.qs")), old_qs_time)
  expect_equal(file_time(file.path(target_dir, "a.hash")), old_hash_time)

  expect_null(stash("a", {
    a <- 2
  }))
  expect_equal(a, 2)
  expect_false(file_time(file.path(target_dir, "a.qs")) == old_qs_time)
  expect_false(file_time(file.path(target_dir, "a.hash")) == old_hash_time)

  clear_stash()

  b <- 1
  expect_null(stash("a", depends_on = "b", {
    a <- b + 1
  }))
  expect_equal(a, 2)
  expect_true(file.exists(file.path(target_dir, "a.qs")))
  expect_true(file.exists(file.path(target_dir, "a.hash")))
  expect_false(file.exists(file.path(target_dir, "b.qs")))
  expect_false(file.exists(file.path(target_dir, "b.hash")))

  old_qs_time <- file_time(file.path(target_dir, "a.qs"))
  old_hash_time <- file_time(file.path(target_dir, "a.hash"))
  Sys.sleep(1.5)

  expect_null(stash("a", depends_on = "b", {
    a <- b + 1
  }))
  expect_equal(a, 2)
  expect_equal(file_time(file.path(target_dir, "a.qs")), old_qs_time)
  expect_equal(file_time(file.path(target_dir, "a.hash")), old_hash_time)

  b <- 2
  expect_null(stash("a", depends_on = "b", {
    a <- b + 1
  }))
  expect_equal(a, 3)
  expect_false(file_time(file.path(target_dir, "a.qs")) == old_qs_time)
  expect_false(file_time(file.path(target_dir, "a.hash")) == old_hash_time)

  # Clean-up
  clear_stash()
  if (dir.exists(target_dir)) unlink(target_dir, recursive = TRUE)
})


test_that("stashing works", {
  stash_filename("x")

  x <- stash("x",
    {
      1
    },
    functional = TRUE
  )
  expect_equal(x, 1)

  x <- stash("x",
    {
      1
    },
    functional = TRUE
  )
  expect_equal(x, 1)

  target_dir <- get_stash_dir()
  expect_true(file.exists(file.path(target_dir, "x.qs")))
  expect_true(file.exists(file.path(target_dir, "x.hash")))

  # Clean-up
  clear_stash()
  # rm(list = c("x"), envir = .GlobalEnv)  # nolint
  if (dir.exists(target_dir)) unlink(target_dir, recursive = TRUE)
})

# nolint start
# test_that("Can stash functions as dependencies", {
#     target_dir <- ".mustashe"
#
#     fxn <- function(x) {
#         x ** 2
#     }
#
#     print(digest(fxn))
#     print(digest(fxn))
#     a <- fxn(2)
#     print(digest(fxn))
#     a <- fxn(2)
#     print(digest(fxn))
#     a <- fxn(4)
#     print(digest(fxn))
#
#     expect_message(
#         stash("a", depends_on = "fxn",{
#             a <- fxn(10)
#         }),
#         "Stashing object."
#     )
#
#     expect_true(a == 100)
#
#     expect_message(
#         stash("a", depends_on = "fxn",{
#             a <- fxn(10)
#         }),
#         "Loading stashed object."
#     )
#
#     fxn <- function(x) {
#         x + 2
#     }
#
#     expect_message(
#         stash("a", depends_on = "fxn",{
#             a <- fxn(10)
#         }),
#         "Updating stash."
#     )
#
#     expect_true(a == 12)
#
#     expect_message(
#         stash("a", depends_on = "fxn",{
#             a <- fxn(10)
#         }),
#         "Loading stashed object."
#     )
#
#     expect_true(a == 12)
#
#     expect_message(
#         stash("a", depends_on = "fxn",{
#             a <- fxn(20)
#         }),
#         "Updating stash."
#     )
#
#     expect_true(a == 22)
#
#     # Clean-up
#     clear_stash()
#     rm(list = c("a", "fxn"), envir = .GlobalEnv)
#     if (dir.exists(target_dir)) unlink(target_dir, recursive = TRUE)
#
# })
# nolint end
