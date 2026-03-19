# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Prepare raster stacks
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

selected_rds <- here::here("data", "predictors_collinearity", "results")

TFtable <- read.csv(file = file.path(selected_rds, "selected_truefalse.csv"))

TFtable %>%
  select()
  filter(species == "GT")
TFtable %>%
  filter(is.na(species))
