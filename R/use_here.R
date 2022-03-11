#' Use the 'here' package when writing stashes to file (deprecated)
#'
#' Sets an option that tells \code{stash()} to write the stashed objects to a
#' path created using the \code{here::here()} function from the
#' \href{https://here.r-lib.org}{'here'} package: "The 'here' package creates
#' paths relative to the top-level directory." It is particularly useful when
#' using an RStudio project.
#'
#' Add \code{mustashe::use_here(silent = TRUE)} to your '.Rprofile' or
#' \code{setup} code block in an R Markdown to set this feature automatically in
#' the future.
#'
#' @param silent A logical to silence the message from the function. (default
#'   \code{FALSE})
#'
#' @return Returns \code{NULL} (invisibly).
#'
#' @note This function has been deprecated and the use of the 'here' function
#'   should instead be set using \code{config_mustashe(use_here = TRUE)}.
#'
#' @examples
#' use_here()
#' @export use_here
use_here <- function(silent = FALSE) {
  option_name <- "mustashe.here"
  set_use_here(TRUE)
  if (!silent) {
    msg <- list(
      paste0("The global option \"", option_name, "\" has been set `TRUE`."),
      "Add `mustashe::use_here(silent = TRUE)` to you're '.Rprofile'",
      "  to have it set automatically in the future."
    )
    message(paste(msg, collapse = "\n"))
  }
  use_here_deprecation_warning()
  invisible(NULL)
}


#' Stop using the 'here' package when writing stashes to file (deprecated)
#'
#' Stop using the \code{here::here()} function from the
#' \href{https://here.r-lib.org}{'here'} package to create the file paths for
#' stashed objects.
#'
#' @param silent A logical to silence the message from the function. (default
#'   \code{FALSE})
#'
#' @return Returns \code{NULL} (invisibly).
#'
#' @note This function has been deprecated and the use of the 'here' function
#'   should instead be set using \code{config_mustashe(use_here = FALSE)}.
#'
#' @examples
#' dont_use_here()
#' @export dont_use_here
dont_use_here <- function(silent = FALSE) {
  set_use_here(FALSE)
  if (!silent) {
    message("No longer using `here::here()` for creating stash file paths.")
  }
  use_here_deprecation_warning()
  invisible(NULL)
}

use_here_deprecation_warning <- function(use_here) {
  msg <- paste(
    "This function is deprecated.",
    "Use `config_mustashe(use_here = TRUE/FALSE` instead."
  )
  warning(msg)
}


set_use_here <- function(val) {
  config_mustashe(use_here = val)
}
