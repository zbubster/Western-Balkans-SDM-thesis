# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Align Sentinel 2 rasters
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

library(terra)

# vstupy
in_dir <- "/media/zbub/DATA/Sentinel2_medoids/"
files <- list.files(in_dir, pattern="\\.tif$", full.names=TRUE)

r_ref <- rast(files[42])          # ref tile
r_ref <- rast(files[21])
r_ref <- rast(files[59])

# union extent všech tile (jen metadata)
ext_all <- Reduce(terra::union, lapply(files, function(f) ext(rast(f))))

# template raster
template <- extend(r_ref[[1]], ext_all)  # 1. band

# --- volba: zhrub mřížku pro vizuální kontrolu ---
# faktor 100 znamená: vezmi každý 100. pixel v X i Y (=> 10 m -> 1 km)
fact <- 100
template_coarse <- aggregate(template, fact=fact)

# polygon grid
# grid_poly <- as.polygons(template_coarse)
# names(grid_poly) <- "cell_id"

# centroids
grid_pts <- as.points(template_coarse, na.rm = F)
names(grid_pts) <- "cell_id"

# export do GeoPackage
# writeVector(grid_poly, "ref_grid_coarse_poly.gpkg", layer="grid_poly", overwrite=TRUE)
# writeVector(grid_pts,  "42_grid_coarse_pts.gpkg", layer="grid_points", overwrite=TRUE)
# writeVector(grid_pts,  "21_grid_coarse_pts.gpkg", layer="grid_points", overwrite=TRUE)
# writeVector(grid_pts,  "59_grid_coarse_pts.gpkg", layer="grid_points", overwrite=TRUE)





library(terra)

r_ref <- rast(files[42])

# pomocná funkce: spočítej offset originu v jednotkách CRS
grid_offset <- function(r, ref) {
  # porovnání rozlišení (můžeš tolerovat malý rozdíl)
  res_r  <- res(r)
  res_rf <- res(ref)
  
  # "origin" v terra: není přímo getter, ale dá se odvodit z extentu a res
  # x origin ~ xmin mod res; podobně y
  # (pro stabilitu používám zbytek po dělení rozlišením)
  ox  <- (xmin(r)  %% res_r[1])
  oy  <- (ymin(r)  %% res_r[2])
  ox0 <- (xmin(ref) %% res_rf[1])
  oy0 <- (ymin(ref) %% res_rf[2])
  
  dx <- abs(ox - ox0)
  dy <- abs(oy - oy0)
  
  # lepší je brát i "druhou stranu" periody (např. rozdíl 19.9 m při res 20 m je vlastně 0.1 m)
  dx <- pmin(dx, res_r[1] - dx)
  dy <- pmin(dy, res_r[2] - dy)
  
  c(dx = dx, dy = dy)
}

# spočítej offset pro každý tile
offs <- lapply(files, function(f) {
  r <- rast(f)
  o <- grid_offset(r, r_ref)
  data.frame(file = basename(f), dx = o["dx"], dy = o["dy"])
})

offs <- do.call(rbind, offs)
offs$shift_m <- sqrt(offs$dx^2 + offs$dy^2)

hist(offs$dx, breaks=20, main="dx (m) shift", xlab="dx")
hist(offs$dy, breaks=20, main="dy (m) shift", xlab="dy")

# udělej z toho vektor bodů (centroid extentu tile) pro mapu v QGIS
centroids <- lapply(files, function(f) {
  r <- rast(f)
  xy <- c((xmin(r)+xmax(r))/2, (ymin(r)+ymax(r))/2)
  vect(matrix(xy, ncol=2), type="points", crs=crs(r))
})
centroids <- do.call(rbind, centroids)

centroids <- cbind(centroids, offs)
writeVector(centroids, "tile_grid_offset.gpkg", layer="offset_points", overwrite=TRUE)
