# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Reflectance, keep TIME
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Convert to physical reflectance (from 0 to 1)

# Sentinel-2 data are often not stored directly as reflectance in the range 0–1,
# but as scaled values (typically reflectance × 10,000) in order to maintain
# accuracy while reducing file size when storing in integer format.
# Therefore, when calculating indices, it is advisable to convert the values
# back to physically interpretable reflectance by dividing by 10,000.
# For purely ratio indices (NDVI), the scaling factor is algebraically
# subtracted, but for indices with additive constants (EVI, OSAVI, SAVI),
# leaving the scaled values would lead to systematic bias.

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Settings

in_dir <- here("data", "Sentinel2_medoids_aligned")
out_dir <- here("data", "Sentinel2_reflectance_tiles_TIME")

if(!dir.exists(out_dir)){
  dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
}

# expected bands
in_bands <- c("B02","B03","B04","B05","B08","B8A","B11","B12","TIME")

# which bands bring spectral information and should be scaled
spectral_bands <- setdiff(in_bands, "TIME")
time_band <- "TIME"

# list files
files <- list.files(in_dir, pattern = "\\.tif(f)?$", full.names = TRUE)
stopifnot(length(files) == 81)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Loop

for (i in seq_along(files)) {
  f <- files[i]
  message(sprintf("[%02d/%02d] %s", i, length(files), basename(f)))
  # load raster
  r <- rast(f)
  
  nm <- names(r)
  
  # sort bands
  r <- r[[in_bands]]
  
  # IDs
  idx_spec <- match(spectral_bands, names(r))
  idx_time <- match(time_band, names(r))
  
  # divide to physical reflectance
  r_spec <- r[[idx_spec]] / 10000
  r_time <- r[[idx_time]]
  
  # merge back together
  r_out <- c(r_spec, r_time)
  names(r_out) <- c(spectral_bands, time_band)
  
  # output name
  base <- tools::file_path_sans_ext(basename(f)) # extract basename without ".tif"
  out_name <- file.path(out_dir, paste0(base, "_refTIME.tif"))
  
  # write
  writeRaster(
    r_out,
    out_name,
    overwrite = TRUE,
    wopt = list(
      datatype = "FLT4S",
      gdal = c("COMPRESS=LZW", "TILED=YES", "BIGTIFF=YES")
    )
  )
  
  # clean memory
  rm(r, r_spec, r_time, r_out); gc()
}
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #