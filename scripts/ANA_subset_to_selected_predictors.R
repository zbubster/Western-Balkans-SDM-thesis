# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Prepare raster stacks
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #


rasters_dir <- here::here("data", "__ANALYSIS__", "ELEV")
r <- list(
  r_1000 = terra::rast(file.path(rasters_dir, "r_1000.tif")),
  r_500 = terra::rast(file.path(rasters_dir, "r_500.tif")),
  r_200 = terra::rast(file.path(rasters_dir, "r_200.tif")),
  r_100 = terra::rast(file.path(rasters_dir, "r_100.tif"))
)




selected_rds <- here::here("data", "predictors_collinearity", "results")

TFtable <- read.csv(file = file.path(selected_rds, "selected_truefalse.csv"))
TFtable %>%
  select(species:bio02)



get_selected_raster <- function(r, TFtable, grain_value, species_value = NULL) {
  
  meta_cols <- base::c("set_name", "item_name", "source_type", "species", "grain_m")
  
  row <- TFtable %>%
    dplyr::filter(
      is.na(species),
      grain_m == grain_value
    )
  
  
  preds <- row %>%
    dplyr::select(-dplyr::all_of(meta_cols)) %>%
    dplyr::select(dplyr::where(~ base::isTRUE(.x))) %>%
    base::names()
  
  ras <- r[[which(
    base::vapply(r, function(x) terra::res(x)[1], numeric(1)) == grain_value
  )]]
  
  ras[[names(ras) %in% preds]]
}

names(ras) %in% preds

r_GT_1000 <- get_selected_raster(
  r = r,
  TFtable = TFtable,
  grain_value = 1000,
  species_value = "GT"
)

r_random_500 <- get_selected_raster(
  r = r,
  TFtable = TFtable,
  grain_value = 500,
  species_value = NULL
)
