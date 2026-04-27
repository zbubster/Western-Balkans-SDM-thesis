# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Shape parallell implementation
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# load function
fun_file <- here::here("scripts", "fun_Shape.R")
source(fun_file)

# main config
grains <- c(1000, 500, 200, 100)
species <- c("GD", "GT", "SB", "PK", "PO", "PP")
shape_id <- "recent_noextrapol_weights_common"
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
tasks <- tasks %>%
  arrange(desc(tasks$grain))
tasks

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Prepare parallel things

# detect available cores
n_cores <- parallelly::availableCores()

# define user library first
user_lib <- Sys.getenv("R_LIBS_USER")

# prepare library paths for workers
main_libpaths <- unique(c(
  user_lib,
  .libPaths()
))

# apply the same library order in the main session
.libPaths(main_libpaths)

# prevent nested threading inside workers
Sys.setenv(
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
# source helper functions on workers once
parallel::clusterEvalQ(cl, {
  fun_file <- here::here("scripts", "fun_Shape.R")
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
    "shape_id"
  ),
  envir = environment()
)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# PARALLEL LOOP

res <- foreach::foreach(
  task_id = seq_len(nrow(tasks)),
  .packages = c("terra", "dplyr", "here", "ggplot2"),
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

  # define output directory
  mod_dir <- here::here("models", "Shape", shape_id, sp, as.character(grain))
  if(!dir.exists(mod_dir)) {
    dir.create(mod_dir, recursive = TRUE, showWarnings = FALSE)
  }

  # run shape function
  shape_function(
    pred = pred,
    spec = occ,
    dir_out = mod_dir
  )

}

print(res)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# explicit cleanup
parallel::stopCluster(cl)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
