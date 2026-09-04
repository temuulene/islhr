#' Apply Island Health styling to a flextable
#'
#' Column widths are resolved here and written into the document, rather than
#' left for the renderer to work out. An "autofit" table is sized by whichever
#' program opens it, so the same file lays out differently in Word and in
#' LibreOffice, and differently again on a machine without BC Sans installed.
#'
#' @param x A flextable or data frame.
#' @param caption Optional caption.
#' @param autofit Size columns in proportion to their contents. With `FALSE`,
#'   every column gets an equal share.
#' @param width Table width as a fraction of the available text width.
#' @param text_width Available text width in inches. The default matches the
#'   Island Health reference document: Letter paper with 2.5 cm margins.
#'
#' @return A styled flextable.
#'
#' @examples
#' if (requireNamespace("flextable", quietly = TRUE) &&
#'     requireNamespace("officer", quietly = TRUE)) {
#'   islh_flextable(
#'     head(islh_example_data()),
#'     caption = "Example encounters"
#'   )
#' }
#'
#' @export
islh_flextable <- function(
  x,
  caption = NULL,
  autofit = TRUE,
  width = 1,
  text_width = .islh_text_width
) {
  .islh_require("flextable", "Word-ready Island Health tables")
  .islh_require("officer", "Island Health table borders")

  created_from_data <- !inherits(x, "flextable")
  if (created_from_data) {
    x <- flextable::flextable(x)
  }

  thin_rule <- officer::fp_border(
    color = islh_hex("grey", 90),
    width = 0.5
  )
  strong_rule <- officer::fp_border(
    color = islh_hex("blue", 20),
    width = 1
  )

  x <- x |>
    flextable::border_remove() |>
    flextable::font(fontname = .islh_table_font(), part = "all") |>
    flextable::fontsize(size = 10, part = "all") |>
    flextable::color(color = islh_brand("black"), part = "body") |>
    flextable::bg(bg = islh_brand("white"), part = "body") |>
    flextable::bg(bg = islh_hex("blue", 20), part = "header") |>
    flextable::color(color = islh_brand("white"), part = "header") |>
    flextable::bold(bold = TRUE, part = "header") |>
    flextable::valign(valign = "center", part = "all") |>
    flextable::padding(padding = 4, part = "all") |>
    flextable::border_inner_h(border = thin_rule, part = "body") |>
    flextable::hline_top(border = strong_rule, part = "header") |>
    flextable::hline_bottom(border = strong_rule, part = "header") |>
    flextable::hline_bottom(border = strong_rule, part = "body") |>
    flextable::set_table_properties(
      # Word reads `width` as the table's preferred width, as a fraction of
      # the text width. flextable's default of 0 writes a 0% preferred width,
      # which makes Word collapse every column to one character.
      layout = "fixed",
      width = width,
      align = "left",
      opts_word = list(split = FALSE, repeat_headers = TRUE)
    ) |>
    flextable::paginate(init = FALSE, hdr_ftr = TRUE)

  if (created_from_data) {
    x <- x |>
      flextable::align_text_col(align = "left") |>
      flextable::align_nottext_col(align = "right")
  }

  if (!is.null(caption)) {
    caption <- flextable::as_paragraph(
      flextable::as_chunk(
        caption,
        props = officer::fp_text(
          color = islh_brand("black"),
          font.size = 10,
          font.family = .islh_table_font()
        )
      )
    )
    x <- flextable::set_caption(x, caption = caption)
  }

  x <- .islh_fix_widths(x, autofit = autofit, width = width,
                        text_width = text_width)

  x
}

# The text width of the Island Health reference document, in inches: Letter
# (12240 twips) less two 1418-twip margins, over 1440 twips per inch.
.islh_text_width <- (12240 - 2 * 1418) / 1440

# Turns whatever widths flextable has into a fixed set that sums to the
# requested fraction of the text width, so Word and LibreOffice lay the table
# out the same way.
.islh_fix_widths <- function(x, autofit, width, text_width) {
  target <- width * text_width
  columns <- flextable::ncol_keys(x)

  shares <- if (isTRUE(autofit)) {
    # autofit() measures the rendered text; use it for the proportions only,
    # then rescale, so the total is ours rather than the measurement's.
    measured <- tryCatch(
      dim(flextable::autofit(x))$widths,
      error = function(condition) NULL
    )
    if (is.null(measured) || length(measured) != columns ||
        !all(is.finite(measured)) || sum(measured) <= 0) {
      rep(1 / columns, columns)
    } else {
      measured / sum(measured)
    }
  } else {
    rep(1 / columns, columns)
  }

  flextable::width(x, width = shares * target)
}

#' Set Island Health defaults for newly created flextables
#'
#' @return Previous flextable defaults, invisibly.
#'
#' @noRd
.islh_set_flextable_defaults <- function() {
  .islh_require("flextable", "Island Health flextable defaults")

  previous <- flextable::set_flextable_defaults(
    font.family = .islh_table_font(),
    hansi.family = .islh_table_font(),
    font.size = 10,
    font.color = islh_brand("black"),
    border.color = islh_hex("grey", 90),
    border.width = 0.5,
    padding = 4,
    table.layout = "fixed",
    table_align = "left",
    split = FALSE,
    na_str = "n/a",
    big.mark = ",",
    decimal.mark = ".",
    theme_fun = islh_flextable
  )

  invisible(previous)
}

#' Save an Island Health flextable as a Word document
#'
#' @param x A flextable object.
#' @param path Output DOCX path.
#' @param title Optional document heading.
#'
#' @return The output path, invisibly.
#'
#' @noRd
.islh_save_flextable_docx <- function(x, path, title = NULL) {
  .islh_require("flextable", "Word-ready Island Health tables")
  .islh_require("officer", "Island Health Word documents")

  if (!inherits(x, "flextable")) {
    cli::cli_abort("{.arg x} must be a flextable object.")
  }

  document <- officer::read_docx()

  if (!is.null(title)) {
    title_text <- officer::ftext(
      title,
      prop = officer::fp_text(
        color = islh_hex("blue", 20),
        font.size = 14,
        bold = TRUE,
        font.family = .islh_table_font()
      )
    )
    document <- officer::body_add_fpar(
      document,
      officer::fpar(
        title_text,
        fp_p = officer::fp_par(padding.bottom = 6, keep_with_next = TRUE)
      )
    )
  }

  document <- flextable::body_add_flextable(document, x)
  print(document, target = path)
  invisible(path)
}

## gt theme ------------------------------------------------------------------
