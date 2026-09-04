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
