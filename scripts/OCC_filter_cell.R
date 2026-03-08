# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Occurence ‒ raster cell filter
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# This script takes focal plants RDS files and reference rasters. It uses function
# filter_pa_to_unique_cells() and reduces species datastet according to different
# modelling grains.

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Config

# data dir
dir_in  <- here::here("data", "occurence", "_ANALYSIS_FOCAL_")
dir_rasters <- here::here("data", "__COMPATIBILITY__")
# results dir
dir_out <- here::here("data", "occurence", "_ANALYSIS_FOCAL_", "_FILTER_")

# create
if (!base::dir.exists(dir_out)) {
  base::dir.create(dir_out, recursive = TRUE)
}

source(here::here("scripts", "fun_unique_obs_per_raster_cell.R"))

# Load data

# Occurence
s <- list()
s[[1]] <- base::readRDS(file.path(dir_in, "GT.rds"))
s[[2]] <- base::readRDS(file.path(dir_in, "SB.rds"))
s[[3]] <- base::readRDS(file.path(dir_in, "PK.rds"))
s[[4]] <- base::readRDS(file.path(dir_in, "PO.rds"))
s[[5]] <- base::readRDS(file.path(dir_in, "PP.rds"))
names(s) <- c("GT", "SB", "PK", "PO", "PP")

# Rasters
r <- list()
r[[1]] <- terra::rast(here::here(dir_rasters, "master_20m.tif"))
r[[2]] <- terra::rast(here::here(dir_rasters, "ref_100.tif"))
r[[3]] <- terra::rast(here::here(dir_rasters, "ref_200.tif"))
r[[4]] <- terra::rast(here::here(dir_rasters, "ref_500.tif"))
r[[5]] <- terra::rast(here::here(dir_rasters, "ref_1000.tif"))
names(r) <- c("20m", "100m", "200m", "500m", "1000m")

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Loop over all species and rasters
for(i in seq_along(s)){
  # load species
  specie <- s[[i]]
  name <- s[[i]]$species
  message("Working on: ", name)
  
  # run over all rasters
  for(j in seq_along(r)){
    message("# - # - # - # ", names(r)[[j]], " # - # - # - #")
    file_name <- paste0(names(s)[[i]], "_", names(r)[[j]], ".rds") # create out filename
    
    # main function
    out <- filter_pa_to_unique_cells(
      spec = specie,
      r = r[[j]],
      drop_outside = T,
      keep_cell_id = F
    )
    
    # write result
    base::saveRDS(out, file = file.path(dir_out, file_name))
    message("DONE")
  }
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #