# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Fun ‒ informed aggregation
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# FUN

fun_informed_aggregation <- function(r,
                                     fact,
                                     fun = "modal",
                                     priority_class = NA_integer_,
                                     threshold = 0.05,
                                     ties = "first",
                                     filename = "",
                                     overwrite = FALSE,
                                     wopt = list(),
                                     cores = 1) {
  
  # number of valid cells within target cell
  n_valid <- terra::aggregate(
    x = r,
    fact = fact,
    fun = function(x, ...) {
      base::sum(!base::is.na(x))
    }
  )
  
  # number of priority cells within target cell
  n_priority <- terra::aggregate(
    x = r,
    fact = fact,
    fun = function(x, ...) {
      base::sum(x == priority_class, na.rm = TRUE)
    }
  )
  
  # proportion of priority class
  prop_priority <- n_priority / n_valid
  prop_priority <- terra::ifel(n_valid == 0, NA, prop_priority)
  
  # aggregate
  r_out <- terra::aggregate(
    x = r,
    fact = fact,
    fun = fun,
    ties = ties,
    na.rm = TRUE,
    cores = cores
  )
  
  # overwrite to priority class when proportion is over threshold
  out <- terra::ifel(
    test = prop_priority >= threshold,
    yes = priority_class,
    no = r_out
  )
  
  # opitional write raster to disk
  if (filename != "") {
    out <- terra::writeRaster(
      x = out,
      filename = filename,
      overwrite = overwrite,
      wopt = wopt
    )
  }
  
  return(out)
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #