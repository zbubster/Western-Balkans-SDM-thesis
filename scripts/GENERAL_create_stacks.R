# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Create raster stacks
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# BEWARE the create_stack() function!!

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Config

source(here::here("scripts", "fun_create_stack.R"))

dir_root <- here::here("data", "__COMPATIBILITY__", "STACKS")
dir_out <- here::here("data", "__COMPATIBILITY__", "STACKS", "__STACKS_OUT__")
if(!dir.exists(dir_out)) dir.create(dir_out)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# 1000m

# recent
dir <- here::here(dir_root, "source_1000")
create_stack(
  source_dir = dir,
  climate_dir = here::here(dir, "CHELSA_1000", "CHELSA_v21", "1981-2010"),
  path_out = here::here(dir_out, "r_1000_recent.tif")
)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# 500m

# recent
dir <- here::here(dir_root, "source_500")
create_stack(
  source_dir = dir,
  climate_dir = here::here(dir, "CHELSA_500", "CHELSA_v21", "1981-2010"),
  path_out = here::here(dir_out, "r_500_recent.tif")
)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# 200m

# recent
dir <- here::here(dir_root, "source_200")
create_stack(
  source_dir = dir,
  climate_dir = here::here(dir, "CHELSA_200", "CHELSA_v21", "1981-2010"),
  path_out = here::here(dir_out, "r_200_recent.tif")
)


# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# 100m

# recent
dir <- here::here(dir_root, "source_100")
create_stack(
  source_dir = dir,
  climate_dir = here::here(dir, "CHELSA_100", "CHELSA_v21", "1981-2010"),
  path_out = here::here(dir_out, "r_100_recent.tif")
)


# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# 20m

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #