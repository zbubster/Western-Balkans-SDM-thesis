# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Create elevation masks
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Config

# paths to DEMs and output dir
dem_dir <- here::here("data", "__COMPATIBILITY__", "DEM")
mask_dir <- here::here("data", "__COMPATIBILITY__", "MASK")
if(!dir.exists(mask_dir)){dir.create(mask_dir)}

# load DEMs
dem_1000 <- terra::rast(here::here(dem_dir, "DEM_1000", "DEM_1000.tif"))
dem_500 <- terra::rast(here::here(dem_dir, "DEM_500", "DEM_500.tif"))
dem_200 <- terra::rast(here::here(dem_dir, "DEM_200", "DEM_200.tif"))
dem_100 <- terra::rast(here::here(dem_dir, "DEM_100", "DEM_100.tif"))
dem_20 <- terra::rast(here::here(dem_dir, "DEM_20", "DEM_20.tif"))

# set elevation threshold
thr <- 500

# create masks, save them
ifel(dem_1000 >= thr, 1, NA, filename = file.path(mask_dir, "m500_1000.tif"))
ifel(dem_500 >= thr, 1, NA, filename = file.path(mask_dir, "m500_500.tif"))
ifel(dem_200 >= thr, 1, NA, filename = file.path(mask_dir, "m500_200.tif"))
ifel(dem_100 >= thr, 1, NA, filename = file.path(mask_dir, "m500_100.tif"))
#ifel(dem_20 >= thr, 1, NA, filename = file.path(mask_dir, "m500_20.tif"))

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #