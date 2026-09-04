test_that("epi curve returns a branded ggplot", {
  data <- data.frame(
    date = as.Date("2026-01-01") + 0:4,
    count = c(0, 1, 3, 2, 1)
  )
  plot <- islh_epi_curve(data, date, count, title = "Example")
  expect_s3_class(plot, "ggplot")
  expect_equal(plot$labels$title, "Example")
  expect_equal(plot$labels$y, "Cases")
})

test_that("epi curve supports fill, facets and total labels", {
  data <- expand.grid(
    date = as.Date("2026-01-01") + 0:2,
    source = c("Community", "Facility"),
    region = c("North", "South")
  )
  data$count <- rep(c(1, 2, 3), 4)
  plot <- expect_only_font_warnings(
    islh_epi_curve(
      data,
      date,
      count,
      fill = source,
      facet = region,
      labels = "total"
    )
  )
  expect_s3_class(plot, "ggplot")
  expect_true(length(plot$layers) >= 2)
  expect_s3_class(plot$facet, "FacetWrap")
})

test_that("case style expands counts into individual rectangles", {
  data <- data.frame(
    date = as.Date(c("2026-01-01", "2026-01-01", "2026-01-02")),
    count = c(2, 3, 1),
    source = c("A", "B", "A")
  )
  plot <- islh_epi_curve(data, date, count, fill = source, style = "cases")
  expect_s3_class(plot, "ggplot")
  expect_equal(nrow(plot$layers[[1]]$data), 6)
  expect_equal(sort(plot$layers[[1]]$data$.islh_case_y[1:5]), seq(0.5, 4.5, 1))
})

test_that("case style has a rendering guard", {
  data <- data.frame(date = as.Date("2026-01-01"), count = 100)
  expect_error(
    islh_epi_curve(data, date, count, style = "cases", max_cases = 10),
    "would draw"
  )
  expect_error(
    islh_epi_curve(data, date, count, style = "cases", position = "dodge"),
    "only supports"
  )
})

test_that("epi curve draws reference ribbons and lines", {
  data <- data.frame(
    period_start = as.Date("2026-01-01") + 0:4,
    count = c(1, 3, 4, 2, 1)
  )
  reference <- data.frame(
    period_start = data$period_start,
    lower_limit = rep(0, 5),
    upper_limit = rep(5, 5),
    reference_mean = rep(2.5, 5)
  )
  plot <- islh_epi_curve(
    data,
    period_start,
    count,
    reference = reference
  )
  expect_equal(length(plot$layers), 3)
  expect_s3_class(plot$layers[[1]]$geom, "GeomRibbon")
  expect_s3_class(plot$layers[[2]]$geom, "GeomLine")
})

test_that("epi curve validates columns, dates and counts", {
  data <- data.frame(date = "bad", count = 1)
  expect_error(islh_epi_curve(data, date, count), "invalid dates")

  data <- data.frame(date = as.Date("2026-01-01"), count = 1.5)
  expect_error(islh_epi_curve(data, date, count), "whole counts")
  expect_error(islh_epi_curve(data, missing, count), "not found")
  expect_error(islh_epi_curve(data, date, count, show_year_lines = NA), "TRUE or FALSE")
})

test_that("epi curve validates reference inputs", {
  data <- data.frame(date = as.Date("2026-01-01") + 0:2, count = 1:3)
  one_limit <- data.frame(date = data$date, lower_limit = 0)
  expect_error(
    islh_epi_curve(data, date, count, reference = one_limit),
    "both lower and upper"
  )

  reversed <- data.frame(
    date = data$date,
    lower_limit = 4,
    upper_limit = 2
  )
  expect_error(
    islh_epi_curve(data, date, count, reference = reversed),
    "lower must not exceed"
  )
})
