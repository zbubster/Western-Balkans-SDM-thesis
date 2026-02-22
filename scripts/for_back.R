# for back
library(here)
library(terra)
library(dplyr)
library(sf)

ref_20 <- terra::rast(here("data", "__COMPATIBILITY__", "master_20m.tif"))
ref_100 <- terra::rast(here("data", "__COMPATIBILITY__", "ref_100.tif"))
ref_200 <- terra::rast(here("data", "__COMPATIBILITY__", "ref_200.tif"))
ref_500 <- terra::rast(here("data", "__COMPATIBILITY__", "ref_500.tif"))
ref_1000 <- terra::rast(here("data", "__COMPATIBILITY__", "ref_1000.tif"))

source(here("scripts", "fun_reproject_tree_to_ref.R"))

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
