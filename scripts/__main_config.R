# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Main config
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
library(here)

source(here("scripts", "knihovnik.R"))
knihovnik(rlang, terra, sf, tidyverse, stars, ggplot2, biomod2, stringr, parallelly, purrr, maptiles, blockCV, usdm, openeo, collinear, corrplot, vegan)

# terraOptions()
# terraOptions(
#   memmax = 50,
#   todisk = TRUE,
#   progress = 1
# )

#RColorBrewer
#viridis