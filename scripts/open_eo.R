## open eo

# load extent
library(terra)
extent <- vect("data/extent_raw.gpkg")

source(here("scripts", "split_into_thirds.R"))

level1 <- split_into_thirds(extent, "horizontal")

plot(extent)
plot(level1[[1]], add = T, col = "orange"); plot(level1[[2]], add = T, col = "steelblue"); plot(level1[[3]], add = T, col = "pink")

level2_1 <- split_into_thirds(level1[[1]], "vertical")
level2_2 <- split_into_thirds(level1[[2]], "vertical")
level2_3 <- split_into_thirds(level1[[3]], "vertical")

tiles <- c(level2_1, level2_2, level2_3)
rm(level1, level2_1, level2_2, level2_3); gc()

# controlplot
plot(extent)
cols <- c("steelblue", "orange", "darkred", "darkgreen", "pink", "darkgrey", "purple", "brown", "skyblue")
for (i in seq_along(tiles)) {
  plot(tiles[[i]], add = TRUE, col = cols[i])
}

# connect to open eo
library(openeo)
con <- connect(host = "https://openeo.dataspace.copernicus.eu")
login()

# create processes obj
p <- processes()

View(list_collections())
describe_collection("SENTINEL2_L2A")
s2 = describe_collection("COPERNICUS/S2") # or use the collection entry from the list, e.g. collections$`COPERNICUS/S2`
print(s2)
#########################################
describe_job(j1)
describe_job("j-251129132925441dbff71cc872cbcc62")
log_job(job = j3)
log_job("j-251129132925441dbff71cc872cbcc62")
x <- log_job("j-251129132925441dbff71cc872cbcc62")
x

job <- describe_job("j-251129132925441dbff71cc872cbcc62")
pg <- as(job, "Process")
pg
#########################################

jobz <- list_jobs()
as.data.frame(jobz)
names <- c(rep("NDII", 9), rep("SAVI", 9), rep("NDVI", 9))

dir_out <- "/media/zbub/DATA/S2/"
if (!dir.exists(dir_out)) dir.create(dir_out, recursive = TRUE)
############# PRASARNA #############
############# PRASARNA #############
############# PRASARNA #############
for (i in 1:27) {
  message(paste0("Job ", jobz[[i]]$id, " start"))
  jobz[[i]]$namez <- names[i]
  download_results(jobz[[i]], folder = paste0(dir_out, i, "_", jobz[[i]]$namez))
  message(paste0("Job ", jobz[[i]]$id, " DONE"))
}

##########################################

# MEDOID misto medianu!
# CLOUD filtering, mozna tohle cely udelat jinak??
cube <- cube$filter_metadata("eo:cloud_cover", "lte", 50)
# odfiltrovat pixely podle bitu, viz sebastiaan script

#########################################
# cloud pokusy
#########################################
# tile5_for_cloud <- p$load_collection(
#   id = "SENTINEL2_L2A",
#   spatial_extent = tiles[[5]], # spatial extent of study
#   temporal_extent = c("2022-05-01", "2022-08-31"), # year in the middle
#   bands = c("B04","B08"), # red, NIR
# )
# 
# OKbits <- c(4, 5, 6, 7, 11)
# 
# #View(list_processes())
# describe_process("to_scl_dilation_mask")
# p$not
# p$mask_scl_dilation
# describe_process("load_collection")
# 
# scl_cube <- p$load_collection(
#   id = "SENTINEL2_L2A",
#   spatial_extent = tiles[[5]],
#   temporal_extent = c("2022-05-01", "2022-08-31"),
#   bands = c("SCL"),
# )
# 
# cloud_mask <- p$to_scl_dilation_mask(
#   data              = scl_cube,
#   kernel1_size      = 17,
#   kernel2_size      = 77,
#   erosion_kernel_size = 3,
#   mask1_values      = c(2, 4, 5, 6, 7),
#   mask2_values      = c(3, 8, 9, 10, 11)
# )
# 
# tile5_for_cloud_masked <- p$mask(
#   data = tile5_for_cloud,
#   mask = cloud_mask
# )



# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# NDVI
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# This service computes the Normalized Difference Vegetation Index (NDVI).
# NDVI is a simple graphical indicator that can be used to analyse remote sensing
# measurements, often from a space platform, assessing whether or not the target
# being observed contains live green vegetation.

# It is calculated as a ratio between the NIR and Red values in traditional fashion.

# The NDVI is computed as NDVI =(NIR-Red)/(NIR+Red)
#
# The process generates an image describing the general status of the crop and
# can be used as a relative metric to monitor the overall development of the crops.

# https://marketplace-portal.dataspace.copernicus.eu/catalogue/app-details/10

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# prepare collection
dc <- vector("list", length = length(tiles))
for(i in seq_along(tiles)){
  x <- p$load_collection(
    id = "SENTINEL2_L2A",
    spatial_extent = tiles[[i]], # spatial extent of study
    temporal_extent = c("2022-05-01", "2022-08-31"), # year in the middle
    bands = c("B04","B08", "SCL"), # red, NIR
  )
  dc[[i]] <- x
}
dc

# compute ndvi
ndvi <- vector("list", length = length(dc))
for(i in seq_along(dc)){
  x <- p$ndvi(data = dc[[i]], nir = "B08", red = "B04")
  ndvi[[i]] <- x
}

# temporal reduction - median
ndvi_med <- vector("list", length = length(ndvi))
for(i in seq_along(ndvi)){
  x <- p$reduce_dimension(
    data = ndvi[[i]],
    reducer = function(x, ctx) p$median(data = x),
    dimension = "t"
  )
  ndvi_med[[i]] <- x
}

# format of results
result <- vector("list", length = length(ndvi_med))
for(i in seq_along(ndvi_med)){
  x <- p$save_result(
    data = ndvi_med[[i]],
    format = "GTiff"
  )
  result[[i]] <- x
}

# send jobs to back-end
jobaky <- vector("list", length(result))
for (i in seq_along(result)) {
  jobaky[[i]] <- create_job(
    graph = result[[i]],
    title = paste0("9_BALKANS_", i, " S2 NDVI summer 2022")
  )
  start_job(jobaky[[i]])
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# SAVI
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# This service calculates Soil Adjusted Vegetation Index (SAVI) for an area and time period.
# The Soil-Adjusted Vegetation Index (SAVI) is an enhancement of
# the Normalized Difference Vegetation Index (NDVI) that takes into account
# the effects of soil background. SAVI minimizes soil brightness influences,
# making it more suitable for areas with substantial soil exposure.
# It is often used to assess vegetation health and density in remote sensing applications.
# It can be applied in agricultural monitoring to evaluate vegetation cover and
# health in areas with varying soil brightness,
# helping to distinguish between bare soil and vegetation.

# SAVI is calculated as a ratio between the R and NIR values
# with a soil brightness correction factor (L) defined as 0.5 to accommodate most
# land cover types.

# The formula is SAVI = ((1 + L) * (NIR - Red)) / (NIR + Red + L), where L = 0.5.

# The process generates an image representing a qualitative descriptor.
# The values will range from -1 to 1, with higher values indicating
# healthier and denser vegetation, while negative values may represent
# areas with minimal vegetation or regions where the soil reflects more than the vegetation.

# https://marketplace-portal.dataspace.copernicus.eu/catalogue/app-details/11

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# prepare collection
# DONE from NDVI subtask

# create function and processing graph for SAVI
savi_fun <- function(x, context) {
  red <- x["B04"]
  nir <- x["B08"]
  (1.5 * (nir - red)) / (nir + red + 0.5)
}

savi <- vector("list", length = length(dc))
for(i in seq_along(dc)){
  x <- p$apply(
    data    = dc[[1]],
    process = savi_fun
  )
  savi[[i]] <- x
}

# temporal reduction - median
savi_med <- vector("list", length = length(savi))
for(i in seq_along(savi)){
  x <- p$reduce_dimension(
    data = savi[[i]],
    reducer = function(x, ctx) p$median(data = x),
    dimension = "t"
  )
  savi_med[[i]] <- x
}

# format of results
result <- vector("list", length = length(savi_med))
for(i in seq_along(savi_med)){
  x <- p$save_result(
    data = savi_med[[i]],
    format = "GTiff"
  )
  result[[i]] <- x
}

# send jobs to back-end
jobaky <- vector("list", length(result))
for (i in seq_along(result)) {
  jobaky[[i]] <- create_job(
    graph = result[[i]],
    title = paste0("9_BALKANS_", i, " S2 SAVI summer 2022")
  )
  start_job(jobaky[[i]])
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# NDII
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# prepare collection
dc <- vector("list", length = length(tiles))
for(i in seq_along(tiles)){
  x <- p$load_collection(
    id = "SENTINEL2_L2A",
    spatial_extent = tiles[[i]], # spatial extent of study
    temporal_extent = c("2022-05-01", "2022-08-31"), # year in the middle
    bands = c("B08", "B11"),
  )
  dc[[i]] <- x
}
dc

# create function and processing graph for SAVI
ndii_fun <- function(x, context) {
  osm <- x["B08"]
  jed <- x["B11"]
  (osm - jed) / (osm + jed)
}

ndii <- vector("list", length = length(dc))
for(i in seq_along(dc)){
  x <- p$apply(
    data    = dc[[1]],
    process = ndii_fun
  )
  ndii[[i]] <- x
}

# temporal reduction - median
ndii_med <- vector("list", length = length(ndii))
for(i in seq_along(ndii)){
  x <- p$reduce_dimension(
    data = ndii[[i]],
    reducer = function(x, ctx) p$median(data = x),
    dimension = "t"
  )
  ndii_med[[i]] <- x
}

# format of results
result <- vector("list", length = length(ndii_med))
for(i in seq_along(ndii_med)){
  x <- p$save_result(
    data = ndii_med[[i]],
    format = "GTiff"
  )
  result[[i]] <- x
}

# send jobs to back-end
jobaky <- vector("list", length(result))
for (i in seq_along(result)) {
  jobaky[[i]] <- create_job(
    graph = result[[i]],
    title = paste0("9_BALKANS_", i, " S2 NDII summer 2022")
  )
  start_job(jobaky[[i]])
}

jobaky[[2]] <- create_job(
  graph = result[[2]],
  title = paste0("9_BALKANS_", 2, " S2 NDII summer 2022")
)
start_job(jobaky[[2]])

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# NDMI
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

#Normalized difference
#moisture index (NDMI)

#(B8A - B11)/(B8A + B11) Higher pixel values
#indicate higher moisture
#content in vegetation.

#(Gao, 1996)

# prepare collection
dc <- vector("list", length = length(tiles))
for(i in seq_along(tiles)){
  x <- p$load_collection(
    id = "SENTINEL2_L2A",
    spatial_extent = tiles[[i]], # spatial extent of study
    temporal_extent = c("2022-05-01", "2022-08-31"), # year in the middle
    bands = c("B08", "B11"),
  )
  dc[[i]] <- x
}
dc

# create function and processing graph for SAVI
ndii_fun <- function(x, context) {
  osm <- x["B08"]
  jed <- x["B11"]
  (osm - jed) / (osm + jed)
}

ndii <- vector("list", length = length(dc))
for(i in seq_along(dc)){
  x <- p$apply(
    data    = dc[[1]],
    process = ndii_fun
  )
  ndii[[i]] <- x
}

# temporal reduction - median
ndii_med <- vector("list", length = length(ndii))
for(i in seq_along(ndii)){
  x <- p$reduce_dimension(
    data = ndii[[i]],
    reducer = function(x, ctx) p$median(data = x),
    dimension = "t"
  )
  ndii_med[[i]] <- x
}

# format of results
result <- vector("list", length = length(ndii_med))
for(i in seq_along(ndii_med)){
  x <- p$save_result(
    data = ndii_med[[i]],
    format = "GTiff"
  )
  result[[i]] <- x
}

# send jobs to back-end
jobaky <- vector("list", length(result))
for (i in seq_along(result)) {
  jobaky[[i]] <- create_job(
    graph = result[[i]],
    title = paste0("9_BALKANS_", i, " S2 NDII summer 2022")
  )
  start_job(jobaky[[i]])
}
