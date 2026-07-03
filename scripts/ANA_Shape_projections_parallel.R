# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Shape projection-only parallel implementation
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# FUNCTION
#
# Function computes Shape metric for projection stacks.
#
# Important:
# pred_train is used only for extracting calibration environmental values
# at species observation points.
#
# pred_projection is the raster stack into which the Shape metric is projected.
#
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

shape_function_projection <- function(
    pred_train,
    pred_projection,
    spec,
    dir_out,
    make_plots = FALSE,
    plot_prop_points = 0.05
) {
  
  # prepare output dir
  if(!base::dir.exists(dir_out)) {
    base::dir.create(dir_out, recursive = TRUE, showWarnings = FALSE)
  }
  
  # check predictor names
  missing_projection_layers <- base::setdiff(
    base::names(pred_train),
    base::names(pred_projection)
  )
  
  if(base::length(missing_projection_layers) > 0) {
    base::stop(
      "Projection stack is missing layers: ",
      base::paste(missing_projection_layers, collapse = ", ")
    )
  }
  
  extra_projection_layers <- base::setdiff(
    base::names(pred_projection),
    base::names(pred_train)
  )
  
  if(base::length(extra_projection_layers) > 0) {
    base::message(
      "Projection stack has extra layers that will be ignored: ",
      base::paste(extra_projection_layers, collapse = ", ")
    )
  }
  
  # keep only predictors used in calibration stack and force correct order
  pred_projection <- pred_projection[[base::names(pred_train)]]
  
  # join coors with observations
  spec_big <- base::cbind(
    spec$coor,
    observ = spec$observations
  )
  
  # load data spatially
  spec_spat <- terra::vect(
    spec_big,
    geom = c("X", "Y"),
    crs = terra::crs(pred_train)
  )
  
  # extract calibration predictor values at observation points
  vals <- terra::extract(
    pred_train,
    spec_spat,
    xy = TRUE,
    bind = TRUE
  )
  
  vals <- base::as.data.frame(vals)
  
  # prepare object without coors
  vals_nocoor <- vals[, !(base::names(vals) %in% c("x", "y")), drop = FALSE]
  
  # remove rows with missing predictor values
  complete_rows <- stats::complete.cases(vals_nocoor)
  vals <- vals[complete_rows, , drop = FALSE]
  vals_nocoor <- vals_nocoor[complete_rows, , drop = FALSE]
  
  if(base::nrow(vals_nocoor) == 0) {
    base::stop("No complete calibration rows after extracting predictor values.")
  }
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # compute shape metric for given predictors set and occurrence data
  
  base::message("Shaping")
  
  shape <- flexsdm::extra_eval(
    training_data = vals_nocoor,
    pr_ab = "observ",
    projection_data = pred_projection,
    metric = "mahalanobis",
    univar_comb = FALSE,
    aggreg_factor = 1
  )
  
  # write shape raster
  terra::writeRaster(
    shape,
    filename = base::file.path(dir_out, "shape.tif"),
    wopt = list(
      gdal = c(
        "COMPRESS=LZW",
        "TILED=YES",
        "BIGTIFF=YES"
      )
    ),
    overwrite = TRUE
  )
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # Plot output graphs
  
  if(base::isTRUE(make_plots)) {
    
    base::message("Plotting")
    
    prediktoraky <- base::names(pred_train)
    pairs <- utils::combn(prediktoraky, 2, simplify = FALSE)
    
    for(i in base::seq_along(pairs)) {
      
      name <- base::paste0(
        pairs[[i]][1],
        "__",
        pairs[[i]][2],
        ".png"
      )
      
      grDevices::png(
        filename = base::file.path(dir_out, name)
      )
      
      base::print(
        flexsdm::p_extra(
          training_data = vals,
          x = "x",
          y = "y",
          pr_ab = "observ",
          color_p = "black",
          extra_suit_data = shape,
          projection_data = pred_projection,
          predictors = pairs[[i]],
          geo_space = FALSE,
          prop_points = plot_prop_points
        )
      )
      
      grDevices::dev.off()
    }
  }
  
  base::invisible(
    base::file.path(dir_out, "shape.tif")
  )
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# main config
grains <- c(1000, 500, 200)
species <- c("GD", "GT", "SB", "PK", "PO", "PP")

shape_id <- "hindcast_forecast_extrapol_weights_common"

occ_base_dir <- here::here(
  "data",
  "__ANALYSIS__",
  "OCC",
  "weights"
)

# recent stack used as calibration / reference environment
train_pred_base_dir <- here::here(
  "data",
  "__PREDICTORS_STACKS__",
  "recent",
  "selected_predictors_stacks",
  "extrapol"
)

# projection stacks
hindcast_pred_base_dir <- here::here(
  "data",
  "__PREDICTORS_STACKS__",
  "hindcast"
)

forecast_pred_base_dir <- here::here(
  "data",
  "__PREDICTORS_STACKS__",
  "forecast"
)

collinearity_type <- "_all_selected"

# hindcast time slices
hindcast_times <- c(
  "-060",
  "-190"
)

# forecast combinations
forecast_times <- c(
  #"2011-2040",
  "2041-2070",
  "2071-2100"
)

climate_models <- c(
  "GFDL-ESM4",
  "IPSL-CM6A-LR",
  "MPI-ESM1-2-HR",
  "MRI-ESM2-0",
  "UKESM1-0-LL"
)

ssps <- c(
  "ssp126",
  "ssp370",
  "ssp585"
)

# plotting all bivariate pngs for all projections is very heavy
make_plots <- TRUE
plot_prop_points <- 0.05

# skip already computed shape.tif files
skip_existing <- TRUE

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# helper functions

make_projection_id <- function(
    projection_type,
    projection_time,
    climate_model,
    ssp
) {
  
  if(projection_type == "hindcast") {
    
    out <- base::paste0(
      "trace21k_",
      projection_time
    )
  }
  
  if(projection_type == "forecast") {
    
    out <- base::paste0(
      projection_time,
      "_",
      climate_model,
      "_",
      ssp
    )
  }
  
  out
}

make_projection_stack_path <- function(
    projection_type,
    projection_time,
    climate_model,
    ssp,
    sp,
    grain
) {
  
  sp_dir <- base::paste0(sp, collinearity_type)
  raster_name <- base::paste0("r_", grain, ".tif")
  
  if(projection_type == "hindcast") {
    
    path <- base::file.path(
      hindcast_pred_base_dir,
      base::paste0("trace21k_", projection_time),
      "selected_predictors_stacks",
      "extrapol",
      sp_dir,
      raster_name
    )
  }
  
  if(projection_type == "forecast") {
    
    path <- base::file.path(
      forecast_pred_base_dir,
      base::paste0(
        projection_time,
        "_",
        climate_model,
        "_",
        ssp
      ),
      "selected_predictors_stacks",
      "extrapol",
      sp_dir,
      raster_name
    )
  }
  
  path
}

make_shape_dir <- function(
    sp,
    grain,
    projection_type,
    projection_id
) {
  
  base::file.path(
    here::here("models", "Shape", shape_id),
    sp,
    base::as.character(grain),
    "projections",
    projection_type,
    projection_id
  )
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# prepare projection table

hindcast_projection_tasks <- base::data.frame(
  projection_type = "hindcast",
  projection_time = hindcast_times,
  climate_model = NA_character_,
  ssp = NA_character_,
  stringsAsFactors = FALSE
)

forecast_projection_tasks <- base::expand.grid(
  projection_type = "forecast",
  projection_time = forecast_times,
  climate_model = climate_models,
  ssp = ssps,
  KEEP.OUT.ATTRS = FALSE,
  stringsAsFactors = FALSE
)

projection_tasks <- base::rbind(
  hindcast_projection_tasks,
  forecast_projection_tasks
)

projection_tasks$projection_id <- base::mapply(
  FUN = make_projection_id,
  projection_type = projection_tasks$projection_type,
  projection_time = projection_tasks$projection_time,
  climate_model = projection_tasks$climate_model,
  ssp = projection_tasks$ssp,
  USE.NAMES = FALSE
)

# prepare species x grain table

species_grain_tasks <- base::expand.grid(
  grain = grains,
  sp = species,
  KEEP.OUT.ATTRS = FALSE,
  stringsAsFactors = FALSE
)

# combine all tasks

tasks <- base::merge(
  species_grain_tasks,
  projection_tasks,
  by = NULL
)

tasks <- tasks[
  base::order(
    -tasks$grain,
    tasks$sp,
    tasks$projection_type,
    tasks$projection_time,
    tasks$climate_model,
    tasks$ssp,
    na.last = TRUE
  ),
]

base::print(tasks)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Prepare parallel things

# detect available cores
n_cores <- parallelly::availableCores()

# define user library first
user_lib <- base::Sys.getenv("R_LIBS_USER")

# prepare library paths for workers
main_libpaths <- base::unique(c(
  user_lib,
  base::.libPaths()
))

# apply the same library order in the main session
base::.libPaths(main_libpaths)

# prevent nested threading inside workers
base::Sys.setenv(
  OMP_NUM_THREADS = "1",
  OPENBLAS_NUM_THREADS = "1",
  MKL_NUM_THREADS = "1",
  VECLIB_MAXIMUM_THREADS = "1",
  NUMEXPR_NUM_THREADS = "1"
)

# create and register cluster with the correct library paths
cl <- parallelly::makeClusterPSOCK(
  workers = n_cores,
  rscript_libs = main_libpaths
)

doParallel::registerDoParallel(cl)

# make foreach operator available
`%dopar%` <- foreach::`%dopar%`

# always stop cluster at the end
base::on.exit({
  base::try(parallel::stopCluster(cl), silent = TRUE)
}, add = TRUE)

# force the same library paths on workers
parallel::clusterCall(
  cl = cl,
  fun = function(libpaths) {
    base::.libPaths(libpaths)
    NULL
  },
  libpaths = main_libpaths
)

# export needed objects to workers
parallel::clusterExport(
  cl = cl,
  varlist = c(
    "tasks",
    "occ_base_dir",
    "train_pred_base_dir",
    "hindcast_pred_base_dir",
    "forecast_pred_base_dir",
    "collinearity_type",
    "shape_id",
    "make_plots",
    "plot_prop_points",
    "skip_existing",
    "shape_function_projection",
    "make_projection_stack_path",
    "make_shape_dir"
  ),
  envir = base::environment()
)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# PARALLEL LOOP

res <- foreach::foreach(
  task_id = base::seq_len(base::nrow(tasks)),
  .packages = c(
    "terra",
    "here",
    "flexsdm",
    "ggplot2"
  ),
  .combine = "rbind",
  .errorhandling = "pass"
) %dopar% {
  
  grain <- tasks$grain[[task_id]]
  sp <- tasks$sp[[task_id]]
  projection_type <- tasks$projection_type[[task_id]]
  projection_time <- tasks$projection_time[[task_id]]
  climate_model <- tasks$climate_model[[task_id]]
  ssp <- tasks$ssp[[task_id]]
  projection_id <- tasks$projection_id[[task_id]]
  
  base::message("__", grain, "__", sp, "__", projection_id, "__")
  
  # define paths
  path_to_occ <- base::file.path(
    occ_base_dir,
    base::paste0(sp, "_", grain, "m.rds")
  )
  
  path_to_train_pred <- base::file.path(
    train_pred_base_dir,
    base::paste0(sp, collinearity_type),
    base::paste0("r_", grain, ".tif")
  )
  
  path_to_projection_pred <- make_projection_stack_path(
    projection_type = projection_type,
    projection_time = projection_time,
    climate_model = climate_model,
    ssp = ssp,
    sp = sp,
    grain = grain
  )
  
  # define output directory
  shape_dir <- make_shape_dir(
    sp = sp,
    grain = grain,
    projection_type = projection_type,
    projection_id = projection_id
  )
  
  path_to_shape_out <- base::file.path(
    shape_dir,
    "shape.tif"
  )
  
  out <- base::tryCatch(
    
    {
      # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
      # check inputs
      
      if(!base::file.exists(path_to_occ)) {
        base::stop("Occurrence file does not exist: ", path_to_occ)
      }
      
      if(!base::file.exists(path_to_train_pred)) {
        base::stop("Training predictor stack does not exist: ", path_to_train_pred)
      }
      
      if(!base::file.exists(path_to_projection_pred)) {
        base::stop("Projection predictor stack does not exist: ", path_to_projection_pred)
      }
      
      if(base::isTRUE(skip_existing) && base::file.exists(path_to_shape_out)) {
        
        base::message("Shape already exists. Skipping.")
        
        return(
          base::data.frame(
            grain = grain,
            species = sp,
            projection_type = projection_type,
            projection_time = projection_time,
            climate_model = climate_model,
            ssp = ssp,
            projection_id = projection_id,
            status = "skipped",
            message = "shape.tif already exists",
            training_predictor_file = path_to_train_pred,
            projection_predictor_file = path_to_projection_pred,
            output_dir = shape_dir,
            stringsAsFactors = FALSE
          )
        )
      }
      
      # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
      # load objects
      
      occ <- base::readRDS(path_to_occ)
      pred_train <- terra::rast(path_to_train_pred)
      pred_projection <- terra::rast(path_to_projection_pred)
      
      base::message("Objects loaded.")
      
      # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
      # prepare raster stacks
      
      # mask unwanted landcover class if present
      if("landcover" %in% base::names(pred_train)) {
        pred_train[["landcover"]] <- terra::ifel(
          pred_train[["landcover"]] == 80,
          NA,
          pred_train[["landcover"]]
        )
      }
      
      if("landcover" %in% base::names(pred_projection)) {
        pred_projection[["landcover"]] <- terra::ifel(
          pred_projection[["landcover"]] == 80,
          NA,
          pred_projection[["landcover"]]
        )
      }
      
      # check predictor names
      missing_projection_layers <- base::setdiff(
        base::names(pred_train),
        base::names(pred_projection)
      )
      
      if(base::length(missing_projection_layers) > 0) {
        base::stop(
          "Projection stack is missing layers: ",
          base::paste(missing_projection_layers, collapse = ", ")
        )
      }
      
      extra_projection_layers <- base::setdiff(
        base::names(pred_projection),
        base::names(pred_train)
      )
      
      if(base::length(extra_projection_layers) > 0) {
        base::message(
          "Projection stack has extra layers that will be ignored: ",
          base::paste(extra_projection_layers, collapse = ", ")
        )
      }
      
      # force identical layer order
      pred_projection <- pred_projection[[base::names(pred_train)]]
      
      base::message("Raster stacks checked and ordered.")
      
      # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
      # calculate Shape
      
      shape_function_projection(
        pred_train = pred_train,
        pred_projection = pred_projection,
        spec = occ,
        dir_out = shape_dir,
        make_plots = make_plots,
        plot_prop_points = plot_prop_points
      )
      
      base::message("Shape saved.")
      
      # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
      
      # clean memory
      base::rm(occ, pred_train, pred_projection)
      base::gc()
      
      # write OK into run summary df
      base::data.frame(
        grain = grain,
        species = sp,
        projection_type = projection_type,
        projection_time = projection_time,
        climate_model = climate_model,
        ssp = ssp,
        projection_id = projection_id,
        status = "ok",
        message = NA_character_,
        training_predictor_file = path_to_train_pred,
        projection_predictor_file = path_to_projection_pred,
        output_dir = shape_dir,
        stringsAsFactors = FALSE
      )
    },
    
    error = function(e) {
      base::gc()
      
      # what happened??
      base::data.frame(
        grain = grain,
        species = sp,
        projection_type = projection_type,
        projection_time = projection_time,
        climate_model = climate_model,
        ssp = ssp,
        projection_id = projection_id,
        status = "error",
        message = base::conditionMessage(e),
        training_predictor_file = path_to_train_pred,
        projection_predictor_file = path_to_projection_pred,
        output_dir = shape_dir,
        stringsAsFactors = FALSE
      )
    }
  )
  
  out
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# save run summary

base::print(res)

summary_dir <- here::here(
  "models",
  "Shape",
  shape_id,
  "run_summaries"
)

if(!base::dir.exists(summary_dir)) {
  base::dir.create(summary_dir, recursive = TRUE, showWarnings = FALSE)
}

base::saveRDS(
  res,
  file = base::file.path(summary_dir, "run_summary_shape_projection.rds")
)

# explicit cleanup
parallel::stopCluster(cl)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #