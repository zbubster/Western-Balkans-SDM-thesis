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

# create and start jobs
jobaky <- vector("list", length(result))
for (i in seq_along(result)) {
  jobaky[[i]] <- create_job(
    graph = result[[i]],
    title = paste0("bandy_BALKANS_", i, "_S2_summer_2022")
  )
  start_job(jobaky[[i]]) # send jobs to back-end
}

list_jobs()

list_jobs() %>%
  as_tibble() %>%
  count(status)

jobz <- list_jobs() %>%
  as_tibble()

# id <- unlist(jobs_df[4,"id"])
# name <- paste0("S2/", gsub(" ", "_", unlist(jobs_df[4, "title"])), ".nc")
# print(name)
# download_results(id, folder = "S2/") -> downname
# file.rename(unlist(downname), name)