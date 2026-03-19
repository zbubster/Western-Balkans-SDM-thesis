# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Mask stacks with elevation mask
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Config

stacks_dir <- here::here("data", "__COMPATIBILITY__", "STACKS", "__STACKS__", "coastline_masked")
masks_dir <- here::here("data", "__COMPATIBILITY__", "MASK")
out_dir <- here::here("data", "__COMPATIBILITY__", "STACKS", "__STACKS_MASKED__")
if(!dir.exists(out_dir)){dir.create(out_dir)}

# load rasters
files <- list.files(stacks_dir)
nums <- as.numeric(sub("r_(\\d+)\\.tif", "\\1", files))
files <- files[order(nums)]

r_100 <- terra::rast(file.path(stacks_dir, files[1]))
r_200 <- terra::rast(file.path(stacks_dir, files[2]))
r_500 <- terra::rast(file.path(stacks_dir, files[3]))
r_1000 <- terra::rast(file.path(stacks_dir, files[4]))

# load masks
masks <- list.files(masks_dir)
nums <- as.numeric(sub("m500_(\\d+)\\.tif", "\\1", masks))
masks <- masks[order(nums)]

m_100 <- terra::rast(file.path(masks_dir, masks[1]))
m_200 <- terra::rast(file.path(masks_dir, masks[2]))
m_500 <- terra::rast(file.path(masks_dir, masks[3]))
m_1000 <- terra::rast(file.path(masks_dir, masks[4]))

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

terra::mask(r_1000, m_1000, filename = file.path(out_dir, "r_1000.tif"), overwrite = TRUE)
terra::mask(r_500, m_500, filename = file.path(out_dir, "r_500.tif"), overwrite = TRUE)
terra::mask(r_200, m_200, filename = file.path(out_dir, "r_200.tif"), overwrite = TRUE)
terra::mask(r_100, m_100, filename = file.path(out_dir, "r_100.tif"), overwrite = TRUE)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #