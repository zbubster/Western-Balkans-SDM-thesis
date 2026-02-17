# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Main CHELSA script
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

source(here("scripts", "fun_chelsa_bioclim_v21_crop_aoi.R"))
dir_out <- here("data", "CHELSA", "CHELSA_v21")
extent <- sf::st_read(here("data", "extent_raw.gpkg"))

chelsa_bioclim_v21_crop_aoi(
  aoi_sf = extent,
  include_scd = T,
  out_dir = dir_out,
  overwrite = F
)

source(here("scripts", "fun_chelsa_trace21k_crop_aoi.R"))
dir_out <- here("data", "CHELSA", "CHELSA_TraCE21k")
extent <- sf::st_read(here("data", "extent_raw.gpkg"))

chelsa_trace21k_crop_aoi(
  aoi_sf = extent,
  out_dir = dir_out,
  steps = -200:20,
  include_scd = T,
  overwrite = F
)
