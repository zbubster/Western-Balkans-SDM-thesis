# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Occurence EDA, elevation
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Load data

# data dir
base_dir <- "data/occurence/__analysis__"

# get filenames and species names (from filenames)
files <- base::list.files(base_dir, pattern = "\\.gpkg$", full.names = TRUE)
stopifnot(length(files) > 0)

# načti všechny vrstvy
lst <- lapply(files, function(f) sf::st_read(f))

# CRS sjednoť podle první vrstvy
crs_ref <- sf::st_crs(lst[[1]])
lst <- lapply(lst, function(x) sf::st_transform(x, crs_ref))

# spoj do jedné vrstvy
pts_all <- dplyr::bind_rows(lst)

pts_all

pts_uniq <- pts_all %>%
  dplyr::distinct(geom, .keep_all = TRUE)
pts_uniq

dem <- terra::rast("/media/zbub/DATA/DEM/DEM30_mosaic_cropped.tif")

ex <- terra::extract(dem, pts_uniq)

# set.seed(1)
# area_df <- terra::spatSample(
#   dem,
#   size = 100000,
#   method = "random",
#   na.rm = TRUE,
#   as.df = TRUE
# )
# z_area <- area_df[[1]]
# z_area <- z_area[is.finite(z_area)]

# vektory výšek
z   <- ex$DEM

# očista
z   <- z[is.finite(z)]

# histogram parametry (ať máme šířku binu)
h <- graphics::hist(z, breaks = "FD", plot = FALSE)
bin_w <- h$breaks[2] - h$breaks[1]

# vykreslení histogramu (hlavní)
graphics::hist(
  z,
  breaks = h$breaks,
  main = paste0("Elevation of the observations\n", sprintf("(n = %d unique geometries)", length(z))),
  xlab = "Elevation [m]",
  ylab = "Freq",
  border = "white"
)

# density (škálování na počty v histogramu)
d_all <- stats::density(z)

graphics::lines(d_all$x, d_all$y * length(z)   * bin_w, lwd = 3, col = "firebrick")

graphics::legend(
  "topright",
  legend = "Density curve",
  lwd = 3,
  lty = 1,
  col = "firebrick",
  bty = "n"
)


x <- terra::rast("/media/zbub/DATA/terrascope_world_cover/WORLDCOVER/ESA_WC_4.tif")
x
hist(x)
plot(x)
