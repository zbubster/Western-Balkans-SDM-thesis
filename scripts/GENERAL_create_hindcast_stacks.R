# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Create hindcast raster stacks
# EXTRAPOL edition
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# This script creates projection stacks for temporal extrapolation.
# It always uses the EXTRAPOL predictor set.
# The full projection stack contains climate predictors and EXTRAPOL-compatible static predictors.
# The final species-specific subset is controlled by selected_truefalse.csv.

# User input

# trace_slice <- "-200" # 22kBP
# trace_slice <- "-190" # 21kBP LGM
trace_slice <- "-060" # 8kBP HCO

# Main config
grains  <- c(1000, 500, 200, 100)
species <- c("GD", "GT", "SB", "PK", "PO", "PP")

projection_id <- paste0("trace21k_", trace_slice)

source_root <- here::here("data", "__COMPATIBILITY__", "STACKS")
out_root <- here::here("data", "__PREDICTORS_STACKS__", "hindcast", projection_id)
out_selected <- file.path(out_root, "selected_predictors_stacks", "extrapol")

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

harmonise_trace21k_units <- function(
    x,
    bio04_multiplier = 1
) {
  
  absolute_temperature <- base::intersect(
    c(
      "bio01",
      "bio05",
      "bio06",
      "bio08",
      "bio09",
      "bio10",
      "bio11"
    ),
    base::names(x)
  )
  
  if (base::length(absolute_temperature) > 0) {
    x[[absolute_temperature]] <-
      x[[absolute_temperature]] - 273.15
  }
  
  # bio02 and bio07 are temperature differences.
  # bio03 is dimensionless.
  # bio04 is unaffected by the Kelvin–Celsius offset,
  # but its scale may need harmonisation with CHELSA v2.1.
  if (
    "bio04" %in% base::names(x) &&
    bio04_multiplier != 1
  ) {
    x[["bio04"]] <- x[["bio04"]] * bio04_multiplier
  }
  
  x
}

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
  
  root_paths <- file.path(source_dir, root_files)
  missing <- root_paths[!base::file.exists(root_paths)]
  
  if (base::length(missing) > 0) {
    base::stop(
      "Missing static EXTRAPOL root files:\n",
      base::paste(missing, collapse = "\n")
    )
  }
  
  stats::setNames(root_paths, root_names)
}

get_trace21k_climate_paths <- function(trace_dir, trace_slice) {
  clim_names <- c(base::sprintf("bio%02d", 1:19), "scd")
  
  all_files <- base::list.files(
    trace_dir,
    pattern = "\\.tif{1,2}$",
    full.names = TRUE,
    recursive = TRUE
  )
  
  if (base::length(all_files) == 0) {
    base::stop("No TraCE21k raster files found in: ", trace_dir)
  }
  
  clim_paths <- base::vapply(
    clim_names,
    FUN.VALUE = character(1),
    FUN = function(var) {
      expected_name <- paste0("CHELSA_TraCE21k_", var, "_", trace_slice, "_AOI.tif")
      hits <- all_files[base::basename(all_files) == expected_name]
      
      if (base::length(hits) != 1) {
        base::stop(
          "Expected exactly one file for ", var, " and slice ", trace_slice,
          "\nExpected file name: ", expected_name,
          "\nFound: ", base::length(hits),
          "\nSearch directory: ", trace_dir
        )
      }
      
      hits
    }
  )
  
  stats::setNames(clim_paths, clim_names)
}

create_full_hindcast_stack <- function(grain, trace_slice) {
  message("Creating full hindcast stack: ", grain, " m")
  
  source_dir <- file.path(source_root, paste0("source_", grain))
  trace_dir <- file.path(source_dir, paste0("CHELSA_", grain), "CHELSA_TraCE21k")
  
  root_paths <- get_extrapol_root_paths(
    source_dir = source_dir,
    grain = grain
  )
  
  clim_paths <- get_trace21k_climate_paths(
    trace_dir = trace_dir,
    trace_slice = trace_slice
  )
  
  files_all <- c(root_paths, clim_paths)
  
  stack <- terra::rast(files_all)
  names(stack) <- names(files_all)
  
  stack <- harmonise_trace21k_units(
    x = stack,
    bio04_multiplier = 1 # do nothing with bio4
  )
  
  stack <- mask_stack_with_coastline(stack)
  
  make_dir(out_root)
  
  path_out <- file.path(out_root, paste0("r_", grain, ".tif"))
  
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
  
  ras_name <- paste0("r_", grain_value)
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

check_against_recent <- function(ras, sp, folder_type, raster_name) {
  ref_path <- file.path(
    recent_selected_root,
    paste0(sp, "_", folder_type),
    paste0(raster_name, ".tif")
  )
  
  if (!base::file.exists(ref_path)) {
    base::warning("Recent reference stack not found, skipping name check: ", ref_path)
    return(invisible(FALSE))
  }
  
  ref_names <- names(terra::rast(ref_path))
  
  if (!base::identical(ref_names, names(ras))) {
    base::stop(
      "Layer names do not match recent reference stack:\n",
      "Species: ", sp, "\n",
      "Type: ", folder_type, "\n",
      "Raster: ", raster_name, "\n",
      "Reference: ", base::paste(ref_names, collapse = ", "), "\n",
      "Projection: ", base::paste(names(ras), collapse = ", ")
    )
  }
  
  invisible(TRUE)
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

write_species_stacks <- function() {
  TFtable <- utils::read.csv(selected_table_path)
  
  rasters <- list(
    r_1000 = terra::rast(file.path(out_root, "r_1000.tif")),
    r_500  = terra::rast(file.path(out_root, "r_500.tif")),
    r_200  = terra::rast(file.path(out_root, "r_200.tif")),
    r_100  = terra::rast(file.path(out_root, "r_100.tif"))
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
    folder <- file.path(out_selected, paste0(sp, "_all_selected"))
    make_dir(folder)
    
    for (raster_name in names(selected_rasters)) {
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
    folder <- file.path(out_selected, paste0(sp, "_common"))
    make_dir(folder)
    
    for (raster_name in names(common_rasters)) {
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

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Run
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

for (grain in grains) {
  create_full_hindcast_stack(
    grain = grain,
    trace_slice = trace_slice
  )
}

write_species_stacks()

message("Done: ", out_root)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
