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

# reprojecting to master grid1000
reproject_tree_to_ref(
  root_in = here("data", "__COMPATIBILITY__", "CHELSA", "original"),
  root_out = here("data", "__COMPATIBILITY__", "CHELSA", "CHELSA_1000"),
  reference = ref_1000,
  method = "bilinear",
  tol = 1e-7
  )

# splitting into smaller grid 500
# ORIGINAL DATA: CHELSA_1000
reproject_tree_to_ref(
  root_in = here("data", "__COMPATIBILITY__", "CHELSA", "CHELSA_1000"),
  root_out = here("data", "__COMPATIBILITY__", "CHELSA", "CHELSA_500"),
  reference = ref_500,
  method = "near",
  tol = 1e-7
)

# splitting into smaller grid 200
# ORIGINAL DATA: CHELSA_1000
reproject_tree_to_ref(
  root_in = here("data", "__COMPATIBILITY__", "CHELSA", "CHELSA_1000"),
  root_out = here("data", "__COMPATIBILITY__", "CHELSA", "CHELSA_200"),
  reference = ref_200,
  method = "near",
  tol = 1e-7
)

# splitting into smaller grid 100
# ORIGINAL DATA: CHELSA_1000
reproject_tree_to_ref(
  root_in = here("data", "__COMPATIBILITY__", "CHELSA", "CHELSA_1000"),
  root_out = here("data", "__COMPATIBILITY__", "CHELSA", "CHELSA_100"),
  reference = ref_100,
  method = "near",
  tol = 1e-7
)

# splitting into smaller grid 20
# ORIGINAL DATA: CHELSA_1000
reproject_tree_to_ref(
  root_in = here("data", "__COMPATIBILITY__", "CHELSA", "CHELSA_1000"),
  root_out = here("data", "__COMPATIBILITY__", "CHELSA", "CHELSA_20"),
  reference = ref_20,
  method = "near",
  tol = 1e-7
)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# GEO
# rasterize based on the reference
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# DEM

# reprojecting from 30m to 20m, interpolation, bilinear
reproject_tree_to_ref(
  root_in = here("data", "__COMPATIBILITY__", "DEM", "base"),
  root_out = here("data", "__COMPATIBILITY__", "DEM", "DEM_20"),
  reference = ref_20,
  method = "bilinear",
  tol = 1e-7
)

# from 30 to 100, aggregation, mean
reproject_tree_to_ref(
  root_in = here("data", "__COMPATIBILITY__", "DEM", "base"),
  root_out = here("data", "__COMPATIBILITY__", "DEM", "DEM_100"),
  reference = ref_100,
  method = "mean",
  tol = 1e-7
)

# from 30 to 200, aggregation, mean
reproject_tree_to_ref(
  root_in = here("data", "__COMPATIBILITY__", "DEM", "base"),
  root_out = here("data", "__COMPATIBILITY__", "DEM", "DEM_200"),
  reference = ref_200,
  method = "mean",
  tol = 1e-7
)

# from 30 to 500, aggregation, mean
reproject_tree_to_ref(
  root_in = here("data", "__COMPATIBILITY__", "DEM", "base"),
  root_out = here("data", "__COMPATIBILITY__", "DEM", "DEM_500"),
  reference = ref_500,
  method = "mean",
  tol = 1e-7
)

# from 30 to 1000, aggregation, mean
reproject_tree_to_ref(
  root_in = here("data", "__COMPATIBILITY__", "DEM", "base"),
  root_out = here("data", "__COMPATIBILITY__", "DEM", "DEM_1000"),
  reference = ref_1000,
  method = "mean",
  tol = 1e-7
)


# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# WC

# reprojecting only, method near
reproject_tree_to_ref(
  root_in = here("data", "__COMPATIBILITY__", "WC", "base"),
  root_out = here("data", "__COMPATIBILITY__", "WC", "WC_20"),
  reference = ref_20,
  method = "near",
  tol = 1e-7
)

# 100 aggregation, mode
reproject_tree_to_ref(
  root_in = here("data", "__COMPATIBILITY__", "WC", "base"),
  root_out = here("data", "__COMPATIBILITY__", "WC", "WC_100"),
  reference = ref_100,
  method = "mode",
  tol = 1e-7
)

# 200 aggregation, mode
reproject_tree_to_ref(
  root_in = here("data", "__COMPATIBILITY__", "WC", "base"),
  root_out = here("data", "__COMPATIBILITY__", "WC", "WC_200"),
  reference = ref_200,
  method = "mode",
  tol = 1e-7
)

# 500 aggregation, mode
reproject_tree_to_ref(
  root_in = here("data", "__COMPATIBILITY__", "WC", "base"),
  root_out = here("data", "__COMPATIBILITY__", "WC", "WC_500"),
  reference = ref_500,
  method = "mode",
  tol = 1e-7
)

# 1000 aggregation, mode
reproject_tree_to_ref(
  root_in = here("data", "__COMPATIBILITY__", "WC", "base"),
  root_out = here("data", "__COMPATIBILITY__", "WC", "WC_1000"),
  reference = ref_1000,
  method = "mode",
  tol = 1e-7
)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# RS
### keep only in 20m resolution (it worked as template)
# I dont think, that I will compute anything on coarser res than original 20m