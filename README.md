
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mustashe <a href="https://jhrcook.github.io/mustashe/index.html"> <img src="man/figures/logo.png" align="right" alt="" width="120" /> </a>

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/mustashe)](https://CRAN.R-project.org/package=mustashe)
[![CRAN
downloads](http://cranlogs.r-pkg.org/badges/grand-total/mustashe)](https://cran.r-project.org/package=mustashe)
[![R build
status](https://github.com/jhrcook/mustashe/workflows/R-CMD-check/badge.svg)](https://github.com/jhrcook/mustashe/actions)
[![Travis build
status](https://travis-ci.org/jhrcook/mustashe.svg?branch=master)](https://travis-ci.org/jhrcook/mustashe)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/jhrcook/mustashe?branch=master&svg=true)](https://ci.appveyor.com/project/jhrcook/mustashe)
[![Codecov test
coverage](https://codecov.io/gh/jhrcook/mustashe/branch/master/graph/badge.svg)](https://codecov.io/gh/jhrcook/mustashe?branch=master)
[![License: GPL
v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
<!-- badges: end -->

The goal of ‘mustashe’ is to save time on long-running computations by
storing and reloading the resulting object after the first run. The next
time the computation is run, instead of evaluating the code, the stashed
object is loaded. ‘mustashe’ is great for storing intermediate objects
in an analysis.

## Installation

You can install the released version of ‘mustashe’ from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("mustashe")
```

And the development version from
[GitHub](https://github.com/jhrcook/mustashe) with:

``` r
# install.packages("devtools")
devtools::install_github("jhrcook/mustashe")
```

## Loading ‘mustashe’

The ‘mustashe’ package is loaded like any other, using the `library()`
function.

``` r
library(mustashe)
```

## Basic example

Below is a simple example of how to use the `stash()` function from
‘mustashe’.

Let’s say, for part of an analysis, we are running a long simulation to
generate random data `rnd_vals`. This is mocked below using the
`Sys.sleep()` function. We can time this process using the ‘tictoc’
library.

``` r
tictoc::tic("random simulation")
stash("rnd_vals", {
    Sys.sleep(3)
    rnd_vals <- rnorm(1e5)
})
#> Stashing object.
tictoc::toc()
#> random simulation: 3.425 sec elapsed
```

Now, if we come back tomorrow and continue working on the same analysis,
the second time this process is run the code is not evaluated because
the code passed to `stash()` has not changed. Instead, the random values
`rnd_vals` is loaded.

``` r
tictoc::tic("random simulation")
stash("rnd_vals", {
    Sys.sleep(3)
    rnd_vals <- rnorm(1e5)
})
#> Loading stashed object.
tictoc::toc()
#> random simulation: 0.031 sec elapsed
```

## Dependencies

A common problem with storing intermediates is that they have
dependencies that can change. If a dependency changes, then we want the
stashed value to be updated. This is accomplished by passing the names
of the dependencies to the `depends_on` argument.

For instance, let’s say we are calculating some value `foo` using `x`.
(For the following example, I will use a print statement to indicate
when the code is evaluated.)

``` r
x <- 100

stash("foo", depends_on = "x", {
    print("Calculating `foo` using `x`.")
    foo <- x + 1
})
#> Stashing object.
#> [1] "Calculating `foo` using `x`."

foo
#> [1] 101
```

Now if `x` is not changed, then the code for `foo` does not get
re-evaluated.

``` r
x <- 100

stash("foo", depends_on = "x", {
    print("Calculating `foo` using `x`.")
    foo <- x + 1
})
#> Loading stashed object.

foo
#> [1] 101
```

But if `x` does change, then `foo` gets re-evaluated.

``` r
x <- 200

stash("foo", depends_on = "x", {
    print("Calculating `foo` using `x`.")
    foo <- x + 1
})
#> Updating stash.
#> [1] "Calculating `foo` using `x`."

foo
#> [1] 201
```

-----

### Attribution

The inspiration for this package came from the `cache()` feature in the
[‘ProjectTemplate’](http://projecttemplate.net/index.html) package.
While the functionality and implementation are a bit different, this
would have been far more difficult to do without referencing the source
code from ‘ProjectTemplate’.
