# islhr

Island Health branding for R figures, tables and Quarto reports.

`islhr` applies the Island Health brand colour system, BC Sans typography and
report layout to ggplot2 plots, `flextable` and `gt` tables, and Quarto HTML and
Word output. It also scaffolds a ready-to-render report project and carries the
small-cell suppression helpers the PHASE team uses.

It grew out of the theme script in `islh-brand-standard`, which staff used to
copy into each project by hand.

## Installing

```r
install.packages("remotes", type = "binary")
remotes::install_github("temuulene/islhr")
```

Then install the packages your output format needs:

```r
islhr::islh_install_deps("html")   # or "docx"
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
