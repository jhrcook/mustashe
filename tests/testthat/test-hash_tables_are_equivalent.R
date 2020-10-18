test_that("Hash tables are properly compared", {
  expect_true(hash_tables_are_equivalent(data.frame(), data.frame()))

  expect_true(hash_tables_are_equivalent(
    data.frame(a = c(1, 2, 3, 4)),
    data.frame(a = c(1, 2, 3, 4))
  ))

  expect_true(hash_tables_are_equivalent(
    data.frame(a = as.character(c(1, 2, 3, 4))),
    data.frame(a = as.character(c(1, 2, 3, 4)))
  ))

  expect_false(hash_tables_are_equivalent(
    data.frame(a = c(1, 2, 3, 4)),
    data.frame(a = as.character(c(1, 2, 3, 4)))
  ))

  expect_false(hash_tables_are_equivalent(
    data.frame(a = c(1, 2, 3)),
    data.frame(a = c(1, 2, 3, 4))
  ))

  expect_false(hash_tables_are_equivalent(
    data.frame(a = c(1, 2, 3, 4)),
    data.frame(b = c(1, 2, 3, 4))
  ))

  expect_false(hash_tables_are_equivalent(
    NA,
    data.frame(b = c(1, 2, 3, 4))
  ))

  expect_false(hash_tables_are_equivalent(
    NA_character_,
    data.frame(b = c(1, 2, 3, 4))
  ))

  expect_true(hash_tables_are_equivalent(
    NA_character_,
    NA_character_
  ))

  expect_true(hash_tables_are_equivalent(
    data.frame(a = c(1, 2, 3, 4), b = c(5, 6, 7, 8)),
    data.frame(a = c(1, 2, 3, 4), b = c(5, 6, 7, 8))
  ))


  expect_false(hash_tables_are_equivalent(
    data.frame(a = c(1, 2, 3), b = c(1, 2, 3)),
    data.frame(a = c(1, 2, 3, 4), b = c(1, 2, 3, 4))
  ))

  expect_false(hash_tables_are_equivalent(
    data.frame(b = c(5, 6, 7, 8), a = c(1, 2, 3, 4)),
    data.frame(a = c(1, 2, 3, 4), b = c(5, 6, 7, 8))
  ))
})
