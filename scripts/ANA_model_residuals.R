# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# ESM residual diagnostics
# out-of-fold residual maps + residual correlograms
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# packages

pkgs <- c(
  "here",
  "terra",
  "sf",
  "dplyr",
  "tidyr",
  "ggplot2",
  "readr",
  "spdep"
)

missing_pkgs <- pkgs[!base::vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]

if (base::length(missing_pkgs) > 0) {
  base::stop(
    "Install missing packages first: ",
    base::paste(missing_pkgs, collapse = ", ")
  )
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# main config

modelling_id <- "recent_extrapol_weights_all_selected"

species <- c("GD", "GT", "SB", "PK", "PO", "PP")
grains <- c(1000, 500, 200, 100)

crs_epsg <- 3035

# For correlogram. Coordinates are in EPSG:3035, therefore metres.
# I would start with 10 km classes up to 200 km.
# Later this can be tuned according to point density.
lag_breaks_m <- base::seq(0, 200000, by = 10000)

# minimum number of point pairs within a distance class
min_pairs <- 20

# max cells used only for plotting raster background
# does not affect residual calculations
max_plot_cells <- 500000

esm_base_dir <- here::here("models", "ESM", modelling_id)

diag_base_dir <- here::here(
  "models",
  "ESM",
  modelling_id,
  "_residual_diagnostics"
)

if (!base::dir.exists(diag_base_dir)) {
  base::dir.create(diag_base_dir, recursive = TRUE, showWarnings = FALSE)
}

tasks <- base::expand.grid(
  sp = species,
  grain = grains,
  KEEP.OUT.ATTRS = FALSE,
  stringsAsFactors = FALSE
)

tasks <- tasks |>
  dplyr::arrange(dplyr::desc(grain))

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# helper: raster to df for plotting

raster_to_plot_df <- function(r, max_cells = 500000) {
  
  if (terra::nlyr(r) != 1) {
    r <- r[[1]]
  }
  
  if (terra::ncell(r) > max_cells) {
    fact <- base::ceiling(base::sqrt(terra::ncell(r) / max_cells))
    r <- terra::aggregate(
      x = r,
      fact = fact,
      fun = mean,
      na.rm = TRUE
    )
  }
  
  names(r) <- "suitability"
  
  out <- terra::as.data.frame(
    x = r,
    xy = TRUE,
    na.rm = TRUE
  )
  
  return(out)
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# helper: residual table

make_residual_table <- function(esm, sp, grain) {
  
  if (base::is.null(esm$data)) {
    base::stop("esm$data is missing.")
  }
  
  if (base::is.null(esm$oof_pred)) {
    base::stop("esm$oof_pred is missing.")
  }
  
  data <- base::as.data.frame(esm$data)
  
  needed <- c("observ", "X", "Y")
  missing_needed <- base::setdiff(needed, base::names(data))
  
  if (base::length(missing_needed) > 0) {
    base::stop(
      "esm$data is missing columns: ",
      base::paste(missing_needed, collapse = ", ")
    )
  }
  
  if (base::nrow(data) != base::length(esm$oof_pred)) {
    base::stop("nrow(esm$data) and length(esm$oof_pred) differ.")
  }
  
  out <- data |>
    dplyr::mutate(
      species = sp,
      grain = grain,
      pred_oof = base::as.numeric(esm$oof_pred),
      residual = observ - pred_oof,
      residual_abs = base::abs(residual),
      residual_class = dplyr::case_when(
        base::is.na(pred_oof) ~ "missing_oof_prediction",
        residual > 0 ~ "underpredicted_presence",
        residual < 0 ~ "overpredicted_absence",
        TRUE ~ "zero_residual"
      ),
      .before = 1
    )
  
  return(out)
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# helper: residual sf

make_residual_sf <- function(residual_df, crs_epsg = 3035) {
  
  out <- sf::st_as_sf(
    residual_df,
    coords = c("X", "Y"),
    crs = crs_epsg,
    remove = FALSE
  )
  
  return(out)
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# helper: Moran correlogram from residuals

make_moran_correlogram <- function(
    residual_df,
    lag_breaks_m,
    min_pairs = 20
) {
  
  dat <- residual_df |>
    dplyr::filter(
      !base::is.na(X),
      !base::is.na(Y),
      !base::is.na(residual)
    )
  
  if (base::nrow(dat) < 5) {
    return(
      base::data.frame(
        lag_min_m = numeric(0),
        lag_max_m = numeric(0),
        lag_mid_m = numeric(0),
        moran_i = numeric(0),
        expected_i = numeric(0),
        variance_i = numeric(0),
        p_value = numeric(0),
        n_pairs = numeric(0),
        note = character(0)
      )
    )
  }
  
  if (base::length(base::unique(dat$residual)) < 2) {
    return(
      base::data.frame(
        lag_min_m = lag_breaks_m[-base::length(lag_breaks_m)],
        lag_max_m = lag_breaks_m[-1],
        lag_mid_m = (
          lag_breaks_m[-base::length(lag_breaks_m)] +
            lag_breaks_m[-1]
        ) / 2,
        moran_i = NA_real_,
        expected_i = NA_real_,
        variance_i = NA_real_,
        p_value = NA_real_,
        n_pairs = NA_real_,
        note = "constant residuals"
      )
    )
  }
  
  coords <- base::as.matrix(dat[, c("X", "Y")])
  z <- dat$residual
  
  out <- vector("list", base::length(lag_breaks_m) - 1L)
  
  for (i in base::seq_len(base::length(lag_breaks_m) - 1L)) {
    
    d1 <- lag_breaks_m[[i]]
    d2 <- lag_breaks_m[[i + 1L]]
    
    nb <- spdep::dnearneigh(
      x = coords,
      d1 = d1,
      d2 = d2,
      longlat = FALSE
    )
    
    n_pairs <- base::sum(spdep::card(nb)) / 2
    
    if (base::is.na(n_pairs) || n_pairs < min_pairs) {
      out[[i]] <- base::data.frame(
        lag_min_m = d1,
        lag_max_m = d2,
        lag_mid_m = (d1 + d2) / 2,
        moran_i = NA_real_,
        expected_i = NA_real_,
        variance_i = NA_real_,
        p_value = NA_real_,
        n_pairs = n_pairs,
        note = "too few pairs",
        stringsAsFactors = FALSE
      )
      
      next
    }
    
    lw <- spdep::nb2listw(
      neighbours = nb,
      style = "W",
      zero.policy = TRUE
    )
    
    mt <- base::tryCatch(
      spdep::moran.test(
        x = z,
        listw = lw,
        zero.policy = TRUE,
        alternative = "two.sided"
      ),
      error = function(e) NULL
    )
    
    if (base::is.null(mt)) {
      out[[i]] <- base::data.frame(
        lag_min_m = d1,
        lag_max_m = d2,
        lag_mid_m = (d1 + d2) / 2,
        moran_i = NA_real_,
        expected_i = NA_real_,
        variance_i = NA_real_,
        p_value = NA_real_,
        n_pairs = n_pairs,
        note = "moran.test failed",
        stringsAsFactors = FALSE
      )
      
      next
    }
    
    out[[i]] <- base::data.frame(
      lag_min_m = d1,
      lag_max_m = d2,
      lag_mid_m = (d1 + d2) / 2,
      moran_i = base::as.numeric(mt$estimate[["Moran I statistic"]]),
      expected_i = base::as.numeric(mt$estimate[["Expectation"]]),
      variance_i = base::as.numeric(mt$estimate[["Variance"]]),
      p_value = mt$p.value,
      n_pairs = n_pairs,
      note = "ok",
      stringsAsFactors = FALSE
    )
  }
  
  out <- dplyr::bind_rows(out)
  
  return(out)
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# helper: residual map

plot_residual_map <- function(
    residual_df,
    projection_raster,
    out_file,
    title = NULL,
    max_cells = 500000
) {
  
  proj_df <- raster_to_plot_df(
    r = projection_raster,
    max_cells = max_cells
  )
  
  p <- ggplot2::ggplot() +
    ggplot2::geom_raster(
      data = proj_df,
      ggplot2::aes(
        x = x,
        y = y,
        fill = suitability
      )
    ) +
    ggplot2::scale_fill_viridis_c(
      name = "ESM suitability",
      na.value = NA
    ) +
    ggplot2::geom_point(
      data = residual_df,
      ggplot2::aes(
        x = X,
        y = Y,
        colour = residual,
        size = residual_abs
      ),
      alpha = 0.85
    ) +
    ggplot2::scale_colour_gradient2(
      name = "Residual\nobs - pred",
      midpoint = 0
    ) +
    ggplot2::scale_size_continuous(
      name = "|Residual|",
      range = c(0.7, 4.0)
    ) +
    ggplot2::coord_equal() +
    ggplot2::labs(
      title = title,
      x = NULL,
      y = NULL
    ) +
    ggplot2::theme_bw() +
    ggplot2::theme(
      panel.grid = ggplot2::element_blank()
    )
  
  ggplot2::ggsave(
    filename = out_file,
    plot = p,
    width = 8,
    height = 7,
    dpi = 300
  )
  
  return(p)
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# helper: correlogram plot

plot_correlogram <- function(correlogram_df, out_file, title = NULL) {
  
  p <- ggplot2::ggplot(
    correlogram_df,
    ggplot2::aes(
      x = lag_mid_m / 1000,
      y = moran_i
    )
  ) +
    ggplot2::geom_hline(
      yintercept = 0,
      linewidth = 0.3
    ) +
    ggplot2::geom_line(
      na.rm = TRUE
    ) +
    ggplot2::geom_point(
      ggplot2::aes(
        shape = !base::is.na(p_value) & p_value < 0.05
      ),
      size = 2,
      na.rm = TRUE
    ) +
    ggplot2::scale_shape_manual(
      values = c(`TRUE` = 16, `FALSE` = 1),
      name = "p < 0.05"
    ) +
    ggplot2::labs(
      title = title,
      x = "Distance class midpoint [km]",
      y = "Moran's I"
    ) +
    ggplot2::theme_bw()
  
  ggplot2::ggsave(
    filename = out_file,
    plot = p,
    width = 7,
    height = 4.5,
    dpi = 300
  )
  
  return(p)
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# helper: one task

process_one_task <- function(
    sp,
    grain,
    esm_base_dir,
    diag_base_dir,
    lag_breaks_m,
    min_pairs,
    crs_epsg,
    max_plot_cells
) {
  
  message("Processing residual diagnostics: ", sp, " | ", grain, " m")
  
  mod_dir <- base::file.path(
    esm_base_dir,
    sp,
    base::as.character(grain)
  )
  
  esm_file <- base::file.path(mod_dir, "esm_fit_bivariate.rds")
  proj_file <- base::file.path(mod_dir, "ESM_projection.tif")
  
  if (!base::file.exists(esm_file)) {
    base::stop("Missing file: ", esm_file)
  }
  
  if (!base::file.exists(proj_file)) {
    base::stop("Missing file: ", proj_file)
  }
  
  out_dir <- base::file.path(
    diag_base_dir,
    sp,
    base::as.character(grain)
  )
  
  if (!base::dir.exists(out_dir)) {
    base::dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  }
  
  esm <- base::readRDS(esm_file)
  proj <- terra::rast(proj_file)
  
  residual_df <- make_residual_table(
    esm = esm,
    sp = sp,
    grain = grain
  )
  
  residual_sf <- make_residual_sf(
    residual_df = residual_df,
    crs_epsg = crs_epsg
  )
  
  correlogram_df <- make_moran_correlogram(
    residual_df = residual_df,
    lag_breaks_m = lag_breaks_m,
    min_pairs = min_pairs
  ) |>
    dplyr::mutate(
      species = sp,
      grain = grain,
      .before = 1
    )
  
  residual_csv <- base::file.path(out_dir, "oof_residuals.csv")
  residual_gpkg <- base::file.path(out_dir, "oof_residuals.gpkg")
  correlogram_csv <- base::file.path(out_dir, "residual_moran_correlogram.csv")
  
  readr::write_csv(
    x = residual_df,
    file = residual_csv
  )
  
  sf::st_write(
    obj = residual_sf,
    dsn = residual_gpkg,
    delete_dsn = TRUE,
    quiet = TRUE
  )
  
  readr::write_csv(
    x = correlogram_df,
    file = correlogram_csv
  )
  
  residual_map_file <- base::file.path(
    out_dir,
    "residual_map_over_ESM_projection.png"
  )
  
  correlogram_plot_file <- base::file.path(
    out_dir,
    "residual_moran_correlogram.png"
  )
  
  plot_residual_map(
    residual_df = residual_df,
    projection_raster = proj,
    out_file = residual_map_file,
    title = base::paste0(sp, " | ", grain, " m | OOF residuals over ESM projection"),
    max_cells = max_plot_cells
  )
  
  plot_correlogram(
    correlogram_df = correlogram_df,
    out_file = correlogram_plot_file,
    title = base::paste0(sp, " | ", grain, " m | residual Moran correlogram")
  )
  
  sig_pos <- correlogram_df |>
    dplyr::filter(
      !base::is.na(moran_i),
      !base::is.na(p_value),
      moran_i > 0,
      p_value < 0.05
    )
  
  residual_sac_range_m <- if (base::nrow(sig_pos) > 0) {
    base::max(sig_pos$lag_max_m, na.rm = TRUE)
  } else {
    0
  }
  
  first_valid <- base::which(!base::is.na(correlogram_df$moran_i))[1]
  
  summary_df <- residual_df |>
    dplyr::summarise(
      species = sp,
      grain = grain,
      n = dplyr::n(),
      n_presence = base::sum(observ == 1, na.rm = TRUE),
      n_absence = base::sum(observ == 0, na.rm = TRUE),
      mean_residual = base::mean(residual, na.rm = TRUE),
      mean_abs_residual = base::mean(residual_abs, na.rm = TRUE),
      rmse = base::sqrt(base::mean(residual^2, na.rm = TRUE)),
      oof_somers_d = if (!base::is.null(esm$oof_somers_d)) esm$oof_somers_d else NA_real_,
      first_lag_moran_i = if (!base::is.na(first_valid)) correlogram_df$moran_i[[first_valid]] else NA_real_,
      first_lag_p_value = if (!base::is.na(first_valid)) correlogram_df$p_value[[first_valid]] else NA_real_,
      residual_sac_range_m = residual_sac_range_m
    )
  
  return(
    list(
      summary = summary_df,
      correlogram = correlogram_df,
      residuals = residual_df
    )
  )
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# run diagnostics

summary_list <- list()
correlogram_list <- list()
failed_list <- list()

for (i in base::seq_len(base::nrow(tasks))) {
  
  sp <- tasks$sp[[i]]
  grain <- tasks$grain[[i]]
  
  res <- base::tryCatch(
    process_one_task(
      sp = sp,
      grain = grain,
      esm_base_dir = esm_base_dir,
      diag_base_dir = diag_base_dir,
      lag_breaks_m = lag_breaks_m,
      min_pairs = min_pairs,
      crs_epsg = crs_epsg,
      max_plot_cells = max_plot_cells
    ),
    error = function(e) {
      message("FAILED: ", sp, " | ", grain, " m | ", conditionMessage(e))
      
      failed_list[[base::length(failed_list) + 1L]] <<- base::data.frame(
        species = sp,
        grain = grain,
        message = conditionMessage(e),
        stringsAsFactors = FALSE
      )
      
      return(NULL)
    }
  )
  
  if (!base::is.null(res)) {
    summary_list[[base::length(summary_list) + 1L]] <- res$summary
    correlogram_list[[base::length(correlogram_list) + 1L]] <- res$correlogram
  }
}

summary_all <- dplyr::bind_rows(summary_list)
correlogram_all <- dplyr::bind_rows(correlogram_list)

failed_all <- if (base::length(failed_list) > 0) {
  dplyr::bind_rows(failed_list)
} else {
  base::data.frame(
    species = character(0),
    grain = numeric(0),
    message = character(0)
  )
}

readr::write_csv(
  x = summary_all,
  file = base::file.path(diag_base_dir, "residual_diagnostics_summary.csv")
)

readr::write_csv(
  x = correlogram_all,
  file = base::file.path(diag_base_dir, "residual_moran_correlograms_all.csv")
)

readr::write_csv(
  x = failed_all,
  file = base::file.path(diag_base_dir, "residual_diagnostics_failed.csv")
)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# comparison of grains: one correlogram plot per species

for (sp in species) {
  
  df_sp <- correlogram_all |>
    dplyr::filter(species == sp)
  
  if (base::nrow(df_sp) == 0) {
    next
  }
  
  p <- ggplot2::ggplot(
    df_sp,
    ggplot2::aes(
      x = lag_mid_m / 1000,
      y = moran_i,
      colour = base::factor(grain),
      group = grain
    )
  ) +
    ggplot2::geom_hline(
      yintercept = 0,
      linewidth = 0.3
    ) +
    ggplot2::geom_line(
      na.rm = TRUE
    ) +
    ggplot2::geom_point(
      ggplot2::aes(
        shape = !base::is.na(p_value) & p_value < 0.05
      ),
      size = 2,
      na.rm = TRUE
    ) +
    ggplot2::scale_shape_manual(
      values = c(`TRUE` = 16, `FALSE` = 1),
      name = "p < 0.05"
    ) +
    ggplot2::labs(
      title = base::paste0(sp, " | residual Moran correlogram by grain"),
      x = "Distance class midpoint [km]",
      y = "Moran's I",
      colour = "Grain [m]"
    ) +
    ggplot2::theme_bw()
  
  ggplot2::ggsave(
    filename = base::file.path(
      diag_base_dir,
      base::paste0("grain_comparison_correlogram_", sp, ".png")
    ),
    plot = p,
    width = 7,
    height = 4.5,
    dpi = 300
  )
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# comparison of grains: residual magnitude

p_rmse <- ggplot2::ggplot(
  summary_all,
  ggplot2::aes(
    x = grain,
    y = rmse,
    group = species,
    colour = species
  )
) +
  ggplot2::geom_line() +
  ggplot2::geom_point(size = 2) +
  ggplot2::scale_x_reverse(
    breaks = sort(unique(summary_all$grain), decreasing = TRUE)
  ) +
  ggplot2::labs(
    title = "Out-of-fold residual RMSE by grain",
    x = "Grain [m]",
    y = "RMSE"
  ) +
  ggplot2::theme_bw()

ggplot2::ggsave(
  filename = base::file.path(diag_base_dir, "grain_comparison_residual_rmse.png"),
  plot = p_rmse,
  width = 7,
  height = 4.5,
  dpi = 300
)

p_sac <- ggplot2::ggplot(
  summary_all,
  ggplot2::aes(
    x = grain,
    y = residual_sac_range_m / 1000,
    group = species,
    colour = species
  )
) +
  ggplot2::geom_line() +
  ggplot2::geom_point(size = 2) +
  ggplot2::scale_x_reverse(
    breaks = sort(unique(summary_all$grain), decreasing = TRUE)
  ) +
  ggplot2::labs(
    title = "Approximate range of significant positive residual SAC by grain",
    x = "Grain [m]",
    y = "Max significant positive lag [km]"
  ) +
  ggplot2::theme_bw()

ggplot2::ggsave(
  filename = base::file.path(diag_base_dir, "grain_comparison_residual_sac_range.png"),
  plot = p_sac,
  width = 7,
  height = 4.5,
  dpi = 300
)

message("Residual diagnostics finished.")
