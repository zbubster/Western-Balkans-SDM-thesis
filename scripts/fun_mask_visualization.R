# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# FUN ‒ crop and mask for visualization
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

crop_mask_aoi_land <- function(
    raster_input,
    aoi_path = here::here("data", "extent_raw.gpkg"),
    epsg = 3035,
    aoi_negative_buffer_m = 1000
) {
  
  # load raster
  r <- if (inherits(raster_input, "SpatRaster")) {
    raster_input
  } else {
    terra::rast(raster_input)
  }
  
  target_crs <- paste0("EPSG:", epsg)
  
  # load AOI and transform to target CRS
  aoi <- sf::st_read(aoi_path, quiet = TRUE)
  aoi <- sf::st_make_valid(aoi)
  aoi <- sf::st_transform(aoi, epsg)
  
  # apply negative buffer
  aoi <- sf::st_buffer(aoi, dist = -aoi_negative_buffer_m)
  aoi <- sf::st_make_valid(aoi)
  aoi <- sf::st_collection_extract(aoi, "POLYGON")
  
  if (nrow(aoi) == 0 || all(sf::st_is_empty(aoi))) {
    stop("AOI is empty after applying the negative buffer.")
  }
  
  # download land polygon from Natural Earth and transform to EPSG:3035
  land <- rnaturalearth::ne_download(
    scale = 10,
    type = "land",
    category = "physical",
    returnclass = "sf"
  )
  
  land <- sf::st_make_valid(land)
  land <- sf::st_transform(land, epsg)
  
  # intersect buffered AOI with land polygon
  land_aoi <- sf::st_intersection(
    sf::st_union(aoi),
    sf::st_union(land)
  )
  
  land_aoi <- sf::st_make_valid(land_aoi)
  land_aoi <- sf::st_collection_extract(land_aoi, "POLYGON")
  
  # convert mask polygon to terra vector
  land_aoi_vect <- terra::vect(land_aoi)
  
  # crop and mask raster
  r_crop <- terra::crop(r, land_aoi_vect)
  r_mask <- terra::mask(r_crop, land_aoi_vect)
  
  return(r_mask)
}