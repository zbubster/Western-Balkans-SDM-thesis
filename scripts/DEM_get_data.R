# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Get DEM
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# This script downloads Copernicus 30 m DEM for AOI.
# You have to have CDSE account.

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

dir_out <- "/media/zbub/DATA/DEM"
if (!dir.exists(dir_out)) dir.create(dir_out, recursive = TRUE, showWarnings = FALSE)

# Load extent of AOI

extent <- sf::st_read(here("data", "extent_raw.gpkg"))

# transform to WGS 84
extent <- sf::st_transform(extent, 4326)

# get bbox of extent
e <- terra::ext(extent)
bbox <- list(
  west  = as.numeric(terra::xmin(e)),
  south = as.numeric(terra::ymin(e)),
  east  = as.numeric(terra::xmax(e)),
  north = as.numeric(terra::ymax(e))
)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Backend processes

# connect to openEO backend
connection <- connect("https://openeo.dataspace.copernicus.eu")
login()

# create processes obj
p <- openeo::processes()

#list_collections()
#describe_collection("COPERNICUS_30")

# load collection
dem <- p$load_collection(
  id = "COPERNICUS_30",
  spatial_extent = bbox
)

# create result
out <- p$save_result(
  data = dem,
  format = "GTiff"
)

# crate and start job
job <- create_job(out, title = "COP_DEM30_AOI")
start_job(job)

#list_jobs()

# download result
download_results(
  job,
  folder = dir_out
)
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #