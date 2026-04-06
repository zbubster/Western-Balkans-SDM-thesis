# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Terra WorldCover informed aggregation
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Config

# load data
base <- terra::rast(here::here("data", "__COMPATIBILITY__", "WC", "base", "ESA_WC_3035_20.tiff"))
ref_20 <- terra::rast(here::here("data", "__COMPATIBILITY__", "master_20m.tif"))
# check geom
stopifnot(terra::compareGeom(base, ref_20))

# set outdir
dir_out <- here::here("data", "__COMPATIBILITY__", "WC", "INFORMED")
if(!dir.exists(dir_out)) dir.create(dir_out)

# load function
source(here::here("scripts", "fun_informed_aggregation.R"))

# wopt, cores
ncores <- 15
wopt <- list(
  gdal = c("COMPRESS=LZW", "TILED=YES", "BIGTIFF=YES")
)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Categories info

# 10 Tree cover 
# 20 Shrubland 
# 30 Grassland 
# 40 Cropland 
# 50 Built-up 
# 60 Bare/sparse vegetation 
# 70 Snow and ice 
# 80 Permanent water bodies 
# 90 Herbaceous wetland 
# 95 Mangroves 
# 100 Moss and lichen


# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# apply function on different grain levels

# 100 m
fun_informed_aggregation(
  r = base,
  fact = 5,
  fun = "modal",
  priority_class = 60,
  threshold = 0.05,
  ties = "first",
  filename = file.path(dir_out, "ESA_WC_100m_cat60_005.tif"),
  overwrite = TRUE,
  wopt = wopt,
  cores = ncores
)

# 200 m
fun_informed_aggregation(
  r = base,
  fact = 10,
  fun = "modal",
  priority_class = 60,
  threshold = 0.05,
  ties = "first",
  filename = file.path(dir_out, "ESA_WC_200m_cat60_005.tif"),
  overwrite = TRUE,
  wopt = wopt,
  cores = ncores
)

# 500 m
fun_informed_aggregation(
  r = base,
  fact = 25,
  fun = "modal",
  priority_class = 60,
  threshold = 0.05,
  ties = "first",
  filename = file.path(dir_out, "ESA_WC_500m_cat60_005.tif"),
  overwrite = TRUE,
  wopt = wopt,
  cores = ncores
)

# 1000 m
fun_informed_aggregation(
  r = base,
  fact = 50,
  fun = "modal",
  priority_class = 60,
  threshold = 0.05,
  ties = "first",
  filename = file.path(dir_out, "ESA_WC_1000m_cat60_005.tif"),
  overwrite = TRUE,
  wopt = wopt,
  cores = ncores
)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #