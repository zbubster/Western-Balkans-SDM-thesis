# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Align S2 tiles ‒ main workflow
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Settings

terraOptions(progress = 1)
in_dir  <- "/media/zbub/DATA/Sentinel2_medoids/"
out_dir <- "/media/zbub/DATA/Sentinel2_aligned_medoids/"
ref_id  <- 42 # reference tile
pattern <- "\\.tif$"
bandy <- c("B02", "B03", "B04", "B05", "B08", "B8A", "B11", "B12", "TIME")

if(!dir.exists(out_dir)){
  dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Data load, etc

# List files
files <- list.files(in_dir, pattern = pattern, full.names = TRUE); message("Tiles loaded: ", length(files))
stopifnot(length(files) == 81)

# Set reference
ref <- rast(files[ref_id])
ref1 <- ref[[1]]   # one leyer is enought

message("Reference file: ", basename(files[ref_id]))
message("Reference CRS: ", crs(ref1))
message("Reference res: ", paste(res(ref1), collapse = "*"))

# Global extent
ext_all <- Reduce(terra::union, lapply(files, function(f) ext(rast(f))))

# Template ‒ extrapolate reference grid to global extent
template <- extend(ref1, ext_all)
template <- init(template, 1)  # fill template with constant, this should prevent unexpected behavior

# Reference nlyr, rename layers 
ref_nlyr <- nlyr(ref)
ref_names <- bandy

# Empty names vector
aligned_files <- character(length(files))

# GDAL write options
wopt <- list(
  datatype = "FLT4S",  # float
  gdal = c("COMPRESS=LZW", "TILED=YES")
)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Loop

for (i in seq_along(files)) {
  f <- files[i]
  # progress
  message(sprintf("[%02d/%02d] %s", i, length(files), basename(f)))
  
  # load raster
  r <- rast(f)
  
  # check layers
  if (nlyr(r) != ref_nlyr) {
    stop("Tile has different number of layers than reference: ",
         basename(f), " (", nlyr(r), " vs ", ref_nlyr, ")")
  }
  
  # names
  names(r) <- ref_names
  
  # create mask ‒ cells with data (only layer 1 taken into consideration)
  m <- !is.na(r[[1]])
  
  # align cells (NN method)
  # if CRS == CRS -> resample, if not -> project
  if (!same.crs(r, template)) {
    r_al <- project(r, template, method = "near")
    m_al <- project(m, template, method = "near")
  } else {
    r_al <- resample(r, template, method = "near")
    m_al <- resample(m, template, method = "near")
  }
  
  # mask out cells, which originaly had NA (prevent extrapolation)
  m_al <- as.int(m_al)
  r_al <- mask(r_al, m_al, maskvalues = 0, updatevalue = NA)
  
  # write aligned raster
  out_file <- file.path(out_dir, sprintf("%03d_aligned.tif", i))
  writeRaster(r_al, out_file, overwrite = TRUE, wopt = wopt)
  
  aligned_files[i] <- out_file
  
  # clean memory
  rm(r, m, r_al, m_al)
  gc()
}

message("Done. Aligned tiles written to: ", out_dir)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #