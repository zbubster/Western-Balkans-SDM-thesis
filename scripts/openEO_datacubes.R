# Load required libraries
library(openeo)
library(sf)
library(dplyr)
library(terra)

# Connect to openEO backend
connection <- connect("https://openeo.dataspace.copernicus.eu")
login()

# create processes obj
p <- processes()

# Define bands to download
bands <- c("B02", "B03", "B04", "B05", "B08", "B8A", "B11", "B12", "SCL")

# Define temporal extent
temp_extent <- list("2022-05-01", "2022-08-31")

# load extent
extent <- vect("data/extent_raw.gpkg")
extent <- project(extent, "epsg:4326")

source(here("scripts", "split_into_thirds.R"))

level1 <- split_into_thirds(extent, "horizontal")
level2 <- lapply(level1, split_into_thirds, direction = "vertical")
level3 <- lapply(level2, function(a)
  lapply(a, split_into_thirds, direction = "horizontal"))
level4 <- lapply(level3, function(a)
  lapply(a, function(b)
    lapply(b, split_into_thirds, direction = "vertical")
  )
)

tiles <- unlist(level4, recursive = T)
stopifnot(
  length(tiles) == 81
)
rm(level1, level2, level3, level4); gc()

# controlplot
cols <- c("steelblue", "orange", "darkred", "darkgreen", "pink", "darkgrey", "purple", "brown", "skyblue")
plot(extent)
for (i in seq_along(tiles)) {
  plot(tiles[[i]], add = TRUE, col = rep(cols, 10)[i])
}

# get bbox
bboxes <- vector("list", length = length(tiles))
for(i in seq_along(tiles)){
  e <- ext(tiles[[i]])
  tile_extent <- list(
    west  = as.numeric(xmin(e)),
    south = as.numeric(ymin(e)),
    east  = as.numeric(xmax(e)),
    north = as.numeric(ymax(e))
  )
  bboxes[[i]] <- tile_extent
}
bboxes

##################################################################################################################################
# DONE ABOVE
##################################################################################################################################

SCL <- c("SCL")
focal_bands <- c("B02", "B03", "B04", "B05", "B08", "B8A", "B11", "B12")
temp_extent <- c("2022-05-01","2022-08-31")

results <- vector(mode = "list", length = length(bboxes))
for(i in seq_along(bboxes)){
  scl <- p$load_collection(
    id = "SENTINEL2_L2A",
    spatial_extent = bboxes[[i]],
    temporal_extent = temp_extent,
    bands = SCL
  )
  
  scl_mask <- p$to_scl_dilation_mask(
    data = scl
  )
  
  rest <- p$load_collection(
    id = "SENTINEL2_L2A",
    spatial_extent = bboxes[[i]],
    temporal_extent = temp_extent,
    bands = focal_bands
  )
  
  rest_masked <- p$mask(
    data = rest,
    mask = scl_mask
  )
  
  dvacka <- p$resample_spatial(
    data = rest_masked,
    projection = 3035,
    resolution = 20,
    method = "bilinear"
  )
  
  results[[i]] <- dvacka
}

results
i <- 1
jobs <- vector("list", length(results))
# for(i in seq_along(results)){
#   out <- p$save_result(results[[i]], format = "NetCDF")
#   jobs[[i]] <- create_job(out, title = sprintf("SCLmasked_ALL_%02d_2022", i))
#   start_job(jobs[[i]])
# }

list_jobs()

jobz_names <- list_jobs() %>%
  names()

describe_job(jobz_names[1])
log_job(jobz_names[1])

#####################################




















# load collection

# prepare collection
dc <- vector("list", length = length(tiles))
for(i in seq_along(tiles)){
  x <- p$load_collection(
    id = "SENTINEL2_L2A",
    spatial_extent = tiles[[i]], # spatial extent of study
    temporal_extent = temp_extent, # year in the middle
    bands = bands, 
  )
  dc[[i]] <- x
}
dc

# save result
result <- vector("list", length = length(dc))
for(i in seq_along(dc)){
  x <- p$save_result(
    data = dc[[i]],
    format = "NetCDF"
  )
  result[[i]] <- x
}
result

result <- result[45]

# create and start jobs
jobaky <- vector("list", length(result))
for (i in seq_along(result)) {
  jobaky[[i]] <- create_job(
    graph = result[[i]],
    title = paste0("bandy_81_BALKANS_", i, "_S2_summer_2022")
  )
  start_job(jobaky[[i]]) # send jobs to back-end
}


list_jobs()
list_collections()


jobz_df <- list_jobs() %>%
  as_tibble()
print(jobz_df, n = 100)

x<-read_stars("/media/zbub/DATA/S2/openEO.nc")
str(x)

# Sentinel-2 SCL class codes and definitions
scl_code <- dplyr::tibble(
  SCL = 0:11,
  SCL_name = c(
    "No data",
    "Saturated or defective",
    "Dark area pixels",
    "Cloud shadow",
    "Vegetation",
    "Bare soils",
    "Water",
    "Cloud low probability / Unclassified",
    "Cloud medium probability",
    "Cloud high probability",
    "Thin cirrus",
    "Snow or ice"
  )
)
scl_code

