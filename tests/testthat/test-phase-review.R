test_that("returned scoped plots retain style after reset", {
  old <- ggplot2::theme_get()
  p <- suppressWarnings(with_islh(
    ggplot2::ggplot(mtcars, ggplot2::aes(wt, mpg)) + ggplot2::geom_point(),
    format = "plots",
    set_knitr = FALSE
  ))
  expect_equal(ggplot2::theme_get(), old)
  built <- ggplot2::ggplot_build(p)
  expect_equal(unique(built$data[[1]]$colour), islh_brand("primary"))
  expect_true(length(p$theme) > 0)
})

test_that("epidemic curve timestamps follow local reporting dates", {
  stamp <- as.POSIXct("2026-07-05 23:30:00", tz = "America/Vancouver")
  expect_equal(.islh_plot_dates(stamp, "date"), as.Date("2026-07-05"))
  expect_equal(.islh_plot_dates(stamp, "date", "UTC"), as.Date("2026-07-06"))
})

test_that("branding preserves semantic body colours", {
  skip_if_not_installed("flextable", "0.9.10")
  ft <- flextable::flextable(data.frame(result = "Review"))
  ft <- flextable::color(ft, color = "red", part = "body")
  ft <- flextable::bg(ft, bg = "yellow", part = "body")
  styled <- suppressWarnings(islh_flextable(ft))
  expect_equal(
    styled$body$styles$text$color$data,
    ft$body$styles$text$color$data
  )
  expect_equal(
    styled$body$styles$cells$background.color$data,
    ft$body$styles$cells$background.color$data
  )
})

test_that("branding does not choose gtsummary statistics", {
  skip_if_not_installed("gtsummary")
  th <- .islh_gtsummary_theme(set_theme = FALSE, quiet = TRUE)
  expect_false(any(grepl(
    "statistic|digits|missing_text|pvalue_fun|percent_fun",
    names(th)
  )))
  preset <- islh_gtsummary_statistics(set_theme = FALSE)
  expect_true("tbl_summary-arg:statistic" %in% names(preset))
})

test_that("setup errors roll back partially changed state", {
  state <- .islh_capture_state()
  withr::defer(.islh_restore_state(state))
  old_theme <- ggplot2::theme_get()
  old_fill <- getOption("ggplot2.discrete.fill")
  local_mocked_bindings(.islh_use_theme = function(...) {
    ggplot2::theme_set(ggplot2::theme_void())
    options(ggplot2.discrete.fill = "broken")
    stop("deliberate setup failure")
  })
  expect_error(
    suppressWarnings(islh_setup(format = "plots", quiet = TRUE)),
    "deliberate setup failure"
  )
  expect_identical(ggplot2::theme_get(), old_theme)
  expect_identical(getOption("ggplot2.discrete.fill"), old_fill)
})

test_that("each document registers its own cached webfont", {
  skip_if_not_installed("knitr")
  skip_if_not_installed("htmltools")
  old <- knitr::knit_meta(clean = TRUE)
  withr::defer({
    knitr::knit_meta(clean = TRUE)
    knitr::knit_meta_add(old)
  })
  local_mocked_bindings(.islh_bc_sans_webfont_css = function(...) {
    "/* fixture */"
  })
  .islh_register_webfont_dependency()
  first <- knitr::knit_meta(clean = TRUE)
  .islh_register_webfont_dependency()
  second <- knitr::knit_meta(clean = TRUE)
  expect_true(any(vapply(
    first,
    function(x) identical(x$name, "islh-bc-sans"),
    logical(1)
  )))
  expect_true(any(vapply(
    second,
    function(x) identical(x$name, "islh-bc-sans"),
    logical(1)
  )))
})
