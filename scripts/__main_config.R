# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Main config
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
library(here)

packages <- c(
  "tidyverse", "sf", "terra", "stars", "ggplot2",
  "biomod2", "remotes", "stringr", "parallelly", "parallel",
  "purrr", "maptiles", "blockCV", "usdm", "openeo", "collinear",
  "corrplot", "vegan", "rnaturalearth", "flexsdm", "foreach", "doParallel"
)

for (pkg in packages) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    install.packages(pkg, dependencies = TRUE)
    library(pkg, character.only = TRUE)
  }
}

source(here("scripts", "knihovnik.R"))
knihovnik(rlang, terra, sf, tidyverse,
          stars, ggplot2, biomod2, stringr,
          parallelly, parallel, purrr, maptiles,
          blockCV, usdm, openeo, collinear,
          corrplot, vegan, rnaturalearth,
          flexsdm, foreach, doParallel)

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