## ESA world cover

esa_dir <- "/media/zbub/DATA/terrascope_world_cover/WORLDCOVER"
extent <- vect("data/extent_raw.gpkg")

files <- list.files(
  path = esa_dir,
  pattern = "Map\\.tif$",
  full.names = TRUE
)
files

# rs <- vector("list", length = length(files))
# for(i in seq_along(files)){
#   rs[[i]] <- rast(files[i])
# }

# x <- rast(files[2])
# plot(x)
# crs(x) == crs(extent)
# x <- project(x, extent)

# cuts <- lapply(files, function(f) {
#   r <- rast(f)
#   r <- project(r, extent)
#   r <- crop(r, extent)
#   r <- mask(r, extent)
#   r
# })

# load SpatRasterCollection
rc <- terra::sprc(files)

r <- terra::mosaic(rc)
extent <- vect("data/extent_raw.gpkg")
aoi <- terra::project(extent, terra::crs(rc[1]))
r_croped <- terra::crop(r, extent)
r_masked <- terra::mask(r_croped, extent)
r_final <- terra::project(r_masked, terra::crs(extent))





for(i in seq_along(files)){
  print(paste0("R_", i, "_load"))
  r <- rast(files[i])
  print(paste0("R_", i, "_project"))
  r <- project(r, extent)
  print(paste0("R_", i, "_crop"))
  r <- crop(r, extent)
  print(paste0("R_", i, "_mask"))
  r <- mask(r, extent)
  n <- paste0("ESA_WC_", i, ".tif")
  print(paste0("R_", i, "_write"))
  writeRaster(r, filename = paste0("/media/zbub/DATA/terrascope_world_cover/WORLDCOVER/", n))
  print("GC")
  rm(r, n); gc()
}

x <- rast("/media/zbub/DATA/terrascope_world_cover/WORLDCOVER/ESA_WC_5.tif")
plot(x)
x

# merge

wc_dir <- "/media/zbub/DATA/WORLDCOVER"

files <- list.files(
  path = wc_dir,
  pattern = "\\.tif$",
  full.names = TRUE
)
files

# load SpatRasterCollection
rc <- terra::sprc(files)

# ref = první soubor jako šablona
ref <- terra::rast(files[1])

info <- do.call(
  rbind,
  lapply(files, function(f) {
    r <- terra::rast(f)
    data.frame(
      file   = basename(f),
      crs_ok = terra::same.crs(r, ref),
      res_x  = terra::res(r)[1],
      res_y  = terra::res(r)[2],
      org_x  = terra::origin(r)[1],
      org_y  = terra::origin(r)[2]
    )
  })
)

info

