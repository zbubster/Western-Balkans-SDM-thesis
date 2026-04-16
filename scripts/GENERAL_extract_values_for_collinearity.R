# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Collinearity ‒ extract values
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Config

# where should be cormats and other info stored
out_dir <- here::here("data", "__predictors_collinearity__")
if(!dir.exists(out_dir)){dir.create(out_dir)}

values_dir <- here::here(out_dir, "values")
if(!dir.exists(values_dir)) dir.create(values_dir)


rasters_dir <- here::here("data", "__PREDICTORS_STACKS__", "recent")
r <- list()
for(i in seq_along(list.files(rasters_dir))){
  n <- list.files(rasters_dir)[i]
  r[[i]] <- terra::rast(file.path(rasters_dir, n))
  names(r)[i] <- n
}

species_dir <- here::here("data", "__ANALYSIS__", "OCC")
s <- list()
for(i in seq_along(list.files(species_dir, pattern = "*.rds"))){
  n <- list.files(species_dir, pattern = "*.rds")[i]
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

# convert selected predictors to factors
pred_factors <- function(l){
  l$bedrock <- as.factor(l$bedrock)
  l$landcover <- as.factor(l$landcover)
  return(l)
}

v_random <- lapply(v, pred_factors)
v_1000 <- lapply(v_1000, pred_factors)
v_500 <- lapply(v_500, pred_factors)
v_200 <- lapply(v_200, pred_factors)
v_100 <- lapply(v_100, pred_factors)

# save extracted values
saveRDS(v_random, file = file.path(here::here(values_dir, "v_random.rds")))
saveRDS(v_1000, file = file.path(here::here(values_dir, "v_1000.rds")))
saveRDS(v_500, file = file.path(here::here(values_dir, "v_500.rds")))
saveRDS(v_200, file = file.path(here::here(values_dir, "v_200.rds")))
saveRDS(v_100, file = file.path(here::here(values_dir, "v_100.rds")))

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #