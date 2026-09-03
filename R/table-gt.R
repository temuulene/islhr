#' Apply Island Health styling to a gt table
#'
#' @param data A gt table or data frame.
#' @param title,subtitle Optional table heading.
#' @param source_note Optional source note.
#' @param width Table width as a fraction of the available text width.
#' @param embed_fonts Embed the installed BC Sans faces as data URLs. The
#'   session default is set by `islh_setup()` and defaults to `TRUE` otherwise.
#'
#' @return A styled gt table.
#'
#' @export
islh_gt <- function(
    data,
    title = NULL,
    subtitle = NULL,
    source_note = NULL,
    width = 1,
    embed_fonts = getOption("islh.embed_fonts", TRUE)) {
  .islh_require("gt", "Island Health HTML tables")

  if (!inherits(data, "gt_tbl")) {
    data <- gt::gt(data)
  }

  if (!is.null(title) || !is.null(subtitle)) {
    data <- gt::tab_header(
      data,
      title = if (is.null(title)) "" else title,
      subtitle = subtitle
    )
  }

  if (!is.null(source_note)) {
    data <- gt::tab_source_note(data, source_note = source_note)
  }

  data <- gt::tab_options(
    data,
    table.font.names = unique(c(
      .islh_table_font(), .islh_fallback_font, "Arial", "sans-serif"
    )),
    # Without an explicit width, gt shrinks the table to its contents and
    # centres it, which reads as an afterthought beside full-width prose.
    table.width = gt::pct(width * 100),
    table.align = "left",
    table.margin.left = gt::px(0),
    table.margin.right = gt::px(0),
    table.font.size = gt::px(13),
    table.font.color = islh_brand("black"),
    table.font.color.light = islh_brand("white"),
    table.background.color = islh_brand("white"),
    heading.background.color = islh_brand("white"),
    heading.align = "left",
    heading.title.font.size = gt::px(20),
    heading.title.font.weight = "bold",
    heading.subtitle.font.size = gt::px(14),
    column_labels.background.color = islh_hex("blue", 20),
    column_labels.font.weight = "bold",
    column_labels.padding = gt::px(7),
    column_labels.border.top.style = "solid",
    column_labels.border.top.width = gt::px(1),
    column_labels.border.top.color = islh_hex("blue", 20),
    column_labels.border.bottom.style = "solid",
    column_labels.border.bottom.width = gt::px(1),
    column_labels.border.bottom.color = islh_hex("blue", 20),
    table_body.hlines.style = "solid",
    table_body.hlines.width = gt::px(1),
    table_body.hlines.color = islh_hex("grey", 90),
    table_body.vlines.style = "none",
    table_body.border.bottom.style = "solid",
    table_body.border.bottom.width = gt::px(1),
    table_body.border.bottom.color = islh_hex("blue", 20),
    data_row.padding = gt::px(5),
    row_group.background.color = islh_hex("blue", 96),
    row_group.font.weight = "bold",
    footnotes.font.size = gt::px(11),
    source_notes.font.size = gt::px(11),
    table.border.top.style = "none",
    table.border.bottom.style = "none"
  )

  embed_in_table <- isTRUE(embed_fonts) &&
    !isTRUE(getOption("islh.document_webfont", FALSE))
  if (embed_in_table) {
    webfont_css <- .islh_bc_sans_webfont_css()
    if (nzchar(webfont_css)) {
      data <- gt::opt_css(data, css = webfont_css, add = FALSE)
    }
  }

  data
}

## gtsummary integration -----------------------------------------------------

