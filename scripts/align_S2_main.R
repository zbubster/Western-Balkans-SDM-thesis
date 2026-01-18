# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Align S2 tiles ‒ main workflow
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Settings

# in_dir <- here("data", "Sentinel2_medoids")
in_dir <- "/media/zbub/DATA/Sentinel2_medoids/" 
# out_dir <- here("data", "Sentinel2_medoids_aligned")
out_dir <- "/media/zbub/DATA/Sentinel2_medoids_aligned_2/"

if(!dir.exists(out_dir)){
  dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
}

# reference tile
ref_id <- 42

ref_names <- c("B02", "B03", "B04", "B05", "B08", "B8A", "B11", "B12", "TIME")

# clamp settings
spectral_bands <- c("B02", "B03", "B04", "B05", "B08", "B8A", "B11", "B12")
clamp_upper <- 15000
clamp_lower <- 0

# other
terraOptions(progress = 1)

# cores allocation ‒ only if running localy!
# setGDALconfig("GDAL_NUM_THREADS", "14")

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Data load, etc

# List files
files <- list.files(in_dir, pattern = "\\.tif$", full.names = TRUE); message("Tiles loaded: ", length(files))
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

# Reference nlyr
ref_nlyr <- nlyr(ref)

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
  
  # get original extent for later crop
  e0 <- ext(r)
  
  # create mask ‒ cells with data (only layer 1 taken into consideration)
  m <- !is.na(r[[1]])
  
  # buffer ‒ avoid edge errors
  buf <- 40  # units = m
  e_buf <- ext(xmin(e0)-buf, xmax(e0)+buf, ymin(e0)-buf, ymax(e0)+buf)
  
  # local target grid
  tmpl_loc <- crop(template, e_buf, snap = "out")
  
  # align
  if (!same.crs(r, tmpl_loc)) {
    r_al <- project(r, tmpl_loc, method = "near", use_gdal = TRUE)
    m_al <- project(m, tmpl_loc, method = "near", use_gdal = TRUE)
  } else {
    r_al <- resample(r, tmpl_loc, method = "near")
    m_al <- resample(m, tmpl_loc, method = "near")
  }
  
  # mask out cells, which originaly had NA (prevent extrapolation)
  m_al <- as.int(m_al)
  r_al <- mask(r_al, m_al, maskvalues = 0, updatevalue = NA)
  
  # crop aligned raster to original extent
  r_al <- crop(r_al, e0, snap = "out")
  
  # clamp spectral layers
  # only spectral_bands (TIME excluded)
  r_al[[spectral_bands]] <- terra::clamp(
    r_al[[spectral_bands]],
    lower  = clamp_lower,
    upper  = clamp_upper,
    values = T
  )
  
  # write aligned raster
  out_file <- file.path(out_dir, sprintf("%03d_aligned.tif", i))
  writeRaster(r_al, out_file, overwrite = TRUE, wopt = wopt)
  
  # clean memory
  rm(r, m, r_al, m_al)
  gc()
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #