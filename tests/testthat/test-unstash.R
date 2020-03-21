test_that("unstashing works", {
    expect_null(stash("a", { a <- 1 }))

    expect_true(has_been_stashed("a"))

    expect_null(unstash("a"))

    expect_false(has_been_stashed("a"))

    expect_null(stash("b", { b <- 2 }))
    expect_null(stash("c", { c <- 2 }))

    expect_true(has_been_stashed("b"))
    expect_true(has_been_stashed("c"))

    expect_message(unstash("a"), "No object 'a'")
    expect_message(unstash("b"), "Unstashing 'b'")

    expect_false(has_been_stashed("b"))
    expect_true(has_been_stashed("c"))

    if (dir.exists(".mustashe")) unlink(".mustashe", recursive = TRUE)
})
