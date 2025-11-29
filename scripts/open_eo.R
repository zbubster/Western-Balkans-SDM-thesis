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

jobz <- list_jobs()
jobz
#########################################

# create processes obj
p <- processes()

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
    bands = c("B04","B08"), # red, NIR
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

# download results
dir_out <- "/media/zbub/DATA/S2/ndvi"
if (!dir.exists(dir_out)) dir.create(dir_out, recursive = TRUE)
download_results(, folder = dir_out)
download_results(, folder = dir_out)
download_results(, folder = dir_out)

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

# download results
dir_out <- "/media/zbub/DATA/S2/savi"
if (!dir.exists(dir_out)) dir.create(dir_out, recursive = TRUE)
download_results(, folder = dir_out)
download_results(, folder = dir_out)
download_results(, folder = dir_out)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# 
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
