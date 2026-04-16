# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# FUN ‒ compile and write stacks
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# 
# WARNING: This feature is far from universal; the order of the files matters. Use with extreme caution.
# 
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

create_stack <- function(
    source_dir,
    climate_dir,
    path_out
){
  
  grain <- substr(basename(source_dir), 8, 100)
  message(grain)
  
  expected_files <- c(
    paste0("absolute_depth_to_bedrock_", grain, ".tif"),
    paste0("aspect_", grain, ".tif"),
    paste0("avail_soil_water_capacity_until_wilting_point_", grain, ".tif"),
    paste0("DEM_agg_", grain, "m_max.tif"),
    paste0("DEM_agg_", grain, "m_median.tif"),
    paste0("DEM_agg_", grain, "m_min.tif"),
    paste0("DEM_agg_", grain, "m_range.tif"),
    paste0("DEM_agg_", grain, "m_sd.tif"),
    paste0("eastness_", grain, ".tif"),
    paste0("ESA_WC_", grain, "m_cat60_005.tif"),
    paste0("flowdir_", grain, ".tif"),
    paste0("glim_", grain, ".tiff"),
    paste0("hli_", grain, ".tif"),
    paste0("northness_", grain, ".tif"),
    paste0("roughness_", grain, ".tif"),
    paste0("slope_", grain, ".tif"),
    paste0("soil_pH_in_H2O_", grain, ".tif"),
    paste0("TPI_", grain, ".tif"),
    paste0("TRI_", grain, ".tif"),
    paste0("TRIriley_", grain, ".tif"),
    paste0("TRIrmsd_", grain, ".tif"),
    paste0("twi_", grain, ".tif")
  )
  
  root_names <- c(
    "depth_to_bedrock",
    "aspect",
    "soil_water_cap",
    "dem_max",
    "dem_median",
    "dem_min",
    "dem_range",
    "dem_sd",
    "eastness",
    "landcover",
    "flowdir",
    "bedrock",
    "HLI",
    "northness",
    "roughness",
    "slope",
    "pH_in_H2O",
    "TPI",
    "TRI",
    "TRI_riley",
    "TRI_rmsd",
    "TWI"
  )
  
  clim_names <- c(
    "bio01",
    "bio02",
    "bio03",
    "bio04",
    "bio05",
    "bio06",
    "bio07",
    "bio08",
    "bio09",
    "bio10",
    "bio11",
    "bio12",
    "bio13",
    "bio14",
    "bio15",
    "bio16",
    "bio17",
    "bio18",
    "bio19",
    "scd"
  )
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  
  # get root rasters paths
  files_root <- list.files(
    source_dir,
    pattern = "\\.tif{1,2}$",
    full.names = T,
    recursive = F
  ) %>%
    sort()
  
  # little check
  stopifnot(
    all(basename(files_root) == expected_files)
  )
  
  # get clim rasters paths
  files_clim <- list.files(
    climate_dir,
    pattern = "\\.tif{1,2}$",
    full.names = T,
    recursive = F
  ) %>%
    sort()
  
  files_all <- c(files_root, files_clim)
  names_all <- c(root_names, clim_names)
  
  # little check again
  stopifnot(
    length(files_all) == length(names_all)
  )
  
  # crate stack, rename
  stack <- terra::rast(files_all)
  names(stack) <- names_all
  
  # write stack on disk
  terra::writeRaster(
    stack,
    filename = path_out,
    overwrite = T,
    wopt = list(gdal = c("COMPRESS=LZW", "TILED=YES", "BIGTIFF=YES"))
  )
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #