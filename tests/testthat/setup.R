
# Check any possible locations for the stash dir
stash_dirs <- c(".mustashe", here::here(".mustashe"))

if (any(file.exists(stash_dirs))) {

  # If a pre-existing stash directory is found, we want to abort the tests,
  # because they would change and then destroy potentially valuable stashes
  found_dirs <- paste0(stash_dirs[file.exists(stash_dirs)], "\n")
  stop(paste0("Aborting tests because a pre-existing stash directory was found:\n     ",
              found_dirs,
              "  Please delete it and try again"))

} else {

  # Proceed with the tests, but first register the deferred deletion of the
  # stash directory, which will be executed after all the tests are run
  withr::defer(unlink(stash_dirs, recursive=TRUE), teardown_env())

}
