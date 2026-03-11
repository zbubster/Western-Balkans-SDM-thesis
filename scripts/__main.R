# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Main
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
library(here)

source(here("scripts", "knihovnik.R"))
knihovnik(rlang, terra, sf, tidyverse, stars, ggplot2, biomod2, stringr, parallelly, purrr, maptiles, blockCV, usdm, openeo, collinear, corrplot)

terraOptions()
terraOptions(
  memmax = 90,
  todisk = TRUE,
  progress = 1
)

#RColorBrewer
#viridis