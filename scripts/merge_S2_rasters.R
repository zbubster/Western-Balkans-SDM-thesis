# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Merge rasters
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Settings

terraOptions(progress = 1)
in_dir <- here("data", "Sentinel2_medoids_aligned")
out_file <- here("data", "Sentinel2_MOSAIC.tif")

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Prepare collection

# load files
files <- list.files(in_dir, pattern = "\\.tif$", full.names = TRUE)
files <- sort(files)

# create SpatRasterCollection
rc <- sprc(files)

# little check
stopifnot(length(rc) == 81)
check <- rast(files[1])
message("nlyr = ", nlyr(check), ", res = ", paste(res(check), collapse="x"))

# GDAL write options
wopt <- list(
  datatype = "FLT4S",
  gdal = c("COMPRESS=LZW", "TILED=YES", "BIGTIFF=YES")
)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Mosaic
mosaic(
  rc,
  fun = "first", # takes first layer value
  filename = out_file,
  overwrite = TRUE,
  wopt = wopt
)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #