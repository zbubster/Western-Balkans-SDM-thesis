# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Collinearity
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Config

# where should be cormats and other info stored
out_dir <- here::here("data", "predictors_collinearity")
if(!dir.exists(out_dir)){dir.create(out_dir)}

rasters_dir <- here::here("data", "__COMPATIBILITY__", "STACKS", "__STACKS_MASKED__")
r <- list()
for(i in seq_along(list.files(rasters_dir))){
  n <- list.files(rasters_dir)[i]
  r[[i]] <- terra::rast(file.path(rasters_dir, n))
  names(r)[i] <- n
}

species_dir <- here::here("data", "occurence", "_ANALYSIS_FOCAL_", "_FILTER_")
s <- list()
for(i in seq_along(list.files(species_dir))){
  n <- list.files(species_dir)[i]
  s[[i]] <- base::readRDS(file.path(species_dir, n))
  names(s)[i] <- n
}

# load species spatially
spatialspec <- function(l){
  coords <- l$coor
  obs <- l$observations
  out <- terra::vect(
    x = coords,
    geom = c("X", "Y"),
    crs = terra::crs("epsg:3035")
  )
  out$observ <- obs
  return(out)
}

s <- lapply(s, spatialspec)

# divide species list into lists based on grain
s_1000 <- s[grepl("_1000m\\.rds$", names(s))]
s_500 <- s[grepl("_500m\\.rds$",  names(s))]
s_200 <- s[grepl("_200m\\.rds$",  names(s))]
s_100 <- s[grepl("_100m\\.rds$",  names(s))]

str(r)
str(s)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# sample values, extract

seed <- 722085415
set.seed(seed)

# RANDOM

# random spat sample function
spsam <- function(l){
  vals <- terra::spatSample(
    l,
    size = 50000,
    method = "random",
    na.rm = TRUE,
    as.df = TRUE
  )
  return(vals) # returns sampled predictor values
}
# apply function over grain levels
v <- lapply(r, spsam)

# OBSERVATIONS

# extract raster values on observation points
extract_predictor_values_on_observations <- function(spec_list, raster){
  stopifnot(class(raster) == "SpatRaster")
  out <- list()
  out <- lapply(spec_list, terra::extract, x = raster, bind = TRUE)
  out <- lapply(out, as.data.frame)
  out <- lapply(out, drop_na)
  return(out)
}

# apply extract function over different grain levels and different species
v_1000 <- extract_predictor_values_on_observations(s_1000, raster = r$r_1000.tif)
v_500 <- extract_predictor_values_on_observations(s_500, raster = r$r_500.tif)
v_200 <- extract_predictor_values_on_observations(s_200, raster = r$r_200.tif)
v_100 <- extract_predictor_values_on_observations(s_100, raster = r$r_100.tif)

# convert selected predictors
specpred <- function(l){
  # geo to factor 
  l$glim <- as.factor(l$glim)
  # aspect to orientation
  l$northness <- cos(l$aspect*pi/180)
  l$eastness <- sin(l$aspect*pi/180)
  
  return(l)
}

v_random <- lapply(v, specpred)
v_1000 <- lapply(v_1000, specpred)
v_500 <- lapply(v_500, specpred)
v_200 <- lapply(v_200, specpred)
v_100 <- lapply(v_100, specpred)

# save extracted values
values_dir <- here::here(out_dir, "values")
if(!dir.exists(values_dir)) dir.create(values_dir)
saveRDS(v_random, file = file.path(here::here(values_dir, "v_random.rds")))
saveRDS(v_1000, file = file.path(here::here(values_dir, "v_1000.rds")))
saveRDS(v_500, file = file.path(here::here(values_dir, "v_500.rds")))
saveRDS(v_200, file = file.path(here::here(values_dir, "v_200.rds")))
saveRDS(v_100, file = file.path(here::here(values_dir, "v_100.rds")))

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# define prefered order of predictors based on ecological knowledge
predictors <- c(
  "glim", 
  "TPI", "TRI", "TRIriley", "TRIrmsd", "roughness", 
  "slope", "northness", "eastness", "aspect", "hli", "twi", "scd",
  "bio04", "bio05", "bio06", "bio13", "bio14", "bio18", "bio19",
  "bio09", "bio10", "bio11", "bio12", "bio07", "bio08", "bio01", "bio15", "bio16", 
  "bio17", "bio02", "bio03")

# load collinearity function
source(here::here("scripts", "fun_compute_collinear_metrices.R"))

# results dir
res_dir <- here::here(out_dir, "results")
if(!dir.exists(res_dir)) dir.create(res_dir)

# Next sections use function "compute_collinearity_metrices()" on 
# different lists (those with species responses on various grains & random
# spatilly sampled from various grains). Results are saved within folder res_dir
# for later inspection. Note, that function runs in loop over different objects
# within list ‒ species on same grain/different grains ‒ with regenerating
# layer name.

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# species 1000

res_v_1000 <- vector(mode = "list", length = length(v_1000))
names(res_v_1000) <- names(v_1000)
for(i in seq_along(v_1000)){
  name <- sub("\\.rds$", "", names(v_1000)[i])
  res_v_1000[[i]] <- compute_collinearity_metrices(
    v_1000[[i]],
    nm = name,
    response = "observ",
    predictors = predictors,
    out_dir = out_dir)
}
saveRDS(res_v_1000, here::here(res_dir, "RES_1000.rds"))

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# species 500

res_v_500 <- vector(mode = "list", length = length(v_500))
names(res_v_500) <- names(v_500)
for(i in seq_along(v_500)){
  name <- sub("\\.rds$", "", names(v_500)[i])
  res_v_500[[i]] <- compute_collinearity_metrices(
    v_500[[i]],
    nm = name,
    response = "observ",
    predictors = predictors,
    out_dir = out_dir)
}
saveRDS(res_v_500, here::here(res_dir, "RES_500.rds"))

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# species 200

res_v_200 <- vector(mode = "list", length = length(v_200))
names(res_v_200) <- names(v_200)
for(i in seq_along(v_200)){
  name <- sub("\\.rds$", "", names(v_200)[i])
  res_v_200[[i]] <- compute_collinearity_metrices(
    v_200[[i]],
    nm = name,
    response = "observ",
    predictors = predictors,
    out_dir = out_dir)
}
saveRDS(res_v_200, here::here(res_dir, "RES_200.rds"))

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# species 100

res_v_100 <- vector(mode = "list", length = length(v_100))
names(res_v_100) <- names(v_100)
for(i in seq_along(v_100)){
  name <- sub("\\.rds$", "", names(v_100)[i])
  res_v_100[[i]] <- compute_collinearity_metrices(
    v_100[[i]],
    nm = name,
    response = "observ",
    predictors = predictors,
    out_dir = out_dir)
}
saveRDS(res_v_100, here::here(res_dir, "RES_100.rds"))

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# random over all all grains

res_v_random <- vector(mode = "list", length = length(v_random))
names(res_v_random) <- names(v_random)
for(i in seq_along(v_random)){
  name <- sub("\\.tif$", "", names(v_random)[i])
  res_v_random[[i]] <- compute_collinearity_metrices(
    v_random[[i]],
    nm = name,
    predictors = predictors,
    out_dir = out_dir)
}
saveRDS(res_v_random, here::here(res_dir, "RES_random.rds"))

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #