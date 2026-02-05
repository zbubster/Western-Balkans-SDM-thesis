x <- read.csv("data/occurence/counts.csv")
x
library(dplyr)
library(terra)
library(sf)
library(maptiles)


x2 <- x %>%
  dplyr::arrange(desc(pres))

genter <- st_read("data/occurence/__analysis__/gen_tergestina.gpkg")
phyorb <- st_read("data/occurence/__analysis__/phy_orbiculare.gpkg")
prikit <- st_read("data/occurence/__analysis__/pri_kitaibeliana.gpkg")
camvel <- st_read("data/occurence/__analysis__/cam_velebitica.gpkg")
saxbla <- st_read("data/occurence/__analysis__/sax_blavii.gpkg")
camalb <- st_read("data/occurence/__analysis__/cam_albanica.gpkg")
genutri <- st_read("data/occurence/__analysis__/gen_utriculosa.gpkg")
gendin <- st_read("data/occurence/__analysis__/gen_dinarica.gpkg")

plot(genter[genter$P_A == 1,"species"], pch = 16)
genter$species

extent <- st_read("data/extent_raw.gpkg")

plot(extent)

ext_wgs <- sf::st_transform(extent, 4326)

tiles <- maptiles::get_tiles(
  x = ext_wgs,
  provider = "OpenStreetMap",
  zoom = 12,
  crop = TRUE,
  project = TRUE
)

leaflet::leaflet() |>
  leaflet::addRasterImage(tiles, opacity = 1) |>
  leaflet::addPolygons(data = ext_wgs, fill = FALSE, weight = 3) |>
  leaflet::addControl(maptiles::get_credit(tiles), position = "bottomright")
