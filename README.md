
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mustashe <a href="https://jhrcook.github.io/mustashe/index.html"> <img src="man/figures/logo.png" align="right" alt="" width="120" /> </a>

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/mustashe)](https://CRAN.R-project.org/package=mustashe)
[![CRAN
downloads](http://cranlogs.r-pkg.org/badges/grand-total/mustashe)](https://cran.r-project.org/package=mustashe)
[![R-CMD-check](https://github.com/jhrcook/mustashe/workflows/R-CMD-check/badge.svg)](https://github.com/jhrcook/mustashe/actions)
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
#> random simulation: 3.044 sec elapsed
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
#> random simulation: 0.023 sec elapsed
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

## Other API features

### Functional interface

In the examples above, `stash()` does not return a value (actually, it
invisibly returns `NULL`), instead assigning the result of the
computation to an object named using the `var` argument. Frequently,
though, a return value is desired. This behavior can be induced by
setting the argument `functional = TRUE`.

``` r
b <- stash("b", functional = FALSE, {
  rnorm(5, 0, 1)
})
#> Stashing object.
b
#> NULL
```

``` r
b <- stash("b", functional = TRUE, {
  rnorm(5, 0, 1)
})
#> Loading stashed object.
b
#> [1]  0.26499342  1.83074748 -0.05937826 -0.05320937  0.43790418
```

### Functions as dependencies

The `stash()` function can take other functions as dependencies. The
body and formals components of the function object are checked to see if
they have changed. (More information on the structure of function
objects in R can be found in Hadley Wickham’s [*Advanced R* - Functions:
Function
components](http://adv-r.had.co.nz/Functions.html#function-components).)

As an example, suppose you have a script with the following code. It is
run, and the value of 5 is stashed for `a` and it is dependent on the
function `add_x()`.

``` r
add_x <- function(y, x = 2) {
  y + x
}

stash("a", depends_on = "add_x", {
  a <- add_x(3)
})
#> Stashing object.
a
#> [1] 5
```

You continue working and change the function `add_x()` to use the
default value of 5 instead of 2. This change will cause the code for `a`
to be re-run and `a` will be assigned the value 8. Note that the code in
the `code` argument for `stash()` did not change, the code was re-run
because a dependency changed.

``` r
add_x <- function(y, x = 5) {
  y + x
}

stash("a", depends_on = "add_x", {
  a <- add_x(3)
})
#> Updating stash.
a
#> [1] 8
```

### Using `stash()` in functions

Because of the careful management of R environments, `stash()` can be
used inside of functions. In the example below, note that the stashed
object will depend on the value of the `magic_number` object *in the
function*.

``` r
magic_number <- 10
do_data_science <- function() {
  magic_number <- 5
  stash("rand_num", depends_on = c("magic_number"), {
    runif(1, 0, 10)
  })
  return(rand_num)
}

do_data_science()
#> Stashing object.
#> [1] 9.094619
```

Changing the value of the `magic_number` object in the global
environment will not invalidate the stash.

``` r
magic_number <- 11
do_data_science()
#> Loading stashed object.
#> [1] 9.094619
```

### Stashing results of sourcing a R script

It is also possible to stash the results of sourcing and R script. The
contents of the script are an implicit dependency for the stash, so if
the script changes, it will be re-sourced the next time around. It is
also possible to include additional dependencies using the `depends_on`
parameter in the same way as with a regular stash.

The natural behavior of the `source()` function is maintained by
returning the last evaluated value in the script.

``` r
# Write a temporary R script.
temp_script <- tempfile()
write("print('Script to get 5 letters'); sample(letters, 5)", temp_script)

x <- stash_script(temp_script)
#> Stashing object.
#> [1] "Script to get 5 letters"
x
#> [1] "d" "t" "l" "o" "u"
```

``` r
x2 <- stash_script(temp_script)
#> Loading stashed object.
x2
#> [1] "d" "t" "l" "o" "u"
```

## Configuration

### Using [‘here’](https://here.r-lib.org) to create file paths

The [‘here’](https://here.r-lib.org) package is useful for handling file
paths in R projects, particularly when using an RStudio project. The
main function, `here::here()`, can be used to create the file path for
stashing an object by setting the ‘mustashe’ configuration option with
the `config_mustashe()` function.

``` r
config_mustashe(use_here = TRUE)
```

This behavior can be turned off, too.

``` r
config_mustashe(use_here = FALSE)
```

### Other options

Defaults for the `verbose` and `functional` (see above) arguments of
stashing functions can also be configured. For example, you can have the
functions run silently and return the result by default.

``` r
config_mustashe(verbose = FALSE, functional = TRUE)
```

------------------------------------------------------------------------

## Acknowledgements

### Contributors

I would like to thank the contributors to this package for their
additions of key features and bug squashing:

-   [vinayakvsv](https://github.com/vinayakvsv) fixed an annoying bug
    early on in the development of the library.
-   [jimbrig](https://github.com/jimbrig) replaced the file read/write
    system with the ‘qs’ library.
-   [traversc](https://github.com/traversc) introduced the functional
    API to `stash()`.
-   [torfason](https://github.com/torfason) upgraded R environment
    management enabling stashing in functions and linking functions as
    dependencies to a stashed object. He also created `stash_script()`.

### Attribution

The inspiration for this package came from the `cache()` feature in the
[‘ProjectTemplate’](http://projecttemplate.net/index.html) package.
While the functionality and implementation are a bit different, this
would have been far more difficult to do without referencing the source
code from ‘ProjectTemplate’.

------------------------------------------------------------------------

### Contact

Any issues and feedback on ‘mustashe’ can be submitted
[here](https://github.com/jhrcook/mustashe/issues). Alternatively, I can
be reached through the contact form on my
[website](https://joshuacook.netlify.app) or on Twitter
[@JoshDoesa](https://twitter.com/JoshDoesa)
