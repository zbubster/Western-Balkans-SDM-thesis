# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Align Sentinel 2 rasters
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Settings

in_dir <- here("data", "Sentinel2_medoids")
files <- list.files(in_dir, pattern="\\.tif$", full.names=TRUE)

# reference tile
# compute for other tiles shifts from this reference tile
r_ref <- rast(files[42])

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Function

# compute offsets in CRS units
grid_offset <- function(r, ref) {
  # compare resolutions
  res_r  <- res(r)
  res_rf <- res(ref)
  
  # origin
  ox  <- (xmin(r)  %% res_r[1])
  oy  <- (ymin(r)  %% res_r[2])
  ox0 <- (xmin(ref) %% res_rf[1])
  oy0 <- (ymin(ref) %% res_rf[2])
  
  # shift
  dx <- abs(ox - ox0)
  dy <- abs(oy - oy0)
  
  dx <- pmin(dx, res_r[1] - dx)
  dy <- pmin(dy, res_r[2] - dy)
  
  c(dx = dx, dy = dy)
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Apply functon on tiles

# compute offset for every tile
offs <- lapply(files, function(f) {
  r <- rast(f)
  o <- grid_offset(r, r_ref)
  data.frame(file = basename(f), dx = o["dx"], dy = o["dy"])
})
offs <- do.call(rbind, offs)

# shift combined for two axes
offs$shift_m <- sqrt(offs$dx^2 + offs$dy^2)

# offset distribution
par(mfrow = c(2,1))
hist(offs$dx, breaks=20, main="dx (m) shift", xlab="dx")
hist(offs$dy, breaks=20, main="dy (m) shift", xlab="dy")
par(mfrow = c(1,1))

# get tile centroids (for spatial vizsualization)
centroids <- lapply(files, function(f) {
  r <- rast(f)
  xy <- c((xmin(r)+xmax(r))/2, (ymin(r)+ymax(r))/2)
  vect(matrix(xy, ncol=2), type="points", crs=crs(r))
})
centroids <- do.call(rbind, centroids)
centroids <- cbind(centroids, offs)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Write

writeVector(centroids, here("data", "tile_grid_offset.gpkg"), layer="offset_points", overwrite=TRUE)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #