# 'mustashe' 0.1.5

June 12, 2022

## Test environments

Developed on: macOS Monterey 12.4 (x86_64-apple-darwin17.0 (64-bit)), R 4.2.0

CI on GitHub Actions:

- macOS Catalina 10.15.7 (x86_64), R versions
    - 4.2.0
- macOS Big Sur 11.6.4 (x86_64), R versions
    - 4.2.0
- Ubuntu 20.04.4 LTS (x86_64), R versions:
    - 4.0.5
    - 4.1.3
    - 4.2.0
- Microsoft Windows Server 2022 (build 20348, 10.0.20348), R versions:
    - 4.0.5
    - 4.1.3
    - 4.2.0

## `R CMD check --as-cran` results

There were no NOTEs, ERRORs, nor WARNINGs

## Changes

This update brings several new features to 'mustashe':

- Functions can now be listed as dependencies.
- The results of sourcing a R script can be stashed.
- Improved (fixed) management of environments when assigning evaluation results to variables or searching for dependencies.
- Configuration system for using the 'here' package and default values for `verbose` and `functional` arguments in stashing functions. (Deprecation of `use_here()` and `dont_use_here()`.)
- Updated documentation and vignettes with the new features.
