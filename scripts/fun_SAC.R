# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# FUN ‒ SAC, bind biomod2 CV table with original data
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# This function takes list with spec information, computes SAC, estimates
# SAC effect range and prepare spatial CV blocks prapred for biomod2 modelling.

# Opitional SAC objects info is saved in RDS object, if specified.

# input list structure:
# $species       character, species name
# $observations  numeric/integer 1/0, representing presences/absences
# $coor          data.frame with columns X, Y, representing coordinates

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# function:

spatial_cv <- function(
    spec, # data list
    sac_info_rds = NULL, # output SAC info
    k = 8, # n-folds
    selection = "random", # see blockCV::cv_spatial
    iteration = 100, # see blockCV::cv_spatial
    crs_epsg = 3035, 
    plot_sa = FALSE, # plot blockCV::cv_spatial_autocor
    plot_hex = FALSE, # plot blockCV::cv_spatial
    progress = TRUE,
    background = NULL # plot background (raster with same CRS)
    ){
  
  # transform spec list to df
  df <- base::data.frame(
    row_id = base::seq_along(spec$observations),
    X = spec$coor$X,
    Y = spec$coor$Y,
    PA = base::as.integer(spec$observations)
  )
  
  # keep only unique geometries, presences should be kept
  df_u <- df |>
    dplyr::group_by(X, Y) |>
    dplyr::summarise(
      PA = base::max(PA),
      .groups = "drop"
    )
  
  # create sf spatial object
  sf_u <- sf::st_as_sf(
    df_u,
    coords = c("X", "Y"),
    crs = crs_epsg,
    remove = FALSE
  )
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # estimate SAC from observations
  sa_obj <- blockCV::cv_spatial_autocor(
    x = sf_u,
    column = "PA",
    plot = plot_sa,
    r = background,
    progress = progress
  )
  
  # extract SAC effect range
  range_sa <- base::as.numeric(sa_obj$range)
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # create spatial blocks defined by range_sa
  cv_obj <- blockCV::cv_spatial(
    x = sf_u,
    column = "PA",
    size = range_sa,
    k = k,
    selection = selection,
    iteration = iteration,
    biomod2 = TRUE,
    progress = progress,
    plot = plot_hex,
    r = background
  )
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # fold id for unique coords
  fold_id <- base::data.frame(
    X = df_u$X,
    Y = df_u$Y,
    fold_id = cv_obj$folds_ids
  )
  
  # map fold ids back to original row order
  df_folded <- dplyr::left_join(df, fold_id, by = c("X", "Y"))
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # build biomod2 CV table, keep structure of spec data
  cv_user_table <- base::sapply(
    X = base::seq_len(k),
    FUN = function(i) {
      df_folded$fold_id != i
    }
  )
  
  cv_user_table <- base::as.data.frame(cv_user_table)
  base::colnames(cv_user_table) <- base::paste0(
    "_allData_RUN",
    base::seq_len(k)
  )
  
  # bind only biomod2 table to spec
  spec$CV.user.table <- cv_user_table
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # create separate SAC info object
  sac_info_obj <- list(
    rangeSA = range_sa,
    fold_id = df_folded$fold_id,
    spatial_cv_info = list(
      n_original = nrow(df),
      n_unique_coords = nrow(df_u),
      k = k,
      selection = selection,
      iteration = iteration,
      rangeSA = range_sa
    ),
    sa_obj = sa_obj,
    blockcv_obj = cv_obj
  )
  
  # save SAC info to rds
  if (!base::is.null(sac_info_rds)) {
    dir_out <- base::dirname(sac_info_rds)
    if (!base::dir.exists(dir_out)) {
      base::dir.create(dir_out, recursive = TRUE)}
    base::saveRDS(sac_info_obj, sac_info_rds)
  }
  
  return(spec)
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #