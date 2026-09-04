test_that("the map theme removes geographic chart furniture", {
  map_theme <- theme_islh_map()

  expect_s3_class(map_theme, "theme")
  expect_s3_class(map_theme$axis.title, "element_blank")
  expect_s3_class(map_theme$axis.text, "element_blank")
  expect_s3_class(map_theme$axis.ticks, "element_blank")
  expect_s3_class(map_theme$axis.line, "element_blank")
  expect_s3_class(map_theme$panel.grid, "element_blank")
})

test_that("the map theme composes with the binned fill scale", {
  plot <- ggplot2::ggplot(
    data.frame(x = 1:4, y = 1:4, value = 1:4),
    ggplot2::aes(x, y, fill = value)
  ) +
    ggplot2::geom_tile() +
    scale_fill_islh_b() +
    ggplot2::coord_equal() +
    theme_islh_map()

  expect_s3_class(plot, "ggplot")
  expect_no_warning(ggplot2::ggplot_build(plot))
})

test_that("the map theme blanks the axis children theme_islh() sets", {
  map_theme <- theme_islh_map()

  # `theme_islh()` sets these directly, so the blank parent does not reach
  # them. This is the bug that left a box and tick marks around a map.
  expect_s3_class(map_theme$axis.line.x, "element_blank")
  expect_s3_class(map_theme$axis.line.y, "element_blank")
  expect_s3_class(map_theme$axis.ticks.x, "element_blank")
  expect_s3_class(map_theme$axis.ticks.y, "element_blank")
  expect_s3_class(map_theme$panel.grid.major, "element_blank")
  expect_s3_class(map_theme$panel.grid.minor, "element_blank")
})

test_that("the binned fill legend is wide enough to label", {
  legend <- .islh_legend_bar_theme()

  # `legend.key.width` sets the whole bar length for a horizontal colour bar.
  # At the 0.9-line qualitative key size the bar is shorter than its own break
  # labels, which is what made them overprint each other.
  expect_gt(as.numeric(legend$legend.key.width), 6)
  expect_identical(legend$legend.title.position, "top")
  expect_s3_class(legend$legend.ticks, "element_blank")
})

test_that("binned fill breaks are abbreviated by default", {
  labels <- formals(scale_fill_islh_b)$labels |> eval()

  expect_identical(labels(c(1000, 25000, 1e6)), c("1K", "25K", "1M"))
})

test_that("key_width lengthens the legend bar", {
  narrow <- .islh_legend_bar_theme()
  wide <- .islh_legend_bar_theme(key_width = 16)

  expect_gt(
    as.numeric(wide$legend.key.width),
    as.numeric(narrow$legend.key.width)
  )
})

test_that("the binned fill scale accepts a caller's labels and guide", {
  scale <- scale_fill_islh_b(
    labels = scales::label_comma(),
    guide = "none"
  )

  expect_identical(scale$labels(1e5), "100,000")
  expect_identical(scale$guide, "none")
})
