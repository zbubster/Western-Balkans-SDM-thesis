# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Add northness, eastness
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

rasters_dir <- here::here("data", "__COMPATIBILITY__", "DEM_indices")

# get file path, but drop 20m raster !
aspects <- list.files(
  path = rasters_dir,
  pattern = "aspect*",
  full.names = T
) %>%
  subset(!grepl("20.tif", aspects))

# load rasters into SpatRasterCollection
r <- terra::sprc(aspects)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# functions
northness <- function(r){
  n <- cos(r$aspect*pi/180)
  names(n) <- stringr::str_replace(names(n), "aspect", "northness")
  terra::varnames(n) <- stringr::str_replace(terra::varnames(n), "aspect", "northness")
  return(n)
}

eastness <- function(r){
  e <- sin(r$aspect*pi/180)
  names(e) <- stringr::str_replace(names(e), "aspect", "eastness")
  terra::varnames(e) <- stringr::str_replace(terra::varnames(e), "aspect", "eastness")
  return(e)
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# loop
for(i in seq_along(r)){
  # get aspect from collection
  x <- r[i]
  message("working on grain: ", terra::res(x)[1])
  
  # northness, incl write
  x_n <- northness(x)
  name <- paste0(terra::varnames(x_n), ".tif")
  terra::writeRaster(
    x_n,
    filename = file.path(rasters_dir, name)
  )
  message("northness DONE")
  
  # eastenss, incl write
  x_e <- eastness(x)
  name <- paste0(terra::varnames(x_e), ".tif")
  terra::writeRaster(
    x_e,
    filename = file.path(rasters_dir, name)
  )
  message("eastness DONE")
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #