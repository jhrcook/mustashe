# styler: off
test_that("non-string var names work if functional is specified", {
  # using NULL as var always results in an error
  expect_error(stash(NULL, {1}))
  expect_error(stash(NULL, {1}, functional=TRUE))

  # in regular use, good variable names should be accepted and bad ones rejected
  expect_null(stash("good_var_name",  {1}))
  expect_error(stash("bad-var-name",  {1}))
  expect_error(stash("bad/file/name", {1}))
  expect_error(stash(c("s_1", "s_2"), {1}))
  expect_error(stash(list(letters, cars), {1}))

  # in functional use, arbitrary objects should be accepted as names/keys
  expect_equal(stash("good_var_name", {1}, functional=TRUE), 1)
  expect_equal(stash("bad-var-name",  {1}, functional=TRUE), 1)
  expect_equal(stash("bad/file/name", {1}, functional=TRUE), 1)
  expect_equal(stash(c("s_1", "s_2"), {1}, functional=TRUE), 1)
  expect_equal(stash(list(letters, cars), {1}, functional=TRUE), 1)
})
# styler: on
