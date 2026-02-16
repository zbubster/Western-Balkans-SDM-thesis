# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# ESA world cover
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# This script loads TERRASCOPE WORLDCOVER data tiles by ESA (downloaded elsewhere,
# for example on the internet: https://viewer.esa-worldcover.org/worldcover/), than
# merge them into one global mosaic, crop them according to study extent, mask outter
# values as NA and reproject the final product to desired CRS (this is delivered from
# polygon representing AOI ‒ extent obj).
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Load data

# dirs & files
esa_dir <- here("data", "WORLDCOVER")
extent <- vect(here("data", "extent_raw.gpkg")) # AOI, CRS for final output will be taken from this
# GDAL write options
wopt <- list(
  datatype = "FLT4S",
  gdal = c("COMPRESS=LZW", "TILED=YES", "BIGTIFF=YES")
)

# list files
files <- list.files(
  path = esa_dir,
  pattern = "Map\\.tif$",
  full.names = TRUE
)
files

# load SpatRasterCollection
rc <- terra::sprc(files)

# Mosaic
mosaic(
  rc,
  fun = "first", # takes value of the first layer
  filename = here("data", "WORLDCOVER", "1_ESA_WC_mosaic.tiff"),
  overwrite = TRUE,
  wopt = wopt
)
gc()

# reload
r <- terra::rast(here("data", "WORLDCOVER", "1_ESA_WC_mosaic.tiff"))

# get AOI object with matching CRS
aoi <- terra::project(extent, terra::crs(r))

# crop
terra::crop(
  r,
  aoi,
  filename = here("data", "WORLDCOVER", "2_ESA_WC_mosaic_cropped.tiff"),
  wopt = wopt
  )

# mask
r <- terra::rast(here("data", "WORLDCOVER", "2_ESA_WC_mosaic_cropped.tiff"))
terra::mask(
  r,
  aoi,
  filename = here("data", "WORLDCOVER", "3_ESA_WC_mosaic_cropped_masked.tiff"),
  wopt = wopt
  )

# reproject to original extent CRS (3035)
r <- terra::rast(here("data", "WORLDCOVER", "3_ESA_WC_mosaic_cropped_masked.tiff"))
terra::project(
  r,
  y = terra::crs(extent),
  filename = here("data", "WORLDCOVER", "ESA_WC_3035.tiff"),
  wopt = wopt
  )

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #