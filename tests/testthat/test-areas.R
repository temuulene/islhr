# Adjacency of Island Health's local health areas, computed from the BC Data
# Catalogue boundaries (WHSE_ADMIN_BOUNDARIES.BCHA_LOCAL_HEALTH_AREA_SP) by
# intersecting each area, buffered by 200 m, with the others.
lha_neighbours <- list(
  "411" = c("412", "413"),
  "412" = c("411", "413", "421", "422"),
  "413" = c("411", "412"),
  "414" = character(),
  "421" = c("412", "422", "423"),
  "422" = c("412", "421", "423", "424", "426"),
  "423" = c("421", "422", "424"),
  "424" = c("422", "423", "425", "426"),
  "425" = c("424", "426", "431"),
  "426" = c("422", "424", "425", "431", "432", "433"),
  "431" = c("425", "426", "432"),
  "432" = c("426", "431", "433", "434"),
  "433" = c("426", "432", "434"),
  "434" = c("432", "433")
)

test_that("the 14 local health areas carry their catalogue codes and names", {
  lha <- islh_areas()
  expect_equal(nrow(lha), 14L)
  expect_equal(
    lha$code,
    c(as.character(411:414), as.character(421:426), as.character(431:434))
  )
  expect_equal(
    lha$name[lha$code %in% c("421", "422", "426")],
    c("Cowichan Valley South", "Cowichan Valley West", "Alberni/Clayoquot")
  )
  expect_equal(
    as.vector(table(lha$hsda)[unique(lha$hsda)]),
    c(4L, 6L, 4L)
  )
  expect_false(anyDuplicated(lha$colour) > 0)
})

value_of <- function(hex) {
  # Find each colour's family and value in the brand ramp.
  ramp <- unlist(islhr:::.islh_colours)
  hit <- names(ramp)[match(toupper(hex), toupper(ramp))]
  data.frame(
    family = sub("\\..*$", "", hit),
    value = as.numeric(sub("^.*\\.", "", hit))
  )
}

test_that("each HSDA uses one low-signal family and every fill is dark enough", {
  lha <- islh_areas()
  found <- value_of(lha$colour)
  expect_false(anyNA(found$value))

  # The brand standard keeps Red, Green and Orange for signal meanings and
  # Grey for "inactive"; Blue, Cedar and Thistle organise content.
  families <- tapply(found$family, lha$hsda, unique)
  expect_equal(
    as.vector(unlist(families[unique(lha$hsda)], use.names = FALSE)),
    c("blue", "cedar", "thistle")
  )

  # Graphics need 30 values of contrast with a white page.
  expect_true(all(found$value <= 70))

  # Large labels need 50: every fill is white-text dark or Grey 10-text light.
  expect_true(all(found$value <= 50 | found$value >= 60))
  expect_equal(
    lha$label_colour,
    ifelse(found$value <= 50, "#FFFFFF", islh_hex("grey", 10))
  )
})

test_that("neighbouring areas are far apart in value", {
  lha <- islh_areas()
  value <- stats::setNames(value_of(lha$colour)$value, lha$code)
  hsda <- stats::setNames(substr(lha$code, 1, 2), lha$code)

  for (code in names(lha_neighbours)) {
    for (neighbour in lha_neighbours[[code]]) {
      gap <- abs(value[[code]] - value[[neighbour]])
      same <- hsda[[code]] == hsda[[neighbour]]
      expect_gte(gap, if (same) 20 else 10)
      # Blue and Thistle are the pair protanopia confuses; they must never
      # meet, so South and North Vancouver Island must never touch.
      expect_false(setequal(c(hsda[[code]], hsda[[neighbour]]), c("41", "43")))
    }
  }

  # Within an HSDA, no two areas share a value.
  expect_true(all(tapply(value, hsda, function(v) !anyDuplicated(v))))
})

test_that("HSDA colours are the representative colour of each family", {
  hsda <- islh_areas("hsda")
  expect_equal(hsda$code, c("41", "42", "43"))
  expect_equal(
    hsda$colour,
    c(islh_hex("blue", 50), islh_hex("cedar", 60), islh_hex("thistle", 50))
  )
})

test_that("the scale matches names, codes and common spellings", {
  data <- data.frame(
    area = c("Greater Nanaimo", "424", "Alberni-Clayoquot", "Comox Valley"),
    y = 1:4
  )
  plot <- ggplot2::ggplot(data, ggplot2::aes(area, y, fill = area)) +
    ggplot2::geom_col() +
    scale_fill_islh_area()
  fills <- ggplot2::ggplot_build(plot)$data[[1]]$fill

  colours <- stats::setNames(islh_areas()$colour, islh_areas()$name)
  expected <- colours[c(
    "Greater Nanaimo",
    "Greater Nanaimo",
    "Alberni/Clayoquot",
    "Comox Valley"
  )]
  # geom_col() orders bars by the x factor levels, which are alphabetical.
  expect_setequal(fills, unname(expected))
})

test_that("the legend follows code order, not alphabetical order", {
  data <- data.frame(
    area = c("Vancouver Island North", "Greater Victoria", "Oceanside"),
    y = 1
  )
  plot <- ggplot2::ggplot(data, ggplot2::aes(area, y, fill = area)) +
    ggplot2::geom_col() +
    scale_fill_islh_area()
  legend <- ggplot2::get_guide_data(plot, "fill")
  expect_equal(
    legend$.label,
    c("Greater Victoria", "Oceanside", "Vancouver Island North")
  )
})

test_that("an unknown area warns once and is drawn as missing", {
  data <- data.frame(area = c("Oceansid", "Oceanside"), y = 1)
  plot <- ggplot2::ggplot(data, ggplot2::aes(area, y, colour = area)) +
    ggplot2::geom_point() +
    scale_colour_islh_area()

  warnings <- character()
  built <- withCallingHandlers(
    ggplot2::ggplot_build(plot),
    warning = function(condition) {
      warnings <<- c(warnings, conditionMessage(condition))
      invokeRestart("muffleWarning")
    }
  )
  expect_length(grep("Oceansid", warnings), 1L)
  expect_true(.islh_unknown() %in% built$data[[1]]$colour)
})

test_that("the HSDA level works the same way", {
  data <- data.frame(area = c("42", "North Vancouver Island"), y = 1)
  plot <- ggplot2::ggplot(data, ggplot2::aes(area, y, fill = area)) +
    ggplot2::geom_col() +
    scale_fill_islh_area("hsda")
  expect_setequal(
    ggplot2::ggplot_build(plot)$data[[1]]$fill,
    c(islh_hex("cedar", 60), islh_hex("thistle", 50))
  )
  expect_error(scale_fill_islh_area("chsa"))
})
