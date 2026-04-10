# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# SAC processing
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Config

# data dir
dir_in  <- here::here("data", "occurence", "_ANALYSIS_FOCAL_", "_FILTER_")
# results dir
dir_out <- here::here("data", "occurence", "_ANALYSIS_FOCAL_", "_SAC_CV_")
# results info dir
dir_sac_info <- here::here("data", "occurence", "_ANALYSIS_FOCAL_", "_SAC_INFO_")

# create
if (!base::dir.exists(dir_out)) {
  base::dir.create(dir_out, recursive = TRUE)
}
if (!base::dir.exists(dir_sac_info)) {
  base::dir.create(dir_sac_info, recursive = TRUE)
}
# load function
source(here::here("scripts", "fun_SAC.R"))

# load background for plottinig
raster <- terra::rast(here::here("data", "__COMPATIBILITY__", "MASK", "m500_1000.tif"))

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# list all .rds files
rds_files <- base::list.files(
  path = dir_in,
  pattern = "\\.rds$",
  full.names = TRUE
)

# load all RDS files and prepare SAC info files
spec_list <- list()
sac_info_files <- list()
rds_names <- tools::file_path_sans_ext(base::basename(rds_files))

for(i in seq_along(rds_files)){
  # load RDS
  spec_list[[i]] <- base::readRDS(rds_files[[i]])
  names(spec_list)[[i]] <- rds_names[i]
  # prepare SAC info path
  sac_info_files[[i]] <- here::here(dir_sac_info, paste0(rds_names[i], "_SAC_info.rds"))
  names(sac_info_files)[[i]] <- rds_names[i]
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Manually run spatial_cv function

# current
xxx <- "GD_1000m"
xxx <- "GD_500m"
xxx <- "GD_200m"
xxx <- "GD_100m"
xxx <- "GD_20m"

xxx <- "GT_1000m"
xxx <- "GT_500m"
xxx <- "GT_200m"
xxx <- "GT_100m"
xxx <- "GT_20m"

xxx <- "SB_1000m"
xxx <- "SB_500m"
xxx <- "SB_200m"
xxx <- "SB_100m"
xxx <- "SB_20m"

xxx <- "PK_1000m"
xxx <- "PK_500m"
xxx <- "PK_200m"
xxx <- "PK_100m"
xxx <- "PK_20m"

xxx <- "PO_1000m"
xxx <- "PO_500m"
xxx <- "PO_200m"
xxx <- "PO_100m"
xxx <- "PO_20m"

xxx <- "PP_1000m"
xxx <- "PP_500m"
xxx <- "PP_200m"
xxx <- "PP_100m"
xxx <- "PP_20m"


# load selected spec and matching SAC info
s <- spec_list[[xxx]]
i <- sac_info_files[[xxx]]
i

base::set.seed(722085415)

grDevices::pdf(file = file.path(dir_sac_info, paste0(xxx, ".pdf")), title = xxx)
# run with parameters that you can change each time
spec_out <- spatial_cv(
  spec = s,
  sac_info_rds = i,
  k = 7,
  selection = "random",
  iteration = 800,
  crs_epsg = 3035,
  plot_sa = TRUE,
  plot_hex = TRUE,
  progress = TRUE,
  background = raster
)
grDevices::dev.off()

# save result under the same name as input file
out_file <- base::file.path(dir_out, paste0(xxx, ".rds"))
base::saveRDS(spec_out, out_file)
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #