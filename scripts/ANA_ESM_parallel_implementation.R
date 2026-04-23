# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# ESM
# parallel edition
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# load functions
fun_file <- here::here("scripts", "fun_ESM_functions.R")
source(fun_file)

# main config
grains <- c(100)
species <- c("GD", "GT", "SB", "PK", "PO", "PP")
modelling_id <- "recent_noextrapol_weights_common"
occ_base_dir <- here::here("data", "__ANALYSIS__", "OCC", "weights")
pred_base_dir <- here::here("data", "__PREDICTORS_STACKS__", "recent", "selected_predictors_stacks", "noextrapol")
collinearity_type <- "_common"

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# prepare task table
tasks <- expand.grid(
  grain = grains,
  sp = species,
  KEEP.OUT.ATTRS = FALSE,
  stringsAsFactors = FALSE
)

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
    "occ_base_dir",
    "pred_base_dir",
    "collinearity_type",
    "modelling_id"
  ),
  envir = environment()
)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# PARALLEL LOOP

res <- foreach::foreach(
  task_id = seq_len(nrow(tasks)),
  .packages = c("terra", "dplyr", "here"),
  .combine = "rbind",
  .errorhandling = "pass"
) %dopar% {
  
  grain <- tasks$grain[[task_id]]
  sp <- tasks$sp[[task_id]]
  
  message("__", grain, "__", sp, "__")
  
  # define paths
  path_to_occ <- file.path(
    occ_base_dir,
    paste0(sp, "_", grain, "m.rds")
  )
  
  path_to_pred <- file.path(
    pred_base_dir,
    paste0(sp, collinearity_type),
    paste0("r_", grain, ".tif")
  )
  
  # load objects
  occ <- readRDS(path_to_occ)
  pred <- terra::rast(path_to_pred)
  
  # define output directories
  mod_dir <- here::here("models", "ESM", modelling_id, sp, as.character(grain))
  if(!dir.exists(mod_dir)) {
    dir.create(mod_dir, recursive = TRUE, showWarnings = FALSE)
  }
  
  resp_curv_dir <- file.path(mod_dir, "resp_curv")
  if(!dir.exists(resp_curv_dir)) {
    dir.create(resp_curv_dir, recursive = TRUE, showWarnings = FALSE)
  }
  
  # seed
  seed <- 722085415
  
  out <- tryCatch(
    
    {
      # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
      # prepare data for modelling
      
      cats <- intersect(names(pred), c("landcover", "bedrock"))
      
      # mask unwanted landcover class before modelling and projection
      # at grain 100, LC cathegory produces errors
      if("landcover" %in% names(pred)) {
        pred[["landcover"]] <- terra::ifel(
          pred[["landcover"]] == 80,
          NA,
          pred[["landcover"]]
        )
      }
      
      prep <- prepare_occ_for_modeling(
        occ = occ,
        pred = pred,
        factor_cols = cats
      )

      saveRDS(prep, file = file.path(mod_dir, "prepared_data.rds"))
      message("Prepared data saved.")

      # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
      # fit models
      
      esm <- esm_fit_bivariate(
        prep = prep,
        algorithms = c("glm", "gbm", "gam", "cta", "mars", "rf"),
        threshold = 0, # threshold for SommersD
        weight_transform = "identity",
        seed = seed
      )

      saveRDS(esm, file = file.path(mod_dir, "esm_fit_bivariate.rds"))
      message("ESM saved.")

      # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
      # projection
      
      proj <- esm_project_bivariate(
        esm = esm,
        new_env = pred
      )
      
      terra::writeRaster(
        proj,
        filename = file.path(mod_dir, "ESM_projection.tif"),
        overwrite = TRUE,
        wopt = list(gdal = c("COMPRESS=LZW", "TILED=YES", "BIGTIFF=YES"))
      )
      message("Raster projection saved.")
      
      # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
      # response curves
      
      rc <- esm_response_curves_bivariate(
        esm = esm,
        vars = esm$predictors,
        ref_data = esm$data,
        n_points = 100
      )
      
      saveRDS(rc, file = file.path(mod_dir, "response_curves.rds"))
      message("Response curves RDS file saved.")
      
      # plot response curves
      prediktoraky <- unique(rc$variable)
      prediktoraky_con <- prediktoraky[!(prediktoraky %in% c("landcover", "bedrock"))]
      prediktoraky_fac <- prediktoraky[prediktoraky %in% c("landcover", "bedrock")]

      # numeric predictors
      for(k in seq_along(prediktoraky_con)){
        p <- prediktoraky_con[[k]]
        
        grDevices::png(filename = base::file.path(resp_curv_dir, base::paste0(p, "_simple.png")), width = 500, height = 400)
        print(plot_esm_response_numeric(rc, p))
        grDevices::dev.off()
        
        grDevices::png(filename = base::file.path(resp_curv_dir, base::paste0(p, "_complex.png")), width = 500, height = 400)
        print(plot_esm_response_numeric_with_small(rc, p))
        grDevices::dev.off()
      }
      
      # factor predictors
      for(l in seq_along(prediktoraky_fac)){
        p <- prediktoraky_fac[[l]]
        
        grDevices::png(file = base::file.path(resp_curv_dir, base::paste0(p, "_barplot.png")), width = 500, height = 400)
        print(plot_esm_response_factor(rc, p))
        grDevices::dev.off()
      }
      
      # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
      
      # clean memory
      rm(occ, pred, prep, esm, proj, rc)
      gc()
      
      # write OK into run summary df
      data.frame(
        grain = grain,
        species = sp,
        status = "ok",
        message = NA_character_,
        stringsAsFactors = FALSE
      )
    },
    
    error = function(e) {
      gc()
      
      # what happened??
      data.frame(
        grain = grain,
        species = sp,
        status = "error",
        message = conditionMessage(e),
        stringsAsFactors = FALSE
      )
    }
  )
  
  out
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# save run summary

print(res)

summary_dir <- here::here("models", "ESM", modelling_id)
if(!dir.exists(summary_dir)) dir.create(summary_dir, recursive = T)
saveRDS(res, file = file.path(summary_dir, "run_summary.rds"))

# explicit cleanup
parallel::stopCluster(cl)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #