#' Choose readable text for an Island Health background colour
#'
#' @param value Brand lightness value of the background.
#' @param size Text size category, either large or small.
#'
#' @return A character vector containing white or dark grey.
#'
#' @noRd
.islh_text_on <- function(value, size = c("large", "small")) {
  size <- match.arg(size)
  required <- if (size == "large") 50 else 70
  value <- as.numeric(value)

  diff_white <- 100 - value
  diff_dark <- value - 10

  chosen <- ifelse(
    diff_white >= diff_dark,
    "#FFFFFF",
    islh_hex("grey", 10)
  )
  best <- pmax(diff_white, diff_dark)

  if (any(best < required)) {
    cli::cli_warn(c(
      "Value {.val {value[best < required]}} cannot carry {size} text at the required contrast.",
      i = "Needs a value difference of {required}; the best available is {max(best[best < required])}.",
      i = "Place the label outside the shape instead, on a white background."
    ))
  }

  chosen
}

#' Check contrast using the Island Health value-difference rule
#'
#' @param foreground_value Numeric brand value of the foreground.
#' @param background_value Numeric brand value of the background.
#' @param use Intended use: graphic, large_text, or small_text.
#'
#' @return A logical vector. `TRUE` means the pair meets the required contrast.
#'
#' @noRd
.islh_contrast_ok <- function(
    foreground_value,
    background_value,
    use = c("graphic", "large_text", "small_text")) {
  use <- match.arg(use)
  threshold <- c(graphic = 30, large_text = 50, small_text = 70)[[use]]

  foreground_value <- as.numeric(foreground_value)
  background_value <- as.numeric(background_value)

  invalid <- is.na(foreground_value) |
    is.na(background_value) |
    foreground_value < 0 |
    foreground_value > 100 |
    background_value < 0 |
    background_value > 100

  if (any(invalid)) {
    cli::cli_abort(
      "Colour values must be numeric values between 0 and 100."
    )
  }

  abs(foreground_value - background_value) >= threshold
}

#' Perceptual lightness of a colour
#'
#' CIE L*, from 0 for black to 100 for white. It is what a greyscale print
#' leaves of a colour, so it is the measure that says whether a sequential
#' ramp still reads without hue, and whether a missing-data fill can be told
#' apart from the bins around it.
#'
#' @param colour A character vector of colours.
#'
#' @return A numeric vector of L* values.
#'
#' @noRd
.islh_lightness <- function(colour) {
  rgb <- t(grDevices::col2rgb(colour)) / 255
  grDevices::convertColor(rgb, from = "sRGB", to = "Lab")[, "L"]
}

#' Calculate a WCAG contrast ratio
#'
#' @param foreground Foreground colour as a name or hexadecimal value.
#' @param background Background colour as a name or hexadecimal value.
#'
#' @return A numeric vector of contrast ratios from 1 to 21.
#'
#' @noRd
.islh_contrast_ratio <- function(foreground, background) {
  lengths <- c(length(foreground), length(background))
  output_length <- max(lengths)

  if (any(!lengths %in% c(1L, output_length))) {
    cli::cli_abort(
      "{.arg foreground} and {.arg background} must have compatible lengths."
    )
  }

  foreground <- rep(foreground, length.out = output_length)
  background <- rep(background, length.out = output_length)

  relative_luminance <- function(colour) {
    rgb <- tryCatch(
      grDevices::col2rgb(colour) / 255,
      error = function(cnd) {
        cli::cli_abort(
          "Could not interpret one or more colours.",
          parent = cnd
        )
      }
    )
    rgb <- ifelse(
      rgb <= 0.04045,
      rgb / 12.92,
      ((rgb + 0.055) / 1.055)^2.4
    )
    drop(c(0.2126, 0.7152, 0.0722) %*% rgb)
  }

  foreground_luminance <- relative_luminance(foreground)
  background_luminance <- relative_luminance(background)

  (pmax(foreground_luminance, background_luminance) + 0.05) /
    (pmin(foreground_luminance, background_luminance) + 0.05)
}

## Reusable palettes ----------------------------------------------------------

# Qualitative colours are drawn across families for unordered categories. The
# palette is limited to five categories because larger legends become difficult
# to distinguish and interpret. Pair colour with direct labels, shapes, or line
# types when practical.
