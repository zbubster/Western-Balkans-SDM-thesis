# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# SAC processing
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Config

# data dir
dir_in  <- here::here("data", "occurence", "_ANALYSIS_FOCAL_")
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

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Gentiana tergestina

# load RDS, info out
s <- base::readRDS(file.path(dir_in, "GT.rds"))
i <- here::here(file.path(dir_sac_info, "GT_sac.rds"))

base::set.seed(722085415)

# process
spec_out <- spatial_cv(
  spec = s,
  sac_info_rds = i,
  k = 8,
  selection = "random",
  iteration = 100,
  crs_epsg = 3035,
  plot_sa = TRUE,
  progress = TRUE
)

# write result
out_file <- base::file.path(dir_out, paste0(base::basename(s$species), ".rds"))
base::saveRDS(spec_out, out_file)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Saxifraga blavii

# load RDS, info out
s <- base::readRDS(file.path(dir_in, "SB.rds"))
i <- here::here(file.path(dir_sac_info, "SB_sac.rds"))

base::set.seed(722085415)

# process
spec_out <- spatial_cv(
  spec = s,
  sac_info_rds = i,
  k = 8,
  selection = "random",
  iteration = 100,
  crs_epsg = 3035,
  plot_sa = TRUE,
  progress = TRUE
)

# write result
out_file <- base::file.path(dir_out, paste0(base::basename(s$species), ".rds"))
base::saveRDS(spec_out, out_file)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Primula kitaibeliana

# load RDS, info out
s <- base::readRDS(file.path(dir_in, "PK.rds"))
i <- here::here(file.path(dir_sac_info, "PK_sac.rds"))

base::set.seed(722085415)

# process
spec_out <- spatial_cv(
  spec = s,
  sac_info_rds = i,
  k = 8,
  selection = "random",
  iteration = 100,
  crs_epsg = 3035,
  plot_sa = TRUE,
  progress = TRUE
)

# write result
out_file <- base::file.path(dir_out, paste0(base::basename(s$species), ".rds"))
base::saveRDS(spec_out, out_file)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Phyteuma orbiculare

# load RDS, info out
s <- base::readRDS(file.path(dir_in, "PO.rds"))
i <- here::here(file.path(dir_sac_info, "PO_sac.rds"))

base::set.seed(722085415)

# process
spec_out <- spatial_cv(
  spec = s,
  sac_info_rds = i,
  k = 8,
  selection = "random",
  iteration = 100,
  crs_epsg = 3035,
  plot_sa = TRUE,
  progress = TRUE
)

# write result
out_file <- base::file.path(dir_out, paste0(base::basename(s$species), ".rds"))
base::saveRDS(spec_out, out_file)


# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Phyteuma pseudorbiculare

# load RDS, info out
s <- base::readRDS(file.path(dir_in, "PP.rds"))
i <- here::here(file.path(dir_sac_info, "PP_sac.rds"))

base::set.seed(722085415)

# process
spec_out <- spatial_cv(
  spec = s,
  sac_info_rds = i,
  k = 8,
  selection = "random",
  iteration = 100,
  crs_epsg = 3035,
  plot_sa = TRUE,
  progress = TRUE
)

# write result
out_file <- base::file.path(dir_out, paste0(base::basename(s$species), ".rds"))
base::saveRDS(spec_out, out_file)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #