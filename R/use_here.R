#' Use the 'here' package when writing stashes to file
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
  invisible(NULL)
}


#' Stop using the 'here' package when writing stashes to file
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
#' @examples
#' dont_use_here()
#' @export dont_use_here
dont_use_here <- function(silent = FALSE) {
  set_use_here(FALSE)
  if (!silent) {
    message("No longer using `here::here()` for creating stash file paths.")
  }
  invisible(NULL)
}


set_use_here <- function(val) {
  options("mustashe.here" = val)
}
