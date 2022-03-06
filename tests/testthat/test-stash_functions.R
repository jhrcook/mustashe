
test_that("stashing works with function dependencies", {

  f1 <- function(x) { sum(x) }
  f2 <- sum
  hash_naive_1 <- digest::digest(f1)

  set.seed(1)
  result_1 <- stash("stash_func", {sample(letters, 2)},
                    depends_on = c("f1","f2"), functional=TRUE)

  # Calling the function changes it
  expect_equal(f1(1:3),6)
  expect_equal(f2(1:3),6)
  hash_naive_2 <- digest::digest(f1)

  # This should be loaded, because the body of f1 is not changed
  result_2 <- stash("stash_func", {sample(letters, 2)},
                    depends_on = c("f1","f2"), functional=TRUE)

  # If function bodies are correctly hashed, these should be equal
  expect_equal(result_1, result_2)

  expect_true(hash_naive_1!=hash_naive_2)

  f1 <- function(x) { var(x) }

  # Now the body of f1 IS changed, forcing an update
  result_3 <- stash("stash_func", {sample(letters, 2)},
                    depends_on = c("f1","f2"), functional=TRUE)

  # If updating a function body correctly invalidates cache, these should not be equal
  expect_false(isTRUE(all.equal(result_1, result_3)))

  unstash("stash_func")
})
