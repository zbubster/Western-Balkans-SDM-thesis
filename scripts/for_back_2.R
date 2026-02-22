# for back 2
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

# # splitting into smaller grid 200
# # ORIGINAL DATA: CHELSA_1000
# reproject_tree_to_ref(
#   root_in = here("data", "__COMPATIBILITY__", "CHELSA", "CHELSA_1000"),
#   root_out = here("data", "__COMPATIBILITY__", "CHELSA", "CHELSA_200"),
#   reference = ref_200,
#   method = "near",
#   tol = 1e-7
# )

# splitting into smaller grid 100
# ORIGINAL DATA: CHELSA_1000
# reproject_tree_to_ref(
#   root_in = here("data", "__COMPATIBILITY__", "CHELSA", "CHELSA_1000", "CHELSA_v21"),
#   root_out = here("data", "__COMPATIBILITY__", "CHELSA", "CHELSA_100"),
#   reference = ref_100,
#   method = "near",
#   tol = 1e-7
# )

# # splitting into smaller grid 20
# # ORIGINAL DATA: CHELSA_1000
# reproject_tree_to_ref(
#   root_in = here("data", "__COMPATIBILITY__", "CHELSA", "CHELSA_1000", "CHELSA_v21"),
#   root_out = here("data", "__COMPATIBILITY__", "CHELSA", "CHELSA_20"),
#   reference = ref_20,
#   method = "near",
#   tol = 1e-7
# )