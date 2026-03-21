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
# functions

# FUN 1
# extract selected predictors for given grain

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

# FUN 2
# get shared predictors acros all grain levels

select_common_predictors <- function(list){
  common <- Reduce(intersect, lapply(list, names))
  rasters <- lapply(list, function(x) x[[common]])
  return(rasters)
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# apply functions over all species
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# sp <- "GT"
# sp <- "SB"
# sp <- "PK"
# sp <- "PO"
# sp <- "PP"

# apply function to get collinearity selected rasters

rasters <- list(
  r_1000 = get_selected_raster(
    r = r,
    TFtable = TFtable,
    grain_value = 1000,
    species_value = sp
  ),
  r_500 = get_selected_raster(
    r = r,
    TFtable = TFtable,
    grain_value = 500,
    species_value = sp
  ),
  r_200 = get_selected_raster(
    r = r,
    TFtable = TFtable,
    grain_value = 200,
    species_value = sp
  ),
  r_100 = get_selected_raster(
    r = r,
    TFtable = TFtable,
    grain_value = 100,
    species_value = sp
  )
)

# apply common function to get shared predictors

common <- select_common_predictors(rasters)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# save results

# GDAL write options
wopt <- list(
  gdal = c("COMPRESS=LZW", "TILED=YES")
)

# ALL rasters

# define folder where to save results
folder <- file.path(TF_stacks_dir, paste0(sp, "_all_selected"))
if(!dir.exists(folder)) dir.create(folder)
# loop over raster list
for(i in seq_along(rasters)){
  name <- names(rasters)[i]
  file <- file.path(folder, paste0(name, ".tif"))
  terra::writeRaster(rasters[[i]], filename = file, wopt = wopt, overwrite = T)
  print(file)
}

# COMMON rasters

# define folder where to save results
folder <- file.path(TF_stacks_dir, paste0(sp, "_common"))
if(!dir.exists(folder)) dir.create(folder)
# loop over raster list
for(i in seq_along(common)){
  name <- names(common)[i]
  file <- file.path(folder, paste0(name, ".tif"))
  terra::writeRaster(common[[i]], filename = file, wopt = wopt, overwrite = T)
  print(file)
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #