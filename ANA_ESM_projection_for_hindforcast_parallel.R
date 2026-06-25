# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# ESM
# projection-only
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# load functions
fun_file <- here::here("scripts", "fun_ESM_functions.R")
source(fun_file)

# main config
grains <- c(1000, 500, 200)
species <- c("GD", "GT", "SB", "PK", "PO", "PP")

# id of already fitted models
modelling_id <- "recent_extrapol_weights_all_selected"

# id of new projection
#projection_id <- "060_all_selected"
#projection_id <- "190_all_selected"
#projection_id <- "2041-2070_MPI-ESM1-2-HR_ssp370"
#projection_id <- "2041-2070_MPI-ESM1-2-HR_ssp585"
#projection_id <- "2041-2070_MPI-ESM1-2-HR_ssp126"
#projection_id <- "2071-2100_MPI-ESM1-2-HR_ssp370"
projection_id <- "2071-2100_MPI-ESM1-2-HR_ssp585"

# BACHAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
# pred_base_dir <- here::here(
#   "data",
#   "__PREDICTORS_STACKS__",
#   "hindcast",
#   "trace21k_-060", #################################################
#   "selected_predictors_stacks",
#   "extrapol"
# )

pred_base_dir <- here::here(
  "data",
  "__PREDICTORS_STACKS__",
  "forecast",
  "2071-2100_MPI-ESM1-2-HR_ssp585",
  "selected_predictors_stacks",
  "extrapol"
)

collinearity_type <- "_all_selected"

# should individual algorithm-level projections be returned, if supported by function?
return_algorithms <- FALSE

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# prepare task table
tasks <- base::expand.grid(
  grain = grains,
  sp = species,
  KEEP.OUT.ATTRS = FALSE,
  stringsAsFactors = FALSE
)

tasks <- tasks[base::order(tasks$grain, decreasing = TRUE), ]
tasks

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Prepare parallel things

# detect available cores
n_cores <- parallelly::availableCores()

# prevent nested threading inside workers
Sys.setenv(
  OMP_NUM_THREADS = "1",
  OPENBLAS_NUM_THREADS = "1",
  MKL_NUM_THREADS = "1",
  VECLIB_MAXIMUM_THREADS = "1",
  NUMEXPR_NUM_THREADS = "1"
)

# create and register cluster
cl <- parallelly::makeClusterPSOCK(n_cores)
doParallel::registerDoParallel(cl)

# make foreach operator available without library()
`%dopar%` <- foreach::`%dopar%`

# always stop cluster at the end
on.exit({
  base::try(parallel::stopCluster(cl), silent = TRUE)
}, add = TRUE)

# source helper functions on workers once
parallel::clusterEvalQ(cl, {
  fun_file <- here::here("scripts", "fun_ESM_functions.R")
  base::source(fun_file)
  NULL
})

# export needed objects to workers
parallel::clusterExport(
  cl = cl,
  varlist = c(
    "tasks",
    "pred_base_dir",
    "collinearity_type",
    "modelling_id",
    "projection_id",
    "return_algorithms"
  ),
  envir = base::environment()
)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# PARALLEL LOOP

Sys.time()
res <- foreach::foreach(
  task_id = base::seq_len(base::nrow(tasks)),
  .packages = c(
    "terra",
    "here",
    "dplyr",
    "gbm",
    "mgcv",
    "rpart",
    "earth",
    "randomForest"
  ),
  .combine = "rbind",
  .errorhandling = "pass"
) %dopar% {
  
  grain <- tasks$grain[[task_id]]
  sp <- tasks$sp[[task_id]]
  
  base::message("__", grain, "__", sp, "__")
  
  # define paths
  mod_dir <- here::here(
    "models",
    "ESM",
    modelling_id,
    sp,
    base::as.character(grain)
  )
  
  path_to_model <- base::file.path(
    mod_dir,
    "esm_fit_bivariate.rds"
  )
  
  path_to_pred <- base::file.path(
    pred_base_dir,
    base::paste0(sp, collinearity_type),
    base::paste0("r_", grain, ".tif")
  )
  
  # define output directories
  proj_dir <- base::file.path(
    mod_dir,
    "projections",
    projection_id
  )
  
  if(!base::dir.exists(proj_dir)) {
    base::dir.create(proj_dir, recursive = TRUE, showWarnings = FALSE)
  }
  
  out <- base::tryCatch(
    
    {
      # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
      # check inputs
      
      if(!base::file.exists(path_to_model)) {
        base::stop("Model file does not exist: ", path_to_model)
      }
      
      if(!base::file.exists(path_to_pred)) {
        base::stop("Predictor stack does not exist: ", path_to_pred)
      }
      
      # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
      # load model and new predictors
      
      esm <- base::readRDS(path_to_model)
      pred <- terra::rast(path_to_pred)
      
      base::message("Model and predictors loaded.")
      
      # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
      # prepare predictors for projection
      
      # mask unwanted landcover class before projection
      # at grain 100, LC category 80 produced errors in previous runs
      if("landcover" %in% base::names(pred)) {
        pred[["landcover"]] <- terra::ifel(
          pred[["landcover"]] == 80,
          NA,
          pred[["landcover"]]
        )
      }
      
      # check that all model predictors are present in new stack
      missing_predictors <- base::setdiff(
        esm$predictors,
        base::names(pred)
      )
      
      if(base::length(missing_predictors) > 0) {
        base::stop(
          "Missing predictors in new stack: ",
          base::paste(missing_predictors, collapse = ", ")
        )
      }
      
      # keep only predictors used by the model and force correct order
      pred <- pred[[esm$predictors]]
      
      base::message("Predictors checked and ordered.")
      
      # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
      # projection
      
      proj <- esm_project_bivariate(
        esm = esm,
        new_env = pred,
        return_algorithms = return_algorithms
      )
      
      terra::writeRaster(
        proj,
        filename = base::file.path(
          proj_dir,
          base::paste0("ESM_projection_", projection_id, ".tif")
        ),
        overwrite = TRUE,
        wopt = list(
          gdal = c(
            "COMPRESS=LZW",
            "TILED=YES",
            "BIGTIFF=YES"
          )
        )
      )
      
      base::message("Raster projection saved.")
      
      # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
      
      # clean memory
      base::rm(esm, pred, proj)
      base::gc()
      
      # write OK into run summary df
      base::data.frame(
        grain = grain,
        species = sp,
        projection_id = projection_id,
        status = "ok",
        message = NA_character_,
        model_file = path_to_model,
        predictor_file = path_to_pred,
        output_dir = proj_dir,
        stringsAsFactors = FALSE
      )
    },
    
    error = function(e) {
      base::gc()
      
      # what happened??
      base::data.frame(
        grain = grain,
        species = sp,
        projection_id = projection_id,
        status = "error",
        message = base::conditionMessage(e),
        model_file = path_to_model,
        predictor_file = path_to_pred,
        output_dir = proj_dir,
        stringsAsFactors = FALSE
      )
    }
  )
  
  out
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# save run summary
Sys.time()
base::print(res)

summary_dir <- here::here(
  "models",
  "ESM",
  modelling_id,
  "projections",
  projection_id
)

if(!base::dir.exists(summary_dir)) {
  base::dir.create(summary_dir, recursive = TRUE, showWarnings = FALSE)
}

saveRDS(
  res,
  file = base::file.path(summary_dir, "run_summary_projection.rds")
)

# explicit cleanup
parallel::stopCluster(cl)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #