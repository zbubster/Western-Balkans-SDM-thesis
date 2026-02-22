# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# OCCURENCE ‒ manage Phyteumas
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

phy_orb_path <- here("data", "occurence", "__analysis__", "phy_orbiculare.gpkg")
phy_pseudorb_path <- here("data", "occurence", "__analysis__", "phy_pseudorbiculare.gpkg")

phy_orb <- sf::st_read(phy_orb_path)
phy_pseudorb <- sf::st_read(phy_pseudorb_path)
