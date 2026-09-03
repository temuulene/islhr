# islhr 0.1.0

First release of `islhr` as an R package.

The Island Health plot and table themes previously shipped as a single script
that staff copied into each project and loaded with `source()`. They are now a
package, so a theme fix reaches every report on the next install instead of the
next re-download.

## Getting started

* `islh_setup()` configures ggplot2 and the table engine for the output format
  you are rendering to, detecting HTML vs Word automatically under Quarto.
* `islh_check()` reports which packages a given format needs, and
  `islh_install_deps()` installs the missing ones as binaries.
* `islh_create_report()` writes a ready-to-render Quarto project, replacing the
  starter-kit ZIPs.
* `islh_help()` prints a grouped quick reference.

## Fixes carried over from the script

Three error messages could never be built, because `cli` interpolates in the
calling frame and the wrappers did not forward it, or because a message held
two quantities and `cli` could not tell which the plural marker referred to.
Each failed with a `cli` error instead of saying what was wrong:

* `islh_hex()` with a value that is not a ramp step now names the value and
  lists the steps that exist.
* `.islh_require()` now names the missing package and the feature that needed
  it, with the command to install it.
* `islh_setup()` now names a package that is installed but too old, rather
  than printing an empty bullet.

## Notable changes from the script

* Loading is inert. `library(islhr)` probes no fonts, sets no options and
  prints nothing; all setup happens in `islh_setup()`.
* `islhr` now declares `ggplot2 (>= 3.5.0)`. The discrete scales rely on
  `discrete_scale()` no longer requiring a `scale_name` argument, which was
  undeclared before and failed with a confusing error on ggplot2 3.4.x.
* `islh_theme_version` is replaced by `islh_version()`.
* Dependency checks stay format-specific: HTML setup does not require the Word
  packages, and Word setup does not require `gt`.
