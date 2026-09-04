#' Island Health map theme
#'
#' Applies the Island Health figure theme while removing axes, ticks and panel
#' grids that do not carry meaning on a geographic map. Pair it with
#' `ggplot2::geom_sf()` and [scale_fill_islh_b()] for choropleth maps.
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
      axis.text = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      axis.line = ggplot2::element_blank(),
      panel.grid = ggplot2::element_blank()
    )
}
