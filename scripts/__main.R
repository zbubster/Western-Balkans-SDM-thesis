# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Main
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
library(here)

source(here("scripts", "knihovnik.R"))
knihovnik(terra, sf, dplyr, stars, ggplot2, tidyr, openeo, biomod2, paisaje, parallel)
library(parallel)

#RColorBrewer
#viridis

