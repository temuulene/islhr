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

## Notable changes from the script

* Loading is inert. `library(islhr)` probes no fonts, sets no options and
  prints nothing; all setup happens in `islh_setup()`.
* `islhr` now declares `ggplot2 (>= 3.5.0)`. The discrete scales rely on
  `discrete_scale()` no longer requiring a `scale_name` argument, which was
  undeclared before and failed with a confusing error on ggplot2 3.4.x.
* `islh_theme_version` is replaced by `islh_version()`.
* Dependency checks stay format-specific: HTML setup does not require the Word
  packages, and Word setup does not require `gt`.
