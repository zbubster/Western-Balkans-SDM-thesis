# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# ESM
# projection-only for all forecast scenarios
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# load functions
fun_file <- here::here("scripts", "fun_ESM_functions.R")
source(fun_file)

# main config
grains <- c(1000, 500, 200)
species <- c("GD", "GT", "SB", "PK", "PO", "PP")

# id of already fitted models
modelling_id <- "recent_extrapol_weights_all_selected"

# id of whole projection run summary
run_id <- "forecast_all"

# base directory with all forecast predictor combinations
forecast_base_dir <- here::here(
  "data",
  "__PREDICTORS_STACKS__",
  "forecast"
)

# subdirectory structure inside every forecast combination
forecast_stack_subdir <- file.path(
  "selected_predictors_stacks",
  "extrapol"
)

collinearity_type <- "_all_selected"

# should individual algorithm-level projections be returned, if supported by function?
return_algorithms <- FALSE

# maximum number of parallel workers
max_workers <- 24L

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# detect available forecast projection combinations

projection_ids <- list.dirs(
  path = forecast_base_dir,
  full.names = FALSE,
  recursive = FALSE
)

projection_ids <- projection_ids[projection_ids != ""]

# keep only folders matching expected format:
# 2011-2040_GFDL-ESM4_ssp126
projection_ids <- projection_ids[
  grepl(
    pattern = "^[0-9]{4}-[0-9]{4}_.+_ssp[0-9]+$",
    x = projection_ids
  )
]

projection_ids <- sort(projection_ids)

if(length(projection_ids) == 0) {
  stop("No forecast projection directories found in: ", forecast_base_dir)
}

projection_ids

# already computed projections - do not run again
skip_projection_ids <- c(
  "2041-2070_MPI-ESM1-2-HR_ssp370",
  "2041-2070_MPI-ESM1-2-HR_ssp585",
  "2041-2070_MPI-ESM1-2-HR_ssp126",
  "2071-2100_MPI-ESM1-2-HR_ssp370",
  "2071-2100_MPI-ESM1-2-HR_ssp585",
  "2071-2100_MPI-ESM1-2-HR_ssp126"
)

projection_ids <- setdiff(
  projection_ids,
  skip_projection_ids
)

projection_ids <- sort(projection_ids)

projection_ids

# parse projection_id into time / model / ssp for easier run summary
projection_info <- data.frame(
  projection_id = projection_ids,
  projection_time = sub(
    pattern = "^([0-9]{4}-[0-9]{4})_.+_ssp[0-9]+$",
    replacement = "\\1",
    x = projection_ids
  ),
  climate_model = sub(
    pattern = "^[0-9]{4}-[0-9]{4}_(.+)_ssp[0-9]+$",
    replacement = "\\1",
    x = projection_ids
  ),
  ssp = sub(
    pattern = "^[0-9]{4}-[0-9]{4}_.+_(ssp[0-9]+)$",
    replacement = "\\1",
    x = projection_ids
  ),
  stringsAsFactors = FALSE
)

projection_info

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# prepare task table
tasks <- expand.grid(
  grain = grains,
  sp = species,
  projection_id = projection_ids,
  KEEP.OUT.ATTRS = FALSE,
  stringsAsFactors = FALSE
)

tasks <- dplyr::left_join(
  tasks,
  projection_info,
  by = "projection_id"
)

projection_time_order <- c(
  "2071-2100",
  "2041-2070",
  "2011-2040"
)

grain_order <- c(
  1000,
  500,
  200
)

tasks <- tasks[
  base::order(
    base::match(tasks$projection_time, projection_time_order),
    base::match(tasks$grain, grain_order),
    tasks$climate_model,
    tasks$ssp,
    tasks$sp,
    na.last = TRUE
  ),
]

row.names(tasks) <- NULL
tasks

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Prepare parallel things

# prevent nested threading inside workers
Sys.setenv(
  OMP_NUM_THREADS = "1",
  OPENBLAS_NUM_THREADS = "1",
  MKL_NUM_THREADS = "1",
  VECLIB_MAXIMUM_THREADS = "1",
  NUMEXPR_NUM_THREADS = "1"
)

# detect available cores
available_cores <- parallelly::availableCores()

n_cores <- min(
  as.integer(available_cores),
  as.integer(max_workers),
  nrow(tasks)
)

message("Available cores: ", available_cores)
message("Used workers: ", n_cores)

# create and register cluster
cl <- parallelly::makeClusterPSOCK(n_cores)
doParallel::registerDoParallel(cl)

# make foreach operator available without library()
`%dopar%` <- foreach::`%dopar%`

# always stop cluster at the end
on.exit({
  try(parallel::stopCluster(cl), silent = TRUE)
}, add = TRUE)

# source helper functions on workers once
parallel::clusterEvalQ(cl, {
  fun_file <- here::here("scripts", "fun_ESM_functions.R")
  source(fun_file)
  NULL
})

# export needed objects to workers
parallel::clusterExport(
  cl = cl,
  varlist = c(
    "tasks",
    "forecast_base_dir",
    "forecast_stack_subdir",
    "collinearity_type",
    "modelling_id",
    "return_algorithms"
  ),
  envir = environment()
)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# PARALLEL LOOP

Sys.time()

res <- foreach::foreach(
  task_id = seq_len(nrow(tasks)),
  .packages = c(
    "terra",
    "here",
    "dplyr",
    "gbm",
    "mgcv",
    "rpart",
    "earth",
    "randomForest",
    "ranger"
  ),
  .combine = "rbind",
  .errorhandling = "pass"
) %dopar% {
  
  grain <- tasks$grain[[task_id]]
  sp <- tasks$sp[[task_id]]
  projection_id <- tasks$projection_id[[task_id]]
  projection_time <- tasks$projection_time[[task_id]]
  climate_model <- tasks$climate_model[[task_id]]
  ssp <- tasks$ssp[[task_id]]
  
  message(
    "__",
    projection_id,
    "__",
    grain,
    "__",
    sp,
    "__"
  )
  
  # define paths
  mod_dir <- here::here(
    "models",
    "ESM",
    modelling_id,
    sp,
    as.character(grain)
  )
  
  path_to_model <- file.path(
    mod_dir,
    "esm_fit_bivariate.rds"
  )
  
  pred_base_dir <- file.path(
    forecast_base_dir,
    projection_id,
    forecast_stack_subdir
  )
  
  path_to_pred <- file.path(
    pred_base_dir,
    paste0(sp, collinearity_type),
    paste0("r_", grain, ".tif")
  )
  
  # define output directories
  proj_dir <- file.path(
    mod_dir,
    "projections",
    projection_id
  )
  
  if(!dir.exists(proj_dir)) {
    dir.create(proj_dir, recursive = TRUE, showWarnings = FALSE)
  }
  
  out <- tryCatch(
    
    {
      # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
      # check inputs
      
      if(!file.exists(path_to_model)) {
        stop("Model file does not exist: ", path_to_model)
      }
      
      if(!file.exists(path_to_pred)) {
        stop("Predictor stack does not exist: ", path_to_pred)
      }
      
      # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
      # load model and new predictors
      
      esm <- readRDS(path_to_model)
      pred <- terra::rast(path_to_pred)
      
      message("Model and predictors loaded.")
      
      # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
      # prepare predictors for projection
      
      # mask unwanted landcover class before projection
      # should normally not be relevant for forecast extrapol stacks,
      # but it is kept here as a safety check
      if("landcover" %in% names(pred)) {
        pred[["landcover"]] <- terra::ifel(
          pred[["landcover"]] == 80,
          NA,
          pred[["landcover"]]
        )
      }
      
      # check that all model predictors are present in new stack
      missing_predictors <- setdiff(
        esm$predictors,
        names(pred)
      )
      
      if(length(missing_predictors) > 0) {
        stop(
          "Missing predictors in new stack: ",
          paste(missing_predictors, collapse = ", ")
        )
      }
      
      # keep only predictors used by the model and force correct order
      pred <- pred[[esm$predictors]]
      
      message("Predictors checked and ordered.")
      
      # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
      # projection
      
      proj <- esm_project_bivariate(
        esm = esm,
        new_env = pred,
        return_algorithms = return_algorithms
      )
      
      terra::writeRaster(
        proj,
        filename = file.path(
          proj_dir,
          paste0("ESM_projection_", projection_id, ".tif")
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
      
      message("Raster projection saved.")
      
      # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
      
      # clean memory
      rm(esm, pred, proj)
      gc()
      
      # write OK into run summary df
      data.frame(
        grain = grain,
        species = sp,
        projection_id = projection_id,
        projection_time = projection_time,
        climate_model = climate_model,
        ssp = ssp,
        status = "ok",
        message = NA_character_,
        model_file = path_to_model,
        predictor_file = path_to_pred,
        output_dir = proj_dir,
        stringsAsFactors = FALSE
      )
    },
    
    error = function(e) {
      gc()
      
      # what happened??
      data.frame(
        grain = grain,
        species = sp,
        projection_id = projection_id,
        projection_time = projection_time,
        climate_model = climate_model,
        ssp = ssp,
        status = "error",
        message = conditionMessage(e),
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
print(res)

summary_dir <- here::here(
  "models",
  "ESM",
  modelling_id,
  "projections",
  run_id
)

if(!dir.exists(summary_dir)) {
  dir.create(summary_dir, recursive = TRUE, showWarnings = FALSE)
}

utils::write.csv(
  res,
  file = file.path(summary_dir, "run_summary_projection.csv"),
  row.names = FALSE
)

# explicit cleanup
try(parallel::stopCluster(cl), silent = TRUE)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #