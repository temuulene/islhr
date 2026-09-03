
## Disclosure helper ---------------------------------------------------------

#' Suppress small cell counts
#'
#' @param n Count vector.
#' @param threshold Approved disclosure-control threshold. It must be supplied
#'   explicitly because the appropriate rule depends on the data and context.
#' @param inclusive Suppress positive counts less than or equal to the threshold.
#' @param label Optional display label. With `NULL`, suppressed values become
#'   missing numeric values; otherwise the result is a character vector.
#'
#' @return A vector with small positive cell counts suppressed.
#'
#' @export
islh_suppress <- function(n, threshold, inclusive = TRUE, label = NULL) {
  if (missing(threshold) || length(threshold) != 1L ||
      is.na(threshold) || threshold < 0) {
    cli::cli_abort(
      "{.arg threshold} must be one non-negative approved threshold."
    )
  }

  n_numeric <- suppressWarnings(as.numeric(n))
  if (any(is.na(n_numeric) & !is.na(n))) {
    cli::cli_abort("{.arg n} must contain only counts or missing values.")
  }

  small <- if (isTRUE(inclusive)) {
    !is.na(n_numeric) & n_numeric > 0 & n_numeric <= threshold
  } else {
    !is.na(n_numeric) & n_numeric > 0 & n_numeric < threshold
  }

  if (is.null(label)) {
    n_numeric[small] <- NA_real_
    return(n_numeric)
  }

  output <- as.character(n)
  output[small] <- as.character(label)
  output
}

## Flextable theme -----------------------------------------------------------

