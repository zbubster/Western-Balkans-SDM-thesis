# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# OCCURENCE ‒ focal plants
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# 
# Those plants were selected for further ananlysis:
# 
# Gentiana tergestina
# Saxifraga blavii
# Primula kitaibeliana
# Phyteuma orbiculare
# Phyteuma pseudorbiculare
# 
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Load data

gen_ter_path <- here("data", "occurence", "__analysis__", "gen_tergestina.gpkg")
sax_bla_path <- here("data", "occurence", "__analysis__", "sax_blavii.gpkg")
prim_kit_path <- here("data", "occurence", "__analysis__", "pri_kitaibeliana.gpkg")
phy_orb_path <- here("data", "occurence", "__analysis__", "phy_orbiculare.gpkg")
phy_pseudorb_path <- here("data", "occurence", "__analysis__", "phy_pseudorbiculare.gpkg")

GT <- sf::st_read(gen_ter_path)
SB <- sf::st_read(sax_bla_path)
PK <- sf::st_read(prim_kit_path)
PO <- sf::st_read(phy_orb_path)
PP <- sf::st_read(phy_pseudorb_path)

extent <- sf::st_read(here("data", "extent_raw.gpkg"))

# output dir
dir_out <- here("data", "occurence", "_ANALYSIS_FOCAL_")
if (!dir.exists(dir_out)) dir.create(dir_out, recursive = TRUE)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Phyteumas
# drop TN data


# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #



