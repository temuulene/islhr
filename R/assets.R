# Paths to files shipped inside the package. Each returns a path rather than
# the file's contents, so callers can pass it straight to Quarto, `officer`,
# `knitr::include_graphics()` or a copy.

.islh_path <- function(...) {
  path <- system.file(..., package = "islhr")
  if (!nzchar(path)) {
    .islh_abort(c(
      "Cannot find {.file {file.path(...)}} in the installed package.",
      i = "The installation may be incomplete; try reinstalling {.pkg islhr}."
    ))
  }
  path
}

#' Path to an Island Health logo file
#'
#' The brand system has two lockups in four colour variants. Full-colour is the
#' primary variant for both lockups, and dark blue is a second primary for the
#' horizontal lockup. Use white on dark backgrounds. **Black is for print
#' only** — do not use it on screen.
#'
#' Only the vector (`svg`) and raster (`png`) files ship with the package. The
#' Illustrator sources and print PDFs live in the `islh-brand-standard`
#' repository.
#'
#' @param lockup Logo arrangement: `"horizontal"` or `"stacked"`.
#' @param variant Colour variant: `"full-colour"`, `"dark-blue"`, `"white"` or
#'   `"black"`.
#' @param format File format: `"svg"` for anything scalable, `"png"` where a
#'   raster is required.
#'
#' @return A file path.
#' @export
#'
#' @examples
#' islh_logo()
#' islh_logo("stacked", "white", "png")
islh_logo <- function(
  lockup = c("horizontal", "stacked"),
  variant = c("full-colour", "dark-blue", "white", "black"),
  format = c("svg", "png")
) {
  lockup <- match.arg(lockup)
  variant <- match.arg(variant)
  format <- match.arg(format)

  .islh_path(
    "logos",
    paste0("islh-logo-", lockup, "-", variant, ".", format)
  )
}

#' Path to the Island Health `_brand.yml`
#'
#' The brand file Quarto and Shiny read for colours and typography. Use
#' [islh_use_brand()] to copy it into a project.
#'
#' @return A file path.
#' @export
#'
#' @examples
#' islh_brand_yml()
islh_brand_yml <- function() {
  .islh_path("brand", "_brand.yml")
}

#' Path to the Island Health Word reference document
#'
#' The `reference-doc` Quarto uses for `docx` output. It carries the letterhead
#' header, the page footer, BC Sans and the Island Health heading styles.
#'
#' @return A file path.
#' @export
#'
#' @examples
#' islh_reference_docx()
islh_reference_docx <- function() {
  .islh_path(
    "quarto", "_extensions", "islh", "islh-report",
    "islh-report-reference.docx"
  )
}

#' Example programme counts
#'
#' A three-row table used in the package examples and in the report scaffold,
#' so a new report renders with something in it before you supply real data.
#'
#' @return A data frame with columns `program`, `encounters` and
#'   `median_wait_minutes`.
#' @export
#'
#' @examples
#' islh_example_data()
islh_example_data <- function() {
  utils::read.csv(
    .islh_path("extdata", "example-program-counts.csv"),
    stringsAsFactors = FALSE
  )
}
