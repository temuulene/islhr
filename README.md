# islhr

Island Health branding for R figures, tables and Quarto reports.

`islhr` applies the Island Health brand colour system, BC Sans typography and
report layout to ggplot2 plots, epidemic curves, `flextable` and `gt` tables,
and Quarto HTML and Word output. It also scaffolds a ready-to-render report
project.

Epidemiological calculations and surveillance data preparation are provided by
[`islhepi`](https://github.com/temuulene/islhepi). The packages can be loaded
together in the same report.

Documentation: <https://temuulene.github.io/islhr/>

New users should start with
[Getting started with islhr](https://temuulene.github.io/islhr/articles/islhr.html).
For routine surveillance plots, see the evaluated
[surveillance figures guide](https://temuulene.github.io/islhr/articles/surveillance.html).

## Installing

For staff, use a checked Windows binary from the team's approved release,
with its dependencies preinstalled in a writable user library. Run installation
outside a report render. See [the supported installation guide](inst/INSTALL.md)
and `inst/scripts/install-phase.R` for the base-R bootstrap.

Release assets are created only after release checks pass. A version number in
DESCRIPTION does not mean its ZIP has been published. Download the exact
approved ZIP from GitHub Releases or obtain it from the team lead; the installer
checks the package name and version against your requested version.

Developers can install a reviewed commit using `remotes::install_github()` with
an explicit `ref`. Record both package versions and `sessionInfo()` with every
report.

## Choose the function

| Task | Function |
|---|---|
| Routine surveillance or epidemic curve | `islh_epi_curve()` |
| Branded ggplot | `theme_islh()` and `scale_*_islh()` |
| HTML table | `islh_gt()` |
| Word table | `islh_flextable()` |
| Quarto report project | `islh_create_report()` |
| Health-geography map | `theme_islh_map()` and `coord_islh_map()` |

## Epidemic curves

```r
library(islhr)

weekly_counts <- data.frame(
  period_start = seq(as.Date("2026-01-04"), by = "week", length.out = 8),
  count = c(1, 2, 4, 8, 6, 4, 2, 1)
)

islh_epi_curve(
  weekly_counts,
  date = period_start,
  count = count,
  title = "Reported cases by week"
)
```

Use `style = "cases"` to outline individual cases in a small outbreak. Routine
surveillance defaults to bars for faster rendering. Historical ranges can be
supplied as a separate reference data frame.

When starting from a line list:

```r
counts <- islhepi::islh_count_events(
  events,
  date = event_date,
  id = encounter_id,
  by = region,
  interval = "epiweek",
  fill = TRUE
)

islh_epi_curve(counts, period_start, count, fill = region)
```

## Using it in a report

```r
library(islhr)
islh_setup()
```

`islh_setup()` detects whether you are rendering to HTML or Word and configures
ggplot2 and the matching table engine. Run `islh_help()` for the functions you
will use most.

Start a complete project with:

```r
islhr::islh_create_report("2026-flu-season-report", format = "docx")
```

That writes a Quarto project with the Island Health format extension, brand
file and a worked example already wired up.

## Mapping BC health geographies

Use `islhepi` to retrieve standardized population and geography data, then
apply the map presentation layer from `islhr`:

```r
library(dplyr)
library(ggplot2)
library(islhepi)
library(islhr)

population <- islh_bc_population("lha", years = 2025, sex = "T") |>
  summarise(
    population = sum(population),
    .by = c(geography, geography_code, year, estimate_type)
  )

boundaries <- islh_bc_geography("lha")

map_data <- left_join(
  boundaries,
  population,
  by = join_by(geography, geography_code),
  relationship = "one-to-one",
  na_matches = "never"
)

if (anyNA(map_data$population)) {
  stop("One or more Island Health boundaries did not match population data.")
}

ggplot(map_data, aes(fill = population)) +
  geom_sf(colour = islh_hex("grey", 80), linewidth = 0.25) +
  scale_fill_islh_b(labels = scales::label_comma()) +
  labs(title = "Population by Local Health Area", fill = "Population") +
  theme_islh_map()
```

The population resource covers all of BC. The boundary helper defaults to
Island Health, so population rows from other health authorities are expected
to be discarded by this join.
