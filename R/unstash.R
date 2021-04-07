#' Unstash an object
#'
#' Remove an object from the stash.
#'
#' @param var The name or a vector of names of objects to remove.
#' @param verbose Whether to print action statements (default TRUE).
#'
#' @return Returns \code{NULL} (invisibly).
#'
#' @examples
#' \donttest{
#' stash("x", {
#'   x <- 1
#' })
#'
#' unstash("x")
#'
#' #' # Remove directory for this example - do not do in real use.
#' unlink(".mustashe", recursive = TRUE)
#' }
#'
#' @export unstash
unstash <- function(var, verbose = TRUE) {
  f <- function(v) {
    if (has_been_stashed(v)) {
      if (verbose) { message(paste0("Unstashing '", v, "'.")) }
      file.remove(unlist(stash_filename(v)))
    } else {
      if (verbose) { message(paste0("No object '", v, "' in stash.")) }
    }
  }
  lapply(var, f)
  invisible(NULL)
}
