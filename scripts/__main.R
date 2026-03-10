# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Main
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
library(here)

source(here("scripts", "knihovnik.R"))
knihovnik(rlang, terra, sf, dplyr, stars, ggplot2, tidyr, openeo, biomod2, stringr, parallelly, purrr, maptiles, blockCV, usdm)

terraOptions(
  memmax = 90,
  todisk = TRUE,
  progress = 1
)

#RColorBrewer
#viridis