test_that("expressions are evaluated in correct environment", {
  verbose <- FALSE

  # Un-stash any old versions of this variable
  unstash("test_stash_environment", verbose = verbose)

  # Assign the variable in the global environment
  assign("the_variable", "global", envir = .GlobalEnv)

  # `the_variable` should be searched for in parent environments, eventually
  # reaching the global env.
  result <- stash("test_stash_global_env",
    {
      toupper(the_variable)
    },
    functional = TRUE,
    verbose = verbose
  )
  unstash("test_stash_global_env")
  expect_equal(result, "GLOBAL")

  # Assign `the_variable` in the "outer" (testthat) environment
  the_variable <- "outer"

  # `the_variable` should be retrieved from the scope of the test, not global
  result <- stash("test_stash_environment",
    {
      toupper(the_variable)
    },
    functional = TRUE,
    verbose = verbose
  )
  unstash("test_stash_environment", verbose = verbose)
  expect_equal(result, "OUTER")

  # `the_variable` should be retrieved from the scope of the inner function
  inner_fun <- function() {
    the_variable <- "inner"
    another_inner_variable <- "another inner"
    stash("test_stash_environment",
      {
        toupper(the_variable)
      },
      functional = TRUE,
      verbose = verbose
    )
  }
  result <- inner_fun()
  unstash("test_stash_environment", verbose = verbose)
  expect_equal(result, "INNER")
})

test_that("dependencies are checked in correct environment", {
  verbose <- FALSE

  # Un-stash any old versions of this variable
  unstash("test_stash_environment", verbose = verbose)

  # Assign a dependency variable in the "outer" (testthat) environment
  the_dependency <- "it depends"

  # Set seed, so sample(100, 1) will return these numbers in order:
  # 49  65  25  74  18 100  47  24  71  89
  set.seed(42)

  # Result should be computed
  result_1 <- stash("test_stash_environment",
    {
      sample(100, 1)
    },
    depends_on = "the_dependency",
    functional = TRUE,
    verbose = verbose
  )
  expect_equal(result_1, 49)

  # Result should be retrieved from stash
  result_2 <- stash("test_stash_environment",
    {
      sample(100, 1)
    },
    depends_on = "the_dependency",
    functional = TRUE,
    verbose = verbose
  )
  expect_equal(result_1, 49)

  # Update dependency, should cause re-stashing
  the_dependency <- "dep in outer environment"
  result_2 <- stash("test_stash_environment",
    {
      sample(100, 1)
    },
    depends_on = "the_dependency",
    functional = TRUE,
    verbose = verbose
  )
  expect_equal(result_2, 65)

  # `the_dependency` should be retrieved from the scope of the inner function,
  # which differs, so a re-stash should be triggered.
  inner_fun <- function() {
    the_dependency <- "dep in inner environment"
    result <- stash("test_stash_fxn_env",
      {
        sample(100, 1)
      },
      depends_on = "the_dependency",
      functional = TRUE,
      verbose = verbose
    )
    return(result)
  }
  result_3 <- inner_fun()
  expect_equal(result_3, 25)
})

test_that(
  paste(
    "stashing in a function with a dependency that is an argument",
    "to the function uses the correct environment"
  ),
  {
    # Setup
    unstash("x")
    unstash("y")
    # Set seed, so sample(100, 1) will return these numbers in order:
    # 49  65  25  74  18 100  47  24  71  89
    set.seed(42)

    add_random <- function(x = 100) {
      stash("y",
        {
          y <- x + sample(100, 1)
        },
        depends_on = "x"
      )
      return(y)
    }

    # Initial call to run computation with default parameter value.
    res <- add_random()
    expect_equal(res, 49 + 100)
    # Second call to get value from stash.
    res <- add_random()
    expect_equal(res, 49 + 100)

    # Initial call to run computation with a new argument object.
    dep_x <- 4
    res <- add_random(dep_x)
    expect_equal(res, 65 + dep_x)
    # Second call to get value from stash.
    res <- add_random(dep_x)
    expect_equal(res, 65 + dep_x)

    # Third call with a new value for the dependency "x".
    dep_x2 <- 5
    res <- add_random(dep_x2)
    expect_equal(res, 25 + dep_x2)
  }
)


test_that("result is assigned in correct environment", {
  verbose <- FALSE

  # Un-stash any old versions of this variable.
  # It should not exist, either in the local test environment or .GlobalEnv
  unstash("test_stash_environment_var", verbose = verbose)
  expect_false(
    exists("test_stash_environment_var", environment(), inherits = FALSE)
  )
  expect_false(
    exists("test_stash_environment_var", .GlobalEnv, inherits = FALSE)
  )

  # Call stash in non-function mode
  stash("test_stash_environment_var",
    {
      letters[1:3]
    },
    verbose = verbose
  )

  # Variable should now exist in local test environment, but not in .GlobalEnv
  expect_true(
    exists("test_stash_environment_var", environment(), inherits = FALSE)
  )
  rm("test_stash_environment_var")
})
