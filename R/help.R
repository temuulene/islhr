#' Print a short guide to the functions most people need
#'
#' @return The printed lines, invisibly.
#'
#' @export
islh_help <- function() {
  lines <- c(
    paste0("Island Health theme ", islh_version()),
    "",
    "SETUP  once per document or session",
    "  islh_setup()                  apply the theme; detects HTML or Word",
    "  islh_check()                  list any packages you still need",
    "",
    "FIGURES  islh_setup() already applies the theme, so plot as usual",
    "  scale_fill_islh()             colours for categories",
    "  scale_colour_islh()           the same, for lines and points",
    "  scale_fill_islh_ordinal()     low to high within one colour",
    "  scale_fill_islh_signal()      red, orange, green for status",
    "  scale_y_islh_count()          count axis with thousands separators",
    "  theme_islh(base_size = 12)    the theme on its own, for one plot",
    "  theme_islh_map()              map theme without axes or grids",
    "",
    "COLOURS",
    '  islh_brand("primary")         the main Island Health blue',
    '  islh_hex("blue", 40)          any step of any colour family',
    "",
    "TABLES",
    "  islh_gt(data)                 HTML",
    "  islh_flextable(data)          Word",
    "  both fill the text width; use width = 0.6 for a narrower table",
    "",
    "SAVING A FIGURE",
    '  islh_save_plot("figure.png")  standard report size',
    '  islh_save_plot("f.png", preset = "slide")',
    "",
    "STARTING A REPORT",
    "  islh_create_report(\"my-report\", format = \"docx\")",
    "  islh_install_deps(\"docx\")           install what the format needs",
    "",
    "SEE IT WORK",
    "  islh_example_plot()                 a themed plot from simulated data"
  )

  cat(lines, sep = "\n")
  cat("\n")
  invisible(lines)
}

## Runnable examples and smoke test ------------------------------------------

#' Create a runnable Island Health example plot
#'
#' @return A ggplot object.
#'
#' @export
islh_example_plot <- function() {
  ggplot2::ggplot(
    datasets::mtcars,
    ggplot2::aes(x = wt, y = mpg, colour = factor(cyl))
  ) +
    ggplot2::geom_point(size = 3) +
    scale_colour_islh() +
    ggplot2::labs(
      title = "Fuel economy by vehicle weight",
      subtitle = "Example using the Island Health visual system",
      x = "Weight (1,000 lb)",
      y = "Miles per US gallon",
      colour = "Cylinders"
    ) +
    theme_islh(grid = "both")
}

#' Build a gallery that exercises plot and table themes
#'
#' @return A list containing example plots and available table outputs.
#'
#' @noRd
.islh_theme_gallery <- function() {
  base_plot <- islh_example_plot()
  plots <- lapply(
    c("y", "x", "both", "none"),
    function(grid) base_plot + theme_islh(grid = grid)
  )
  names(plots) <- c("grid_y", "grid_x", "grid_both", "grid_none")

  map_data <- expand.grid(x = seq_len(5), y = seq_len(5))
  map_data$value <- seq_len(nrow(map_data))
  plots$binned <- ggplot2::ggplot(
    map_data,
    ggplot2::aes(x = x, y = y, fill = value)
  ) +
    ggplot2::geom_tile() +
    scale_fill_islh_b(n.breaks = 5) +
    ggplot2::coord_equal() +
    theme_islh(grid = "none")

  tables <- list()
  example_data <- utils::head(datasets::mtcars[c("mpg", "cyl", "wt")])

  if (requireNamespace("flextable", quietly = TRUE) &&
      requireNamespace("officer", quietly = TRUE)) {
    tables$flextable <- islh_flextable(example_data)
  }

  if (requireNamespace("gt", quietly = TRUE)) {
    tables$gt <- islh_gt(example_data)
  }

  if (requireNamespace("gtsummary", quietly = TRUE)) {
    summary_table <- gtsummary::tbl_summary(
      gtsummary::trial,
      include = c("age", "grade")
    )

    if (requireNamespace("flextable", quietly = TRUE) &&
        requireNamespace("officer", quietly = TRUE)) {
      tables$gtsummary_flextable <- islh_gtsummary_flex(summary_table)
    }

    if (requireNamespace("gt", quietly = TRUE)) {
      tables$gtsummary_gt <- islh_gtsummary_gt(summary_table)
    }
  }

  list(plots = plots, tables = tables)
}
