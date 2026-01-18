# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Reflectance, drop TIME band
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Settings

in_tif  <- here("data", "Sentinel2_MOSAIC.tif")
in_bands <- c("B02","B03","B04","B05","B08","B8A","B11","B12", "TIME") # bands which should be in in_tif
keep <- setdiff(in_bands, "TIME") # which bands should be kept for indices computing

out_dir <- here("data", "Sentinel2_reflectance")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Load data, drop TIME band

# load raster, drop TIME band
r <- rast(in_tif)
r <- r[[keep]]
stopifnot(nlyr(r) == 8)

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

# path vector
ven <- character(nlyr(r))

for (i in 1:nlyr(r)) {
  lay <- r[[i]] # load one layer
  nm <- names(lay)
  outf <- file.path(out_dir, paste0(nm, "_ref.tif"))
  ven[i] <- outf
  
  # compute reflectance layer and write it to the disk
  # cell_value / 10000 -> 0-1 scale
  writeRaster(lay/10000, outf, overwrite = TRUE,
              wopt = list(datatype="FLT4S",
                          gdal=c("COMPRESS=LZW","TILED=YES","BIGTIFF=YES")))
  
  # clean memory
  rm(lay); gc()
}

# virtual stack
# r <- rast(ven)
# names(r) <- keep
# r

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #