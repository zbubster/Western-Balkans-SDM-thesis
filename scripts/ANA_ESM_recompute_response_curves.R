# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# ESM
# Recompute predictor-specific response curves from saved ESM fits
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# This script does NOT refit models and does NOT recreate raster projections.
# It recursively finds saved esm_fit_bivariate.rds files, recalculates response
# curves with the current functions in fun_ESM_functions.R, overwrites
# response_curves.rds and recreates response-curve figures.

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# LOAD FUNCTIONS
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

fun_file <- here::here("scripts", "fun_ESM_functions.R")

if (!base::file.exists(fun_file)) {
  base::stop("Function file does not exist: ", fun_file)
}

base::source(fun_file)

required_functions <- base::c(
  "esm_response_curves_bivariate",
  "plot_esm_response_numeric",
  "plot_esm_response_numeric_with_algorithms",
  "plot_esm_response_numeric_with_small",
  "plot_esm_response_factor"
)

missing_functions <- required_functions[
  !base::vapply(required_functions, base::exists, logical(1), mode = "function")
]

if (base::length(missing_functions) > 0L) {
  base::stop(
    "These required functions were not loaded from fun_ESM_functions.R: ",
    base::paste(missing_functions, collapse = ", ")
  )
}

# Packages required while predicting saved model objects and drawing figures.
required_packages <- base::c(
  "ggplot2",
  "gbm",
  "mgcv",
  "rpart",
  "earth",
  "ranger"
)

missing_packages <- required_packages[
  !base::vapply(required_packages, base::requireNamespace, logical(1), quietly = TRUE)
]

if (base::length(missing_packages) > 0L) {
  base::stop(
    "These required packages are not installed: ",
    base::paste(missing_packages, collapse = ", ")
  )
}

# Prevent nested threading inside model-prediction workers.
base::Sys.setenv(
  OMP_NUM_THREADS = "1",
  OPENBLAS_NUM_THREADS = "1",
  MKL_NUM_THREADS = "1",
  VECLIB_MAXIMUM_THREADS = "1",
  NUMEXPR_NUM_THREADS = "1"
)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# CONFIGURATION
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Root containing directories with saved ESM fits:
# models/ESM/<modelling_id>/<species>/<grain>/esm_fit_bivariate.rds
model_root <- here::here("models", "ESM")

# NULL means all available values are processed.
# Examples:
# modelling_ids <- c(
#   "recent_extrapol_weights_all_selected",
#   "recent_noextrapol_weights_all_selected",
#   "recent_noextrapol_weights_common"
# )
modelling_ids <- NULL
species <- NULL
grains <- NULL

# Response-curve settings.
n_points <- 100L
probs <- base::c(0.01, 0.99)
include_small_models <- TRUE
include_algorithm_curves <- TRUE

# Output settings.
overwrite_response_rds <- TRUE
clean_existing_png <- TRUE
save_algorithm_plots <- TRUE
png_width <- 400L
png_height <- 300L

# Parallel processing is optional. Sequential processing is safer for memory.
use_parallel <- TRUE
n_workers <- 6L

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# FIND SAVED MODEL FITS
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

if (!base::dir.exists(model_root)) {
  base::stop("Model root does not exist: ", model_root)
}

model_files <- base::list.files(
  path = model_root,
  pattern = "^esm_fit_bivariate\\.rds$",
  recursive = TRUE,
  full.names = TRUE
)

if (base::length(model_files) == 0L) {
  base::stop("No esm_fit_bivariate.rds files were found under: ", model_root)
}

get_model_metadata <- function(model_file) {
  model_dir <- base::dirname(model_file)
  
  base::data.frame(
    model_file = model_file,
    model_dir = model_dir,
    modelling_id = base::basename(base::dirname(base::dirname(model_dir))),
    species = base::basename(base::dirname(model_dir)),
    grain = base::suppressWarnings(base::as.numeric(base::basename(model_dir))),
    stringsAsFactors = FALSE
  )
}

model_table <- base::do.call(
  base::rbind,
  base::lapply(model_files, get_model_metadata)
)

if (!base::is.null(modelling_ids)) {
  model_table <- model_table[
    model_table$modelling_id %in% modelling_ids,
    ,
    drop = FALSE
  ]
}

if (!base::is.null(species)) {
  model_table <- model_table[
    model_table$species %in% species,
    ,
    drop = FALSE
  ]
}

if (!base::is.null(grains)) {
  model_table <- model_table[
    model_table$grain %in% grains,
    ,
    drop = FALSE
  ]
}

if (base::nrow(model_table) == 0L) {
  base::stop("No saved model fits remain after applying the configured filters.")
}

model_table <- model_table[
  base::order(
    model_table$modelling_id,
    model_table$species,
    -model_table$grain
  ),
  ,
  drop = FALSE
]

base::rownames(model_table) <- NULL

base::message("Saved ESM fits selected: ", base::nrow(model_table))
base::print(model_table[, base::c("modelling_id", "species", "grain")])

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# HELPERS
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

save_plot_png <- function(plot_object, filename, width, height) {
  grDevices::png(
    filename = filename,
    width = width,
    height = height
  )
  
  base::tryCatch(
    base::print(plot_object),
    finally = grDevices::dev.off()
  )
  
  base::invisible(filename)
}

process_one_esm <- function(
    model_file,
    n_points,
    probs,
    include_small_models,
    include_algorithm_curves,
    overwrite_response_rds,
    clean_existing_png,
    save_algorithm_plots,
    png_width,
    png_height
) {
  start_time <- base::Sys.time()
  meta <- get_model_metadata(model_file)
  
  base::message(
    "__", meta$modelling_id,
    "__", meta$species,
    "__", meta$grain,
    "__"
  )
  
  base::tryCatch(
    {
      model_dir <- meta$model_dir
      response_rds <- base::file.path(model_dir, "response_curves.rds")
      response_dir <- base::file.path(model_dir, "resp_curv")
      
      if (base::file.exists(response_rds) && !overwrite_response_rds) {
        return(base::data.frame(
          modelling_id = meta$modelling_id,
          species = meta$species,
          grain = meta$grain,
          model_file = model_file,
          status = "skipped",
          n_predictors = NA_integer_,
          n_response_rows = NA_integer_,
          elapsed_seconds = 0,
          message = "response_curves.rds already exists",
          stringsAsFactors = FALSE
        ))
      }
      
      esm <- base::readRDS(model_file)
      
      if (base::is.null(esm$predictors) || base::length(esm$predictors) == 0L) {
        base::stop("The saved ESM object has no predictors.")
      }
      
      if (base::is.null(esm$data) || base::nrow(esm$data) == 0L) {
        base::stop("The saved ESM object has no reference data in esm$data.")
      }
      
      rc <- esm_response_curves_bivariate(
        esm = esm,
        vars = esm$predictors,
        ref_data = esm$data,
        n_points = n_points,
        probs = probs,
        include_small_models = include_small_models,
        include_algorithm_curves = include_algorithm_curves
      )
      
      base::saveRDS(
        object = rc,
        file = response_rds
      )
      
      if (!base::dir.exists(response_dir)) {
        base::dir.create(
          path = response_dir,
          recursive = TRUE,
          showWarnings = FALSE
        )
      }
      
      if (clean_existing_png) {
        old_png <- base::list.files(
          path = response_dir,
          pattern = "\\.png$",
          full.names = TRUE
        )
        
        if (base::length(old_png) > 0L) {
          base::unlink(old_png)
        }
      }
      
      numeric_predictors <- base::unique(
        rc$variable[rc$var_type == "numeric"]
      )
      
      factor_predictors <- base::unique(
        rc$variable[rc$var_type == "factor"]
      )
      
      for (p in numeric_predictors) {
        save_plot_png(
          plot_object = plot_esm_response_numeric(rc = rc, var = p),
          filename = base::file.path(
            response_dir,
            base::paste0(p, "_simple.png")
          ),
          width = png_width,
          height = png_height
        )
        
        if (save_algorithm_plots && include_algorithm_curves) {
          save_plot_png(
            plot_object = plot_esm_response_numeric_with_algorithms(
              rc = rc,
              var = p
            ),
            filename = base::file.path(
              response_dir,
              base::paste0(p, "_algorithms.png")
            ),
            width = png_width,
            height = png_height
          )
        }
        
        if (include_small_models) {
          save_plot_png(
            plot_object = plot_esm_response_numeric_with_small(
              rc = rc,
              var = p
            ),
            filename = base::file.path(
              response_dir,
              base::paste0(p, "_complex.png")
            ),
            width = png_width,
            height = png_height
          )
        }
      }
      
      for (p in factor_predictors) {
        save_plot_png(
          plot_object = plot_esm_response_factor(rc = rc, var = p),
          filename = base::file.path(
            response_dir,
            base::paste0(p, "_barplot.png")
          ),
          width = png_width,
          height = png_height
        )
      }
      
      elapsed_seconds <- base::as.numeric(
        base::difftime(
          base::Sys.time(),
          start_time,
          units = "secs"
        )
      )
      
      out <- base::data.frame(
        modelling_id = meta$modelling_id,
        species = meta$species,
        grain = meta$grain,
        model_file = model_file,
        status = "ok",
        n_predictors = base::length(base::unique(rc$variable)),
        n_response_rows = base::nrow(rc),
        elapsed_seconds = elapsed_seconds,
        message = NA_character_,
        stringsAsFactors = FALSE
      )
      
      base::rm(esm, rc)
      base::gc()
      
      out
    },
    error = function(e) {
      elapsed_seconds <- base::as.numeric(
        base::difftime(
          base::Sys.time(),
          start_time,
          units = "secs"
        )
      )
      
      base::gc()
      
      base::data.frame(
        modelling_id = meta$modelling_id,
        species = meta$species,
        grain = meta$grain,
        model_file = model_file,
        status = "error",
        n_predictors = NA_integer_,
        n_response_rows = NA_integer_,
        elapsed_seconds = elapsed_seconds,
        message = base::conditionMessage(e),
        stringsAsFactors = FALSE
      )
    }
  )
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# RECOMPUTE RESPONSE CURVES
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

process_arguments <- base::list(
  n_points = n_points,
  probs = probs,
  include_small_models = include_small_models,
  include_algorithm_curves = include_algorithm_curves,
  overwrite_response_rds = overwrite_response_rds,
  clean_existing_png = clean_existing_png,
  save_algorithm_plots = save_algorithm_plots,
  png_width = png_width,
  png_height = png_height
)

run_one <- function(model_file) {
  base::do.call(
    what = process_one_esm,
    args = base::c(
      base::list(model_file = model_file),
      process_arguments
    )
  )
}

if (use_parallel) {
  if (!base::requireNamespace("parallelly", quietly = TRUE)) {
    base::stop("Package 'parallelly' is required when use_parallel = TRUE.")
  }
  
  available_workers <- parallelly::availableCores(omit = 1L)
  n_workers_actual <- base::max(
    1L,
    base::min(
      base::as.integer(n_workers),
      base::as.integer(available_workers),
      base::nrow(model_table)
    )
  )
  
  base::message("Parallel workers: ", n_workers_actual)
  
  cl <- parallelly::makeClusterPSOCK(n_workers_actual)
  
  base::tryCatch(
    {
      parallel::clusterCall(
        cl = cl,
        fun = function(path) {
          base::source(path)
          NULL
        },
        fun_file
      )
      
      parallel::clusterExport(
        cl = cl,
        varlist = base::c(
          "get_model_metadata",
          "save_plot_png",
          "process_one_esm",
          "process_arguments",
          "run_one"
        ),
        envir = base::environment()
      )
      
      result_list <- parallel::parLapplyLB(
        cl = cl,
        X = model_table$model_file,
        fun = run_one
      )
    },
    finally = parallel::stopCluster(cl)
  )
} else {
  result_list <- base::lapply(
    X = model_table$model_file,
    FUN = run_one
  )
}

run_summary <- base::do.call(base::rbind, result_list)
base::rownames(run_summary) <- NULL

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# SAVE RUN SUMMARY
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

summary_rds <- base::file.path(
  model_root,
  "response_curves_recompute_summary.rds"
)

summary_csv <- base::file.path(
  model_root,
  "response_curves_recompute_summary.csv"
)

base::saveRDS(
  object = run_summary,
  file = summary_rds
)

utils::write.csv(
  x = run_summary,
  file = summary_csv,
  row.names = FALSE,
  na = ""
)

base::print(run_summary)

base::message(
  "Finished. OK: ",
  base::sum(run_summary$status == "ok"),
  "; skipped: ",
  base::sum(run_summary$status == "skipped"),
  "; errors: ",
  base::sum(run_summary$status == "error")
)

base::message("Summary RDS: ", summary_rds)
base::message("Summary CSV: ", summary_csv)
