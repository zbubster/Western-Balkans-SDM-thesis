# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Compute aggregated DEM with other stats
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Config

# load function
source(here::here("scripts", "fun_DEM_aggregation_with_SD_etal.R"))
# load dem
dem_20 <- terra::rast(here::here("data", "__COMPATIBILITY__", "DEM", "DEM_20", "DEM_20.tif"))

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# 1000
out_dir <- here::here("data", "__COMPATIBILITY__", "DEM_agg", "1000")
if(!dir.exists(out_dir)) dir.create(out_dir)

aggregate_dem_stats_to_disk(
  dem = dem_20,
  out_dir = out_dir,
  grains = 1000,
  prefix = "DEM_agg",
  overwrite = TRUE
)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# 500
out_dir <- here::here("data", "__COMPATIBILITY__", "DEM_agg", "500")
if(!dir.exists(out_dir)) dir.create(out_dir)

aggregate_dem_stats_to_disk(
  dem = dem_20,
  out_dir = out_dir,
  grains = 500,
  prefix = "DEM_agg",
  overwrite = TRUE
)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# 200
out_dir <- here::here("data", "__COMPATIBILITY__", "DEM_agg", "200")
if(!dir.exists(out_dir)) dir.create(out_dir)

aggregate_dem_stats_to_disk(
  dem = dem_20,
  out_dir = out_dir,
  grains = 200,
  prefix = "DEM_agg",
  overwrite = TRUE
)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# 100
out_dir <- here::here("data", "__COMPATIBILITY__", "DEM_agg", "100")
if(!dir.exists(out_dir)) dir.create(out_dir)

aggregate_dem_stats_to_disk(
  dem = dem_20,
  out_dir = out_dir,
  grains = 100,
  prefix = "DEM_agg",
  overwrite = TRUE
)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #