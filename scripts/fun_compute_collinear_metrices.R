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
# NOTE: Predictors given with 'predictors' argument are alsu used as filter
# of the 'df'. Missing names are filterred out and not analyzed. This could
# be useful when exploring collinearity of stacks for different purpose:
# ig. leaving out Landcover when preparing for temporal extrapolation.
# 
# Function returns list of statistics and correlation matrices plots,
# which are saved within out_dir.

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

compute_collinearity_metrices <- function(
    l,
    nm,
    response = "observ",
    predictors = NULL,
    out_dir = NULL,
    max_cor = max_cor,
    max_vif = max_vif
    ){
  
  if(!dir.exists(out_dir)){dir.create(out_dir)}
  # prepare output list
  out <- list()
  
  # prepare predictors
  if (base::is.null(predictors)) {
    stop("Argument `predictors` must not be NULL.")
  }
  
  predictors <- base::as.character(predictors)
  predictors <- predictors[!base::is.na(predictors)]
  predictors <- base::unique(predictors)
  
  # drop response
  predictors_req <- base::setdiff(predictors, response)
  
  # drop unwanted predictors
  predictors_ok <- base::intersect(predictors_req, base::names(l))
  
  # predictors check
  predictors_missing <- base::setdiff(predictors_req, base::names(l))
  if (base::length(predictors_missing) > 0) {
    warning(
      "These predictors were not found in `l` and were ignored: ",
      paste(predictors_missing, collapse = ", ")
    )
  }
  if (base::length(predictors_ok) == 0) {
    stop("No valid predictors remain after filtering.")
  }
  
  # main collinear function (two paths)
  if(response %in% names(l)){
    out$main <- collinear::collinear(
      df = l,
      responses = response,
      predictors = predictors_ok,
      preference_order = predictors_ok,
      max_cor = max_cor,
      max_vif = max_vif,
      quiet = TRUE
    )
    # selected predictors
    out$selected_predictors <- out$main$observ$selection
    
  } else {
    
    # path without response variable
    out$main <- collinear::collinear(
      df = l,
      predictors = predictors_ok,
      preference_order = predictors_ok,
      max_cor = max_cor,
      max_vif = max_vif,
      quiet = TRUE
    )
    out$selected_predictors <- out$main$result$selection
  }
  
  # compute correlation matrix for all variables
  out$cor_mat <- collinear::cor_matrix(
    df = l,
    predictors = predictors_ok,
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