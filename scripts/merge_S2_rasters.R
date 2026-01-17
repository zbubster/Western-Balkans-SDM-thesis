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

# check metadata
check <- data.frame(
  file   = basename(files),
  nlyr   = sapply(files, \(f) nlyr(rast(f))),
  res_x  = sapply(files, \(f) res(rast(f))[1]),
  res_y  = sapply(files, \(f) res(rast(f))[2]),
  orig_x = sapply(files, \(f) origin(rast(f))[1]),
  orig_y = sapply(files, \(f) origin(rast(f))[2]),
  crs    = sapply(files, \(f) crs(rast(f))),
  stringsAsFactors = FALSE
)

sapply(check[, c("nlyr","res_x","res_y","orig_x","orig_y","crs")], function(x) length(unique(x)))
# there should be always only 1 unique value:
# nlyr  res_x  res_y orig_x orig_y   crs 
#  1      1      1      1      1      1 

# create SpatRasterCollection
rc <- sprc(files)

# GDAL write options
wopt <- list(
  datatype = "FLT4S",
  gdal = c("COMPRESS=LZW", "TILED=YES", "BIGTIFF=YES")
)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Mosaic
mosaic(
  rc,
  fun = "first", # takes value of the first layer
  filename = out_file,
  overwrite = TRUE,
  wopt = wopt
)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #