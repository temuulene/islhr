# Disclosure control.
#
# These implement mechanics, not policy. The threshold, the rounding base and
# whether complementary suppression is needed all depend on the release and on
# your privacy office. Nothing here has a default that decides that for you.

#' Suppress small cell counts across a data frame
#'
#' Applies [islh_suppress()] to several columns at once.
#'
#' Set `complementary = TRUE` when the table also shows a total, or when the
#' rows partition a known population. Suppressing a single cell in such a table
#' does not protect it: a reader subtracts the visible cells from the total and
#' recovers the value. Complementary suppression hides the next-smallest cell
#' as well so the arithmetic no longer closes.
#'
#' Whether you need it, and how many cells to suppress, is a disclosure policy
#' question rather than a statistical one. Check the rule your release is
#' governed by before publishing.
#'
#' @param data A data frame.
#' @param cols Columns to suppress. Character names or numeric positions.
#' @param threshold Approved disclosure-control threshold. It must be supplied
#'   explicitly because the appropriate rule depends on the data and context.
#' @param inclusive Suppress positive counts less than or equal to the
#'   threshold.
#' @param label Optional display label. With `NULL`, suppressed values become
#'   missing numeric values; otherwise the column becomes character.
#' @param complementary Also suppress the smallest surviving value in any
#'   column where exactly one cell was suppressed.
#'
#' @return The data frame, with the named columns suppressed.
#' @export
#'
#' @examples
#' counts <- data.frame(
#'   area = c("North", "Central", "South"),
#'   cases = c(3, 42, 17),
#'   contacts = c(1, 55, 4)
#' )
#'
#' islh_suppress_table(counts, c("cases", "contacts"), threshold = 5)
#'
#' # With a total in view, one suppressed cell can be recovered by
#' # subtraction, so hide a second.
#' islh_suppress_table(
#'   counts, "cases", threshold = 5, complementary = TRUE, label = "<5"
#' )
islh_suppress_table <- function(
  data,
  cols,
  threshold,
  inclusive = TRUE,
  label = NULL,
  complementary = FALSE
) {
  if (!is.data.frame(data)) {
    .islh_abort("{.arg data} must be a data frame.")
  }
  if (missing(threshold)) {
    .islh_abort(c(
      "{.arg threshold} must be supplied.",
      i = "The right threshold depends on the data and the release; there is
           deliberately no default."
    ))
  }

  if (is.character(cols)) {
    unknown <- setdiff(cols, names(data))
    if (length(unknown) > 0L) {
      .islh_abort("{.arg data} has no column{?s} named {.field {unknown}}.")
    }
  }

  for (col in cols) {
    values <- data[[col]]
    hidden <- .islh_small(values, threshold, inclusive)

    if (isTRUE(complementary) && sum(hidden, na.rm = TRUE) == 1L) {
      # Exactly one hidden cell is the recoverable case: a reader subtracts the
      # visible cells from the total and gets it back. Hide the smallest
      # survivor too. Two or more already break that arithmetic.
      survivors <- values
      survivors[hidden | is.na(values)] <- NA
      if (any(!is.na(survivors))) {
        hidden[which.min(survivors)] <- TRUE
      }
    }

    # Route through islh_suppress() so a suppressed cell looks the same however
    # it came to be suppressed, then apply the complementary cell the same way.
    suppressed <- islh_suppress(
      values,
      threshold = threshold,
      inclusive = inclusive,
      label = label
    )
    extra <- hidden & !.islh_small(values, threshold, inclusive)
    extra[is.na(extra)] <- FALSE
    suppressed[extra] <- if (is.null(label)) NA_real_ else as.character(label)

    data[[col]] <- suppressed
  }

  data
}

# Which values does the rule hide? Kept separate so the complementary pass and
# islh_suppress() cannot disagree about what counts as small.
.islh_small <- function(n, threshold, inclusive) {
  n <- suppressWarnings(as.numeric(n))
  small <- if (isTRUE(inclusive)) {
    n > 0 & n <= threshold
  } else {
    n > 0 & n < threshold
  }
  small[is.na(small)] <- FALSE
  small
}

#' Round counts to a fixed base
#'
#' Rounding to a base is used alongside, or instead of, suppression when a
#' release must show every cell. `"nearest"` rounds deterministically, so the
#' same input always gives the same output. `"random"` (sometimes called
#' controlled or unbiased rounding) rounds up or down with probability set by
#' how far the value sits between the two neighbouring multiples, which removes
#' the systematic bias that deterministic rounding introduces in a total.
#'
#' Random rounding gives a different answer each run unless you set a seed, so
#' round once and save the result rather than rounding at render time.
#'
#' @param x Numeric counts.
#' @param base Rounding base. Commonly 5 or 10.
#' @param method `"nearest"` for deterministic rounding, `"random"` for
#'   controlled random rounding.
#'
#' @return A numeric vector of rounded counts.
#' @export
#'
#' @examples
#' islh_round_base(c(0, 2, 3, 7, 12, 43), base = 5)
#'
#' set.seed(42)
#' islh_round_base(c(2, 3, 7, 12), base = 5, method = "random")
islh_round_base <- function(x, base = 5, method = c("nearest", "random")) {
  method <- match.arg(method)

  if (!is.numeric(x)) {
    .islh_abort("{.arg x} must be numeric.")
  }
  if (length(base) != 1L || is.na(base) || base <= 0) {
    .islh_abort("{.arg base} must be a single positive number.")
  }

  if (method == "nearest") {
    # round() breaks .5 ties to even, which is what we want here: it keeps
    # rounding from drifting a total in one direction.
    return(round(x / base) * base)
  }

  lower <- floor(x / base) * base
  remainder <- x - lower
  # Probability of rounding up equals the distance already travelled, so the
  # expected value is the original number.
  round_up <- stats::runif(length(x)) < (remainder / base)
  result <- ifelse(round_up, lower + base, lower)
  result[is.na(x)] <- NA
  result
}
