
test_that("function deps are invalidated when updated", {

  # A function is defined by three components: `formals(f)`, `body(f)`,
  # `environment(f)`. Since the environment of a function is generally not
  # identical across restarts, it is not feasible to rely on it for determining
  # dependencies. However, updates to either a functions `formals()` or `body()`
  # should trigger a restash. (source: http://adv-r.had.co.nz/Functions.html)

  verbose <- FALSE
  unstash("stash_func")
  set.seed(42)

  # Initial stash for reference
  f <- function(x, y) {
    x - y
  }
  result_1 <- stash("stash_func",
    {
      sample(1000, 1)
    },
    depends_on = "f",
    functional = TRUE
  )

  # Changing body SHOULD trigger a restash
  body(f) <- expression({
    y - x
  })
  result_2 <- stash("stash_func",
    {
      sample(1000, 1)
    },
    depends_on = "f",
    functional = TRUE
  )
  expect_true(result_1 != result_2)

  # Changing formals SHOULD trigger a restash
  formals(f)$y <- 3
  result_3 <- stash("stash_func",
    {
      sample(1000, 1)
    },
    depends_on = "f",
    functional = TRUE
  )
  expect_true(result_2 != result_3)

  # Changing environment SHOULD NOT trigger a restash
  environment(f) <- new.env()
  result_4 <- stash("stash_func",
    {
      sample(1000, 1)
    },
    depends_on = "f",
    functional = TRUE
  )
  expect_equal(result_3, result_4)
})


test_that("function deps are not invalidated by calls", {
  f1 <- function(x) {
    sum(x)
  }
  f2 <- sum
  hash_naive_1 <- digest::digest(f1)

  set.seed(1)
  result_1 <- stash("stash_func",
    {
      sample(letters, 2)
    },
    depends_on = c("f1", "f2"),
    functional = TRUE
  )

  # Calling the function changes it
  expect_equal(f1(1:3), 6)
  expect_equal(f2(1:3), 6)
  hash_naive_2 <- digest::digest(f1)

  # This should be loaded, because the body of f1 is not changed
  result_2 <- stash("stash_func",
    {
      sample(letters, 2)
    },
    depends_on = c("f1", "f2"),
    functional = TRUE
  )

  # If function bodies are correctly hashed, these should be equal
  expect_equal(result_1, result_2)
  expect_true(hash_naive_1 != hash_naive_2)

  f1 <- function(x) {
    var(x)
  }

  # Now the body of f1 IS changed, forcing an update
  result_3 <- stash("stash_func",
    {
      sample(letters, 2)
    },
    depends_on = c("f1", "f2"),
    functional = TRUE
  )

  # If updating a function body correctly invalidates cache, these should not be equal
  expect_false(isTRUE(all.equal(result_1, result_3)))

  unstash("stash_func")
})
