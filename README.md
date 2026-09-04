# islhr

Island Health branding for R figures, tables and Quarto reports.

`islhr` applies the Island Health brand colour system, BC Sans typography and
report layout to ggplot2 plots, `flextable` and `gt` tables, and Quarto HTML and
Word output. It also scaffolds a ready-to-render report project.

Epidemiological calculations and disclosure-control helpers are provided by
[`islhepi`](https://github.com/temuulene/islhepi). The packages can be loaded
together in the same report.

Documentation: <https://temuulene.github.io/islhr/>

It grew out of the theme script in `islh-brand-standard`, which staff used to
copy into each project by hand.

## Installing

Install the development version from GitHub:

```r
install.packages("remotes", type = "binary")
remotes::install_github("temuulene/islhr")
```

If your network blocks GitHub, ask your team lead for the built package and
install it from the file. No token, GitHub account or compiler is required:

```r
install.packages("path/to/islhr_0.3.0.zip", repos = NULL)
```

Every tagged release attaches that `.zip` for Windows and a `.tar.gz` source
package.

Then install the packages your output format needs:

```r
islhr::islh_install_deps("html")   # "docx", or "both"
```

## Using it

In a Quarto report:

````
```{r}
#| label: setup
#| include: false
library(islhr)
islh_setup()
```
````

`islh_setup()` detects whether you are rendering to HTML or Word and configures
ggplot2 and the matching table engine. Run `islh_help()` for the functions you
will use most.

## Starting a new report

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

See `vignette("maps", package = "islhr")` for the package boundary and a
complete workflow.
