#' Clear the stash
#'
#' Clears the hidden '.mustashe' directory.
#'
#' @param verbose Whether to print action statements (default TRUE).
#'
#' @return Returns \code{NULL} (invisibly).
#'
#' @examples
#' clear_stash()
#' @export clear_stash
clear_stash <- function(verbose = NULL) {
  if (is.null(verbose)) verbose <- mustashe_verbose()
  if (verbose) {
    message("Clearing stash.")
  }
  file.remove(c(
    list.files(get_stash_dir(), full.names = TRUE, pattern = "qs$"),
    list.files(get_stash_dir(), full.names = TRUE, pattern = "hash$")
  ))
  invisible(NULL)
}
