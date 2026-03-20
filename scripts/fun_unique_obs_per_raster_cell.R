# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# FUN ‒ keep unique points within cell
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Presences are sorted first, so if Presence and Absence fall into the same
# raster cell, Presence is kept and Absence is removed.

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

filter_pa_to_unique_cells <- function(spec, r, drop_outside = TRUE, keep_cell_id = FALSE) {
  
  # get coors & obs
  xy <- base::as.data.frame(spec$coor)[, c("X", "Y"), drop = FALSE]
  obs <- base::as.numeric(spec$observations)
  source <- as.character(spec$source)
  
  # cell id
  cell <- terra::cellFromXY(r, xy)
  
  # drop observations outside raster extent
  if (drop_outside) {
    keep <- !base::is.na(cell)
    xy   <- xy[keep, , drop = FALSE]
    obs  <- obs[keep]
    cell <- cell[keep]
  }
  
  # sort so Presences go first
  ord <- base::order(-obs, base::seq_along(obs))
  xy   <- xy[ord, , drop = FALSE]
  obs  <- obs[ord]
  cell <- cell[ord]
  
  # keep only first record within each cell
  keep <- !base::duplicated(cell)
  
  # output
  out <- list(
    species = spec$species,
    observations = obs[keep],
    coor = xy[keep, , drop = FALSE],
    source = source[keep]
  )
  
  # if cell id is wanted
  if (keep_cell_id) {
    out$cell <- cell[keep]
  }
  
  return(out)
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #