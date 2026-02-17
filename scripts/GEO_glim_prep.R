# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# GLIM preparation
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Input layer was created in QGIS.

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

glim_path_in <- here("data", "GEO", "54012_glim_clipped.gpkg")
glim_path_out <- here("data", "GEO", "glim.gpkg")
# read layer
v <- sf::st_read(glim_path_in)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# GLIM key
xx_to_geo <- c(
  su = "Unconsolidated sediments",
  ss = "Siliciclastic sedimentary rocks",
  py = "Pyroclastics",
  sm = "Mixed sedimentary rocks",
  sc = "Carbonate sedimentary rocks",
  ev = "Evaporites",
  va = "Acid volcanic rocks",
  vi = "Intermediate volcanic rocks",
  vb = "Basic volcanic rocks",
  pa = "Acid plutonic rocks",
  pi = "Intermediate plutonic rocks",
  pb = "Basic plutonic rocks",
  mt = "Metamorphic rocks",
  wb = "Water Bodies",
  ig = "Ice and Glaciers",
  nd = "No Data"
)

# create collumn with full name of bedrock
v$geo_full <- unname(xx_to_geo[as.character(v$xx)])

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# simplified key: https://doi.org/10.1002/ecm.1433
geo_to_simple <- c(
  "Carbonate sedimentary rocks"    = "Calcareous",
  "Basic plutonic rocks"           = "Calcareous",
  "Basic volcanic rocks"           = "Calcareous",
  "Unconsolidated sediments"       = "Mixed",
  "Mixed sedimentary rocks"        = "Mixed",
  "Pyroclastics"                   = "Mixed",
  "Evaporites"                     = "Mixed",
  "Intermediate plutonic rocks"    = "Mixed",
  "Intermediate volcanic rocks"    = "Mixed",
  "Siliciclastic sedimentary rocks"= "Siliceous",
  "Metamorphic rocks"              = "Siliceous",
  "Acid plutonic rocks"            = "Siliceous",
  "Acid volcanic rocks"            = "Siliceous"
)

# simplified litho key
v$geo_simple <- unname(geo_to_simple[as.character(v$geo_full)])

# no data handling
v$geo_simple[is.na(v$geo_simple) & v$geo_full %in% c("Water Bodies","Ice and Glaciers","No Data")] <- "Other"

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# select only desired columns
v_out <- v %>%
  select(OBJECTID, geo_full, geo_simple, glim_lvl1 = xx, IDENTITY_, geom)

# write result
sf::st_write(v_out, glim_path_out, delete_dsn = T)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #