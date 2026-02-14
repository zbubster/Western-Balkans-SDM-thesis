# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Main CHELSA script
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

source(here("scripts", "fun_chelsa_bioclim_v21_crop_aoi.R"))

#dir_out <- "/media/zbub/DATA/CHELSA/CHELSA_v21_bioclim_AOI"
extent

chelsa_bioclim_v21_crop_aoi(
  aoi_sf = extent,
  out_dir = dir_out,
  overwrite = F
)
