#' Stash an object
#'
#' Stash an object after the first time is is created and re-load it the next
#' time. If the code that generates the object is changed or any of its
#' dependencies change, the code is re-evaluated and the new object is stashed.
#'
#' @param var A variable to stash (as a string).
#' @param code The code to generate the object to be stashed.
#' @param depends_on A vector of other objects that this one depends on. Changes
#'   to these objects will cause the re-running of the code, next time.
#' @param functional If TRUE, return the object rather than setting in the
#'   global environment (default FALSE).
#' @param verbose Whether to print action statements (default TRUE).
#'
#' @return Returns \code{NULL} (invisibly).
#'
#' @examples
#' \donttest{
#' # A value that is used to create `rnd_vals`.
#' x <<- 1e6 # The `<<-` is not normally required, just for this example.
#'
#' # Stash the results of the comuption of `rnd_vals`.
#' stash("rnd_vals", depends_on = "x", {
#'   # Some long running computation.
#'   rnd_vals <- rnorm(x)
#' })
#'
#' # Remove directory for this example - do not do in real use.
#' unlink(".mustashe", recursive = TRUE)
#' }
#'
#' @export stash
stash <- function(var, code, depends_on = NULL, functional = FALSE, verbose = TRUE) {
  check_stash_dir()

  deparsed_code <- deparse(substitute(code))
  formatted_code <- format_code(deparsed_code)

  if (is.null(var)) stop("`var` cannot be NULL")
  if (formatted_code == "NULL") stop("`code` cannot be NULL")

  # The environment where all code is evaluated and variables assigned.
  target_env <- parent.frame()
  new_hash_tbl <- make_hash_table(formatted_code, depends_on, target_env)

  # if the variable has been stashed:
  #     if the hash tables are equivalent:
  #         load the stored variable
  #     else:
  #         make a new stash
  # else:
  #     make a new stash
  if (has_been_stashed(var)) {
    old_hash_tbl <- get_hash_table(var)
    if (hash_tables_are_equivalent(old_hash_tbl, new_hash_tbl)) {
      if (verbose) {
        message("Loading stashed object.")
      }
      res <- load_variable(var, functional, target_env)
    } else {
      if (verbose) {
        message("Updating stash.")
      }
      res <- new_stash(
        var, formatted_code, new_hash_tbl, functional, target_env
      )
    }
  } else {
    if (verbose) {
      message("Stashing object.")
    }
    res <- new_stash(var, formatted_code, new_hash_tbl, functional, target_env)
  }

  invisible(res)
}

# Make a new stash from a variable, code, and hash table.
new_stash <- function(var, code, hash_tbl, functional, target_env) {
  val <- evaluate_code(code, target_env)
  write_hash_table(var, hash_tbl)
  write_val(var, val)
  if (functional) {
    return(val)
  } else {
    assign_value(var, val, target_env = target_env)
    return(NULL)
  }
}


# Format the code.
format_code <- function(code) {
  fmt_code <- formatR::tidy_source(
    text = code,
    comment = FALSE,
    blank = FALSE,
    arrow = TRUE,
    brace.newline = FALSE,
    indent = 4,
    wrap = TRUE,
    output = FALSE,
    width.cutoff = 80
  )$text.tidy
  paste(fmt_code, sep = "", collapse = "\n")
}


# Make a hash table for code and any variables in the dependencies.
make_hash_table <- function(code, depends_on, target_env) {
  code_hash <- make_hash("code", environment())
  depends_on <- sort(depends_on)
  dependency_hashes <- make_hash(depends_on, target_env)
  tibble::tibble(
    name = c("CODE", depends_on),
    hash = c(code_hash, dependency_hashes)
  )
}


# Make hash of an object.
make_hash <- function(vars, target_env) {
  if (is.null(vars)) {
    return(NULL)
  }

  missing <- !unlist(lapply(vars, exists, envir = target_env))
  if (any(missing)) {
    stop("Some dependencies are missing from the environment.")
  }

  hashes <- c()
  for (var in vars) {
    obj <- get(var, envir = target_env)
    if (is.function(obj) & !is.primitive(obj)) {
      # For functions, deparse before digesting
      obj <- deparse(obj)
    }
    hashes <- c(hashes, digest::digest(obj))
  }

  return(hashes)
}


# Are the two hash tables equivalent?
hash_tables_are_equivalent <- function(tbl1, tbl2) {
  isTRUE(all.equal(tbl1, tbl2, check.attributes = TRUE, use.names = TRUE))
}


# Has the `var` been stashed before?
has_been_stashed <- function(var) {
  paths <- stash_filename(var)
  isTRUE(all(unlist(lapply(paths, file.exists))))
}


# Retrieve the hash table as a `tibble`.
get_hash_table <- function(var) {
  dat <- qs::qread(stash_filename(var)$hash_name)
  dat <- tibble::as_tibble(dat)
  return(dat)
}


# Write the hash table to file.
write_hash_table <- function(var, tbl) {
  qs::qsave(tbl, stash_filename(var)$hash_name)
}


# Write the value to disk.
write_val <- function(var, val) {
  path <- stash_filename(var)$data_name
  qs::qsave(val, path)
}


# Load in a variable from disk and assign it to the target environment.
load_variable <- function(var, functional, target_env) {
  path <- stash_filename(var)$data_name
  val <- qs::qread(path)
  if (functional) {
    return(val)
  } else {
    assign_value(var, val, target_env)
    return(NULL)
  }
}


# Evaluate the code in a new child environment of the target environment.
# Creating a new child environment isolates the code and prevents
# inadvertent assignment from polluting the target environment.
evaluate_code <- function(code, target_env) {
  eval(parse(text = code), envir = new.env(parent = target_env))
}


# Assign the value `val` to the variable `var` in the target environment.
assign_value <- function(var, val, target_env) {
  assign(var, val, envir = target_env)
}


# Get the file names for staching
stash_filename <- function(var) {
  stash_dir <- get_stash_dir()
  return(list(
    data_name = file.path(stash_dir, paste0(var, ".qs")),
    hash_name = file.path(stash_dir, paste0(var, ".hash"))
  ))
}


check_stash_dir <- function() {
  stash_dir <- get_stash_dir()
  if (!dir.exists(stash_dir)) {
    tryCatch(
      dir.create(stash_dir, showWarnings = TRUE, recursive = TRUE),
      warning = stash_dir_warning
    )
  }
  invisible(NULL)
}

stash_dir_warning <- function(w) {
  warning(w)
  # if (grep("cannot create dir", w) > 0 & grep("Permission denied", w) > 0) {
  if (TRUE) {
    stop_msg1 <- "
'mustashe' is unable to create a directory to stash your objects.
Please create the directory manually using:"

    stop_msg2 <- paste0("\n  dir.create(", get_stash_dir(), ")")

    stop_msg3 <- paste0(
      "If that does not work, please create the directory ",
      "from the command line and open an issue at: ",
      "https://github.com/jhrcook/mustashe"
    )

    stop_msg <- paste(stop_msg1, stop_msg2, stop_msg3, sep = "\n")
    stop(stop_msg)
  }
}


get_stash_dir <- function() {
  stash_dir <- ".mustashe"

  use_here_option <- getOption("mustashe.here")
  if (!is.null(use_here_option)) {
    if (use_here_option == TRUE) {
      return(here::here(stash_dir))
    }
  }
  return(stash_dir)
}
