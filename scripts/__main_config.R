# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Main config
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
library(here)

source(here("scripts", "knihovnik.R"))
knihovnik(rlang, terra, sf, tidyverse,
          stars, ggplot2, biomod2, stringr,
          parallelly, purrr, maptiles,
          blockCV, usdm, openeo, collinear,
          corrplot, vegan, rnaturalearth,
          flexsdm)

remotes::install_github("sjevelazco/flexsdm@HEAD")

tmp_dir <- "../terra_tmp"
if(!dir.exists(tmp_dir)) dir.create(tmp_dir)

terraOptions(
  tempdir = tmp_dir,
  todisk = TRUE,
  progress = 1
)

#RColorBrewer
#viridis