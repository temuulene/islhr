#' Save an Island Health plot with a standard size
#'
#' @param filename Output PNG filename.
#' @param plot Plot to save.
#' @param preset Standard output size: report, slide, or half_width.
#' @param width,height Optional size overrides in inches.
#' @param dpi Optional resolution override.
#' @param bg Background colour.
#' @param ... Additional arguments passed to `ggplot2::ggsave()`.
#'
#' @return The filename, invisibly.
#'
#' @export
islh_save_plot <- function(
    filename,
    plot = ggplot2::last_plot(),
    preset = c("report", "slide", "half_width"),
    width = NULL,
    height = NULL,
    dpi = NULL,
    bg = "white",
    ...) {
  .islh_require("ragg", "saving standard Island Health plot files")
  preset <- match.arg(preset)

  if (tolower(tools::file_ext(filename)) != "png") {
    cli::cli_abort("{.arg filename} must end in {.file .png}.")
  }

  settings <- list(
    report = c(width = 6.5, height = 4.2, dpi = 300),
    slide = c(width = 10, height = 5.625, dpi = 192),
    half_width = c(width = 3.15, height = 3.5, dpi = 300)
  )[[preset]]

  if (is.null(width)) width <- settings[["width"]]
  if (is.null(height)) height <- settings[["height"]]
  if (is.null(dpi)) dpi <- settings[["dpi"]]

  ggplot2::ggsave(
    filename = filename,
    plot = plot,
    device = ragg::agg_png,
    width = width,
    height = height,
    units = "in",
    dpi = dpi,
    bg = bg,
    ...
  )

  invisible(filename)
}
