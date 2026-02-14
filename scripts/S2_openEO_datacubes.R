# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Get data cubes from CDSE via openEO
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# This script is used to retrieve data from CDSE (Copernicus Data Space Ecosystem).
# The total extent of the study is required as input, which is first
# divided into 81 smaller parts for easier processing on the backend.
# For the selected time period and each part of the studied extent,
# it returns a NetCDF file containing individual scenes for the given
# spectral bands that were captured during that period,
# cleaned of unwanted pixels according to the SCL (scene classification layer).
# At the end all procesed 'tiles' are saved on given local location.

# NOTE: Unless you have access to CDSE's premium services,
# this script will generate 'errors'.
# For example, it will not be possible to run all 81 jobs at once. 

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# DIRS, BANDS and EXTENTS (t & s)

# scl band for cloud etal filter creation
SCL <- c("SCL")

# focal bands, which should be included in resultin NetCDF
focal_bands <- c("B02", "B03", "B04", "B05", "B08", "B8A", "B11", "B12")

# temporal extent
temp_extent <- c("2022-05-01","2022-08-31") # one 'summer'

# spatial extent
extent <- vect("data/extent_raw.gpkg")
extent <- project(extent, "epsg:4326") # to be safe, but the result on the backend projected to 3035

# output dir
dir_out <- "/media/zbub/DATA/Sentinel2_datacubes/"
if (!dir.exists(dir_out)) dir.create(dir_out, recursive = TRUE)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# TILES & BBoxes

# load script, which split given terra::vect to thirds
source(here("scripts", "fun_split_into_thirds.R"))

# apply splitter 4times
level1 <- split_into_thirds(extent, "horizontal") # first splitting (= 3 tiles)
level2 <- lapply(level1, split_into_thirds, direction = "vertical") # spliting thirds to thirds (= 9 tiles)
level3 <- lapply(level2, function(a)
  lapply(a, split_into_thirds, direction = "horizontal")) # spliting nine tiles to thirds (= 27 tiles)
level4 <- lapply(level3, function(a)
  lapply(a, function(b)
    lapply(b, split_into_thirds, direction = "vertical") # spliting thirds of thirds of thirds to thirds (= 81 tiles)
  )
)

tiles <- unlist(level4, recursive = T) # break hierarchical structure
stopifnot(
  length(tiles) == 81 #control
)
# rm(level1, level2, level3, level4); gc()

# controlplot
cols <- c("steelblue", "orange", "darkred", "darkgreen", "pink", "darkgrey", "purple", "brown", "skyblue")
plot(extent)
for (i in seq_along(tiles)) {
  plot(tiles[[i]], add = TRUE, col = rep(cols, 10)[i])
}

# get bboxes from tiles
# (following backend functions work with boundingboxes, not with the vectors themselves)
bboxes <- vector("list", length = length(tiles))
for(i in seq_along(tiles)){
  e <- ext(tiles[[i]]) # extract extent of the tile
  tile_extent <- list( # crate list of extent limits
    west  = as.numeric(xmin(e)),
    south = as.numeric(ymin(e)),
    east  = as.numeric(xmax(e)),
    north = as.numeric(ymax(e))
  )
  bboxes[[i]] <- tile_extent
}
# bboxes

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# BACKEND PROCESSES

# connect to openEO backend
connection <- connect("https://openeo.dataspace.copernicus.eu")
login()

# create processes obj
p <- openeo::processes()

# build process graph for backend
results <- vector(mode = "list", length = length(bboxes)) # empty list for each tile/boundingbox

# loop over all bboxes
for(i in seq_along(bboxes)){
  
  # SCL mask
  scl <- p$load_collection(
    id = "SENTINEL2_L2A",
    spatial_extent = bboxes[[i]],
    temporal_extent = temp_extent,
    bands = SCL 
  )
  
  scl_mask <- p$to_scl_dilation_mask(
    data = scl # default parameters used
  )
  
  # load optical bands (similar as for SCL mask)
  rest <- p$load_collection(
    id = "SENTINEL2_L2A",
    spatial_extent = bboxes[[i]],
    temporal_extent = temp_extent,
    bands = focal_bands
  )
  
  # mask focal bands with scl mask
  rest_masked <- p$mask(
    data = rest,
    mask = scl_mask
  )
  
  # aggregate spatialy
  # aggregate bands with finer resolution (10*10 m) to common resolution (20*20 m)
  dvacka <- p$resample_spatial(
    data = rest_masked,
    projection = 3035, # ETRS89-extended / LAEA Europe, EPSG: 3035
    resolution = 20, # 20*20 m
    method = "bilinear"
  )
  
  # define format of the results
  out <- p$save_result(
    data = dvacka,
    format = "NetCDF"
  )
  
  results[[i]] <- out
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# REGISTER & START JOBS

###### DONT RUN THIS ############ DONT RUN THIS ######
###### DONT RUN THIS ############ DONT RUN THIS ######
###### DONT RUN THIS ############ DONT RUN THIS ######

# estimated costs: >10000 credits (in the case of my temp & spat extent)

# jobaky <- vector("list", length(results)) # prepare empty list
# for(i in seq_along(jobaky)){
#
#   cat("Strating job", i, "\n")
#   
#   # register job on the backend
#   jobaky[[i]] <- create_job(results[[i]], title = sprintf("SCLmasked_ALL_%02d_2022", i))
#   
#   # start job
#   start_job(jobaky[[i]])
# }

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# PROGRESS CONTROL

jobz_names <- list_jobs() %>%
  names()
jobz_names

jobz_df <- list_jobs() %>%
  as_tibble()
print(jobz_df, n = 100)

# log_job()
# describe_job()

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# DOWNLOAD RESULTS

# check dir_out and which jobs you would like to download (head of the for cycle)
# !!! could take a lot of time and internet data !!!

# for(i in seq_along(jobz_df)){
#   id <- unlist(jobz_df[i,"id"])
#   name <- paste0(dir_out ,unlist(jobz_df[i, "title"]), ".nc")
#   cat("Downloading tile", name, "\n")
#   downname <- download_results(id, folder = dir_out)
#   file.rename(unlist(downname), name)
# }

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #