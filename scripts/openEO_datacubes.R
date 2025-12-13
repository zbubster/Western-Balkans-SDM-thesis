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

################################################################################
# DONE ABOVE
################################################################################

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
  
  out <- p$save_result(
    data = dvacka,
    format = "NetCDF"
  )
  
  results[[i]] <- out
}

jobaky <- vector("list", length(results))
for(i in seq_along(jobaky)){
  cat("Strating job", i, "/n")
  jobaky[[i]] <- create_job(results[[i]], title = sprintf("SCLmasked_ALL_%02d_2022", i))
  start_job(jobaky[[i]])
}

dir_out <- "/media/zbub/DATA/Sentinel2_datacubes/"
if (!dir.exists(dir_out)) dir.create(dir_out, recursive = TRUE)
 
# for (i in 1:27) {
#   message(paste0("Job ", jobz[[i]]$id, " start"))
#   jobz[[i]]$namez <- names[i]
#   download_results(jobz[[i]], folder = paste0(dir_out, i, "_", jobz[[i]]$namez))
#   message(paste0("Job ", jobz[[i]]$id, " DONE"))
# }

id <- unlist(jobz_df[1,"id"])
name <- paste0(dir_out ,unlist(jobz_df[1, "title"]), ".nc")
print(name)
downname <- download_results(id, folder = dir_out)
file.rename(unlist(downname), name)

####################################

r <- terra::rast("/media/zbub/DATA/Sentinel2_datacubes/SCLmasked_ALL_01_2022.nc")
plot(r)
plot(r[[102]])

# r <- stars::read_ncdf("/media/zbub/DATA/Sentinel2_datacubes/SCLmasked_ALL_01_2022.nc")
# plot(r)
# plot(r[,,100])

####################################

list_jobs()

jobz_names <- list_jobs() %>%
  names()

jobz_df <- list_jobs() %>%
  as_tibble()
jobz_df

# describe_job(jobz_names[1])
# log_job(jobz_names[1])

#####################################

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