
## Discrete ggplot scales -----------------------------------------------------

#' Island Health qualitative colour scale
#'
#' @param reverse Reverse the palette order.
#' @param ... Additional arguments passed to `ggplot2::discrete_scale()`.
#' @param na.value Colour for missing values.
#'
#' @return A ggplot2 discrete scale.
#'
#' @export
scale_colour_islh <- function(
    reverse = FALSE,
    ...,
    na.value = .islh_unknown()) {
  ggplot2::discrete_scale(
    aesthetics = "colour",
    palette = function(n) .islh_pal_qualitative(n, reverse = reverse),
    na.value = na.value,
    ...
  )
}

# American spelling alias used by ggplot2.
#' @rdname scale_colour_islh
#' @export
scale_color_islh <- scale_colour_islh

#' Island Health qualitative fill scale
#'
#' @inheritParams scale_colour_islh
#'
#' @return A ggplot2 discrete scale.
#'
#' @export
scale_fill_islh <- function(
    reverse = FALSE,
    ...,
    na.value = .islh_unknown()) {
  ggplot2::discrete_scale(
    aesthetics = "fill",
    palette = function(n) .islh_pal_qualitative(n, reverse = reverse),
    na.value = na.value,
    ...
  )
}

#' Island Health ordinal colour scale
#'
#' @param family Island Health colour family.
#' @param reverse Reverse the light-to-dark order.
#' @param ... Additional arguments passed to `ggplot2::discrete_scale()`.
#' @param na.value Colour for missing values.
#'
#' @return A ggplot2 discrete scale.
#'
#' @export
scale_colour_islh_ordinal <- function(
    family = "blue",
    reverse = FALSE,
    ...,
    na.value = .islh_unknown()) {
  ggplot2::discrete_scale(
    aesthetics = "colour",
    palette = function(n) {
      .islh_pal_ordinal(n, family = family, reverse = reverse)
    },
    na.value = na.value,
    ...
  )
}

#' @rdname scale_colour_islh_ordinal
#' @export
scale_color_islh_ordinal <- scale_colour_islh_ordinal

#' Island Health ordinal fill scale
#'
#' @inheritParams scale_colour_islh_ordinal
#'
#' @return A ggplot2 discrete scale.
#'
#' @export
scale_fill_islh_ordinal <- function(
    family = "blue",
    reverse = FALSE,
    ...,
    na.value = .islh_unknown()) {
  ggplot2::discrete_scale(
    aesthetics = "fill",
    palette = function(n) {
      .islh_pal_ordinal(n, family = family, reverse = reverse)
    },
    na.value = na.value,
    ...
  )
}

#' Island Health signal colour scale
#'
#' @param ... Additional arguments passed to `ggplot2::scale_colour_manual()`.
#' @param na.value Colour for missing values.
#'
#' @return A ggplot2 discrete scale.
#'
#' @export
scale_colour_islh_signal <- function(..., na.value = .islh_unknown()) {
  ggplot2::scale_colour_manual(
    ...,
    values = .islh_pal_signal(),
    na.value = na.value
  )
}

#' @rdname scale_colour_islh_signal
#' @export
scale_color_islh_signal <- scale_colour_islh_signal

#' Island Health signal fill scale
#'
#' @param ... Additional arguments passed to `ggplot2::scale_fill_manual()`.
#' @param na.value Colour for missing values.
#'
#' @return A ggplot2 discrete scale.
#'
#' @export
scale_fill_islh_signal <- function(..., na.value = .islh_unknown()) {
  ggplot2::scale_fill_manual(
    ...,
    values = .islh_pal_signal(),
    na.value = na.value
  )
}

## Binned map scale -----------------------------------------------------------

#' Default guide for the Island Health binned fill scale
#'
#' The stock `coloursteps` guide takes its bar length from `legend.key.width`,
#' which [theme_islh()] sizes for qualitative keys. That leaves a bar too short
#' to hold its own break labels, so they overprint each other. This guide gives
#' the bar a fixed 10-line length, puts the title above it, and drops the tick
#' marks between bins.
#'
#' @param key_width Bar length in lines of text.
#' @param ... Additional arguments passed to `ggplot2::guide_coloursteps()`.
#'
#' @return A ggplot2 guide.
#'
#' @noRd
.islh_guide_coloursteps <- function(key_width = 10, ...) {
  ggplot2::guide_coloursteps(
    ...,
    theme = .islh_legend_bar_theme(key_width = key_width)
  )
}

#' Legend theme for a horizontal binned colour bar
#'
#' @param key_width Bar length in lines of text.
#'
#' @return A ggplot2 theme object.
#'
#' @noRd
.islh_legend_bar_theme <- function(key_width = 10) {
  ggplot2::theme(
    legend.title.position = "top",
    legend.key.width = grid::unit(key_width, "lines"),
    legend.key.height = grid::unit(0.8, "lines"),
    legend.ticks = ggplot2::element_blank()
  )
}

#' Island Health binned fill scale
#'
#' The brand standard specifies solid fills and advises against gradients, so
#' this scale uses discrete steps rather than a continuous gradient. Use it for
#' choropleth maps and other continuous quantities that read better in bands.
#'
#' Counts are abbreviated by default (`12,500` prints as `12.5K`) because a
#' horizontal bar legend has little room between breaks. Pass `labels` to
#' override, for example `labels = scales::label_comma()` for full numbers or
#' `labels = scales::label_percent()` for rates. Longer labels need a longer
#' bar: raise `key_width`, or lower `n.breaks` so there are fewer of them.
#'
#' Areas with no data take a grey that is lighter than every bin, so they do
#' not read as the lowest band in greyscale. Suppressed cells are a different
#' thing again: draw them as their own layer with their own legend key rather
#' than letting them share the missing-data colour.
#'
#' @param ... Additional arguments passed to `ggplot2::scale_fill_stepsn()`.
#' @param reverse Reverse the palette order.
#' @param na.value Colour for areas with no data.
#' @param n.breaks Suggested number of bins. Pass `breaks` instead when a
#'   report maps the same indicator more than once: bins chosen from each
#'   year's data make an unchanged pattern look like a change.
#' @param labels Break label function.
#' @param key_width Legend bar length in lines of text. Ignored when you pass
#'   your own `guide`.
#' @param guide Guide type.
#'
#' @return A ggplot2 binned fill scale.
#'
#' @export
scale_fill_islh_b <- function(
    ...,
    reverse = FALSE,
    na.value = .islh_map_missing(),
    n.breaks = 5,
    labels = scales::label_number(scale_cut = scales::cut_short_scale()),
    key_width = 10,
    guide = .islh_guide_coloursteps(key_width = key_width)) {
  colours <- if (isTRUE(reverse)) rev(.islh_pal_map()) else .islh_pal_map()

  ggplot2::scale_fill_stepsn(
    ...,
    colours = colours,
    na.value = na.value,
    n.breaks = n.breaks,
    labels = labels,
    guide = guide
  )
}

## Plot theme -----------------------------------------------------------------

