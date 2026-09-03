# Project scaffolding.
#
# This replaces the starter-kit ZIPs. Those shipped a copy of the theme script
# in every project, so a fix reached nobody until they re-downloaded. A
# scaffolded project holds no copy of anything: it calls `library(islhr)`.

.islh_rproj <- c(
  "Version: 1.0",
  "",
  "RestoreWorkspace: No",
  "SaveWorkspace: No",
  "AlwaysSaveHistory: No",
  "",
  "EnableCodeIndexing: Yes",
  "UseSpacesForTab: Yes",
  "NumSpacesForTab: 2",
  "Encoding: UTF-8",
  "",
  "RnwWeave: knitr",
  "LaTeX: pdfLaTeX"
)

.islh_project_gitignore <- c(
  "# Rendered output. Re-render rather than committing these.",
  "*.html",
  "*.docx",
  "*_files/",
  "/.quarto/",
  "",
  "# RStudio",
  ".Rproj.user",
  ".Rhistory",
  ".RData",
  ".Ruserdata"
)

.islh_quarto_yml <- function(format) {
  formats <- switch(
    format,
    html = "  islh-report-html: default",
    docx = "  islh-report-docx: default",
    both = c("  islh-report-html: default", "  islh-report-docx: default")
  )
  c(
    "project:",
    "  title: \"Island Health report\"",
    "",
    "format:",
    formats
  )
}

.islh_report_qmd <- function(title, author, format) {
  # The Word branch uses islh_flextable(); HTML uses islh_gt(). With both
  # formats, pick by what islh_setup() resolved, so one file renders to either.
  table_call <- switch(
    format,
    html = 'islh_gt(counts, title = "Encounters by programme")',
    docx = 'islh_flextable(counts, caption = "Encounters by programme")',
    both = paste0(
      'if (identical(getOption("islh.output_format"), "html")) {\n',
      '  islh_gt(counts, title = "Encounters by programme")\n',
      '} else {\n',
      '  islh_flextable(counts, caption = "Encounters by programme")\n',
      '}'
    )
  )

  c(
    "---",
    paste0('title: "', title, '"'),
    'subtitle: "Population Health and Surveillance"',
    if (!is.null(author)) paste0('author: "', author, '"'),
    "date: today",
    'date-format: "D MMMM YYYY"',
    "---",
    "",
    "```{r}",
    "#| label: setup",
    "#| include: false",
    "",
    "# Do not edit this block. islh_setup() detects whether you are rendering",
    "# to HTML or Word and configures plots and tables to match.",
    "library(islhr)",
    "islh_setup()",
    "```",
    "",
    "# Executive summary",
    "",
    "Two or three sentences a busy reader can act on. Write this last.",
    "",
    "# Background",
    "",
    "Why this report exists and what question it answers.",
    "",
    "# Results",
    "",
    "Replace the example data below with your own. Never put identifiable",
    "information in a report, and suppress small cells with `islh_suppress()`",
    "before anything leaves your team.",
    "",
    "```{r}",
    "#| label: fig-encounters",
    '#| fig-cap: "Encounters by programme"',
    paste0(
      '#| fig-alt: "Bar chart of encounters by programme. Primary care is ',
      'highest at 326, then mental health at 184, then public health at 79."'
    ),
    "#| fig-width: 6",
    "#| fig-height: 3.2",
    "",
    "counts <- islh_example_data()",
    "",
    "ggplot2::ggplot(",
    "  counts,",
    "  ggplot2::aes(x = reorder(program, encounters), y = encounters)",
    ") +",
    "  ggplot2::geom_col(fill = islh_brand(\"primary\"), width = 0.7) +",
    "  ggplot2::coord_flip() +",
    "  scale_y_islh_count() +",
    "  ggplot2::labs(x = NULL, y = \"Encounters\")",
    "```",
    "",
    "@fig-encounters shows the distribution across programmes.",
    "",
    "```{r}",
    "#| label: tbl-encounters",
    '#| tbl-cap: "Encounters and median wait by programme"',
    "",
    "# Give columns the names a reader should see, not the ones your data",
    "# happens to use.",
    "counts <- setNames(counts, c(\"Programme\", \"Encounters\", \"Median wait (minutes)\"))",
    "",
    unlist(strsplit(table_call, "\n")),
    "```",
    "",
    "# Recommendations",
    "",
    "What you are asking the reader to do.",
    "",
    "# Next steps",
    "",
    "Who does what, and by when."
  )
}

.islh_project_readme <- function(name, format) {
  c(
    paste0("# ", name),
    "",
    "An Island Health report built with Quarto and the `islhr` package.",
    "",
    "## Rendering it",
    "",
    "1. Open the `.Rproj` file in RStudio.",
    "2. Install what this format needs, once per machine:",
    "",
    "   ```r",
    paste0('   islhr::islh_install_deps("', if (format == "both") "html" else format, '")'),
    "   ```",
    "",
    "3. Open `report.qmd` and click **Render**.",
    "",
    "## If something goes wrong",
    "",
    "- `islhr::islh_check()` reports what is missing or out of date.",
    "- `islhr::islh_help()` lists the functions you will use most.",
    "- BC Sans must be installed on your machine; it is licensed by the BC",
    "  government and cannot be shipped with the package. Without it, output",
    "  falls back to another font.",
    "- On Windows, a path longer than 260 characters silently drops figures.",
    "  Keep the project somewhere short.",
    "- Word locks a file it has open. Close `report.docx` before re-rendering."
  )
}

#' Start a new Island Health report project
#'
#' Writes a Quarto project that renders as it stands: the Island Health format
#' extension, the brand file, an RStudio project file, and a `report.qmd`
#' with a worked example.
#'
#' This replaces the starter-kit ZIPs. Those carried a copy of the theme script
#' in every project, so a theme fix reached nobody until they downloaded a new
#' ZIP. A scaffolded project carries no copy: `report.qmd` calls
#' `library(islhr)`, so it picks up whatever version is installed.
#'
#' @param path Directory to create. Its basename becomes the project name.
#' @param format Output format: `"html"`, `"docx"`, or `"both"`.
#' @param title Report title, used in `report.qmd`'s front matter.
#' @param author Report author. `NULL` leaves the field out.
#' @param example_data Include the example CSV and the worked example.
#' @param rproj Write an RStudio `.Rproj` file.
#' @param overwrite Write into a directory that already has files in it.
#'
#' @return The project path, invisibly.
#' @export
#'
#' @examples
#' project <- file.path(tempdir(), "flu-season-report")
#' islh_create_report(project, format = "html")
#' list.files(project)
islh_create_report <- function(
  path,
  format = c("html", "docx", "both"),
  title = "Island Health report",
  author = NULL,
  example_data = TRUE,
  rproj = TRUE,
  overwrite = FALSE
) {
  format <- match.arg(format)
  name <- basename(normalizePath(path, mustWork = FALSE))

  if (dir.exists(path) && length(list.files(path)) > 0L && !isTRUE(overwrite)) {
    .islh_abort(c(
      "{.file {path}} already has files in it.",
      i = "Pass {.code overwrite = TRUE} to write into it anyway."
    ))
  }
  dir.create(path, recursive = TRUE, showWarnings = FALSE)

  write_lines <- function(lines, file) {
    writeLines(lines, file.path(path, file))
  }

  write_lines(.islh_quarto_yml(format), "_quarto.yml")
  write_lines(.islh_report_qmd(title, author, format), "report.qmd")
  write_lines(.islh_project_readme(name, format), "README.md")
  write_lines(.islh_project_gitignore, ".gitignore")
  if (isTRUE(rproj)) {
    write_lines(.islh_rproj, paste0(name, ".Rproj"))
  }

  if (isTRUE(example_data)) {
    dir.create(file.path(path, "data"), showWarnings = FALSE)
    file.copy(
      .islh_path("extdata", "example-program-counts.csv"),
      file.path(path, "data", "example-program-counts.csv"),
      overwrite = TRUE
    )
  }

  suppressMessages(islh_use_quarto(path, overwrite = TRUE))
  suppressMessages(islh_use_brand(path, overwrite = TRUE))

  install_for <- if (format == "both") "html" else format
  .islh_inform(c(
    "v" = "Created {.file {path}}.",
    "i" = "Open {.file {paste0(name, '.Rproj')}}, then run
           {.code islhr::islh_install_deps(\"{install_for}\")} once.",
    "i" = "Then open {.file report.qmd} and click Render."
  ))

  invisible(path)
}

# Backs the RStudio project template in
# inst/rstudio/templates/project/islh_report.dcf. RStudio creates the
# directory first and passes the widget values as strings, so this is a thin
# adapter around `islh_create_report()` rather than a second implementation.
#
# @noRd
islh_report_skeleton <- function(path, ...) {
  dots <- list(...)

  as_logical <- function(x, default = TRUE) {
    if (is.null(x)) default else isTRUE(x) || identical(x, "On")
  }
  blank_to_null <- function(x) {
    if (is.null(x) || !nzchar(trimws(x))) NULL else x
  }

  islh_create_report(
    path = path,
    format = dots$format %||% "docx",
    title = blank_to_null(dots$title) %||% "Island Health report",
    author = blank_to_null(dots$author),
    example_data = as_logical(dots$example_data),
    rproj = FALSE,      # RStudio writes its own .Rproj for template projects
    overwrite = TRUE    # RStudio creates the directory before calling us
  )
}

`%||%` <- function(x, y) if (is.null(x)) y else x
