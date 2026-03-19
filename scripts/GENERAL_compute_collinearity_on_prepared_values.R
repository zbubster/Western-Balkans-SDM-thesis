# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Collineartiy ‒ compute collinearity
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Config

out_dir <- here::here("data", "predictors_collinearity")

# load extracted values
values_dir <- here::here(out_dir, "values")

v_random <- readRDS(file = file.path(here::here(values_dir, "v_random.rds")))
v_1000 <- readRDS(file = file.path(here::here(values_dir, "v_1000.rds")))
v_500 <- readRDS(file = file.path(here::here(values_dir, "v_500.rds")))
v_200 <- readRDS(file = file.path(here::here(values_dir, "v_200.rds")))
v_100 <- readRDS(file = file.path(here::here(values_dir, "v_100.rds")))

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# define prefered order of predictors based on ecological knowledge
predictors <- c(
  "glim", "northness", "scd", "TPI", "TRI", "slope", 
  "bio18", "bio04", "bio05", "bio06", "bio13", "bio14","bio19",
  "TRIriley", "TRIrmsd", "roughness", 
  "bio09", "bio10", "bio11", "bio12", "bio07", "bio08", "bio01", "bio15", "bio16", 
  "eastness", "aspect", "hli", "twi", 
  "bio17", "bio02", "bio03")

# load collinearity function
source(here::here("scripts", "fun_compute_collinear_metrices.R"))

# Next sections use function "compute_collinearity_metrices()" on 
# different lists (those with species responses on various grains & random
# spatilly sampled from various grains). Results are saved within folder res_dir
# for later inspection. Note, that function runs in loop over different objects
# within list ‒ species on same grain/different grains ‒ with regenerating
# layer name.

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
    max_cor = 0.7,
    max_vif = 7)
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
    max_cor = 0.7,
    max_vif = 7)
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
    max_cor = 0.7,
    max_vif = 7)
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
    max_cor = 0.7,
    max_vif = 7)
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
    max_cor = 0.7,
    max_vif = 7)
}

saveRDS(res_v_random, here::here(res_dir, "RES_random.rds"))

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #