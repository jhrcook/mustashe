

test_that("stash_script works", {

  # init
  set.seed(42) # sampled sequence: "q" "e" "a" "y" "j" "d" ...
  script_name <- tempfile()
  write("sample(letters,1)", script_name)

  # will be stashed
  x <- stash_script(script_name)
  expect_equal(x, "q")

  # will be retrieved
  x <- stash_script(script_name)
  expect_equal(x, "q")

  # changing file causes restash
  write("a_var<-5; sample(letters,1)", script_name)
  x <- stash_script(script_name)
  expect_equal(x, "e")

})
