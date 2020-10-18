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
stash <- function(var, code, depends_on = NULL) {
  check_stash_dir()

  deparsed_code <- deparse(substitute(code))
  formatted_code <- format_code(deparsed_code)

  if (is.null(var)) stop("`var` cannot be NULL")
  if (formatted_code == "NULL") stop("`code` cannot be NULL")

  new_hash_tbl <- make_hash_table(formatted_code, depends_on)

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
      message("Loading stashed object.")
      load_variable(var)
    } else {
      message("Updating stash.")
      new_stash(var, formatted_code, new_hash_tbl)
    }
  } else {
    message("Stashing object.")
    new_stash(var, formatted_code, new_hash_tbl)
  }

  invisible(NULL)
}

# Make a new stash from a variable, code, and hash table.
new_stash <- function(var, code, hash_tbl) {
  val <- evaluate_code(code)
  assign_value(var, val)
  write_hash_table(var, hash_tbl)
  write_val(var, val)
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
make_hash_table <- function(code, depends_on) {
  code_hash <- make_hash("code", env = environment())
  depends_on <- sort(depends_on)
  dependency_hashes <- make_hash(depends_on, .TargetEnv)
  tibble::tibble(
    name = c("CODE", depends_on),
    hash = c(code_hash, dependency_hashes)
  )
}


# Make hash of an object.
make_hash <- function(vars, env) {
  if (is.null(vars)) {
    return(NULL)
  }

  missing <- !unlist(lapply(vars, exists, envir = env))
  if (any(missing)) {
    stop("Some dependencies are missing from the environment.")
  }

  hashes <- c()
  for (var in vars) {
    hashes <- c(hashes, digest::digest(get(var, envir = env)))
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


# Load in a variable from disk and assign it to the global environment.
load_variable <- function(var) {
  path <- stash_filename(var)$data_name
  val <- qs::qread(path)
  assign_value(var, val)
}


# Evaluate the code in a new environment.
evaluate_code <- function(code) {
  eval(parse(text = code), envir = new.env())
}


# Assign the value `val` to the variable `var`.
assign_value <- function(var, val) {
  assign(var, val, envir = .TargetEnv)
}


# Get the file names for staching
stash_filename <- function(var) {
  return(list(
    data_name = file.path(.stash_dir, paste0(var, ".qs")),
    hash_name = file.path(.stash_dir, paste0(var, ".hash"))
  ))
}


check_stash_dir <- function() {
  if (!dir.exists(.stash_dir)) {
    tryCatch(
      dir.create(.stash_dir, showWarnings = TRUE, recursive = TRUE),
      warning = stash_dir_warning
    )
  }
  invisible(NULL)
}

stash_dir_warning <- function(w) {
  warning(w)
  if (grep("cannot create dir", w) > 0 & grep("Permission denied", w) > 0) {
    stop_msg <- "
'mustashe' is unable to create a directory to stash your objects.
Please create the directory manually using:

  dir.create(\".mustashe\")

If that does not work, please create the directory from the command line and open an issue at:
  https://github.com/jhrcook/mustashe"
    stop(stop_msg)
  }
}


# The environment where all code is evaluated and variables assigned.
.TargetEnv <- .GlobalEnv
.stash_dir <- ".mustashe"
