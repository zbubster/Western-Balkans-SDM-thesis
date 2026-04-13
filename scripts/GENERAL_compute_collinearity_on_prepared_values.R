# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Collineartiy ‒ compute collinearity
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# 
# This script takes pre-prepared samples of predictor values from observations
# localities and 50k randomly selected data points, and calculates
# predictor multicollinearity on them.
# 
# At the beginning of the script, it is advisable to manually
# specify the predictor files to be included in the analysis,
# based on prior biological knowledge.
#
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Config

root_dir <- here::here("data", "__predictors_collinearity__")

# load extracted values
values_dir <- here::here(root_dir, "values")

v_random <- readRDS(file = file.path(here::here(values_dir, "v_random.rds")))
v_1000 <- readRDS(file = file.path(here::here(values_dir, "v_1000.rds")))
v_500 <- readRDS(file = file.path(here::here(values_dir, "v_500.rds")))
v_200 <- readRDS(file = file.path(here::here(values_dir, "v_200.rds")))
v_100 <- readRDS(file = file.path(here::here(values_dir, "v_100.rds")))

available_predictors <- names(v_random$r_100.tif)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# predictors handout

# "depth_to_bedrock", "aspect", "soil_water_cap", "dem_max", "dem_median", "dem_min", "dem_range", 
# "dem_sd", "eastness", "landcover", "flowdir", "bedrock", "HLI", "northness", 
# "roughness", "slope", "pH_in_H2O", "TPI", "TRI", "TRI_riley", "TRI_rmsd", 
# "TWI",   "bio01", "bio02", "bio03", "bio04", "bio05", "bio06", 
# "bio07", "bio08", "bio09", "bio10", "bio11", "bio12", "bio13", 
# "bio14", "bio15", "bio16", "bio17", "bio18", "bio19", "scd"

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# no extrapol

# stack_type <- "noextrapol"
# 
# # PRIORITY
# predictors <- c(
#   "bio06", "bio05", "bio10", "bio11", "scd", "landcover", "pH_in_H2O", "northness", "HLI", "TWI", "soil_water_cap", "dem_sd", "dem_range",
#   "TPI", "TRI", "TRI_riley", "TRI_rmsd", "bio18", "bio19", "bio04", "bio01", "slope", "aspect", "depth_to_bedrock",
#   "aspect", "eastness", "bedrock", "dem_median"
# )
# # REST
# diff <- dplyr::setdiff(available_predictors, predictors)
# predictors <- c(predictors, diff)
# # NOGO
# predictors <- predictors[!(predictors %in% c("bio02", "bio03", "bio08", "bio09", "bio15"))]
# 
# max_cor <- 0.7
# max_vif <- 7

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# for extrapolation

stack_type <- "extrapol"
predictors <- c(
  "bio10", "bio11", "northness", "scd", "bio06", "bio05", "dem_sd", "dem_range",
  "TPI", "TRI", "TRI_riley", "TRI_rmsd", "bio18", "bio19", "bio04", "bio01", "slope",
  "aspect", "eastness", "bedrock", "dem_median"
)
diff <- dplyr::setdiff(available_predictors, predictors)
diff <- diff[!(diff %in% c("bio02", "bio03", "bio08", "bio09", "bio15", "landcover", 
                           "pH_in_H2O", "HLI", "soil_water_cap", "depth_to_bedrock", "TWI"))]
predictors <- c(predictors, diff)
max_cor <- 0.7
max_vif <- 7

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# load collinearity function
source(here::here("scripts", "fun_compute_collinear_metrices.R"))

# Next sections use function "compute_collinearity_metrices()" on 
# different lists (those with species responses on various grains & random
# spatilly sampled from various grains). Results are saved within folder res_dir
# for later inspection. Note, that function runs in loop over different objects
# within list ‒ species on same grain/different grains ‒ with regenerating
# layer name.

# define outputs based on stack purpose
out_dir <- here::here(root_dir, stack_type)
if(!dir.exists(out_dir)) dir.create(out_dir)
# results dir
res_dir <- here::here(out_dir, "results")
if(!dir.exists(res_dir)) dir.create(res_dir)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# species 1000

res_v_1000 <- vector(mode = "list", length = length(v_1000))
names(res_v_1000) <- names(v_1000)

for(i in seq_along(v_1000)){
  v_1000[[i]]$observ <- as.integer(v_1000[[i]]$observ)
  name <- sub("\\.rds$", "", names(v_1000)[i])
  res_v_1000[[i]] <- compute_collinearity_metrices(
    v_1000[[i]],
    nm = name,
    response = "observ",
    predictors = predictors,
    out_dir = out_dir,
    max_cor = max_cor,
    max_vif = max_vif)
}

saveRDS(res_v_1000, here::here(res_dir, "RES_1000.rds"))

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# species 500

res_v_500 <- vector(mode = "list", length = length(v_500))
names(res_v_500) <- names(v_500)

for(i in seq_along(v_500)){
  v_500[[i]]$observ <- as.integer(v_500[[i]]$observ)
  name <- sub("\\.rds$", "", names(v_500)[i])
  res_v_500[[i]] <- compute_collinearity_metrices(
    v_500[[i]],
    nm = name,
    response = "observ",
    predictors = predictors,
    out_dir = out_dir,
    max_cor = max_cor,
    max_vif = max_vif)
}

saveRDS(res_v_500, here::here(res_dir, "RES_500.rds"))

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# species 200

res_v_200 <- vector(mode = "list", length = length(v_200))
names(res_v_200) <- names(v_200)

for(i in seq_along(v_200)){
  v_200[[i]]$observ <- as.integer(v_200[[i]]$observ)
  name <- sub("\\.rds$", "", names(v_200)[i])
  res_v_200[[i]] <- compute_collinearity_metrices(
    v_200[[i]],
    nm = name,
    response = "observ",
    predictors = predictors,
    out_dir = out_dir,
    max_cor = max_cor,
    max_vif = max_vif)
}

saveRDS(res_v_200, here::here(res_dir, "RES_200.rds"))

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# species 100

res_v_100 <- vector(mode = "list", length = length(v_100))
names(res_v_100) <- names(v_100)

for(i in seq_along(v_100)){
  v_100[[i]]$observ <- as.integer(v_100[[i]]$observ)
  name <- sub("\\.rds$", "", names(v_100)[i])
  res_v_100[[i]] <- compute_collinearity_metrices(
    v_100[[i]],
    nm = name,
    response = "observ",
    predictors = predictors,
    out_dir = out_dir,
    max_cor = max_cor,
    max_vif = max_vif)
}

saveRDS(res_v_100, here::here(res_dir, "RES_100.rds"))

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# random over all all grains

res_v_random <- vector(mode = "list", length = length(v_random))
names(res_v_random) <- names(v_random)

for(i in seq_along(v_random)){
  #v_random[[i]]$observ <- as.integer(v_random[[i]]$observ)
  name <- sub("\\.tif$", "", names(v_random)[i])
  res_v_random[[i]] <- compute_collinearity_metrices(
    v_random[[i]],
    nm = name,
    predictors = predictors,
    out_dir = out_dir,
    max_cor = max_cor,
    max_vif = max_vif)
}

saveRDS(res_v_random, here::here(res_dir, "RES_random.rds"))

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #