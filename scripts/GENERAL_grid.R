# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# General predictor preparation ‒ grid
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# GDAL write options
wopt <- list(
  gdal = c("COMPRESS=LZW", "TILED=YES", "BIGTIFF=YES")
)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# REFERENCE
# Sentinel 2 data

# compute reference master layer from Sentinel 2 first band, save as template
ref <- terra::rast(here("data", "Sentinel2_MOSAIC.tif"))
ref_20 <- ref[[1]]
tmpl20 <- terra::rast(terra::ext(ref_20), res = terra::res(ref_20), crs = terra::crs(ref_20))
tmpl20 <- terra::init(tmpl20, 1)

# write template
terra::writeRaster(
  tmpl20, here("data", "__COMPATIBILITY__", "master_20m.tif"),
  overwrite = TRUE,
  wopt = list(
    datatype = "INT1U", # 0..255 (1 byte/pixel)
    gdal = c("COMPRESS=LZW","TILED=YES","BIGTIFF=YES")
  )
)

# aggregate master template to various reference layers
master <- terra::rast(here("data", "__COMPATIBILITY__", "master_20m.tif"))
terra::aggregate(master, fact =  5, fun = "mean", filename = here("data", "__COMPATIBILITY__", "ref_100.tif"), wopt = wopt)
terra::aggregate(master, fact = 10, fun = "mean", filename = here("data", "__COMPATIBILITY__", "ref_200.tif"), wopt = wopt)
terra::aggregate(master, fact = 25, fun = "mean", filename = here("data", "__COMPATIBILITY__", "ref_500.tif"), wopt = wopt)
terra::aggregate(master, fact = 50, fun = "mean", filename = here("data", "__COMPATIBILITY__", "ref_1000.tif"), wopt = wopt)

ref_20 <- terra::rast(here("data", "__COMPATIBILITY__", "master_20m.tif"))
ref_100 <- terra::rast(here("data", "__COMPATIBILITY__", "ref_100.tif"))
ref_200 <- terra::rast(here("data", "__COMPATIBILITY__", "ref_200.tif"))
ref_500 <- terra::rast(here("data", "__COMPATIBILITY__", "ref_500.tif"))
ref_1000 <- terra::rast(here("data", "__COMPATIBILITY__", "ref_1000.tif"))

source(here("scripts", "fun_reproject_tree_to_ref.R"))

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# CHELSA
# use function, it returns same structure
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# GEO
# rasterize based on the reference
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# DEM
# project
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# RS
### keep only in 20m resolution (it worked as template)
# I dont think, that I will compute anything on coarser res than original 20m