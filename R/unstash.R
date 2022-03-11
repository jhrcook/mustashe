#' Unstash an object
#'
#' Remove one or more objects from the stash.
#'
#' @param var The name or a vector of names of objects to remove.
#' @param single_var Specifies a single name (key) to remove. Use this
#'   when the object was stashed using an arbitrary object as the key.
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
#' stash(list(letters, cars), { 7 }, functional = TRUE)  # styler: off
#' unstash(single_var = list(letters, cars))
#'
#' #' # Remove directory for this example - do not do in real use.
#' unlink(".mustashe", recursive = TRUE)
#' }
#'
#' @export unstash
unstash <- function(var, single_var, verbose = NULL) {
  if (is.null(verbose)) verbose <- mustashe_verbose()
  f <- function(v) {
    v <- validate_var(v, functional = TRUE)
    if (has_been_stashed(v)) {
      if (verbose) {
        message(paste0("Unstashing '", v, "'."))
      }
      file.remove(unlist(stash_filename(v)))
    } else {
      if (verbose) {
        message(paste0("No object '", v, "' in stash."))
      }
    }
  }
  if (!missing(var)) {
    lapply(var, f)
  }
  if (!missing(single_var)) {
    f(single_var)
  }
  if (missing(var) && missing(single_var)) {
    stop("all var arguments are missing, nothing to unstash")
  }
  invisible(NULL)
}
