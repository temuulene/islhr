# Quarto reads extensions and `_brand.yml` from the project directory, not from
# an R library, so these helpers copy the shipped files in.

# Copies a directory tree, reporting each file and refusing to clobber unless
# asked. Returns the paths written, relative to `dir`.
.islh_copy_into <- function(source, target, dir, overwrite) {
  files <- list.files(source, recursive = TRUE, all.files = TRUE, no.. = TRUE)
  written <- character()
  skipped <- character()

  for (file in files) {
    destination <- file.path(target, file)
    if (file.exists(destination) && !isTRUE(overwrite)) {
      skipped <- c(skipped, file)
      next
    }
    dir.create(dirname(destination), recursive = TRUE, showWarnings = FALSE)
    file.copy(file.path(source, file), destination, overwrite = TRUE)
    written <- c(written, destination)
  }

  list(
    written = .islh_relative(written, dir),
    skipped = skipped
  )
}

.islh_relative <- function(paths, dir) {
  if (length(paths) == 0L) {
    return(character())
  }
  prefix <- paste0(normalizePath(dir, mustWork = FALSE), .Platform$file.sep)
  sub(prefix, "", normalizePath(paths, mustWork = FALSE), fixed = TRUE)
}

.islh_report_copy <- function(result, what, overwrite) {
  if (length(result$written) > 0L) {
    .islh_inform(c("v" = paste0("Wrote ", what, ":")))
    .islh_inform(stats::setNames(
      paste0("{.file ", result$written, "}"),
      rep("*", length(result$written))
    ))
  }
  skipped <- length(result$skipped)
  if (skipped > 0L && !isTRUE(overwrite)) {
    .islh_inform(c(
      "i" = paste0(
        "{skipped} file{?s} already existed and {?was/were} left alone.",
        " Pass {.code overwrite = TRUE} to replace {?it/them}."
      )
    ))
  }
  invisible(result$written)
}

#' Add the Island Health Quarto format to a project
#'
#' Copies the `islh-report` Quarto extension into `dir/_extensions`. Quarto
#' only looks for extensions inside the project directory, so this has to be a
#' copy rather than a reference into the R library. Re-run it after upgrading
#' `islhr` to pick up format changes.
#'
#' Afterwards, set the format in the document's front matter or `_quarto.yml`:
#'
#' ```yaml
#' format: islh-report-html    # or islh-report-docx
#' ```
#'
#' @param dir Project directory. Defaults to the working directory.
#' @param overwrite Replace files that are already there.
#'
#' @return The paths written, relative to `dir`, invisibly.
#' @export
#'
#' @examples
#' project <- file.path(tempdir(), "example-report")
#' dir.create(project, showWarnings = FALSE)
#' islh_use_quarto(project)
islh_use_quarto <- function(dir = ".", overwrite = FALSE) {
  .islh_check_dir(dir)
  source <- .islh_path("quarto", "_extensions")
  result <- .islh_copy_into(
    source, file.path(dir, "_extensions"), dir, overwrite
  )
  .islh_report_copy(result, "the Island Health Quarto format", overwrite)
}

#' Add the Island Health brand file to a project
#'
#' Copies `_brand.yml` into `dir`. Quarto 1.6 and later, and Shiny via
#' `bslib`, read it for the Island Health palette and typography.
#'
#' @param dir Project directory. Defaults to the working directory.
#' @param overwrite Replace an existing `_brand.yml`.
#'
#' @return The path written, relative to `dir`, invisibly.
#' @export
#'
#' @examples
#' project <- file.path(tempdir(), "example-brand")
#' dir.create(project, showWarnings = FALSE)
#' islh_use_brand(project)
islh_use_brand <- function(dir = ".", overwrite = FALSE) {
  .islh_check_dir(dir)
  destination <- file.path(dir, "_brand.yml")

  if (file.exists(destination) && !isTRUE(overwrite)) {
    .islh_inform(c(
      "i" = "{.file _brand.yml} already exists and was left alone.",
      "*" = "Pass {.code overwrite = TRUE} to replace it."
    ))
    return(invisible(character()))
  }

  file.copy(islh_brand_yml(), destination, overwrite = TRUE)
  .islh_inform(c("v" = "Wrote {.file _brand.yml}."))
  invisible(.islh_relative(destination, dir))
}

.islh_check_dir <- function(dir) {
  if (!dir.exists(dir)) {
    .islh_abort(c(
      "{.file {dir}} does not exist.",
      i = "Create it first, or use {.fn islh_create_report} to start a project."
    ))
  }
  invisible(TRUE)
}
