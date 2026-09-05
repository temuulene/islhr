# Table styling is a central feature and was previously untested.

sample_counts <- function() {
  data.frame(
    program = c("Primary care", "Mental health", "Public health"),
    encounters = c(326L, 184L, 79L),
    stringsAsFactors = FALSE
  )
}

# BC Sans is not installed on CI runners, so the webfont builder warns. That
# is expected and separately tested; it must not fail these.
quietly <- function(expr) suppressWarnings(suppressMessages(expr))

test_that("islh_flextable styles a data frame and keeps its content", {
  skip_if_not_installed("flextable")
  skip_if_not_installed("officer")

  ft <- quietly(islh_flextable(sample_counts()))
  expect_s3_class(ft, "flextable")
  expect_equal(flextable::nrow_part(ft, "body"), 3L)
  expect_equal(flextable::ncol_keys(ft), 2L)
})

test_that("flextable column widths are fixed and sum to the text width", {
  skip_if_not_installed("flextable")
  skip_if_not_installed("officer")

  # An autofit table is sized by whichever program opens it, so Word and
  # LibreOffice lay the same file out differently. The widths are resolved
  # here instead and written into the document.
  ft <- quietly(islh_flextable(sample_counts()))
  widths <- dim(ft)$widths
  expect_length(widths, 2L)
  expect_true(all(widths > 0))
  expect_equal(sum(widths), islhr:::.islh_text_width, tolerance = 1e-6)

  half <- quietly(islh_flextable(sample_counts(), width = 0.5))
  expect_equal(
    sum(dim(half)$widths),
    islhr:::.islh_text_width / 2,
    tolerance = 1e-6
  )

  # Without autofit every column gets an equal share.
  equal <- quietly(islh_flextable(sample_counts(), autofit = FALSE))
  shares <- dim(equal)$widths
  expect_equal(unname(shares[1]), unname(shares[2]), tolerance = 1e-9)
})

test_that("islh_flextable accepts an existing flextable and a caption", {
  skip_if_not_installed("flextable")
  skip_if_not_installed("officer")

  ft <- quietly(islh_flextable(
    flextable::flextable(sample_counts()),
    caption = "Encounters by programme"
  ))
  expect_s3_class(ft, "flextable")
})

test_that("islh_flextable copes with awkward tables", {
  skip_if_not_installed("flextable")
  skip_if_not_installed("officer")

  # One column.
  one <- quietly(islh_flextable(data.frame(x = 1:3)))
  expect_equal(flextable::ncol_keys(one), 1L)
  expect_equal(sum(dim(one)$widths), islhr:::.islh_text_width,
               tolerance = 1e-6)

  # No rows: a table of nothing is still a table, not an error.
  empty <- quietly(islh_flextable(sample_counts()[0, ]))
  expect_s3_class(empty, "flextable")
  expect_equal(flextable::nrow_part(empty, "body"), 0L)

  # Many rows and many columns.
  wide <- as.data.frame(matrix(1:120, nrow = 20))
  big <- quietly(islh_flextable(wide))
  expect_equal(flextable::ncol_keys(big), 6L)
  expect_equal(sum(dim(big)$widths), islhr:::.islh_text_width,
               tolerance = 1e-6)
})

test_that("islh_gt styles a data frame and renders", {
  skip_if_not_installed("gt")

  tbl <- quietly(islh_gt(sample_counts()))
  expect_s3_class(tbl, "gt_tbl")

  html <- quietly(gt::as_raw_html(tbl))
  expect_true(grepl("Primary care", html, fixed = TRUE))
  expect_true(grepl("326", html, fixed = TRUE))
})

test_that("islh_gt titles and source notes appear in the output", {
  skip_if_not_installed("gt")

  html <- quietly(gt::as_raw_html(islh_gt(
    sample_counts(),
    title = "Encounters",
    subtitle = "By programme",
    source_note = "Source: simulated data"
  )))

  expect_true(grepl("Encounters", html, fixed = TRUE))
  expect_true(grepl("By programme", html, fixed = TRUE))
  expect_true(grepl("Source: simulated data", html, fixed = TRUE))
})

test_that("islh_gt copes with awkward tables", {
  skip_if_not_installed("gt")

  expect_s3_class(quietly(islh_gt(data.frame(x = 1:3))), "gt_tbl")
  expect_s3_class(quietly(islh_gt(sample_counts()[0, ])), "gt_tbl")
  expect_s3_class(
    quietly(islh_gt(as.data.frame(matrix(1:120, nrow = 20)))), "gt_tbl"
  )
})

gtsummary_example <- function() {
  data <- data.frame(
    group = rep(c("a", "b"), each = 10),
    value = as.numeric(1:20)
  )
  quietly(gtsummary::tbl_summary(data, by = "group"))
}

test_that("the gtsummary gt converter produces a gt table", {
  skip_if_not_installed("gtsummary")
  skip_if_not_installed("gt")

  expect_s3_class(quietly(islh_gtsummary_gt(gtsummary_example())), "gt_tbl")
})

test_that("the gtsummary flextable converter produces a flextable", {
  skip_if_not_installed("gtsummary")
  # The package itself needs flextable 0.9.10, but this path runs through
  # gtsummary::as_flex_table(), which raised its own floor to 0.9.11 after
  # that. Gate on gtsummary's floor rather than lifting the package's.
  skip_if_not_installed("flextable", "0.9.11")

  expect_s3_class(
    quietly(islh_gtsummary_flex(gtsummary_example())), "flextable"
  )
})

test_that("both table engines use the same brand colours", {
  skip_if_not_installed("gt")
  skip_if_not_installed("flextable")

  # The header band and its text come from the brand ramp in both engines, so
  # an HTML report and a Word report of the same table look like siblings.
  html <- quietly(gt::as_raw_html(islh_gt(sample_counts())))
  band <- tolower(islh_hex("blue", 20))
  expect_true(grepl(band, tolower(html), fixed = TRUE))
})
