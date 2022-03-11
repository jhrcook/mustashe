#' Source script and stash result
#'
#' @description
#' Source a R script, only if the result has not already been stashed. The final
#' expression in the script is treated as the return value from the script (as
#' per the functionality of \code{source()}, and this value is returned and
#' stashed (using \code{stash()} as the underlying caching mechanism).
#'
#' @param script_path Path (absolute or relative) to the script to source.
#' @param depends_on A vector of other objects that this one depends on. Changes
#'   to these objects will cause the re-running of the code next time.
#' @param verbose Whether to print action statements (default TRUE).
#'
#' @return The last line in the script referred to by the script at
#'   \code{script_path} is treated as a return value, and is returned and
#'   cached.
#'
#' @details
#' This function always calls \code{stash()} in functional mode.
#'
#' Note that the stashed result is keyed according to the specified path to the
#' script without any canonization. The function will therefore not realize that
#' an absolute and relative path refer to the same file, and treat them as two
#' separate results to cache.
#'
#' The time of modification is also included in the key of the results so any
#' modification to the file will result in the script being re-run on the next
#' call.
#'
#' @examples
#' script_name <- tempfile()
#' set.seed(42)
#' write("sample(letters,5)", script_name)
#' x <- stash_script(script_name) # will be cached
#' print(x)
#' x <- stash_script(script_name) # will use cached data
#' print(x)
#' @export
stash_script <- function(script_path, depends_on = NULL, verbose = NULL) {
  if (is.null(verbose)) verbose <- mustashe_verbose()

  # check input
  if (check_script_path(script_path)) {
    stop("Script name invalid or missing")
  }

  # Make the hash table based on the `depends_on` variables in the parent
  # environment. By passing that hash table as a `depends_on` variable in the
  # call to `stash()`, the cache correctly depends on any changes in those vars
  # in the `parent.frame()`.
  other_deps <- make_hash_table(
    "__dummy_code__",
    depends_on,
    target_env = parent.frame()
  )

  # The stash depends_on `mtime` and contents of `script_path`.
  script_key <- list("stash_script()", script_path)
  script_deps <- list(
    file.mtime(script_path),
    digest::digest(script_path, file = TRUE)
  )

  # Use stash to source the script, and return the result
  stash(script_key,
    {
      source(file = script_path, local = TRUE)$value
    },
    depends_on = c("script_deps", "other_deps"),
    functional = TRUE,
    verbose = verbose
  )
}

check_script_path <- function(p) {
  is.null(p) || length(p) != 1 || !utils::file_test("-f", p)
}
