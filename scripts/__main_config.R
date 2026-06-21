# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Main config
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
library(here)

source(here("scripts", "knihovnik.R"))
knihovnik(terra, sf, tidyverse, ggplot2, stringr,
          parallelly, parallel, purrr, maptiles,
          blockCV, openeo, collinear,
          corrplot, rnaturalearth, dplyr,
          flexsdm, foreach, doParallel,
          Hmisc, gbm, mgcv, rpart, earth, ranger,
          maps, spatialEco, readr, tidyr, tibble
)

# remotes::install_github("sjevelazco/flexsdm@HEAD")

tmp_dir <- "../terra_tmp"
if(!dir.exists(tmp_dir)) dir.create(tmp_dir)

terraOptions(
  tempdir = tmp_dir,
  todisk = TRUE,
  progress = 1
)

#RColorBrewer
#viridis