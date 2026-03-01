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

# path to data
gen_ter_path <- here("data", "occurence", "__analysis__", "gen_tergestina.gpkg")
sax_bla_path <- here("data", "occurence", "__analysis__", "sax_blavii.gpkg")
prim_kit_path <- here("data", "occurence", "__analysis__", "pri_kitaibeliana.gpkg")
phy_orb_path <- here("data", "occurence", "__analysis__", "phy_orbiculare.gpkg")
phy_pseudorb_path <- here("data", "occurence", "__analysis__", "phy_pseudorbiculare.gpkg")

# load data
GT <- sf::st_read(gen_ter_path)
SB <- sf::st_read(sax_bla_path)
PK <- sf::st_read(prim_kit_path)
PO <- sf::st_read(phy_orb_path)
PP <- sf::st_read(phy_pseudorb_path)

# output dir
dir_out <- here("data", "occurence", "_ANALYSIS_FOCAL_")
if (!dir.exists(dir_out)) dir.create(dir_out, recursive = TRUE)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Phyteumas
# drop TN data

# - # - # - # - # - # - # - # - # - # - # - # - #
# Phyteuma pseudorbiculare
# n <- "Phyteuma pseudorbiculare"
# o <- PP
# oo <- "PP.rds"
# - # - # - # - # - # - # - # - # - # - # - # - #
#Phyteuma orbiculare
# n <- "Phyteuma orbiculare"
# o <- PO
# oo <- "PO.rds"

o %>%
  dplyr::filter(source == "FW") %>%
  dplyr::transmute(
    P_A,
    X = sf::st_coordinates(geom)[, 1],
    Y = sf::st_coordinates(geom)[, 2]
  ) %>%
  sf::st_drop_geometry() %>%
  dplyr::arrange(dplyr::desc(P_A)) %>%
  {
    list(
      species = n,
      observations = base::as.numeric(.$P_A),
      coor = base::as.data.frame(.[, c("X", "Y"), drop = FALSE])
    )
  } %>%
  base::saveRDS(file.path(dir_out, oo))

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Gentiana tergestina, Saxifraga blavii, Primula kitaibeliana
# keep TN data

# - # - # - # - # - # - # - # - # - # - # - # - #
# n <- "Gentiana tergestina"
# o <- GT
# oo <- "GT.rds"
# - # - # - # - # - # - # - # - # - # - # - # - #
# n <- "Saxifraga blavii"
# o <- SB
# oo <- "SB.rds"
# - # - # - # - # - # - # - # - # - # - # - # - #
# n <- "Primula kitaibeliana"
# o <- PK
# oo <- "PK.rds"

o %>%
  dplyr::transmute(
    P_A,
    X = sf::st_coordinates(geom)[, 1],
    Y = sf::st_coordinates(geom)[, 2]
  ) %>%
  sf::st_drop_geometry() %>%
  dplyr::arrange(dplyr::desc(P_A)) %>%
  {
    list(
      species = n,
      observations = base::as.numeric(.$P_A),
      coor = base::as.data.frame(.[, c("X", "Y"), drop = FALSE])
    )
  } %>%
  base::saveRDS(file.path(dir_out, oo))

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #