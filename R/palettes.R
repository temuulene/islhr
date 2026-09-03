.islh_pal_qualitative <- function(n, reverse = FALSE) {
  if (length(n) != 1L || is.na(n) || n < 1 || n != as.integer(n)) {
    cli::cli_abort("{.arg n} must be one positive whole number.")
  }

  values <- c(
    islh_hex("blue", 50),
    islh_hex("cedar", 60),
    islh_hex("thistle", 50),
    islh_hex("fern", 50),
    islh_hex("grey", 45)
  )

  if (n > length(values)) {
    cli::cli_abort(c(
      "The Island Health qualitative palette supports at most 5 categories.",
      i = "Collapse categories, use facets, or add a non-colour cue."
    ))
  }

  colours <- values[seq_len(n)]

  if (isTRUE(reverse)) {
    colours <- rev(colours)
  }

  colours
}

# Ordinal scales stay within one colour family because lightness carries the
# order. Values are kept at 70 or darker for graphic contrast on white.
.islh_pal_ordinal <- function(n, family = "blue", reverse = FALSE) {
  if (length(n) != 1L || is.na(n) || n < 1 || n != as.integer(n)) {
    cli::cli_abort("{.arg n} must be one positive whole number.")
  }

  values <- switch(
    as.character(n),
    "1" = 50,
    "2" = c(25, 60),
    "3" = c(20, 45, 70),
    "4" = c(20, 40, 55, 70),
    "5" = c(15, 30, 45, 60, 70),
    cli::cli_abort(c(
      "The Island Health ordinal palette supports at most 5 categories.",
      i = "Collapse categories or use facets rather than interpolating colours."
    ))
  )

  colours <- islh_hex(family, values)

  if (isTRUE(reverse)) {
    colours <- rev(colours)
  }

  colours
}


# Colour for unknown, missing, or not-recorded categories.
#
# These three were top-level constants in the script. In a package that makes
# the built value depend on file collation order, so each is a function with a
# session cache instead.
.islh_unknown <- function() {
  if (is.null(.islh_state$unknown)) {
    .islh_state$unknown <- islh_hex("grey", 70)
  }
  .islh_state$unknown
}

# Sequential palette for map bins, ordered from lower to higher values.
.islh_pal_map <- function() {
  if (is.null(.islh_state$pal_map)) {
    .islh_state$pal_map <- islh_hex("blue", c(70, 60, 50, 40, 25))
  }
  .islh_state$pal_map
}

# Conventional status colours from the brand standard. Keep their meanings
# intact and pair colour with a label, icon, shape, or other non-colour cue.
.islh_pal_signal <- function() {
  if (is.null(.islh_state$pal_signal)) {
    .islh_state$pal_signal <- c(
      success = islh_brand("success"),
      warning = islh_brand("warning"),
      danger = islh_brand("danger")
    )
  }
  .islh_state$pal_signal
}
