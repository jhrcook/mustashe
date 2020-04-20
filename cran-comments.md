# mustashe

## Bug fix and minor version release

Brian Ripley reported that the tests for this package failed on the CRAN macOS servers.
I was unable to reproduce this on my machine running macOS 10.15.2, and it seems like this problem only occured on versions of macOS 10.12 and older.
We were able able to correct the problem without changing any of the tests or package as it was caused by how the time of last modification was reported for files written and read by the `stash()` function.

This is also a minor version release because we have switched to using the 'qs: Quick Serialization of R Objects' package for reading and writing files instead of using RDS files.


## Test environments

* local macOS Catalina v10.15.2
    - R version 3.6.1 (2019-07-05)
* Ubuntu 16.04.6 LTS
    - R version 3.6.2 (2017-01-27)
* Windows Server 2012 R2 x64 (build 9600)
    - R version 3.6.3 Patched (2020-03-11 r78011)


## R CMD check results

There were no ERRORs,  WARNINGs, or NOTES
