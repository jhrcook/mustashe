#' Clear the stash
#'
#' Clears the hidden '.stashR' directory
clear_stash <- function() {
    message("Clearing stash.")
    file.remove(c(
        list.files(.stash_dir, full.names = TRUE, pattern = "rds$"),
        list.files(.stash_dir, full.names = TRUE, pattern = "hash$")
    ))
    invisible(NULL)
}
