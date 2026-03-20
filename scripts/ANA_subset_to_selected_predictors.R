# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Prepare raster stacks
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# 
# This script produces two types of result:
#   1. ALL raster stacks with layers which were selected by collinearity filter
#     in given grain level
#   2. COMMON raster stacks with only those predictors, which were selected by 
#     collinearity filter in the all grain levels
# 
# NOTE: TF_stacks_dir & rasters_dir define over which rasters should this be made
# (in this case it is ELEV-rasters masked with elevation and FULL-full extent rasters)
# 
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# rasters outputs

# TF_stacks_dir <- here::here("data", "__ANALYSIS__", "STACKS_ELEV")
# if(!dir.exists(TF_stacks_dir)) dir.create(TF_stacks_dir)
# 
# TF_stacks_dir <- here::here("data", "__ANALYSIS__", "STACKS_FULL")
# if(!dir.exists(TF_stacks_dir)) dir.create(TF_stacks_dir)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# load rasters

# rasters_dir <- here::here("data", "__ANALYSIS__", "ELEV", "NE")
# rasters_dir <- here::here("data", "__ANALYSIS__", "FULL", "NE")

r <- list(
  r_1000 = terra::rast(file.path(rasters_dir, "r_1000.tif")),
  r_500 = terra::rast(file.path(rasters_dir, "r_500.tif")),
  r_200 = terra::rast(file.path(rasters_dir, "r_200.tif")),
  r_100 = terra::rast(file.path(rasters_dir, "r_100.tif"))
)

# load colienarity result table
selected_rds <- here::here("data", "predictors_collinearity", "results")
TFtable <- read.csv(file = file.path(selected_rds, "selected_truefalse.csv"))

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# function

get_selected_raster <- function(r, TFtable, grain_value, species_value = NULL) {
  
  # not to mess with predctors
  meta_cols <- base::c("set_name", "item_name", "source_type", "species", "grain_m")
  
  # get correct row for combination SPEC:GRAIN
  row <- TFtable %>%
    dplyr::filter(
      species == species_value,
      grain_m == grain_value
    )
  
  # extract selected predictors (those with TRUE)
  preds <- row %>%
    dplyr::select(-dplyr::all_of(meta_cols)) %>%
    dplyr::select(dplyr::where(~ base::isTRUE(.x))) %>%
    base::names()
  print(preds)
  
  # keep only those layers, which are selected by collinearity filter
  ras <- r[[which(
    vapply(r, function(x) terra::res(x)[1], numeric(1)) == grain_value
  )]]
  
  ras[[names(ras) %in% preds]]
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# apply function over all species, save as ALL truefalse selected predictors
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

GT_rasters <- list(
  r_GT_1000 <- get_selected_raster(
    r = r,
    TFtable = TFtable,
    grain_value = 1000,
    species_value = "GT"
  ),
  r_GT_500 <- get_selected_raster(
    r = r,
    TFtable = TFtable,
    grain_value = 500,
    species_value = "GT"
  ),
  r_GT_200 <- get_selected_raster(
    r = r,
    TFtable = TFtable,
    grain_value = 200,
    species_value = "GT"
  ),
  r_GT_100 <- get_selected_raster(
    r = r,
    TFtable = TFtable,
    grain_value = 100,
    species_value = "GT"
  )
)

file <- file.path(TF_stacks_dir, "GT_all.rds")
saveRDS(GT_rasters, file = file)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

SB_rasters <- list(
  r_SB_1000 <- get_selected_raster(
    r = r,
    TFtable = TFtable,
    grain_value = 1000,
    species_value = "SB"
  ),
  r_SB_500 <- get_selected_raster(
    r = r,
    TFtable = TFtable,
    grain_value = 500,
    species_value = "SB"
  ),
  r_SB_200 <- get_selected_raster(
    r = r,
    TFtable = TFtable,
    grain_value = 200,
    species_value = "SB"
  ),
  r_SB_100 <- get_selected_raster(
    r = r,
    TFtable = TFtable,
    grain_value = 100,
    species_value = "SB"
  )
)

file <- file.path(TF_stacks_dir, "SB_all.rds")
saveRDS(SB_rasters, file = file)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

PK_rasters <- list(
  r_PK_1000 <- get_selected_raster(
    r = r,
    TFtable = TFtable,
    grain_value = 1000,
    species_value = "PK"
  ),
  r_PK_500 <- get_selected_raster(
    r = r,
    TFtable = TFtable,
    grain_value = 500,
    species_value = "PK"
  ),
  r_PK_200 <- get_selected_raster(
    r = r,
    TFtable = TFtable,
    grain_value = 200,
    species_value = "PK"
  ),
  r_PK_100 <- get_selected_raster(
    r = r,
    TFtable = TFtable,
    grain_value = 100,
    species_value = "PK"
  )
)

file <- file.path(TF_stacks_dir, "PK_all.rds")
saveRDS(PK_rasters, file = file)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

PO_rasters <- list(
  r_PO_1000 <- get_selected_raster(
    r = r,
    TFtable = TFtable,
    grain_value = 1000,
    species_value = "PO"
  ),
  r_PO_500 <- get_selected_raster(
    r = r,
    TFtable = TFtable,
    grain_value = 500,
    species_value = "PO"
  ),
  r_PO_200 <- get_selected_raster(
    r = r,
    TFtable = TFtable,
    grain_value = 200,
    species_value = "PO"
  ),
  r_PO_100 <- get_selected_raster(
    r = r,
    TFtable = TFtable,
    grain_value = 100,
    species_value = "PO"
  )
)

file <- file.path(TF_stacks_dir, "PO_all.rds")
saveRDS(PO_rasters, file = file)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

PP_rasters <- list(
  r_PP_1000 <- get_selected_raster(
    r = r,
    TFtable = TFtable,
    grain_value = 1000,
    species_value = "PP"
  ),
  r_PP_500 <- get_selected_raster(
    r = r,
    TFtable = TFtable,
    grain_value = 500,
    species_value = "PP"
  ),
  r_PP_200 <- get_selected_raster(
    r = r,
    TFtable = TFtable,
    grain_value = 200,
    species_value = "PP"
  ),
  r_PP_100 <- get_selected_raster(
    r = r,
    TFtable = TFtable,
    grain_value = 100,
    species_value = "PP"
  )
)

file <- file.path(TF_stacks_dir, "PP_all.rds")
saveRDS(PP_rasters, file = file)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# get common predictors over all grains

select_common_predictors <- function(list){
  common <- Reduce(intersect, lapply(list, names))
  rasters <- lapply(list, function(x) x[[common]])
  return(rasters)
}

# apply function and save as COMMON predictors for each SPEC

GT_common <- select_common_predictors(GT_rasters)
file <- file.path(TF_stacks_dir, "GT_common.rds")
saveRDS(GT_common, file = file)

SB_common <- select_common_predictors(SB_rasters)
file <- file.path(TF_stacks_dir, "SB_common.rds")
saveRDS(SB_common, file = file)

PK_common <- select_common_predictors(PK_rasters)
file <- file.path(TF_stacks_dir, "PK_common.rds")
saveRDS(PK_common, file = file)

PO_common <- select_common_predictors(PO_rasters)
file <- file.path(TF_stacks_dir, "PO_common.rds")
saveRDS(PO_common, file = file)

PP_common <- select_common_predictors(PP_rasters)
file <- file.path(TF_stacks_dir, "PP_common.rds")
saveRDS(PP_common, file = file)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #