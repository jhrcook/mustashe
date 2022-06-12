# mustashe 0.1.5

- Functions can now be listed as dependencies (@torfason).
- The results of sourcing a R script can be stashed (@torfason).
- Improved (fixed) management of environments when assigning evaluation results to variables or searching for dependencies (@torfason).
- Configuration system for using the 'here' package and default values for `verbose` and `functional` arguments in stashing functions. (Deprecation of `use_here()` and `dont_use_here()`.)
- Updated documentation and vignettes with the new features.

# mustashe 0.1.4

- Functional and verbose parameters in the 'stash()' function (@traversc).
- Minor fixes for CRAN package checking process.
- Tooling changes to add [pre-commit](https://pre-commit.com) and ['renv'](https://CRAN.R-project.org/package=renv) and remove AppVeyor and Travis CI (only using GitHub Actions, now).
- Add code coverage report CI as a GitHub Action (based on implementation by ['ggplot2'](https://github.com/tidyverse/ggplot2/blob/master/.github/workflows/test-coverage.yaml))

# mustashe 0.1.3

- An error is raised if the '.mustashe' directory cannot be created (#9).
- Add an option to use the ['here'](https://CRAN.R-project.org/package=here) package for creating file paths for stashed objects.
- Minor fixes for CRAN package checking process.

# mustashe 0.1.2

- Jimmy changed the reading and writing system from the base R RDS system to using the ['qs: Quick Serialization of R Objects'](https://CRAN.R-project.org/package=qs) package for faster reading and writing.
- Vinay and I fixed a bug that was causing the tests to fail on macOS 10.12 or older.

# mustashe 0.1.1

- A minor release with not functional changes, only changes to documentation.
- Two vignettes were added to help getting started with 'mustashe' and explain how it works.

# mustashe 0.1.0

- The first release of 'mustashe.'
