# mustashe

## Resubmission

This is a resubmission. I have addressed the following comments from the first attempt:

1. I omitted the redundant "in R" from the title.
2. I added "\value" to the documentation of each function.
3. I replaced the "\dontrun{}" statements with "\donttest{}" in the examples for some of the functions.

I was unable to address the final comment: "Please do not modifiy the .GlobalEnv. This is not allowed by the CRAN policies." I am unable to address this because the purpose of the 'mustashe' project is to load stashed values into the global environment. This functionality is very simillar (in fact, derived from) the `cache()` function in 'ProjectTemplate'. In a personal correspondence with the maintainer of 'ProjectTemplate', I found out that they were gradnfathered in when this policy was created. I am hoping an exception can be made for 'mustashe', too.

I have also added two vignettes to the package to explain how to use it and how it works.


## Test environments

* local macOS Catalina v10.15.2
    - R version 3.6.1 (2019-07-05)
* Ubuntu 16.04.6 LTS
    - R version 3.6.2 (2017-01-27)
* Windows Server 2012 R2 x64 (build 9600)
    - R version 3.6.3 Patched (2020-03-11 r78011)


## R CMD check results

There were no ERRORs,  WARNINGs, or NOTES
