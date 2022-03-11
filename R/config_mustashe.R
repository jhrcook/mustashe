#' Configure default options for 'mustashe'
#'
#' Sets options that affect the behavior of 'mustashe' or the default values for
#' stashing arguments. This function can be added to a .Rprofile to set the
#' defaults for 'mustashe' in a project.
#'
#' @param use_here Use the 'here' package when writing stashes to file. The
#'   default behavior is to not use 'here.'
#' @param verbose The default value of \code{verbose} arguments when stashing or
#'   unstashing. The default behavior is \code{verbose = TRUE}.
#' @param functional The default value of \code{functional} arguments when
#'   stashing. The default behavior is \code{functional = FALSE}.
#'
#' @note Providing no value for any of the arguments results in no value being
#'   set. Therefore, \code{config_mustashe()} can be called with different
#'   arguments without over-writing previously set options.
#'
#' @export config_mustashe
config_mustashe <- function(use_here, verbose, functional) {
  if (!missing(use_here)) {
    options("mustashe.use_here" = use_here)
  }
  if (!missing(verbose)) {
    options("mustashe.verbose" = verbose)
  }
  if (!missing(functional)) {
    options("mustashe.functional" = functional)
  }
  invisible(NULL)
}


mustashe_use_here <- function() {
  res <- getOption("mustashe.use_here")
  if (!is.null(res)) {
    return(res)
  }
  return(FALSE)
}

mustashe_verbose <- function() {
  res <- getOption("mustashe.verbose")
  if (!is.null(res)) {
    return(res)
  }
  return(TRUE)
}

mustashe_functional <- function() {
  res <- getOption("mustashe.functional")
  if (!is.null(res)) {
    return(res)
  }
  return(FALSE)
}
