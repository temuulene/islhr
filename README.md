# islhr

Island Health branding for R figures, tables and Quarto reports.

`islhr` applies the Island Health brand colour system, BC Sans typography and
report layout to ggplot2 plots, `flextable` and `gt` tables, and Quarto HTML and
Word output. It also scaffolds a ready-to-render report project.

Epidemiological calculations and disclosure-control helpers are provided by
[`islhepi`](https://github.com/temuulene/islhepi). The packages can be loaded
together in the same report.

It grew out of the theme script in `islh-brand-standard`, which staff used to
copy into each project by hand.

## Installing

**While this repository is private**, `install_github()` needs a GitHub
account with access to it and a personal access token. Create a token with the
`repo` scope at <https://github.com/settings/tokens>, then:

```r
install.packages("remotes", type = "binary")

# Stores the token in ~/.Renviron so you only do this once.
usethis::edit_r_environ()      # add: GITHUB_PAT=ghp_your_token_here
# restart R, then:
remotes::install_github("temuulene/islhr")
```

**If you cannot do that** — no GitHub account, or the network blocks it — ask
your team lead for the built package and install it from the file. No token,
no GitHub, no compiler required:

```r
install.packages("path/to/islhr_0.2.0.zip", repos = NULL)
```

Every tagged release attaches that `.zip` (Windows) and a `.tar.gz`.

Once the repository is public, the `install_github()` line works on its own
with no token.

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
