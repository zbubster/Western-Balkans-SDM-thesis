# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# FUN ‒ DEM aggregation with other stats
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# FUN
aggregate_dem_stats_to_disk <- function(
    dem,
    out_dir,
    grains = c(100, 200, 500, 1000),
    prefix = "dem",
    overwrite = FALSE,
    wopt = list(
      gdal = c("COMPRESS=LZW", "TILED=YES", "BIGTIFF=YES"),
      datatype = "FLT4S"
    )
) {
  
  base::dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  
  ref_grain <- terra::res(dem_20)[1]
  
  facts <- grains/ref_grain
  
  if (base::any(facts != base::as.integer(facts))) {
    base::stop("All target grains have to be dividable by input DEM grain.")
  }
  
  # prepare output
  out <- base::vector("list", base::length(grains))
  base::names(out) <- paste0("r_", grains, "m")
  
  # Loop over all grains
  for (i in base::seq_along(grains)) {
    
    g <- grains[i]
    f <- facts[i]
    
    message("Working on ", g, " m")
    
    f_mean <- base::file.path(out_dir, paste0(prefix, "_", g, "m_mean.tif"))
    f_median <- base::file.path(out_dir, paste0(prefix, "_", g, "m_median.tif"))
    f_sd     <- base::file.path(out_dir, paste0(prefix, "_", g, "m_sd.tif"))
    f_min    <- base::file.path(out_dir, paste0(prefix, "_", g, "m_min.tif"))
    f_max    <- base::file.path(out_dir, paste0(prefix, "_", g, "m_max.tif"))
    f_range  <- base::file.path(out_dir, paste0(prefix, "_", g, "m_range.tif"))
    
    # MEAN
    r_mean <- terra::aggregate(
      dem,
      fact = f,
      fun = "mean",
      na.rm = TRUE,
      filename = f_median,
      overwrite = overwrite,
      wopt = wopt
    )
    
    # MEDIAN
    r_median <- terra::aggregate(
      dem,
      fact = f,
      fun = "median",
      na.rm = TRUE,
      filename = f_median,
      overwrite = overwrite,
      wopt = wopt
    )
    
    # STANDARD DEVIATION
    r_sd <- terra::aggregate(
      dem,
      fact = f,
      fun = "sd",
      na.rm = TRUE,
      filename = f_sd,
      overwrite = overwrite,
      wopt = wopt
    )
    
    # MINIMUM
    r_min <- terra::aggregate(
      dem,
      fact = f,
      fun = "min",
      na.rm = TRUE,
      filename = f_min,
      overwrite = overwrite,
      wopt = wopt
    )
    
    # MAXIMUM
    r_max <- terra::aggregate(
      dem,
      fact = f,
      fun = "max",
      na.rm = TRUE,
      filename = f_max,
      overwrite = overwrite,
      wopt = wopt
    )
    
    # RANGE
    r_range <- terra::writeRaster(
      r_max - r_min,
      filename = f_range,
      overwrite = overwrite,
      wopt = wopt
    )
    
    # names
    base::names(r_median) <- paste0("elev_median_", g, "m")
    base::names(r_sd)     <- paste0("elev_sd_", g, "m")
    base::names(r_min)    <- paste0("elev_min_", g, "m")
    base::names(r_max)    <- paste0("elev_max_", g, "m")
    base::names(r_range)  <- paste0("elev_range_", g, "m")
    
    # output
    out[[i]] <- list(
      median = r_median,
      sd = r_sd,
      min = r_min,
      max = r_max,
      range = r_range
    )
  }
  
  return(out)
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #