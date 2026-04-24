

shape_function <- function(
    pred_path,
    spec_path,
    dir_out
){
  
  if(!dir.exists(dir_out)) dir.create(dir_out, recursive = TRUE)
  pred <- terra::rast(pred_path)
  spec <- readRDS(spec_path)
  
  spec <- cbind(spec$coor, observ = spec$observations)
  spec_spat <- terra::vect(
    spec,
    geom = c("X", "Y"),
    crs = terra::crs(pred)
  )
  
  vals <- terra::extract(
    pred,
    spec_spat,
    xy = TRUE,
    bind = TRUE
  ) %>%
    as.data.frame()
  
  vals_nocoor <- vals %>%
    dplyr::select(-x, -y)
  
  message("Shaping")
  
  shape <- flexsdm::extra_eval(
    training_data = vals_nocoor,
    pr_ab = "observ",
    projection_data = pred,
    metric = "mahalanobis",
    univar_comb = FALSE,
    #n_cores = 1,
    aggreg_factor = 1
  )
  
  terra::writeRaster(
    shape,
    filename = file.path(dir_out, "shape.tif"),
    wopt = list(gdal = c("COMPRESS=LZW", "TILED=YES", "BIGTIFF=YES")),
    overwrite = TRUE
  )
  
  message("Plotting")
  
  prediktoraky <- names(pred)
  
  pairs <- utils::combn(prediktoraky_con, 2, simplify = FALSE)
  
  for(i in seq_along(pairs)){
    
    name <- paste0(pairs[[i]][1], "__", pairs[[i]][2], ".png")
    
    grDevices::png(filename = file.path(dir_out, name))
    print(
      flexsdm::p_extra(
        training_data = vals,
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

shape_function(
  pred_path = "data/__PREDICTORS_STACKS__/recent/selected_predictors_stacks/noextrapol/GD_common/r_1000.tif",
  spec_path = "data/__ANALYSIS__/OCC/GD_1000m.rds",
  dir_out = "models/Shape/test/GD_1000"
)

