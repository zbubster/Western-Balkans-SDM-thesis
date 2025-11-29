## ESA world cover

esa_dir <- "/media/zbub/DATA/terrascope_world_cover/WORLDCOVER"

files <- list.files(
  path = esa_dir,
  pattern = "Map\\.tif$",
  full.names = TRUE
)
files

rs <- vector("list", length = length(files))
for(i in seq_along(files)){
  rs[[i]] <- rast(files[i])
}

x <- rast(files[1])
plot(x)
crs(x) == crs(extent)
x <- project(x, extent)

cuts <- lapply(files, function(f) {
  r <- rast(f)
  r <- project(r, extent)
  r <- crop(r, extent)
  r <- mask(r, extent)
  r
})






merged <- do.call(mosaic, rs)

writeRaster(merged, )