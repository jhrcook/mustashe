#' Unstash an object
#'
#' Remove an object from the stash.
#'
#' @param var The name or a vector of names of objects to remove.
#'
#' @return \code{NULL}
#'
#' @examples
#' \dontrun{
#' stash("x",
#' {
#'     x <- 1
#' })
#'
#' unstash("x")
#' }
#'
#' @export unstash
unstash <- function(var) {

    f <- function(v) {
        if (has_been_stashed(v)) {
            message(paste0("Unstashing '", v, "'."))
            file.remove(unlist(stash_filename(v)))
        } else {
            message(paste0("No object '", v, "' in stash."))
        }
    }
    lapply(var, f)
    invisible(NULL)
}
