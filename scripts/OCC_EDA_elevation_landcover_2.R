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

dem <- terra::rast(here("data", "DEM30_mosaic_cropped.tif"))

# Elevation pro body ------------------------------------------------------

ex <- terra::extract(dem, terra::vect(pts_uniq))
# terra::extract() vrací data.frame: 1. sloupec ID, 2. sloupec hodnota rastru
z_pts <- ex[[2]]
z_pts <- z_pts[is.finite(z_pts)]

# Elevation pro DEM: vzorek cca 2 % -------------------------------------

# počet buněk (včetně NA)
ncell_dem <- terra::ncell(dem)

# cíl: ~2 % buněk
size_2pc <- base::as.integer(base::round(ncell_dem * 0.02))
size_2pc

# vzorkuj jen platné (na.rm = TRUE); pokud je NA hodně, reálný podíl z platných bude vyšší
# (ale pořád je to náhodný vzorek z dostupných výšek)
set.seed(1)
dem_samp <- terra::spatSample(
  x = dem,
  size = size_2pc,
  method = "random",
  na.rm = TRUE,
  as.df = TRUE
)

z_dem <- dem_samp[[1]]
z_dem <- z_dem[is.finite(z_dem)]

# Density curves ----------------------------------------------------------

d_dem <- stats::density(z_dem)
d_pts <- stats::density(z_pts)

# Histogram DEM + density points (škálovaná na counts) --------------------

# histogram parametry (binning podle DEM)
h_dem <- graphics::hist(z_dem, breaks = "FD", plot = FALSE)
bin_w <- h_dem$breaks[2] - h_dem$breaks[1]

# vykresli histogram DEM
graphics::hist(
  z_dem,
  breaks = h_dem$breaks,
  main = base::paste0(
    "DEM histogram & observation density\n",
    base::sprintf(
      "DEM sample: %s (~2%% of total %s cells), Points: %d",
      format(length(z_dem), big.mark = " "),
      format(ncell_dem, big.mark = " "),
      length(z_pts)
    )
  ),
  xlab = "Elevation [m]",
  ylab = "DEM freq",
  border = "grey40",
  ylim = c(0, 150000)
)

# overlay density křivky bodů – přeškálování na counts histogramu
# density má jednotky 1/m, násobíme n_dem * bin_w => očekávané počty v binu
graphics::lines(
  d_pts$x,
  d_pts$y * length(z_dem) * bin_w,
  lwd = 3,
  col = "firebrick2"
)

graphics::legend(
  "topright",
  legend = c("DEM", "Observations density curve"),
  lwd = c(NA, 3),
  lty = c(NA, 1),
  pch = c(15, NA),
  pt.cex = 2,
  col = c("grey40", "firebrick2"),
  bty = "n"
)


# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# 10 Tree cover 
# 20 Shrubland 
# 30 Grassland 
# 40 Cropland 
# 50 Built-up 
# 60 Bare/sparse vegetation 
# 70 Snow and ice 
# 80 Permanent water bodies 
# 90 Herbaceous wetland 
# 95 Mangroves 
# 100 Moss and lichen

wc <- terra::rast(here("data", "WORLDCOVER", "ESA_WC_3035_20.tiff"))
ex_wc <- terra::extract(wc, terra::vect(pts_uniq))

# ex_wc už máš z terra::extract()
wc_code <- ex_wc$ESA_WorldCover_10m_2021_v200_N36E018_Map
wc_code <- wc_code[is.finite(wc_code)]

# legenda ESA WorldCover (v200)
wc_lut <- data.frame(
  code = c(10,20,30,40,50,60,70,80,90,95,100),
  class = c(
    "Tree cover",
    "Shrubland",
    "Grassland",
    "Cropland",
    "Built-up",
    "Bare / sparse vegetation",
    "Snow and ice",
    "Permanent water bodies",
    "Herbaceous wetland",
    "Mangroves",
    "Moss and lichen"
  ),
  stringsAsFactors = FALSE
)

# četnosti
tab <- as.data.frame(table(wc_code), stringsAsFactors = FALSE)
names(tab) <- c("code", "n")
tab$code <- as.integer(tab$code)

tab <- dplyr::left_join(tab, wc_lut, by = "code") %>%
  dplyr::mutate(
    class = dplyr::if_else(is.na(class), paste0("Unknown (", code, ")"), class),
    pct = 100 * n / sum(n)
  ) %>%
  dplyr::arrange(dplyr::desc(n))

# barplot (hezký, čitelný)
op <- graphics::par(mar = c(10, 5, 5, 3) + 0.1)

bp <- graphics::barplot(
  height = tab$n,
  names.arg = paste0(tab$class),
  las = 2,
  cex.names = 0.85,
  ylab = "Count of observations",
  main = paste0("ESA WorldCover classes at observation locations\n",
                sprintf("(n = %d unique geometries)", length(wc_code))),
  border = NA,
  col = c("lightgreen", "darkgreen", "orange", "grey", "red", "yellow3", "blue")
)

# procenta nad sloupce
graphics::text(
  x = bp,
  y = tab$n,
  labels = sprintf("%.1f%%", tab$pct),
  pos = 3,
  cex = 0.85
)

graphics::text(
  x = bp[1],
  y = tab$n[1]-50,
  labels = sprintf("%.1f%%", tab$pct[1]),
  pos = 3,
  cex = 0.85
)

graphics::par(op)

