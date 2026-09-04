# islhr 0.4.0

## Maps

* Added `coord_islh_map()`, which locks a map to BC Albers (EPSG:3005), the
  projection BC Data Catalogue and BC Stats layers already use. Latitude and
  longitude stretches Vancouver Island sideways and distorts area. It also
  drops the graticule and the panel expansion.
* Added `islh_caption()`, which builds a caption from its parts: source,
  extraction date, boundary vintage, standard population, suppression rule
  and, where the geography covers First Nations communities, a data
  governance statement.
* `scale_fill_islh_b()` now fills areas with no data in a grey lighter than
  every bin. The categorical unknown grey matched the lightest bin in
  lightness, so a greyscale print could not tell no data from the lowest
  band. Suppressed cells still belong in their own layer with their own
  legend key.
* `theme_islh_map()` gained `legend = "inside"`, which puts the legend in the
  open water off the west coast. Island Health runs northwest to southeast,
  and `coord_sf()` fixes the aspect ratio, so a bottom legend costs map area
  that a wider figure cannot win back.
* `islh_caption()` wraps at 100 characters, because ggplot2 draws a caption on
  one line and lets it run off the side of the figure.
* `theme_islh()` now styles the legend title alongside the rest of the brand
  text hierarchy, which the map theme shares.
* `theme_islh_map()` now starts from `ggplot2::theme_void()` and adds the
  brand text hierarchy, rather than stripping `theme_islh()` down element by
  element. It also paints an opaque white background, since a transparent one
  reads as a broken figure in Word and PowerPoint.

# islhr 0.3.1

## Fixes

* `scale_fill_islh_b()` now draws a legend wide enough to label. The
  `coloursteps` guide inherited the qualitative key size from `theme_islh()`,
  which squeezed the colour bar until its break labels printed on top of each
  other. The bar is wider, the title sits above it, and counts are abbreviated
  (`12,500` prints as `12.5K`) unless you pass your own `labels`.
* `theme_islh()` registers the brand font with the Windows font database, so a
  plot themed without calling `islh_setup()` first no longer floods the console
  with "font family not found in Windows font database" warnings.
* `theme_islh_map()` now removes the axis lines and tick marks that framed a
  map in a box. `theme_islh()` sets `axis.line.x` and `axis.ticks.x` directly,
  and a blank parent element does not override a child that is already set, so
  the map theme blanks the children too.

# islhr 0.3.0

## Geographic reporting

* Added `theme_islh_map()` for branded maps without axes, ticks or panel grids.
* Added a map workflow that combines `islhepi` BC Data Catalogue retrieval
  with `islhr` choropleth scales and presentation styling.
* Kept population and boundary retrieval out of `islhr`, preserving its scope
  as the branding and reporting package.
* Corrected the mapping example for provincial population data joined to the
  default Island Health boundary subset.

# islhr 0.2.0

## Package scope

* `islhr` now focuses on Island Health branding, figures, tables and Quarto
  report scaffolding.
* Analytical methods moved to the separate `islhepi` package. The public
  interfaces are unchanged there: `islh_age_group()`, `islh_ci_poisson()`,
  `islh_crude_rate()`, `islh_dsr()`, `islh_suppress()`,
  `islh_suppress_table()` and `islh_round_base()`.
* New report scaffolds direct small-cell suppression to
  `islhepi::islh_suppress()`.

# islhr 0.1.0

## Fixes from the pre-release code review

The first release candidate was reviewed before distribution. These are the
changes that came out of it; the disclosure-control ones could have put wrong
numbers in a published report.

* `islh_suppress_table()` no longer labels a complementary cell with the label
  meant for small cells. With `complementary = TRUE` and `label = "<5"`, a
  value of 17 was displayed as `<5`, a false statement about the data.
  Complementary cells now take a separate neutral `complementary_label`,
  defaulting to `"Suppressed"`. Compact numeric labels are checked against the
  threshold rule, and invalid logical policy switches now fail closed.
* `islh_suppress()` rejects factors instead of converting them. `as.numeric()`
  on a factor returns level codes, so `factor(c("10", "3", "42"))` was read as
  1, 2, 3 and every cell suppressed.
* Counts must now be whole, non-negative and finite everywhere they are
  accepted. Negative, fractional and infinite values used to pass through.
* `islh_round_base()` requires `base`. A default silently made a disclosure
  policy decision, which the package elsewhere refuses to do.
* `islh_ci_poisson()`, `islh_crude_rate()` and `islh_dsr()` validate their
  inputs: whole counts, positive denominators and `per`, matching vector
  lengths, and a standard population with a positive total. Event counts may
  exceed population or person-time denominators when events can recur. An
  all-zero standard population returned `NA` rather than an error, and a
  missing stratum quietly poisoned a standardised rate.
* `islh_install_deps("both")` installs the HTML and Word stacks together. A
  project scaffolded with `format = "both"` was told to install only the HTML
  packages, so its Word render failed at the table.
* `_brand.yml`'s logo paths pointed at the old asset repository's folder
  layout, so every image it named was missing once copied. The paths are
  rewritten and `islh_use_brand()` now copies the logos alongside the file.
* Every file copy and directory creation is checked. A failed write on a
  network share or a read-only folder reported success.
* Word tables have fixed column widths that sum to the text width, so Word and
  LibreOffice lay a document out the same way. They were autofit, which left
  sizing to whichever program opened the file.
* `islh_create_report()` escapes the title and author into YAML, and
  `example_data = FALSE` now omits the worked example rather than leaving a
  report that calls `islh_example_data()` with no data file.
* The scaffold no longer sets a table caption twice, which printed two
  headings in HTML.
* BC Sans is described as "not shipped" rather than "cannot be shipped": it is
  under the SIL Open Font License 1.1, as the package's own webfont notice says.

* Word figure captions now default to the top, and the reference document
  keeps each caption with the following image across page breaks.

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
