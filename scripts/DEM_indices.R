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
# Heat load index
# using spatialEco package

hli_1000 <- spatialEco::hli(dem_1000)
writeRaster(hli_1000, filename = file.path(dir_out, "hli_1000.tif"))
hli_500 <- spatialEco::hli(dem_500)
writeRaster(hli_500, filename = file.path(dir_out, "hli_500.tif"))
hli_200 <- spatialEco::hli(dem_200)
writeRaster(hli_200, filename = file.path(dir_out, "hli_200.tif"))
hli_100 <- spatialEco::hli(dem_100)
writeRaster(hli_100, filename = file.path(dir_out, "hli_100.tif"))
# hli_20 <- spatialEco::hli(dem_20)
# writeRaster(hli_20, filename = file.path(dir_out, "hli_20.tif"))

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# TWI

source(here("scripts", "fun_twi.R"))

calc_twi(dem_1000, dem_units = "m", neighbors = 8, output_dir = file.path(dir_out, "twi_1000"))
calc_twi(dem_500, dem_units = "m", neighbors = 8, output_dir = file.path(dir_out, "twi_500"))
calc_twi(dem_200, dem_units = "m", neighbors = 8, output_dir = file.path(dir_out, "twi_200"))
calc_twi(dem_100, dem_units = "m", neighbors = 8, output_dir = file.path(dir_out, "twi_100"))
# calc_twi(dem_20, dem_units = "m", neighbors = 8, output_dir = file.path(dir_out, "twi_20"))

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #