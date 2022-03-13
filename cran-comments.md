# 'mustashe' 0.1.5

March 13, 2022

## Test environments

Developed on: macOS Monterey 12.2.1, R 4.1.2

CI on GitHub Actions:

- macOS 11.6.4 (64-bit), R 4.2.0
- macOS 11.6.4 (64-bit), R 3.6.3
- Ubuntu 16.04, R 3.5.3
- Ubuntu 16.04, R 3.6.3
- Ubuntu 16.04, R 4.0.5
- Microsoft Windows Server 2022, 10.0.20348, R 3.6
- Microsoft Windows Server 2022, 10.0.20348, R 4.0

## `R CMD check --as-cran` results

There were no NOTEs, ERRORs, nor WARNINGs

## Changes

This update brings several new features to 'mustashe':

- Functions can now be listed as dependencies.
- The results of sourcing a R script can be stashed.
- Improved (fixed) management of environments when assigning evaluation results to variables or searching for dependencies.
- Configuration system for using the 'here' package and default values for `verbose` and `functional` arguments in stashing functions. (Deprecation of `use_here()` and `dont_use_here()`.)
- Updated documentation and vignettes with the new features.
