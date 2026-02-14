# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Crop, mask and reproject DEM
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Load extent

extent <- sf::st_read(here("data", "extent_raw.gpkg"))

out_fn  <- file.path(dir_out, "DEM30_mosaic_cropped.tif")

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

# create mosaic
r_mosaic <- terra::mosaic(rc)

# crs check
if (!terra::same.crs(r_mosaic, extent)) {
  aoi <- terra::project(extent, terra::crs(r_mosaic))
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
  overwrite = TRUE,
  wopt = list(gdal = c("COMPRESS=LZW", "TILED=YES"))
)

r_final

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #