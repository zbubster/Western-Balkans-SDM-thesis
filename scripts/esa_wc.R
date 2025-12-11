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
