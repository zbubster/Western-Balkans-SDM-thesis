# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# FUN ‒ Shape
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
#
# Function comutes Shape metric representing degree of extrapolation,
# aka 'environmental novelty'.
#
# Output: .tif file with shape metric & bivariate graphs representing
# variability within predictors within AOI and adds point for observation
# data points.
#
# This function takes as input
# pred = predictors raster stack, class terra SpatRaster
# spec = species observations list. it should have list objects names as
# spec$coor = df with coordinates, columns should be named as 'X' and 'Y'
# spec$observations = integer binary 0/1, nrow(spec$coor) == length(spec$observ)
# dir_out = output directory, where results will be saved
#
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# FUNCTION

shape_function <- function(
    pred,
    spec,
    dir_out
){
  
  # prepare output dir
  if(!dir.exists(dir_out)) dir.create(dir_out, recursive = TRUE)
  
  # join coors with observations
  spec_big <- cbind(spec$coor, observ = spec$observations)
  # load data spatially
  spec_spat <- terra::vect(
    spec_big,
    geom = c("X", "Y"),
    crs = terra::crs(pred)
  )
  
  # extract predictor values for given predictors
  vals <- terra::extract(
    pred,
    spec_spat,
    xy = TRUE,
    bind = TRUE
  ) %>%
    as.data.frame()
  
  # prepare object without coors
  vals_nocoor <- vals %>%
    dplyr::select(-x, -y)
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # compute shape metric for give predictors set and occurence data
  message("Shaping")
  
  shape <- flexsdm::extra_eval(
    training_data = vals_nocoor, # values without coors
    pr_ab = "observ", # col name of observations
    projection_data = pred, # predictors stack
    metric = "mahalanobis",
    univar_comb = FALSE, # dont work, unfortunatelly
    #n_cores = 1, # this is probably broken
    aggreg_factor = 1
  )
  
  # write shape raster
  terra::writeRaster(
    shape,
    filename = file.path(dir_out, "shape.tif"),
    wopt = list(gdal = c("COMPRESS=LZW", "TILED=YES", "BIGTIFF=YES")),
    overwrite = TRUE
  )
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # Plot output graphs

  message("Plotting")
  
  prediktoraky <- names(pred)
  pairs <- utils::combn(prediktoraky, 2, simplify = FALSE)
  
  for(i in seq_along(pairs)){
    
    name <- paste0(pairs[[i]][1], "__", pairs[[i]][2], ".png")
    
    # save plot into png file named after predictor pair
    grDevices::png(filename = file.path(dir_out, name))
    print(
      flexsdm::p_extra(
        training_data = vals, # values with coors
        x = "x",
        y = "y",
        pr_ab = "observ",
        color_p = "black",
        extra_suit_data = shape,
        projection_data = pred,
        predictors = pairs[[i]],
        geo_space = FALSE,
        prop_points = 0.05
      )
    )
    grDevices::dev.off()
  }
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #