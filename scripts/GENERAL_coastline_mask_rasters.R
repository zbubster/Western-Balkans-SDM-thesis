# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# GENERAL ‒ mask stacks with coastline
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

stacks_dir <- here::here("data", "__COMPATIBILITY__", "STACKS", "__STACKS__")
out_dir <- here::here(stacks_dir, "coastline_masked")
if(!dir.exists(out_dir)) dir.create(out_dir)

# load rasters
files <- list.files(stacks_dir)
nums <- as.numeric(sub("stack_(\\d+)\\.tif", "\\1", files))
files <- files[order(nums)]

r_100 <- terra::rast(file.path(stacks_dir, files[1]))
r_200 <- terra::rast(file.path(stacks_dir, files[2]))
r_500 <- terra::rast(file.path(stacks_dir, files[3]))
r_1000 <- terra::rast(file.path(stacks_dir, files[4]))

# load raw extent
extent <- terra::vect(here::here("data", "extent_raw.gpkg"))

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Land polygon

# get land polygon data
land <- rnaturalearth::ne_download(
  scale = 10,
  type = "land",
  category = "physical",
  returnclass = "sv"
)

# project land polygon to 3035
land <- terra::project(land, terra::crs(extent))

# get intersection of land within focal extent
land_extent <- terra::intersect(land, extent)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Mask out offshore values of predictor raster stacks

terra::mask(r_100, land_extent, filename = file.path(out_dir, "r_100.tif"))
terra::mask(r_200, land_extent, filename = file.path(out_dir, "r_200.tif"))
terra::mask(r_500, land_extent, filename = file.path(out_dir, "r_500.tif"))
terra::mask(r_1000, land_extent, filename = file.path(out_dir, "r_1000.tif"))

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #