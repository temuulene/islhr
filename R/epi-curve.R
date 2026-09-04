#' Draw an Island Health epidemic curve
#'
#' `islh_epi_curve()` turns prepared period counts into a branded surveillance
#' figure. It deliberately keeps counting separate from plotting: use
#' `islhepi::islh_count_events()` first when starting from event-level data.
#'
#' @param data A data frame containing one row per plotted group and period.
#' @param date Date column.
#' @param count Whole-count column.
#' @param fill Optional categorical column used to stack or dodge bars.
#' @param facet Optional column used to create small multiples.
#' @param style `"bars"` for routine surveillance or `"cases"` to draw one
#'   outlined rectangle per case. Case tiles are intended for small outbreaks.
#' @param position Stack or dodge grouped bars. Case tiles require stacking.
#' @param labels Show no labels or total counts above each period.
#' @param reference Optional data frame containing a date column and one or more
#'   of `lower_limit`, `upper_limit` and `reference_mean`.
#' @param reference_date Date column in `reference`. Defaults to the name used
#'   by `date` when that column is present.
#' @param lower,upper,reference_mean Column names used for the reference ribbon
#'   and line. Missing optional columns are ignored.
#' @param show_year_lines Draw a separator at the beginning of each new year.
#' @param bar_width Width in days. When `NULL`, the function infers it from the
#'   distance between periods.
#' @param date_breaks,date_labels Values passed to `ggplot2::scale_x_date()`.
#'   Useful defaults are selected when omitted.
#' @param max_cases Maximum number of rectangles allowed with
#'   `style = "cases"`.
#' @param title,subtitle,caption,x,y Plot labels.
#' @param facet_scales Scale behavior passed to `ggplot2::facet_wrap()`.
#'
#' @return A ggplot object. Additional ggplot2 layers and scales can be added in
#'   the usual way.
#'
#' @examples
#' \dontshow{assign("font", "", envir = getFromNamespace(".islh_state", "islhr"))}
#' curve_data <- data.frame(
#'   week = seq(as.Date("2026-01-04"), by = "week", length.out = 12),
#'   cases = c(1, 2, 3, 5, 8, 13, 10, 7, 5, 3, 2, 1),
#'   source = rep(c("Community", "Facility"), 6)
#' )
#'
#' islh_epi_curve(
#'   curve_data,
#'   date = week,
#'   count = cases,
#'   fill = source,
#'   title = "Reported cases by week"
#' )
#'
#' @export
islh_epi_curve <- function(
    data,
    date,
    count,
    fill = NULL,
    facet = NULL,
    style = c("bars", "cases"),
    position = c("stack", "dodge"),
    labels = c("none", "total"),
    reference = NULL,
    reference_date = NULL,
    lower = "lower_limit",
    upper = "upper_limit",
    reference_mean = "reference_mean",
    show_year_lines = TRUE,
    bar_width = NULL,
    date_breaks = NULL,
    date_labels = NULL,
    max_cases = 50000L,
    title = NULL,
    subtitle = NULL,
    caption = NULL,
    x = NULL,
    y = "Cases",
    facet_scales = "fixed") {
  if (!is.data.frame(data)) {
    .islh_abort("{.arg data} must be a data frame.")
  }
  if (nrow(data) == 0L) {
    .islh_abort("{.arg data} must contain at least one row.")
  }
  style <- match.arg(style)
  position <- match.arg(position)
  labels <- match.arg(labels)
  show_year_lines <- .islh_plot_flag(show_year_lines, "show_year_lines")

  date_name <- .islh_plot_column(data, rlang::enquo(date), "date")
  count_name <- .islh_plot_column(data, rlang::enquo(count), "count")
  fill_name <- .islh_plot_column(
    data,
    rlang::enquo(fill),
    "fill",
    optional = TRUE
  )
  facet_name <- .islh_plot_column(
    data,
    rlang::enquo(facet),
    "facet",
    optional = TRUE
  )

  plot_data <- as.data.frame(data)
  plot_data[[date_name]] <- .islh_plot_dates(plot_data[[date_name]], date_name)
  plot_data[[count_name]] <- .islh_plot_counts(
    plot_data[[count_name]],
    count_name
  )

  if (is.null(bar_width)) {
    unique_dates <- sort(unique(plot_data[[date_name]]))
    if (length(unique_dates) < 2L) {
      bar_width <- 0.9
    } else {
      bar_width <- 0.9 * min(as.numeric(diff(unique_dates)))
    }
  }
  if (!is.numeric(bar_width) || length(bar_width) != 1L ||
      is.na(bar_width) || !is.finite(bar_width) || bar_width <= 0) {
    .islh_abort("{.arg bar_width} must be one positive finite number.")
  }
  if (!is.numeric(max_cases) || length(max_cases) != 1L ||
      is.na(max_cases) || max_cases != round(max_cases) || max_cases < 1L) {
    .islh_abort("{.arg max_cases} must be one positive whole number.")
  }

  plot <- ggplot2::ggplot()

  reference_layers <- .islh_plot_reference(
    reference = reference,
    data_date_name = date_name,
    reference_date = reference_date,
    lower = lower,
    upper = upper,
    reference_mean = reference_mean
  )
  if (!is.null(reference_layers$ribbon)) {
    plot <- plot + reference_layers$ribbon
  }
  if (!is.null(reference_layers$line)) {
    plot <- plot + reference_layers$line
  }

  date_range <- range(plot_data[[date_name]])
  if (isTRUE(show_year_lines)) {
    first_year <- as.integer(format(date_range[1], "%Y"))
    last_year <- as.integer(format(date_range[2], "%Y"))
    if (last_year > first_year) {
      year_starts <- as.Date(paste0(seq.int(first_year + 1L, last_year), "-01-01"))
      plot <- plot + ggplot2::geom_vline(
        xintercept = as.numeric(year_starts),
        colour = islh_hex("grey", 40),
        linewidth = 0.35,
        linetype = "dashed"
      )
    }
  }

  mapping <- if (is.null(fill_name)) {
    ggplot2::aes(x = .data[[date_name]], y = .data[[count_name]])
  } else {
    ggplot2::aes(
      x = .data[[date_name]],
      y = .data[[count_name]],
      fill = .data[[fill_name]]
    )
  }

  if (style == "bars") {
    bar_position <- if (position == "stack") {
      "stack"
    } else {
      ggplot2::position_dodge2(width = bar_width, preserve = "single")
    }
    bar_args <- list(
      data = plot_data,
      mapping = mapping,
      width = bar_width,
      position = bar_position,
      colour = "white",
      linewidth = 0.2
    )
    if (is.null(fill_name)) {
      bar_args$fill <- islh_brand("primary")
    }
    bar <- do.call(ggplot2::geom_col, bar_args)
    plot <- plot + bar
  } else {
    if (position != "stack") {
      .islh_abort("{.code style = \"cases\"} only supports stacked groups.")
    }
    case_data <- .islh_expand_cases(
      plot_data,
      date_name = date_name,
      count_name = count_name,
      facet_name = facet_name,
      max_cases = max_cases
    )
    case_mapping <- if (is.null(fill_name)) {
      ggplot2::aes(x = .data[[date_name]], y = .data$.islh_case_y)
    } else {
      ggplot2::aes(
        x = .data[[date_name]],
        y = .data$.islh_case_y,
        fill = .data[[fill_name]]
      )
    }
    case_args <- list(
      data = case_data,
      mapping = case_mapping,
      width = bar_width,
      height = 1,
      colour = "white",
      linewidth = 0.25
    )
    if (is.null(fill_name)) {
      case_args$fill <- islh_brand("primary")
    }
    cases <- do.call(ggplot2::geom_tile, case_args)
    plot <- plot + cases
  }

  if (!is.null(fill_name)) {
    plot <- plot + scale_fill_islh()
  }

  if (labels == "total") {
    totals <- .islh_plot_totals(
      plot_data,
      date_name = date_name,
      count_name = count_name,
      facet_name = facet_name
    )
    label_mapping <- ggplot2::aes(
      x = .data$.islh_date,
      y = .data$.islh_total,
      label = .data$.islh_total
    )
    plot <- plot + ggplot2::geom_text(
      data = totals,
      mapping = label_mapping,
      inherit.aes = FALSE,
      vjust = -0.35,
      size = 3,
      family = islh_font_family(),
      colour = islh_brand("black")
    )
  }

  if (is.null(date_breaks)) {
    span <- as.numeric(diff(date_range))
    date_breaks <- if (span <= 45) {
      "1 week"
    } else if (span <= 180) {
      "1 month"
    } else {
      "3 months"
    }
  }
  if (is.null(date_labels)) {
    date_labels <- if (as.numeric(diff(date_range)) <= 370) "%b %d" else "%b\n%Y"
  }

  plot <- plot +
    ggplot2::scale_x_date(
      date_breaks = date_breaks,
      date_labels = date_labels,
      expand = ggplot2::expansion(mult = c(0.01, 0.02))
    ) +
    scale_y_islh_count() +
    ggplot2::labs(
      title = title,
      subtitle = subtitle,
      caption = caption,
      x = x,
      y = y,
      fill = if (is.null(fill_name)) NULL else fill_name
    ) +
    theme_islh()

  if (!is.null(facet_name)) {
    plot <- plot + ggplot2::facet_wrap(
      ggplot2::vars(!!rlang::sym(facet_name)),
      scales = facet_scales
    )
  }

  plot
}

.islh_plot_column <- function(data, quo, arg, optional = FALSE) {
  if (rlang::quo_is_null(quo)) {
    if (isTRUE(optional)) {
      return(NULL)
    }
    .islh_abort("{.arg {arg}} must select one column.")
  }
  expression <- rlang::get_expr(quo)
  name <- if (rlang::is_symbol(expression)) {
    rlang::as_name(expression)
  } else if (is.character(expression) && length(expression) == 1L) {
    expression
  } else {
    .islh_abort("{.arg {arg}} must be a bare column name or one string.")
  }
  if (!name %in% names(data)) {
    .islh_abort("Column {.field {name}} selected by {.arg {arg}} was not found.")
  }
  name
}

.islh_plot_flag <- function(x, arg) {
  if (!is.logical(x) || length(x) != 1L || is.na(x)) {
    .islh_abort("{.arg {arg}} must be a single TRUE or FALSE.")
  }
  x
}

.islh_plot_dates <- function(x, arg) {
  if (inherits(x, "Date")) {
    out <- as.Date(x)
  } else if (inherits(x, "POSIXt")) {
    out <- as.Date(x)
  } else if (is.character(x) || is.factor(x)) {
    text <- trimws(as.character(x))
    shape_ok <- grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2}$", text)
    out <- suppressWarnings(as.Date(text, format = "%Y-%m-%d"))
    valid <- !is.na(out) & shape_ok & format(out, "%Y-%m-%d") == text
    out[!valid] <- as.Date(NA)
  } else {
    .islh_abort("{.arg {arg}} must contain dates, not {.cls {class(x)[1]}}.")
  }
  if (anyNA(out)) {
    .islh_abort(c(
      "{.arg {arg}} must not contain missing or invalid dates.",
      i = "Use Date values or ISO dates written as YYYY-MM-DD."
    ))
  }
  out
}

.islh_plot_counts <- function(x, arg) {
  if (is.factor(x) || !is.numeric(x) || anyNA(x) || any(!is.finite(x)) ||
      any(x < 0) || any(abs(x - round(x)) > .Machine$double.eps^0.5)) {
    .islh_abort("{.arg {arg}} must contain non-negative finite whole counts.")
  }
  as.numeric(x)
}

.islh_plot_reference <- function(
    reference,
    data_date_name,
    reference_date,
    lower,
    upper,
    reference_mean) {
  empty <- list(ribbon = NULL, line = NULL)
  if (is.null(reference)) {
    return(empty)
  }
  if (!is.data.frame(reference) || nrow(reference) == 0L) {
    .islh_abort("{.arg reference} must be NULL or a non-empty data frame.")
  }
  reference <- as.data.frame(reference)
  if (is.null(reference_date)) {
    reference_date <- if (data_date_name %in% names(reference)) {
      data_date_name
    } else if ("period_start" %in% names(reference)) {
      "period_start"
    } else {
      .islh_abort(
        "Supply {.arg reference_date}; no matching date column was found."
      )
    }
  }
  if (!is.character(reference_date) || length(reference_date) != 1L ||
      !reference_date %in% names(reference)) {
    .islh_abort("{.arg reference_date} must name a column in {.arg reference}.")
  }
  reference[[reference_date]] <- .islh_plot_dates(
    reference[[reference_date]],
    "reference_date"
  )

  fields <- list(
    lower = lower,
    upper = upper,
    reference_mean = reference_mean
  )
  for (field in names(fields)) {
    value <- fields[[field]]
    if (!is.null(value) &&
        (!is.character(value) || length(value) != 1L || is.na(value))) {
      .islh_abort("{.arg {field}} must be NULL or one column name.")
    }
  }

  has_lower <- !is.null(lower) && lower %in% names(reference)
  has_upper <- !is.null(upper) && upper %in% names(reference)
  has_mean <- !is.null(reference_mean) && reference_mean %in% names(reference)
  if (xor(has_lower, has_upper)) {
    .islh_abort(
      "{.arg reference} must contain both lower and upper limits for a ribbon."
    )
  }
  if (!has_lower && !has_upper && !has_mean) {
    .islh_abort(
      "{.arg reference} contains no reference limits or mean column."
    )
  }

  ribbon <- NULL
  if (has_lower && has_upper) {
    limits <- c(reference[[lower]], reference[[upper]])
    if (!is.numeric(limits) || anyNA(limits) || any(!is.finite(limits)) ||
        any(reference[[lower]] > reference[[upper]])) {
      .islh_abort("Reference limits must be finite and lower must not exceed upper.")
    }
    ribbon <- ggplot2::geom_ribbon(
      data = reference,
      mapping = ggplot2::aes(
        x = .data[[reference_date]],
        ymin = .data[[lower]],
        ymax = .data[[upper]]
      ),
      inherit.aes = FALSE,
      fill = islh_hex("grey", 90),
      alpha = 0.7
    )
  }

  line <- NULL
  if (has_mean) {
    if (!is.numeric(reference[[reference_mean]]) ||
        anyNA(reference[[reference_mean]]) ||
        any(!is.finite(reference[[reference_mean]]))) {
      .islh_abort("The reference mean must be finite and non-missing.")
    }
    line <- ggplot2::geom_line(
      data = reference,
      mapping = ggplot2::aes(
        x = .data[[reference_date]],
        y = .data[[reference_mean]],
        group = 1
      ),
      inherit.aes = FALSE,
      colour = islh_hex("grey", 40),
      linewidth = 0.65,
      linetype = "dashed"
    )
  }

  list(ribbon = ribbon, line = line)
}

.islh_expand_cases <- function(
    data,
    date_name,
    count_name,
    facet_name,
    max_cases) {
  total <- sum(data[[count_name]])
  if (total > max_cases) {
    .islh_abort(c(
      "{.code style = \"cases\"} would draw {total} rectangles.",
      i = "Use {.code style = \"bars\"} or increase {.arg max_cases} explicitly."
    ))
  }

  key_data <- data[date_name]
  if (!is.null(facet_name)) {
    key_data[[facet_name]] <- data[[facet_name]]
  }
  key <- do.call(
    interaction,
    c(
      lapply(key_data, function(x) addNA(as.factor(x))),
      list(drop = TRUE, lex.order = TRUE)
    )
  )
  offset <- stats::ave(
    data[[count_name]],
    key,
    FUN = function(x) cumsum(x) - x
  )
  row_index <- rep(seq_len(nrow(data)), times = data[[count_name]])
  expanded <- data[row_index, , drop = FALSE]
  expanded$.islh_case_y <- unlist(
    Map(
      function(n, start) {
        if (n == 0) numeric() else start + seq_len(n) - 0.5
      },
      data[[count_name]],
      offset
    ),
    use.names = FALSE
  )
  rownames(expanded) <- NULL
  expanded
}

.islh_plot_totals <- function(data, date_name, count_name, facet_name) {
  by <- list(.islh_date = data[[date_name]])
  if (!is.null(facet_name)) {
    by[[facet_name]] <- data[[facet_name]]
  }
  out <- stats::aggregate(data[[count_name]], by = by, FUN = sum)
  names(out)[names(out) == "x"] <- ".islh_total"
  out
}
