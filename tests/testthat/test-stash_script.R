test_that("stash_script works", {
  # init
  set.seed(42) # sampled sequence: "q" "e" "a" "y" "j" "d" ...
  script_name <- tempfile()
  write("sample(letters, 1)", script_name)

  # will be stashed
  x <- stash_script(script_name)
  expect_equal(x, "q")

  # will be retrieved
  x <- stash_script(script_name)
  expect_equal(x, "q")

  # changing file causes re-stash
  write("a_var <- 5; sample(letters, 1)", script_name)
  x <- stash_script(script_name)
  expect_equal(x, "e")
})

test_that("stash_script correctly handles depends_on", {

  # init
  set.seed(42) # sampled sequence: "q" "e" "a" "y" "j" "d" ...
  script_name <- tempfile()
  write("sample(letters, 1)", script_name)

  # will be stashed
  the_dependency <- "initial value"
  x <- stash_script(script_name, depends_on = "the_dependency")
  expect_equal(x, "q")

  # will be retrieved
  the_dependency <- "initial value"
  x <- stash_script(script_name, depends_on = "the_dependency")
  expect_equal(x, "q")

  # changing file causes re-stash
  the_dependency <- "new value"
  x <- stash_script(script_name, depends_on = "the_dependency")
  expect_equal(x, "e")
})
