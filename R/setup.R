#' Apply Island Health HTML table defaults
#'
#' @param embed_fonts Embed BC Sans in each completed gt table.
#' @param quiet Suppress gtsummary's confirmation message.
#'
#' @return Previous options and the configured gtsummary theme, invisibly.
#'
#' @noRd
.islh_use_html_theme <- function(embed_fonts = TRUE, quiet = FALSE) {
  .islh_require("gt", "Island Health HTML tables")

  document_webfont <- FALSE
  if (isTRUE(embed_fonts) &&
      requireNamespace("knitr", quietly = TRUE) &&
      isTRUE(knitr::is_html_output())) {
    document_webfont <- .islh_register_webfont_dependency()
  }

  previous_options <- options(
    islh.output_format = "html",
    islh.embed_fonts = isTRUE(embed_fonts),
    islh.document_webfont = document_webfont
  )
  gtsummary_theme <- NULL
  if (requireNamespace("gtsummary", quietly = TRUE) &&
      requireNamespace("rlang", quietly = TRUE)) {
    gtsummary_theme <- .islh_gtsummary_theme(
      print_engine = "gt",
      quiet = quiet
    )
  }

  invisible(list(
    options = previous_options,
    flextable = NULL,
    gtsummary = gtsummary_theme
  ))
}

#' Apply Island Health DOCX table defaults
#'
#' @param quiet Suppress gtsummary's confirmation message.
#'
#' @return Previous flextable defaults, options, and the configured gtsummary
#'   theme, invisibly.
#'
#' @noRd
.islh_use_docx_theme <- function(quiet = FALSE) {
  .islh_require("flextable", "Island Health Word tables")
  .islh_require("officer", "Island Health Word tables")

  previous_options <- options(
    islh.output_format = "docx",
    islh.embed_fonts = FALSE,
    islh.document_webfont = FALSE
  )
  previous_flextable <- .islh_set_flextable_defaults()
  gtsummary_theme <- NULL
  if (requireNamespace("gtsummary", quietly = TRUE) &&
      requireNamespace("rlang", quietly = TRUE)) {
    gtsummary_theme <- .islh_gtsummary_theme(
      print_engine = "flextable",
      quiet = quiet
    )
  }

  invisible(list(
    options = previous_options,
    flextable = previous_flextable,
    gtsummary = gtsummary_theme
  ))
}

#' Configure Island Health themes for the current project or document
#'
#' @param format Output format. `auto` detects Quarto HTML and DOCX renders;
#'   outside a render it selects plot-only setup.
#' @param tables Configure the table stack for HTML or DOCX output.
#' @param embed_fonts Embed BC Sans in HTML gt tables. This is ignored for
#'   non-HTML output.
#' @param base_size Base ggplot font size in points.
#' @param grid Major ggplot gridlines to display.
#' @param set_knitr Use `ragg_png` for subsequent knitr chunks when available.
#' @param quiet Suppress the setup confirmation message.
#'
#' @return A description of the active setup, invisibly.
#'
#' @examples
#' setup <- suppressWarnings(islh_setup(format = "plots", quiet = TRUE))
#' setup[c("format", "tables", "font")]
#'
#' @export
islh_setup <- function(
    format = c("auto", "html", "docx", "plots"),
    tables = TRUE,
    embed_fonts = TRUE,
    base_size = 12,
    grid = c("y", "x", "both", "none"),
    set_knitr = TRUE,
    quiet = FALSE) {
  grid <- match.arg(grid)
  check <- islh_check(
    format = format,
    tables = tables,
    embed_fonts = embed_fonts,
    quiet = TRUE
  )

  if (!check$ok) {
    .islh_abort(c(
      paste0(
        "Island Health theme setup cannot configure ",
        toupper(check$format), "."
      ),
      .islh_problem_bullets(check)
    ))
  }

  # Caches into `.islh_state$font`; read it back with `.islh_font()`.
  islh_font_family(refresh = TRUE, warn = TRUE)
  plot_config <- .islh_use_theme(
    base_size = base_size,
    grid = grid,
    set_knitr = set_knitr
  )

  table_config <- NULL
  if (check$tables && check$format == "html") {
    table_config <- .islh_use_html_theme(
      embed_fonts = check$embed_fonts,
      quiet = quiet
    )
  } else if (check$tables && check$format == "docx") {
    table_config <- .islh_use_docx_theme(quiet = quiet)
  } else {
    options(
      islh.output_format = check$format,
      islh.embed_fonts = FALSE,
      islh.document_webfont = FALSE
    )
  }

  result <- list(
    version = islh_version(),
    format = check$format,
    tables = check$tables,
    embed_fonts = check$embed_fonts,
    font = if (nzchar(.islh_font())) .islh_font() else "device default",
    plot = plot_config,
    table = table_config
  )

  if (!isTRUE(quiet)) {
    table_note <- if (check$tables) {
      paste0(" with ", if (check$format == "html") "gt" else "flextable")
    } else {
      ""
    }
    .islh_inform(c(
      "v" = paste0(
        "Island Health theme ", islh_version(), " is ready for ",
        toupper(check$format), table_note, "."
      ),
      "i" = paste0("Font: ", result$font, "."),
      "i" = "Run {.code islh_help()} for the functions you need most."
    ))
  }

  invisible(result)
}
