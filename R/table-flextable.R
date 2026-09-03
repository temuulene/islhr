#' Apply Island Health styling to a flextable
#'
#' @param x A flextable or data frame.
#' @param caption Optional caption.
#' @param autofit Automatically size columns to their contents.
#' @param width Table width as a fraction of the available text width.
#'
#' @return A styled flextable.
#'
#' @export
islh_flextable <- function(x, caption = NULL, autofit = TRUE, width = 1) {
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
      layout = "autofit",
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

  if (isTRUE(autofit)) {
    x <- flextable::autofit(x)
  }

  x
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
    table.layout = "autofit",
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

