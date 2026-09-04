#' Island Health map theme
#'
#' Applies the Island Health figure theme while removing the axes, ticks,
#' axis lines and panel grids that do not carry meaning on a geographic map.
#' Pair it with `ggplot2::geom_sf()` and [scale_fill_islh_b()] for choropleth
#' maps.
#'
#' `theme_islh()` sets `axis.line.x`, `axis.line.y`, `axis.ticks.x` and
#' `axis.ticks.y` directly. A ggplot2 theme element only inherits from its
#' parent when the child is unset, so blanking `axis.line` and `axis.ticks`
#' alone leaves the lines and ticks on the plot. This theme blanks the
#' children as well.
#'
#' @param base_size Base font size in points.
#'
#' @return A ggplot2 theme object.
#' @export
#'
#' @examples
#' ggplot2::ggplot() + theme_islh_map()
theme_islh_map <- function(base_size = 12) {
  theme_islh(base_size = base_size, grid = "none") +
    ggplot2::theme(
      axis.title = ggplot2::element_blank(),
      axis.title.x = ggplot2::element_blank(),
      axis.title.y = ggplot2::element_blank(),
      axis.text = ggplot2::element_blank(),
      axis.text.x = ggplot2::element_blank(),
      axis.text.y = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      axis.ticks.x = ggplot2::element_blank(),
      axis.ticks.y = ggplot2::element_blank(),
      axis.line = ggplot2::element_blank(),
      axis.line.x = ggplot2::element_blank(),
      axis.line.y = ggplot2::element_blank(),
      panel.grid = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      panel.border = ggplot2::element_blank()
    )
}
