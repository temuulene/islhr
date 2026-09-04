#' Brand text hierarchy shared by every Island Health theme
#'
#' Titles, subtitles, captions, legend text and strip labels read the same on
#' a bar chart and on a map. Keeping them in one place lets the map theme
#' start from `ggplot2::theme_void()`, which carries no chart furniture to
#' remove, and still match the rest of the package.
#'
#' @return A ggplot2 theme object.
#'
#' @noRd
.islh_text_theme <- function() {
  # Windows base devices, the RStudio plot pane included, resolve family names
  # through R's own font database rather than systemfonts. Registering here as
  # well as in `islh_setup()` keeps a plot drawn with a theme alone from
  # filling the console with "font family not found" warnings.
  .islh_register_screen_font(.islh_font())

  ggplot2::theme(
    plot.title.position = "plot",
    plot.caption.position = "plot",
    plot.title = ggplot2::element_text(
      size = ggplot2::rel(1.15),
      face = "bold",
      colour = islh_hex("blue", 20),
      hjust = 0,
      margin = ggplot2::margin(b = 4)
    ),
    plot.subtitle = ggplot2::element_text(
      size = ggplot2::rel(0.95),
      colour = islh_hex("grey", 40),
      hjust = 0,
      margin = ggplot2::margin(b = 10)
    ),
    plot.caption = ggplot2::element_text(
      size = ggplot2::rel(0.75),
      hjust = 0,
      colour = islh_hex("grey", 40),
      margin = ggplot2::margin(t = 10)
    ),
    legend.position = "bottom",
    legend.text = ggplot2::element_text(
      size = ggplot2::rel(0.85),
      colour = islh_hex("grey", 25)
    ),
    legend.title = ggplot2::element_text(
      size = ggplot2::rel(0.9),
      colour = islh_hex("grey", 25)
    ),
    strip.text = ggplot2::element_text(
      size = ggplot2::rel(0.9),
      face = "bold",
      colour = islh_hex("blue", 20),
      hjust = 0
    )
  )
}

#' Island Health ggplot theme
#'
#' @param base_size Base font size in points.
#' @param grid Major gridlines to display: y, x, both, or none.
#'
#' @return A ggplot2 theme object.
#'
#' @export
theme_islh <- function(base_size = 12, grid = c("y", "x", "both", "none")) {
  grid <- match.arg(grid)

  base <- ggplot2::theme_minimal(
    base_size = base_size,
    base_family = .islh_font()
  ) +
    .islh_text_theme() +
    ggplot2::theme(
      axis.title = ggplot2::element_text(
        size = ggplot2::rel(0.9),
        colour = islh_hex("grey", 30)
      ),
      axis.text = ggplot2::element_text(
        size = ggplot2::rel(0.85),
        colour = islh_hex("grey", 30)
      ),
      panel.grid.major = ggplot2::element_line(
        colour = islh_hex("grey", 93),
        linewidth = 0.4
      ),
      panel.grid.minor = ggplot2::element_blank(),
      legend.key.size = grid::unit(0.9, "lines"),
      plot.margin = ggplot2::margin(6, 10, 6, 6)
    )

  base + switch(
    grid,
    y = ggplot2::theme(
      panel.grid.major.x = ggplot2::element_blank(),
      axis.line.x = ggplot2::element_line(
        colour = islh_hex("grey", 60),
        linewidth = 0.3
      ),
      axis.ticks.x = ggplot2::element_line(
        colour = islh_hex("grey", 60),
        linewidth = 0.3
      )
    ),
    x = ggplot2::theme(
      panel.grid.major.y = ggplot2::element_blank(),
      axis.line.y = ggplot2::element_line(
        colour = islh_hex("grey", 60),
        linewidth = 0.3
      ),
      axis.ticks.y = ggplot2::element_line(
        colour = islh_hex("grey", 60),
        linewidth = 0.3
      )
    ),
    both = ggplot2::theme(
      axis.line.x = ggplot2::element_line(
        colour = islh_hex("grey", 60),
        linewidth = 0.3
      ),
      axis.ticks.x = ggplot2::element_line(
        colour = islh_hex("grey", 60),
        linewidth = 0.3
      ),
      axis.line.y = ggplot2::element_line(
        colour = islh_hex("grey", 60),
        linewidth = 0.3
      ),
      axis.ticks.y = ggplot2::element_line(
        colour = islh_hex("grey", 60),
        linewidth = 0.3
      )
    ),
    none = ggplot2::theme(
      panel.grid.major = ggplot2::element_blank(),
      axis.line.x = ggplot2::element_line(
        colour = islh_hex("grey", 60),
        linewidth = 0.3
      ),
      axis.ticks.x = ggplot2::element_line(
        colour = islh_hex("grey", 60),
        linewidth = 0.3
      ),
      axis.line.y = ggplot2::element_line(
        colour = islh_hex("grey", 60),
        linewidth = 0.3
      ),
      axis.ticks.y = ggplot2::element_line(
        colour = islh_hex("grey", 60),
        linewidth = 0.3
      )
    )
  )
}

## Plot helpers ---------------------------------------------------------------

#' Apply Island Health plot defaults for the current R session
#'
#' @param base_size Base font size in points.
#' @param grid Major gridlines to display.
#' @param set_knitr Use `ragg_png` for subsequent knitr chunks when available.
#'
#' @return Previous theme and options, invisibly.
#'
#' @noRd
.islh_use_theme <- function(
    base_size = 12,
    grid = c("y", "x", "both", "none"),
    set_knitr = TRUE) {
  grid <- match.arg(grid)

  .islh_register_screen_font(.islh_font())
  old_theme <- ggplot2::theme_set(
    theme_islh(base_size = base_size, grid = grid)
  )
  old_options <- options(
    ggplot2.discrete.colour = scale_colour_islh,
    ggplot2.discrete.fill = scale_fill_islh
  )

  ggplot2::update_geom_defaults("bar", list(fill = islh_brand("primary")))
  ggplot2::update_geom_defaults("col", list(fill = islh_brand("primary")))
  ggplot2::update_geom_defaults("line", list(colour = islh_brand("primary")))
  ggplot2::update_geom_defaults("point", list(colour = islh_brand("primary")))
  ggplot2::update_geom_defaults("smooth", list(colour = islh_brand("primary")))
  ggplot2::update_geom_defaults("area", list(fill = islh_brand("primary")))

  if (isTRUE(set_knitr) && requireNamespace("knitr", quietly = TRUE)) {
    if (requireNamespace("ragg", quietly = TRUE)) {
      knitr::opts_chunk$set(dev = "ragg_png")
    } else {
      cli::cli_warn(c(
        "Package {.pkg ragg} is not installed.",
        i = "Quarto is using its existing graphics device."
      ))
    }
  }

  invisible(list(theme = old_theme, options = old_options))
}

#' Count axis with Island Health defaults
#'
#' @param ... Additional arguments passed to `ggplot2::scale_y_continuous()`.
#' @param labels Label function.
#' @param expand Scale expansion. The lower limit stays on the baseline.
#'
#' @return A ggplot2 continuous position scale.
#'
#' @export
scale_y_islh_count <- function(
    ...,
    labels = scales::label_comma(accuracy = 1),
    expand = ggplot2::expansion(mult = c(0, 0.05))) {
  ggplot2::scale_y_continuous(
    ...,
    labels = labels,
    expand = expand
  )
}

