test_that("islh_suppress_table hides small cells in the named columns only", {
  counts <- data.frame(
    area = c("North", "Central", "South"),
    cases = c(3, 42, 17),
    contacts = c(1, 55, 4)
  )

  out <- islh_suppress_table(counts, c("cases", "contacts"), threshold = 5)

  expect_true(is.na(out$cases[1]))
  expect_equal(out$cases[2:3], c(42, 17))
  expect_true(all(is.na(out$contacts[c(1, 3)])))
  expect_equal(out$contacts[2], 55)

  # Untouched columns keep their values and their type.
  expect_equal(out$area, counts$area)
})

test_that("a threshold must be supplied", {
  counts <- data.frame(cases = c(1, 20))
  expect_error(islh_suppress_table(counts, "cases"), "must be supplied")
})

test_that("zero is not a small cell", {
  # A zero is a real, publishable finding: nobody had the thing. Suppressing it
  # would hide information without protecting anyone.
  out <- islh_suppress_table(
    data.frame(cases = c(0, 3, 9)), "cases", threshold = 5
  )
  expect_equal(out$cases[1], 0)
  expect_true(is.na(out$cases[2]))
  expect_equal(out$cases[3], 9)
})

test_that("inclusive controls whether the threshold itself is suppressed", {
  counts <- data.frame(cases = c(4, 5, 6))

  inclusive <- islh_suppress_table(counts, "cases", threshold = 5)
  expect_equal(is.na(inclusive$cases), c(TRUE, TRUE, FALSE))

  exclusive <- islh_suppress_table(
    counts, "cases", threshold = 5, inclusive = FALSE
  )
  expect_equal(is.na(exclusive$cases), c(TRUE, FALSE, FALSE))
})

test_that("complementary suppression hides a second cell when one is recoverable", {
  # With a total in view, a single suppressed cell is recoverable by
  # subtraction, so a second must go.
  counts <- data.frame(cases = c(3, 42, 17))

  plain <- islh_suppress_table(counts, "cases", threshold = 5)
  expect_equal(sum(is.na(plain$cases)), 1L)

  complementary <- islh_suppress_table(
    counts, "cases", threshold = 5, complementary = TRUE
  )
  expect_equal(sum(is.na(complementary$cases)), 2L)
  # The smallest survivor is the one that goes.
  expect_true(is.na(complementary$cases[3]))
  expect_equal(complementary$cases[2], 42)
})

test_that("complementary suppression does nothing when the sum is already safe", {
  # Two cells already suppressed cannot be recovered by subtraction, so no
  # third cell should be hidden.
  counts <- data.frame(cases = c(3, 42, 2))
  out <- islh_suppress_table(
    counts, "cases", threshold = 5, complementary = TRUE
  )
  expect_equal(sum(is.na(out$cases)), 2L)
  expect_equal(out$cases[2], 42)

  # And nothing suppressed means nothing to protect.
  safe <- data.frame(cases = c(30, 42, 17))
  untouched <- islh_suppress_table(
    safe, "cases", threshold = 5, complementary = TRUE
  )
  expect_equal(untouched$cases, safe$cases)
})

test_that("a label turns the column into readable text", {
  out <- islh_suppress_table(
    data.frame(cases = c(3, 42)), "cases", threshold = 5, label = "<5"
  )
  expect_type(out$cases, "character")
  expect_equal(out$cases, c("<5", "42"))
})

test_that("unknown columns are named in the error", {
  expect_error(
    islh_suppress_table(data.frame(a = 1), "nope", threshold = 5),
    "nope"
  )
})

test_that("nearest rounding goes to the closest multiple of the base", {
  expect_equal(islh_round_base(c(0, 2, 3, 7, 12, 43), base = 5),
               c(0, 0, 5, 5, 10, 45))
  expect_equal(islh_round_base(c(4, 6, 14, 15), base = 10),
               c(0, 10, 10, 20))
  expect_true(is.na(islh_round_base(NA_real_)))
})

test_that("random rounding lands on a neighbouring multiple and is unbiased", {
  withr::local_seed(42)

  x <- rep(12, 4000)
  rounded <- islh_round_base(x, base = 5, method = "random")

  # Every value must be one of the two neighbouring multiples.
  expect_setequal(unique(rounded), c(10, 15))

  # 12 sits 2/5 of the way from 10 to 15, so it should round up about 40% of
  # the time and the mean should come back to 12.
  expect_equal(mean(rounded == 15), 0.4, tolerance = 0.05)
  expect_equal(mean(rounded), 12, tolerance = 0.15)

  # An exact multiple never moves.
  expect_equal(islh_round_base(rep(10, 50), base = 5, method = "random"),
               rep(10, 50))
})

test_that("islh_round_base rejects a nonsensical base", {
  expect_error(islh_round_base(1:5, base = 0), "positive")
  expect_error(islh_round_base("a"), "must be numeric")
})
