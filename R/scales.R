
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

#' Island Health binned fill scale
#'
#' The brand standard specifies solid fills and advises against gradients, so
#' this scale uses discrete steps rather than a continuous gradient. Use it for
#' choropleth maps and other continuous quantities that read better in bands.
#'
#' @param ... Additional arguments passed to `ggplot2::scale_fill_stepsn()`.
#' @param reverse Reverse the palette order.
#' @param na.value Colour for missing values.
#' @param n.breaks Suggested number of bins.
#' @param guide Guide type.
#'
#' @return A ggplot2 binned fill scale.
#'
#' @export
scale_fill_islh_b <- function(
    ...,
    reverse = FALSE,
    na.value = .islh_unknown(),
    n.breaks = 5,
    guide = "coloursteps") {
  colours <- if (isTRUE(reverse)) rev(.islh_pal_map()) else .islh_pal_map()

  ggplot2::scale_fill_stepsn(
    ...,
    colours = colours,
    na.value = na.value,
    n.breaks = n.breaks,
    guide = guide
  )
}

## Plot theme -----------------------------------------------------------------

