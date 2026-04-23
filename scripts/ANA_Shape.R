
pred <- terra::rast("data/__PREDICTORS_STACKS__/recent/selected_predictors_stacks/noextrapol/GD_common/r_1000.tif")

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

data_spat <- s$GD_1000m.rds
pred

vals <- terra::extract(
  pred,
  data_spat,
  xy = TRUE,
  bind = TRUE
  ) %>%
  as.data.frame()
  
library(flexsdm)

vals_nocoor <- vals %>%
  dplyr::select(-x, -y)

xp_m <- flexsdm::extra_eval(
  training_data = vals_nocoor,
  pr_ab = "observ",
  projection_data = pred,
  metric = "mahalanobis",
  univar_comb = FALSE,
  n_cores = parallelly::availableCores(),
  aggreg_factor = 1
)

cols <- c("#FDE725", "#B3DC2B", "#6DCC57", "#36B677", "#1F9D87", "#25818E", "#30678D", "#3D4988", "#462777", "#440154")
plot(xp_m$extrapolation, main = "Shape", col = cols)
#plot(xp_m$uni_comb, main = "Univariate (1) and \n combinatorial (2) extrapolation")

p_extra(
  training_data = vals,
  x = "x",
  y = "y",
  pr_ab = "observ",
  color_p = "black",
  extra_suit_data = xp_m,
  projection_data = pred,
  predictors = c("northness", "bio12", "TWI", "HLI", "bio14"),
  geo_space = FALSE,
  prop_points = 0.05
)
names(pred)
