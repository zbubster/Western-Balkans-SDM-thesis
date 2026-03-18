# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# FUN - topographic wettness index
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

calc_twi <- function(dem,
                     dem_units = c("m", "lonlat"),
                     neighbors = 8,
                     output_dir = NULL,
                     overwrite = TRUE) {
  dem_units <- base::match.arg(dem_units)
  
  if (!inherits(dem, "SpatRaster")) {
    stop("`dem` musí být terra::SpatRaster.")
  }
  
  if (!is.null(output_dir) && !base::dir.exists(output_dir)) {
    base::dir.create(output_dir, recursive = TRUE)
  }
  
  # 1) flow direction (D8)
  fd <- terra::terrain(dem, v = "flowdir")
  
  # 2) upslope contributing area (A) v m^2
  if (dem_units == "m") {
    acc_cells <- terra::flowAccumulation(fd)     # počet buněk
    cell_area <- base::prod(terra::res(dem))     # (map units)^2, pro metry => m^2
    A <- acc_cells * cell_area                   # m^2
    w <- base::sqrt(cell_area)                   # m
  } else {
    cell_area <- terra::cellSize(dem, unit = "m")        # m^2 pro každou buňku
    A <- terra::flowAccumulation(fd, weight = cell_area) # m^2
    w <- base::sqrt(cell_area)                            # m
  }
  
  # 3) slope (radians)
  slope <- terra::terrain(dem, v = "slope", unit = "radians", neighbors = neighbors)
  
  # 4) TWI = ln( (A / w) / tan(slope) )
  sca <- A / w
  slope2 <- terra::ifel(slope < 0.001, 0.001, slope)
  twi <- base::log((sca + 1e-6) / base::tan(slope2))
  
  # save
  if (!is.null(output_dir)) {
    terra::writeRaster(fd,    base::file.path(output_dir, "flowdir.tif"),      overwrite = overwrite)
    terra::writeRaster(A,     base::file.path(output_dir, "upslope_area_m2.tif"), overwrite = overwrite)
    terra::writeRaster(slope, base::file.path(output_dir, "slope_rad.tif"),    overwrite = overwrite)
    terra::writeRaster(twi,   base::file.path(output_dir, "twi.tif"),          overwrite = overwrite)
  }
  
  list(twi = twi, slope = slope, upslope_area_m2 = A, flowdir = fd)
}