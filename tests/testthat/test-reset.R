# islh_setup() changes the session, so every test here has to put it back
# itself or it corrupts the ones that follow.
local_clean_session <- function(env = parent.frame()) {
  state <- .islh_capture_state()
  withr::defer(.islh_restore_state(state), envir = env)
  invisible(state)
}

test_that("setup records a way back and reset takes it", {
  local_clean_session()

  before_theme <- ggplot2::theme_get()
  before_fill <- ggplot2::GeomBar$default_aes$fill
  before_discrete <- getOption("ggplot2.discrete.fill")

  suppressWarnings(islh_setup(format = "plots", quiet = TRUE))

  expect_false(identical(ggplot2::theme_get(), before_theme))
  expect_false(identical(ggplot2::GeomBar$default_aes$fill, before_fill))
  expect_false(is.null(getOption("ggplot2.discrete.fill")))
  expect_equal(getOption("islh.output_format"), "plots")

  expect_true(islh_reset(quiet = TRUE))

  expect_identical(ggplot2::theme_get(), before_theme)
  expect_identical(ggplot2::GeomBar$default_aes$fill, before_fill)
  expect_identical(getOption("ggplot2.discrete.fill"), before_discrete)
  expect_null(getOption("islh.output_format"))
})

test_that("reset restores the knitr device it found", {
  skip_if_not_installed("knitr")
  skip_if_not_installed("ragg")
  local_clean_session()

  before <- knitr::opts_chunk$get("dev")
  suppressWarnings(islh_setup(format = "plots", quiet = TRUE))
  expect_equal(knitr::opts_chunk$get("dev"), "ragg_png")

  islh_reset(quiet = TRUE)
  expect_identical(knitr::opts_chunk$get("dev"), before)
})

test_that("reset on an untouched session reports that there is nothing to do", {
  local_clean_session()
  if (exists("setup", envir = .islh_state, inherits = FALSE)) {
    rm("setup", envir = .islh_state)
  }

  expect_false(islh_reset(quiet = TRUE))
  expect_message(islh_reset(), "has not run")
})

test_that("repeated setup keeps the first way back", {
  local_clean_session()

  before <- ggplot2::theme_get()
  suppressWarnings(islh_setup(format = "plots", base_size = 12, quiet = TRUE))
  first_record <- .islh_state$setup

  suppressWarnings(islh_setup(format = "plots", base_size = 18, quiet = TRUE))

  # The second call must not record the first call's settings as the way back,
  # or reset would leave the Island Health theme applied.
  expect_identical(.islh_state$setup, first_record)

  islh_reset(quiet = TRUE)
  expect_identical(ggplot2::theme_get(), before)
})

test_that("with_islh applies the theme only inside the block", {
  local_clean_session()

  before <- ggplot2::theme_get()
  inside <- suppressWarnings(
    with_islh(ggplot2::theme_get(), format = "plots")
  )

  expect_false(identical(inside, before))
  expect_identical(ggplot2::theme_get(), before)
})

test_that("with_islh restores the session when the block fails", {
  local_clean_session()

  before <- ggplot2::theme_get()
  expect_error(
    suppressWarnings(with_islh(stop("something went wrong"), format = "plots")),
    "something went wrong"
  )
  expect_identical(ggplot2::theme_get(), before)
})

test_that("with_islh returns the value of its code", {
  local_clean_session()
  expect_equal(suppressWarnings(with_islh(6 * 7, format = "plots")), 42)
})

test_that("with_islh nests inside an active setup without undoing it", {
  local_clean_session()

  suppressWarnings(islh_setup(format = "plots", quiet = TRUE))
  active <- ggplot2::theme_get()
  record <- .islh_state$setup

  suppressWarnings(with_islh(invisible(NULL), format = "plots"))

  # Leaving the block must return to the surrounding setup, not remove it.
  expect_identical(ggplot2::theme_get(), active)
  expect_identical(.islh_state$setup, record)

  islh_reset(quiet = TRUE)
  expect_false(exists("setup", envir = .islh_state, inherits = FALSE))
})

test_that("reset arguments are checked", {
  expect_error(islh_reset(quiet = NA), "single TRUE or FALSE")
})
