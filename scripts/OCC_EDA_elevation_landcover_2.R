# Load data ---------------------------------------------------------------

base_dir <- "data/occurence/__analysis__"

files <- base::list.files(base_dir, pattern = "\\.gpkg$", full.names = TRUE)
stopifnot(length(files) > 0)

lst <- base::lapply(files, function(f) sf::st_read(f, quiet = TRUE))

crs_ref <- sf::st_crs(lst[[1]])
lst <- base::lapply(lst, function(x) sf::st_transform(x, crs_ref))

pts_all <- dplyr::bind_rows(lst)

# robustní deduplikace geometrie
pts_uniq <- pts_all %>%
  dplyr::mutate(.wkt = sf::st_as_text(sf::st_geometry(.))) %>%
  dplyr::distinct(.wkt, .keep_all = TRUE) %>%
  dplyr::select(-.wkt)

dem <- terra::rast("/media/zbub/DATA/DEM/DEM30_mosaic_cropped.tif")

# Elevation pro body ------------------------------------------------------

ex <- terra::extract(dem, terra::vect(pts_uniq))
# terra::extract() vrací data.frame: 1. sloupec ID, 2. sloupec hodnota rastru
z_pts <- ex[[2]]
z_pts <- z_pts[is.finite(z_pts)]

# Elevation pro DEM: vzorek cca 10 % -------------------------------------

# počet buněk (včetně NA)
ncell_dem <- terra::ncell(dem)

# cíl: ~10 % buněk
size_10pc <- base::as.integer(base::round(ncell_dem * 0.10))

# vzorkuj jen platné (na.rm = TRUE); pokud je NA hodně, reálný podíl z platných bude vyšší
# (ale pořád je to náhodný vzorek z dostupných výšek)
set.seed(1)
dem_samp <- terra::spatSample(
  x = dem,
  size = size_10pc,
  method = "random",
  na.rm = TRUE,
  as.df = TRUE
)

z_dem <- dem_samp[[1]]
z_dem <- z_dem[is.finite(z_dem)]

# Density curves ----------------------------------------------------------

d_dem <- stats::density(z_dem)
d_pts <- stats::density(z_pts)

# Plot --------------------------------------------------------------------

graphics::plot(
  d_dem,
  main = base::paste0(
    "Elevation density curves\n",
    base::sprintf("DEM sample: %s (~10%% of %s cells), Points: %d",
                  format(length(z_dem), big.mark = " "),
                  format(ncell_dem, big.mark = " "),
                  length(z_pts))
  ),
  xlab = "Elevation [m]",
  ylab = "Density"
)

graphics::lines(d_pts, lwd = 3)

graphics::legend(
  "topright",
  legend = c("DEM (sampled)", "Observations (points)"),
  lwd = c(1, 3),
  bty = "n"
)
