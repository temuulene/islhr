# Conditions
#
# Thin wrappers so every message in the package carries consistent formatting
# and, for errors, names the user-facing function rather than the internal
# helper that raised it. `cli` is an Import, so there is no fallback path.
#
# `parent.frame()` in the default argument is evaluated lazily inside
# `.islh_abort()`, so it resolves to whichever function called it.

.islh_abort <- function(message, call = parent.frame()) {
  cli::cli_abort(message, call = call)
}

.islh_warn <- function(message) {
  cli::cli_warn(message)
  invisible(NULL)
}

.islh_inform <- function(message) {
  cli::cli_inform(message)
  invisible(NULL)
}

# Builds the install command shown in error messages. Island Health laptops
# block programs run from a user library, which breaks `pak`, and have no
# compiler, so a source build fails too. Binary installs through base R's
# `install.packages()` are the only route that works. Braces are escaped
# because the result is interpolated into a cli `{.code ...}` span.
.islh_install_command <- function(packages) {
  packages <- unique(packages)
  quoted <- paste(sprintf('"%s"', packages), collapse = ", ")
  command <- paste0('install.packages(c(', quoted, '), type = "binary")')
  gsub("}", "}}", gsub("{", "{{", command, fixed = TRUE), fixed = TRUE)
}

.islh_require <- function(package, feature) {
  if (!requireNamespace(package, quietly = TRUE)) {
    .islh_abort(c(
      "Package {.pkg {package}} is required for {feature}.",
      i = paste0(
        "Install it with {.code ", .islh_install_command(package),
        "} and try again."
      )
    ))
  }
  invisible(TRUE)
}
