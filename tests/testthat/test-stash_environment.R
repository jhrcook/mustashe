

test_that("expressions are evaluated in correct environment", {

  # Configuration
  verbose<-FALSE

  # Unstash any old versions of this variable
  unstash("test_stash_environment", verbose=verbose)

  # Assign the variable in the global environment
  assign("the_variable", "global", envir=.GlobalEnv)

  # Assign the variable in the "outer" (testthat) environment
  the_variable <- "outer"

  # the_variable should be retrieved from the scope of the test, not global scope
  result <- stash("test_stash_environment", {toupper(the_variable)},
                  functional=TRUE, verbose=verbose)
  unstash("test_stash_environment", verbose=verbose)
  expect_equal(result, "OUTER")

  # the_variable should be retreived from the scope of the inner function
  inner_fun <- function() {
    the_variable <- "inner"
    another_inner_variable <- "another inner"
    stash("test_stash_environment", {toupper(the_variable)},
                  functional=TRUE, verbose=verbose)
  }
  result <- inner_fun()
  unstash("test_stash_environment", verbose=verbose)
  expect_equal(result, "INNER")

})

test_that("dependencies are checked in correct environment", {

  # Configuration
  verbose<-FALSE

  # Unstash any old versions of this variable
  unstash("test_stash_environment", verbose=verbose)

  # Assign a dependency variable in the "outer" (testthat) environment
  the_dependency <- "it depends"

  # Set seed, so sample(100, 1) will return these numbers in order:
  # 49  65  25  74  18 100  47  24  71  89
  set.seed(42)

  # Result should be computed
  result_1 <- stash("test_stash_environment", {sample(100,1)}, depends_on="the_dependency",
        functional=TRUE, verbose=verbose)
  expect_equal(result_1, 49)

  # Result should be retrieved from stash
  result_2 <- stash("test_stash_environment", {sample(100,1)}, depends_on="the_dependency",
        functional=TRUE, verbose=verbose)
  expect_equal(result_1, 49)

  # Update dependency, should cause restashing
  the_dependency <- "dep in outer environment"
  result_2 <- stash("test_stash_environment", {sample(100,1)}, depends_on="the_dependency",
        functional=TRUE, verbose=verbose)
  expect_equal(result_2, 65)

  # the_dependency should be retreived from the scope of the inner function,
  # which differs, so a restash should be triggered.
  inner_fun <- function() {
    the_dependency <- "dep in inner environment"
    stash("test_stash_environment", {sample(100,1)}, depends_on="the_dependency",
        functional=TRUE, verbose=verbose)
  }
  result_3 <- inner_fun()
  expect_equal(result_3, 25)

})


test_that("result is assigned in correct environment", {

  # Configuration
  verbose<-FALSE

  # Unstash any old versions of this variable.
  # It should not exist, either in the local test environment or .GlobalEnv
  unstash("test_stash_environment_var", verbose=verbose)
  expect_false(exists("test_stash_environment_var", environment(), inherits=FALSE))
  expect_false(exists("test_stash_environment_var", .GlobalEnv, inherits=FALSE))

  # Call stash in non-function mode
  stash("test_stash_environment_var", {letters[1:3]},
        verbose=verbose)

  # Variable should now exist in local test environment, but not in .GlobalEnv
  expect_true(exists("test_stash_environment_var", environment(), inherits=FALSE))
  rm("test_stash_environment_var")

})
