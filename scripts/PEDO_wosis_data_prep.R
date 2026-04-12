# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# WOSIS preparation
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Config

# load extent and reference layers
extent <- terra::vect(here::here("data", "extent_raw.gpkg"))
ref_1000 <- terra::rast(here::here("data", "__COMPATIBILITY__", "ref_1000.tif"))
ref_500 <- terra::rast(here::here("data", "__COMPATIBILITY__", "ref_500.tif"))
ref_200 <- terra::rast(here::here("data", "__COMPATIBILITY__", "ref_200.tif"))
ref_100 <- terra::rast(here::here("data", "__COMPATIBILITY__", "ref_100.tif"))
ref_20 <- terra::rast(here::here("data", "__COMPATIBILITY__", "master_20m.tif"))

# outputs
dir_out <- here::here("data", "__COMPATIBILITY__", "WOSIS")
if(!dir.exists(dir_out)) dir.create(dir_out)
# write options
wopt <- list(gdal = c("COMPRESS=LZW", "TILED=YES"))

# source data
files <- list.files(here::here("data", "WOSIS", "source"), full.names = TRUE)
r <- lapply(files, terra::rast)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Main processing (crop, project, mask)

# get WGS 84 extent with buffer
extent_84 <- terra::project(extent, terra::crs(r[[1]]))
extent_84 <- terra::buffer(extent_84, 100000)
# extract bounding box
bb <- terra::ext(extent_84)

# process source data
for(i in seq_along(r)){
  message("Processing ", names(r[[i]]))
  r[[i]] <- terra::crop(r[[i]], bb)
  message("Cropped")
  r[[i]] <- terra::project(r[[i]], terra::crs(extent))
  message("Projected")
  r[[i]] <- terra::mask(r[[i]], extent)
  message("Masked")
  r[[i]] <- terra::mask(r[[i]], extent)
  message("DONE")
}

names(r[[1]]) <- "absolute_depth_to_bedrock"
names(r[[2]]) <- "soil_pH_in_H2O"
names(r[[3]]) <- "predicted_USDA_suborder_class"
names(r[[4]]) <- "avail_soil_water_capacity_until_wilting_point"

# save processed data
terra::writeRaster(r[[1]], here::here("data", "WOSIS", "BDTICM_processed.tif"), overwrite = T)
terra::writeRaster(r[[2]], here::here("data", "WOSIS", "PHIHOX_processed.tif"), overwrite = T)
terra::writeRaster(r[[3]], here::here("data", "WOSIS", "TAXOUSDA_processed.tif"), overwrite = T)
terra::writeRaster(r[[4]], here::here("data", "WOSIS", "WWP_processed.tif"), overwrite = T)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Prepare resolution sets

references <- list(ref_1000, ref_500, ref_200, ref_100, ref_20)
# remove catherogical classification layer
r <- r[unlist(lapply(r, names) != "predicted_USDA_suborder_class")]

# loop
for(i in seq_along(r)){
  x <- r[[i]]
  message("Processing ", names(x))
  for(j in seq_along(references)){
    ref <- references[[j]]
    if(terra::res(ref)[[1]] >= terra::res(x)[[1]]){
      metoda <- "mean"
    }else{
      metoda <- "bilinear"
    }
    
    message("Resolution: ", terra::res(ref)[[1]], ", method: ", metoda)
    
    file_out <- file.path(dir_out, paste0(names(x), "_", terra::res(ref)[[1]], ".tif"))
    
    terra::project(
      x,
      ref,
      method = metoda,
      filename = file_out,
      overwrite = TRUE,
      wopt = wopt
    )
    
    message("DONE")
    
  }
  
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #