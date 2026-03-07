# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# FUN ‒ keep unique points within cell
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# !! IMPORTANT !!
# Data should be arranged as there are Presences firs, than Absences. If not,
# Presences could be dropped and Absences kept, which is probably not wanted.

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# function:
filter_pa_to_unique_cells <- function(spec, r, drop_outside = TRUE, keep_cell_id = FALSE) {
  
  # get coors & obs
  xy <- base::as.data.frame(spec$coor)[, c("X", "Y"), drop = FALSE]
  obs <- base::as.numeric(spec$observations)
  
  # cell id
  cell <- terra::cellFromXY(r, xy)
  
  # drop observations outside from raster extent
  if (drop_outside) {
    keep <- !base::is.na(cell)
    xy   <- xy[keep, , drop = FALSE]
    obs  <- obs[keep]
    cell <- cell[keep]
  }
  
  # drop duplicated cell id
  keep <- !base::duplicated(cell)
  
  # output
  out <- list(
    species = spec$species,
    observations = obs[keep],
    coor = xy[keep, , drop = FALSE]
  )
  
  # if cell id is wanted
  if (keep_cell_id) {
    out$cell <- cell[keep]
  }
  
  return(out)
}
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #