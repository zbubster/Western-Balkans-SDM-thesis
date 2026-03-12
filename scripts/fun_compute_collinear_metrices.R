# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# FUN ‒ collinearity metrices
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# This function computes collinearity metrice via "collinear" package.
# 
# As input it requires df representing values extracted from raster layers
# (and optionally response collumn); name of the SpatRaster, which is 
# necessary for plotting; name of the response collumn, if present;
# character vector of predictors (this also stands for preference_order
# in collinear function) and output directory.
# 
# Function returns list of statistics and correlation matrices plots,
# which are saved within out_dir.

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

compute_collinearity_metrices <- function(
    l,
    nm,
    response = "observ",
    predictors = NULL,
    out_dir = NULL
    ){
  
  if(!dir.exists(out_dir)){dir.create(out_dir)}
  # prepare output list
  out <- list()
  
  # main collinear function (two paths)
  if(response %in% names(l)){
    out$main <- collinear::collinear(
      df = l,
      responses = response,
      preference_order = predictors,
      max_cor = 0.7,
      max_vif = 7,
      quiet = T
    )
    # selected predictors
    sel <- out$main$observ$selection
    out$selected_predictors <- base::intersect(sel, predictors)
    
  } else {
    
    # path without response variable
    out$main <- collinear::collinear(
      df = l,
      preference_order = predictors,
      max_cor = 0.7,
      max_vif = 7,
      quiet = T
    )
    sel <- out$main$result$selection
    out$selected_predictors <- base::intersect(sel, predictors)
  }
  
  # compute correlation matrix for all variables
  out$cor_mat <- collinear::cor_matrix(
    df = l,
    predictors = predictors,
    quiet = T
  )
  # compute corrmat for selcted variables
  out$cor_mat_selected <- collinear::cor_matrix(
    df = l,
    predictors = out$selected_predictors,
    quiet = T
  )
  
  cm_a <- out$cor_mat
  cm_s <- out$cor_mat_selected
  
  # compute VIF for all variables
  out$vif_all <- collinear::vif(
    m = cm_a,
    quiet = T
  )
  # comnpute VIF for selected predictors
  out$vif_selected <- collinear::vif(
    m = cm_s,
    quiet = T
  )
  
  # graphs
  grDevices::png(
    filename = file.path(out_dir, paste0(nm, "_all.png")),
    width = 2200,
    height = 2200,
    res = 220
  )
  corrplot::corrplot(
    out$cor_mat,
    method = "ellipse",
    type = "upper",
    order = "alphabet",
    diag = TRUE,
    tl.col = "black",
    tl.cex = 0.8,
    title = "All predictors"
  )
  grDevices::dev.off()
  
  grDevices::png(
    filename = file.path(out_dir, paste0(nm, "_selected.png")),
    width = 2200,
    height = 2200,
    res = 220
  )
  corrplot::corrplot(
    out$cor_mat_selected,
    method = "ellipse",
    type = "upper",
    order = "alphabet",
    diag = TRUE,
    tl.col = "black",
    tl.cex = 0.8,
    title = "Selected predictors"
  )
  grDevices::dev.off()
  return(out)
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #