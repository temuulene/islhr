#' Create or set the Island Health gtsummary theme
#'
#' @param print_engine Default output engine: flextable or gt.
#' @param set_theme Apply the theme for the current R session.
#' @param quiet Suppress gtsummary's confirmation message.
#'
#' @return The gtsummary theme list, invisibly.
#'
#' @noRd
.islh_gtsummary_theme <- function(
  print_engine = c("flextable", "gt"),
  set_theme = TRUE,
  quiet = FALSE
) {
  .islh_require("gtsummary", "Island Health gtsummary tables")
  .islh_require("rlang", "gtsummary conversion hooks")
  print_engine <- match.arg(print_engine)

  theme <- list(
    "pkgwide-str:theme_name" = "Island Health",
    "pkgwide-str:print_engine" = print_engine,
    "as_flex_table-lst:addl_cmds" = list(
      autofit = rlang::expr(islh_flextable())
    ),
    "as_gt-lst:addl_cmds" = list(
      tab_spanner = rlang::expr(islh_gt())
    )
  )

  # Footnote symbols were added after gtsummary 2.5.1. Detect the matching
  # public function so released versions do not reject the newer theme key.
  if ("modify_footnote_symbol" %in% getNamespaceExports("gtsummary")) {
    theme[["pkgwide-chr:footnote_symbol"]] <-
      c("*", "\u2020", "\u2021", "\u00a7")
  }

  if (isTRUE(quiet)) {
    suppressMessages(gtsummary::check_gtsummary_theme(theme))
  } else {
    gtsummary::check_gtsummary_theme(theme)
  }

  if (isTRUE(set_theme)) {
    if (isTRUE(quiet)) {
      suppressMessages(gtsummary::set_gtsummary_theme(theme))
    } else {
      gtsummary::set_gtsummary_theme(theme)
    }
  }

  invisible(theme)
}

#' Apply Island Health table defaults for the current R session
#'
#' @param print_engine Default gtsummary output engine.
#'
#' @return Previous flextable defaults and the active gtsummary theme,
#'   invisibly.
#'
#' @noRd
.islh_use_table_themes <- function(print_engine = c("flextable", "gt")) {
  print_engine <- match.arg(print_engine)

  if (print_engine == "flextable") {
    config <- .islh_use_docx_theme()
  } else {
    config <- .islh_use_html_theme(
      embed_fonts = getOption("islh.embed_fonts", TRUE)
    )
  }

  invisible(list(
    flextable = config$flextable,
    gtsummary = config$gtsummary
  ))
}


#' Convert a gtsummary table to a styled flextable
#'
#' @param x A gtsummary object.
#' @param ... Additional arguments passed to `gtsummary::as_flex_table()`.
#'
#' @return A styled flextable.
#'
#' @export
islh_gtsummary_flex <- function(x, ...) {
  .islh_require("gtsummary", "gtsummary conversion")

  x |>
    gtsummary::as_flex_table(...) |>
    islh_flextable()
}

#' Convert a gtsummary table to a styled gt table
#'
#' @param x A gtsummary object.
#' @param ... Additional arguments passed to `gtsummary::as_gt()`.
#' @param embed_fonts Embed BC Sans in the completed gt table. The session
#'   default is set by `islh_setup()`.
#'
#' @return A styled gt table.
#'
#' @export
islh_gtsummary_gt <- function(
  x,
  ...,
  embed_fonts = getOption("islh.embed_fonts", TRUE)
) {
  .islh_require("gtsummary", "gtsummary conversion")

  x |>
    gtsummary::as_gt(...) |>
    islh_gt(embed_fonts = embed_fonts)
}

## Quick reference ------------------------------------------------------------

#' Explicit statistical display preset for gtsummary
#'
#' This opt-in preset uses median (quartiles), counts (percent), one decimal
#' for continuous summaries, and the missing label "Unknown". Branding setup
#' does not choose these analytical display conventions.
#' @param set_theme Apply the preset to the current session.
#' @return The preset list invisibly.
#' @export
islh_gtsummary_statistics <- function(set_theme = TRUE) {
  .islh_require("gtsummary", "statistical display presets")
  set_theme <- .islh_check_flag(set_theme, "set_theme")
  preset <- list(
    "pkgwide-fn:pvalue_fun" = gtsummary::label_style_pvalue(digits = 2),
    "pkgwide-fn:prependpvalue_fun" = gtsummary::label_style_pvalue(
      digits = 2,
      prepend_p = TRUE
    ),
    "style_number-arg:big.mark" = ",",
    "style_number-arg:decimal.mark" = ".",
    "tbl_summary-fn:percent_fun" = gtsummary::label_style_percent(digits = 1),
    "tbl_summary-arg:statistic" = list(
      gtsummary::all_continuous() ~ "{median} ({p25}, {p75})",
      gtsummary::all_categorical() ~ "{n} ({p}%)"
    ),
    "tbl_summary-arg:digits" = list(
      gtsummary::all_continuous() ~ 1,
      gtsummary::all_categorical() ~ c(0, 1)
    ),
    "tbl_summary-arg:missing_text" = "Unknown"
  )
  if (set_theme) {
    gtsummary::set_gtsummary_theme(preset)
  }
  invisible(preset)
}
