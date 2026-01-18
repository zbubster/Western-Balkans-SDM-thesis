# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Spectral indices from Sentinel 2
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Settings

in_dir <- here("data", "Sentinel2_reflectance")
out_dir <- here("data", "Sentinel2_indices") # output dir
if(!dir.exists(out_dir)){
  dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
}
bandy <- c("B02","B03","B04","B05","B08","B8A","B11","B12")

# parameters
L_savi <- 0.5 # SAVI soil adjustment factor
SAFE <- 1e-12 # constant for divide helper

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Load files, sort them and create virtual stack
files <- list.files(in_dir, pattern = "\\.tif$", full.names = TRUE)
bandz <- sub(".*(B0[2-8]|B8A|B11|B12).*", "\\1", basename(files))
files <- files[match(bandy, bandz)] # sort bands acording to bandy

r <- rast(files)

# extract bands
B02 <- r[["B02"]]  # blue
B03 <- r[["B03"]]  # green
B04 <- r[["B04"]]  # red
B05 <- r[["B05"]]  # red edge 1
B08 <- r[["B08"]]  # NIR
B8A <- r[["B8A"]]  # narrow NIR
B11 <- r[["B11"]]  # SWIR1
B12 <- r[["B12"]]  # SWIR2

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Safe divide
# this function should prevent divide by zero
safe_div <- function(citatel, jmenovatel) {
  jmenovatel2 <- terra::ifel(abs(jmenovatel) < SAFE, NA, jmenovatel)
  citatel / jmenovatel2
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #



idx <- terra::lapp(
  r[[c("B08","B04")]],
  fun = function(v) {
    B08 <- v[1]
    B04 <- v[2]
    safe <- function(n, d) { d[abs(d) < SAFE] <- NA; n / d }
    NDVI <- safe(B08 - B04, B08 + B04)
  },
  filename = "NDVI.tif",
  overwrite = TRUE,
  wopt = list(datatype="FLT4S", gdal=c("COMPRESS=LZW","TILED=YES","BIGTIFF=YES"))
)

names(idx) <- "NDVI"



idx <- terra::app(
  r[[c("B08","B04")]],
  fun = function(v) {
    B08 <- v[, 1]
    B04 <- v[, 2]
    d <- B08 + B04
    d[abs(d) < SAFE] <- NA
    (B08 - B04) / d
  },
  filename  = "NDVI.tif",
  overwrite = TRUE,
  wopt = list(datatype="FLT4S", gdal=c("COMPRESS=LZW","TILED=YES","BIGTIFF=YES")),
  cores = 10
)




NDVI  <- safe_div(B08 - B04, B08 + B04)

# EVI (standard MODIS-style coefficients)
EVI   <- 2.5 * safe_div(B08 - B04, (B08 + 6 * B04 - 7.5 * B02 + 1))

SAVI  <- (1 + L_savi) * safe_div(B08 - B04, (B08 + B04 + L_savi))

# MSAVI2 (commonly used "MSAVI" in practice)
MSAVI <- (2 * B08 + 1 - sqrt((2 * B08 + 1)^2 - 8 * (B08 - B04))) / 2

OSAVI <- safe_div(B08 - B04, (B08 + B04 + 0.16))

# NDMI: moisture (NIR vs SWIR1)
NDMI  <- safe_div(B08 - B11, B08 + B11)

# NDII: here defined with SWIR2 to avoid being identical to NDMI
NDII  <- safe_div(B08 - B12, B08 + B12)

# BSI (Bare Soil Index) – common 4-band form
BSI   <- safe_div((B11 + B04) - (B08 + B02), (B11 + B04) + (B08 + B02))

# NDRE (NIR vs Red-edge 1)
NDRE  <- safe_div(B08 - B05, B08 + B05)

# CIre (Chlorophyll Index red-edge)
CIre  <- safe_div(B8A, B05) - 1

# stack + write
idx <- c(NDVI, EVI, SAVI, MSAVI, OSAVI, NDII, NDMI, BSI, NDRE, CIre)
names(idx) <- c("NDVI","EVI","SAVI","MSAVI","OSAVI","NDII","NDMI","BSI","NDRE","CIre")

writeRaster(idx, out_tif, overwrite = TRUE)
idx