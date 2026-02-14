# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Crop, mask and reproject DEM
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Load extent and raster files, dirs

extent <- sf::st_read(here("data", "extent_raw.gpkg"))
dir_in <- "/media/zbub/DATA/DEM" # folder with raster files
out_fn  <- file.path(dir_out, "DEM30_mosaic_cropped.tif") # where to save result

# list files
files <- list.files(
  path = dir_out,
  pattern = "\\.(tif|tiff)$",
  full.names = TRUE,
  ignore.case = TRUE
)
stopifnot(length(files) > 0)

# load SpatRasterCollection
rc <- terra::sprc(files)

# create mosaic (merge rasters)
r_mosaic <- terra::mosaic(rc)

# crs check
if (!terra::same.crs(r_mosaic, extent)) {
  aoi <- terra::project(extent, terra::crs(r_mosaic))
} else {
  aoi <- extent
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# crop mosaic, mask and reproject
r_crop <- terra::crop(r_mosaic, aoi)
r_mask <- terra::mask(r_crop, aoi)
r_final <- terra::project(r_mask, terra::crs(extent)) # output raster crs should be the same as input extent layer

# save result
terra::writeRaster(
  r_final,
  filename = out_fn,
  overwrite = F,
  wopt = list(gdal = c("COMPRESS=LZW", "TILED=YES"))
)

plot(r_final)

rm(r_crop, r_mask, r_final, rc, extent, aoi); gc()

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #