# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Move datasets for analysis
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

full_extent <- here::here("data", "__COMPATIBILITY__", "STACKS", "__STACKS__", "coastline_masked")
elevation_extent <- here::here("data", "__COMPATIBILITY__", "STACKS", "__STACKS_MASKED__")
occurence <- here::here("data", "occurence", "_ANALYSIS_FOCAL_", "_SAC_CV_")

analysis_dir <- here::here("data", "__ANALYSIS__")
full_dir <- here::here(analysis_dir, "FULL")
elev_dir <- here::here(analysis_dir, "ELEV")
occ_dir  <- here::here(analysis_dir, "OCC")

if(!dir.exists(analysis_dir)) dir.create(analysis_dir)
if(!dir.exists(full_dir)) dir.create(full_dir)
if(!dir.exists(elev_dir)) dir.create(elev_dir)
if(!dir.exists(occ_dir)) dir.create(occ_dir)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# FULL

files_full <- list.files(full_extent, full.names = TRUE)
dest_full <- file.path(full_dir, basename(files_full))
file.rename(from = files_full, to = dest_full)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# ELEV

files_elev <- list.files(elevation_extent, full.names = TRUE)
dest_elev <- file.path(elev_dir, basename(files_elev))
file.rename(from = files_elev, to = dest_elev)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# OCC

files_occ <- list.files(occurence, full.names = TRUE)
dest_occ <- file.path(occ_dir, basename(files_occ))
file.rename(from = files_occ, to = dest_occ)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #