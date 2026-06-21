# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Create forecast raster stacks for all available GCM x SSP combinations
# EXTRAPOL edition
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# This script creates projection stacks for temporal extrapolation.
# It always uses the EXTRAPOL predictor set.
# The full projection stack contains climate predictors and EXTRAPOL-compatible static predictors.
# The final species-specific subset is controlled by selected_truefalse.csv.

# User input
# period <- "2011-2040"
period <- "2041-2070"
# period <- "2071-2100"

# Optional filters
gcms <- NULL
ssps <- NULL

# Main config
grains  <- c(1000, 500, 200, 100)
species <- c("GD", "GT", "SB", "PK", "PO", "PP")

source_root <- here::here("data", "__COMPATIBILITY__", "STACKS")
forecast_root <- here::here("data", "__PREDICTORS_STACKS__", "forecast")

selected_table_path <- here::here(
  "data", "__predictors_collinearity__", "extrapol", "results", "selected_truefalse.csv"
)

recent_selected_root <- here::here(
  "data", "__PREDICTORS_STACKS__", "recent", "selected_predictors_stacks", "extrapol"
)

# Write options
wopt <- list(
  gdal = c("COMPRESS=LZW", "TILED=YES", "BIGTIFF=YES")
)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Helper functions
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

make_dir <- function(path) {
  if (!base::dir.exists(path)) base::dir.create(path, recursive = TRUE)
}

land_extent_cache <- NULL

get_land_extent <- function(template_raster) {
  if (!base::is.null(land_extent_cache)) {
    return(land_extent_cache)
  }
  
  extent <- terra::vect(here::here("data", "extent_raw.gpkg"))
  
  land <- rnaturalearth::ne_download(
    scale = 10,
    type = "land",
    category = "physical",
    returnclass = "sv"
  )
  
  land <- terra::project(land, terra::crs(extent))
  land <- terra::intersect(land, extent)
  land <- terra::project(land, terra::crs(template_raster))
  
  land_extent_cache <<- land
  land_extent_cache
}

mask_stack_with_coastline <- function(stack) {
  land_extent <- get_land_extent(stack)
  terra::mask(stack, land_extent)
}

get_period_dir <- function(grain, period) {
  base::file.path(
    source_root,
    base::paste0("source_", grain),
    base::paste0("CHELSA_", grain),
    "CHELSA_v21",
    period
  )
}

list_directories <- function(path) {
  if (!base::dir.exists(path)) {
    return(character(0))
  }
  
  dirs <- base::list.dirs(path, recursive = FALSE, full.names = FALSE)
  base::sort(dirs)
}

scenario_id <- function(period, gcm, ssp) {
  base::paste(period, gcm, ssp, sep = "_")
}

scenario_key <- function(gcm, ssp) {
  base::paste(gcm, ssp, sep = "|")
}

split_scenario_key <- function(x) {
  y <- base::strsplit(x, "\\|", fixed = FALSE)[[1]]
  list(gcm = y[[1]], ssp = y[[2]])
}

discover_forecast_scenarios <- function(period, grains, gcms = NULL, ssps = NULL) {
  scenario_sets <- list()
  
  for (grain in grains) {
    period_dir <- get_period_dir(grain = grain, period = period)
    
    if (!base::dir.exists(period_dir)) {
      base::stop("Period directory does not exist for grain ", grain, ": ", period_dir)
    }
    
    gcm_dirs <- list_directories(period_dir)
    
    if (!base::is.null(gcms)) {
      gcm_dirs <- gcm_dirs[gcm_dirs %in% gcms]
    }
    
    keys <- character(0)
    
    for (gcm in gcm_dirs) {
      gcm_dir <- base::file.path(period_dir, gcm)
      ssp_dirs <- list_directories(gcm_dir)
      
      if (!base::is.null(ssps)) {
        ssp_dirs <- ssp_dirs[ssp_dirs %in% ssps]
      }
      
      for (ssp in ssp_dirs) {
        keys <- c(keys, scenario_key(gcm, ssp))
      }
    }
    
    scenario_sets[[base::paste0("r_", grain)]] <- base::sort(base::unique(keys))
  }
  
  common_keys <- scenario_sets[[1]]
  
  for (i in base::seq_along(scenario_sets)[-1]) {
    common_keys <- base::intersect(common_keys, scenario_sets[[i]])
  }
  
  if (base::length(common_keys) == 0) {
    base::stop("No GCM x SSP combination is available for all requested grains and filters.")
  }
  
  all_keys <- base::sort(base::unique(base::unlist(scenario_sets)))
  skipped <- base::setdiff(all_keys, common_keys)
  
  if (base::length(skipped) > 0) {
    base::warning(
      "Some GCM x SSP combinations are not available for all grains and will be skipped:\n",
      base::paste(skipped, collapse = "\n")
    )
  }
  
  out <- base::lapply(common_keys, split_scenario_key)
  out <- base::do.call(
    what = base::rbind,
    args = base::lapply(out, function(x) data.frame(gcm = x$gcm, ssp = x$ssp, stringsAsFactors = FALSE))
  )
  
  out[base::order(out$gcm, out$ssp), , drop = FALSE]
}

get_extrapol_root_paths <- function(source_dir, grain) {
  root_files <- c(
    paste0("aspect_", grain, ".tif"),
    paste0("DEM_agg_", grain, "m_max.tif"),
    paste0("DEM_agg_", grain, "m_median.tif"),
    paste0("DEM_agg_", grain, "m_min.tif"),
    paste0("DEM_agg_", grain, "m_range.tif"),
    paste0("DEM_agg_", grain, "m_sd.tif"),
    paste0("eastness_", grain, ".tif"),
    paste0("glim_", grain, ".tiff"),
    paste0("northness_", grain, ".tif"),
    paste0("roughness_", grain, ".tif"),
    paste0("slope_", grain, ".tif"),
    paste0("TPI_", grain, ".tif"),
    paste0("TRI_", grain, ".tif"),
    paste0("TRIriley_", grain, ".tif"),
    paste0("TRIrmsd_", grain, ".tif")
  )
  
  root_names <- c(
    "aspect",
    "dem_max",
    "dem_median",
    "dem_min",
    "dem_range",
    "dem_sd",
    "eastness",
    "bedrock",
    "northness",
    "roughness",
    "slope",
    "TPI",
    "TRI",
    "TRI_riley",
    "TRI_rmsd"
  )
  
  root_paths <- base::file.path(source_dir, root_files)
  missing <- root_paths[!base::file.exists(root_paths)]
  
  if (base::length(missing) > 0) {
    base::stop(
      "Missing static EXTRAPOL root files:\n",
      base::paste(missing, collapse = "\n")
    )
  }
  
  stats::setNames(root_paths, root_names)
}

get_forecast_climate_paths <- function(climate_dir, period, gcm, ssp) {
  clim_names <- c(base::sprintf("bio%02d", 1:19), "scd")
  gcm_file <- base::tolower(gcm)
  
  all_files <- base::list.files(
    climate_dir,
    pattern = "\\.tif{1,2}$",
    full.names = TRUE,
    recursive = FALSE
  )
  
  if (base::length(all_files) == 0) {
    base::stop("No forecast raster files found in: ", climate_dir)
  }
  
  clim_paths <- base::vapply(
    clim_names,
    FUN.VALUE = character(1),
    FUN = function(var) {
      expected_name <- base::paste0("CHELSA_", var, "_", period, "_", gcm_file, "_", ssp, "_AOI.tif")
      hits <- all_files[base::basename(all_files) == expected_name]
      
      if (base::length(hits) != 1) {
        base::stop(
          "Expected exactly one file for ", var, " / ", period, " / ", gcm, " / ", ssp,
          "\nExpected file name: ", expected_name,
          "\nFound: ", base::length(hits),
          "\nSearch directory: ", climate_dir
        )
      }
      
      hits
    }
  )
  
  stats::setNames(clim_paths, clim_names)
}

create_full_forecast_stack <- function(grain, period, gcm, ssp, out_root) {
  message("Creating full forecast stack: ", period, " / ", gcm, " / ", ssp, " / ", grain, " m")
  
  source_dir <- base::file.path(source_root, base::paste0("source_", grain))
  climate_dir <- base::file.path(source_dir, base::paste0("CHELSA_", grain), "CHELSA_v21", period, gcm, ssp)
  
  root_paths <- get_extrapol_root_paths(
    source_dir = source_dir,
    grain = grain
  )
  
  clim_paths <- get_forecast_climate_paths(
    climate_dir = climate_dir,
    period = period,
    gcm = gcm,
    ssp = ssp
  )
  
  files_all <- c(root_paths, clim_paths)
  
  stack <- terra::rast(files_all)
  names(stack) <- names(files_all)
  
  stack <- mask_stack_with_coastline(stack)
  
  make_dir(out_root)
  
  path_out <- base::file.path(out_root, base::paste0("r_", grain, ".tif"))
  
  terra::writeRaster(
    stack,
    filename = path_out,
    overwrite = TRUE,
    wopt = wopt
  )
  
  message("Written: ", path_out)
  invisible(path_out)
}

is_selected_value <- function(x) {
  if (base::is.logical(x)) return(base::isTRUE(x))
  if (base::is.numeric(x)) return(!base::is.na(x) && x == 1)
  if (base::is.character(x)) return(base::tolower(x) %in% c("true", "t", "1", "yes"))
  FALSE
}

get_selected_raster <- function(rasters, TFtable, grain_value, species_value) {
  meta_cols <- c("set_name", "item_name", "source_type", "species", "grain_m")
  
  row_id <- !base::is.na(TFtable$species) &
    TFtable$source_type == "species" &
    TFtable$species == species_value &
    TFtable$grain_m == grain_value
  
  row <- TFtable[row_id, , drop = FALSE]
  
  if (base::nrow(row) != 1) {
    base::stop(
      "Expected exactly one species row in selected_truefalse.csv for species = ", species_value,
      " and grain_m = ", grain_value, ". Found: ", base::nrow(row)
    )
  }
  
  pred_cols <- base::setdiff(base::names(TFtable), meta_cols)
  selected <- base::vapply(row[1, pred_cols, drop = FALSE], is_selected_value, logical(1))
  preds <- pred_cols[selected]
  
  ras_name <- base::paste0("r_", grain_value)
  ras <- rasters[[ras_name]]
  
  missing <- base::setdiff(preds, names(ras))
  
  if (base::length(missing) > 0) {
    base::stop(
      "Selected predictors are missing in projection stack ", ras_name, ":\n",
      base::paste(missing, collapse = "\n")
    )
  }
  
  ras[[preds]]
}

select_common_predictors <- function(raster_list) {
  common <- names(raster_list[[1]])
  
  for (i in base::seq_along(raster_list)[-1]) {
    common <- common[common %in% names(raster_list[[i]])]
  }
  
  base::lapply(raster_list, function(x) x[[common]])
}

get_recent_layer_names <- function(sp, folder_type, raster_name) {
  ref_path <- base::file.path(
    recent_selected_root,
    base::paste0(sp, "_", folder_type),
    base::paste0(raster_name, ".tif")
  )
  
  if (!base::file.exists(ref_path)) {
    base::warning("Recent reference stack not found, keeping current layer order: ", ref_path)
    return(NULL)
  }
  
  base::names(terra::rast(ref_path))
}

align_to_recent <- function(ras, sp, folder_type, raster_name) {
  ref_names <- get_recent_layer_names(
    sp = sp,
    folder_type = folder_type,
    raster_name = raster_name
  )
  
  if (base::is.null(ref_names)) {
    return(ras)
  }
  
  missing <- base::setdiff(ref_names, base::names(ras))
  extra <- base::setdiff(base::names(ras), ref_names)
  
  if (base::length(missing) > 0 || base::length(extra) > 0) {
    base::stop(
      "Layer names do not match recent reference stack:\n",
      "Species: ", sp, "\n",
      "Type: ", folder_type, "\n",
      "Raster: ", raster_name, "\n",
      "Missing in projection: ", base::paste(missing, collapse = ", "), "\n",
      "Extra in projection: ", base::paste(extra, collapse = ", "), "\n",
      "Reference: ", base::paste(ref_names, collapse = ", "), "\n",
      "Projection: ", base::paste(base::names(ras), collapse = ", ")
    )
  }
  
  ras[[ref_names]]
}

check_against_recent <- function(ras, sp, folder_type, raster_name) {
  ref_names <- get_recent_layer_names(
    sp = sp,
    folder_type = folder_type,
    raster_name = raster_name
  )
  
  if (base::is.null(ref_names)) {
    return(invisible(FALSE))
  }
  
  if (!base::identical(ref_names, base::names(ras))) {
    base::stop(
      "Layer order does not match recent reference stack:\n",
      "Species: ", sp, "\n",
      "Type: ", folder_type, "\n",
      "Raster: ", raster_name, "\n",
      "Reference: ", base::paste(ref_names, collapse = ", "), "\n",
      "Projection: ", base::paste(base::names(ras), collapse = ", ")
    )
  }
  
  invisible(TRUE)
}

write_species_stacks <- function(out_root, out_selected) {
  TFtable <- utils::read.csv(selected_table_path)
  
  rasters <- list(
    r_1000 = terra::rast(base::file.path(out_root, "r_1000.tif")),
    r_500  = terra::rast(base::file.path(out_root, "r_500.tif")),
    r_200  = terra::rast(base::file.path(out_root, "r_200.tif")),
    r_100  = terra::rast(base::file.path(out_root, "r_100.tif"))
  )
  
  make_dir(out_selected)
  
  for (sp in species) {
    message("Subsetting selected EXTRAPOL predictors for: ", sp)
    
    selected_rasters <- list(
      r_1000 = get_selected_raster(rasters, TFtable, 1000, sp),
      r_500  = get_selected_raster(rasters, TFtable, 500, sp),
      r_200  = get_selected_raster(rasters, TFtable, 200, sp),
      r_100  = get_selected_raster(rasters, TFtable, 100, sp)
    )
    
    common_rasters <- select_common_predictors(selected_rasters)
    
    # ALL_SELECTED stacks
    folder <- base::file.path(out_selected, base::paste0(sp, "_all_selected"))
    make_dir(folder)
    
    for (raster_name in base::names(selected_rasters)) {
      selected_rasters[[raster_name]] <- align_to_recent(
        selected_rasters[[raster_name]],
        sp,
        "all_selected",
        raster_name
      )
      
      check_against_recent(selected_rasters[[raster_name]], sp, "all_selected", raster_name)
      
      file <- base::file.path(folder, base::paste0(raster_name, ".tif"))
      terra::writeRaster(selected_rasters[[raster_name]], filename = file, overwrite = TRUE, wopt = wopt)
      message("Written: ", file)
    }
    
    # COMMON stacks
    folder <- base::file.path(out_selected, base::paste0(sp, "_common"))
    make_dir(folder)
    
    for (raster_name in base::names(common_rasters)) {
      common_rasters[[raster_name]] <- align_to_recent(
        common_rasters[[raster_name]],
        sp,
        "common",
        raster_name
      )
      
      check_against_recent(common_rasters[[raster_name]], sp, "common", raster_name)
      
      file <- base::file.path(folder, base::paste0(raster_name, ".tif"))
      terra::writeRaster(common_rasters[[raster_name]], filename = file, overwrite = TRUE, wopt = wopt)
      message("Written: ", file)
    }
  }
}

run_forecast_scenario <- function(period, gcm, ssp) {
  projection_id <- scenario_id(period = period, gcm = gcm, ssp = ssp)
  out_root <- base::file.path(forecast_root, projection_id)
  out_selected <- base::file.path(out_root, "selected_predictors_stacks", "extrapol")
  
  message("# - # - # - # - # - # - # - # - # - # - # - # - # - #")
  message("Processing forecast scenario: ", projection_id)
  message("# - # - # - # - # - # - # - # - # - # - # - # - # - #")
  
  for (grain in grains) {
    create_full_forecast_stack(
      grain = grain,
      period = period,
      gcm = gcm,
      ssp = ssp,
      out_root = out_root
    )
  }
  
  write_species_stacks(
    out_root = out_root,
    out_selected = out_selected
  )
  
  message("Done: ", out_root)
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Run
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

scenarios <- discover_forecast_scenarios(
  period = period,
  grains = grains,
  gcms = gcms,
  ssps = ssps
)

message("Forecast scenarios to process:")
print(scenarios)

for (i in base::seq_len(base::nrow(scenarios))) {
  run_forecast_scenario(
    period = period,
    gcm = scenarios$gcm[[i]],
    ssp = scenarios$ssp[[i]]
  )
}

message("All forecast scenarios finished for period: ", period)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
