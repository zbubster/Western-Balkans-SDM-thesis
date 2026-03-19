# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Add northness, eastness
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

rasters_dir <- here::here("data", "__ANALYSIS__", "ELEV")
rasters_dir <- here::here("data", "__ANALYSIS__", "FULL")

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# load rasters into list
r <- list(
  r_1000 = terra::rast(file.path(rasters_dir, "r_1000.tif")),
  r_500 = terra::rast(file.path(rasters_dir, "r_500.tif")),
  r_200 = terra::rast(file.path(rasters_dir, "r_200.tif")),
  r_100 = terra::rast(file.path(rasters_dir, "r_100.tif"))
)

# function
north_east <- function(r){
  r$northness <- cos(r$aspect*pi/180)
  r$eastness <- sin(r$aspect*pi/180)
  return(r)
}

r <- lapply(r, north_east)

# save updated rasterstacks
for(i in seq_along(r)){
  file <- file.path(rasters_dir, paste0(names(r)[i], "_NE.tif"))
  terra::writeRaster(r[[i]], filename = file)
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #