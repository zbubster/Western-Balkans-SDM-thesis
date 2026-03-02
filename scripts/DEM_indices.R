# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Dem indices
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# load DEMs
dem_1000 <- terra::rast(here("data", "__COMPATIBILITY__", "DEM", "DEM_1000", "DEM_1000.tif"))
dem_500 <- terra::rast(here("data", "__COMPATIBILITY__", "DEM", "DEM_500", "DEM_500.tif"))
dem_200 <- terra::rast(here("data", "__COMPATIBILITY__", "DEM", "DEM_200", "DEM_200.tif"))
dem_100 <- terra::rast(here("data", "__COMPATIBILITY__", "DEM", "DEM_100", "DEM_100.tif"))
#dem_20 <- terra::rast(here("data", "__COMPATIBILITY__", "DEM", "DEM_20", "DEM_20.tif"))

# output dir
dir_out <- here("data", "__COMPATIBILITY__", "DEM_indices")
if (!dir.exists(dir_out)) dir.create(dir_out, recursive = TRUE)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Compute indices

# which ind
indices <- c("slope", "aspect", "TPI", "TRI", "TRIriley", "TRIrmsd", "roughness", "flowdir")

# loop over all raster layers
for(i in seq_along(indices)){
  index <- indices[i]
  message("Starting ", toupper(index))
  
  terra::terrain(dem_1000, v = index, neighbors = 8, unit = "degrees", filename = file.path(dir_out, paste0(index, "_1000.tif")))
  print("1000 DONE")
  terra::terrain(dem_500, v = index, neighbors = 8, unit = "degrees", filename = file.path(dir_out, paste0(index, "_500.tif")))
  print("500 DONE")
  terra::terrain(dem_200, v = index, neighbors = 8, unit = "degrees", filename = file.path(dir_out, paste0(index, "_200.tif")))
  print("200 DONE")
  terra::terrain(dem_100, v = index, neighbors = 8, unit = "degrees", filename = file.path(dir_out, paste0(index, "_100.tif")))
  print("100 DONE")
  terra::terrain(dem_20, v = index, neighbors = 8, unit = "degrees", filename = file.path(dir_out, paste0(index, "_20.tif")))
  print("20 DONE")
  
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #