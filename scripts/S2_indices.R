# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Spectral indices from Sentinel 2
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Settings

in_tif  <- here("data", "Sentinel2_MOSAIC.tif")
in_bands <- c("B02","B03","B04","B05","B08","B8A","B11","B12", "TIME") # bands which should be in in_tif
out_tif <- here("data", "Sentinel2_INDEX.tif")

# parameters
L_savi <- 0.5  # SAVI soil adjustment factor
eps    <- 1e-12

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# load raster
r <- rast(in_tif)

# sanity: check required bands exist

miss <- setdiff(in_bands, names(r))
if (length(miss) > 0) {
  stop("Missing bands in input raster: ", paste(miss, collapse = ", "))
}

# ---- convert to reflectance 0..1 if needed ----
# (common for L2A: values 0..10000)
mx <- global(r, fun = "max", na.rm = TRUE)[,1]
if (is.finite(mx) && mx > 1.5) {
  r <- r / 10000
}

# helpers
safe_div <- function(n, d) {
  d2 <- ifel(abs(d) < eps, NA, d)
  n / d2
}

# extract bands
B02 <- r[["B02"]]  # blue
B03 <- r[["B03"]]  # green
B04 <- r[["B04"]]  # red
B05 <- r[["B05"]]  # red edge 1
B08 <- r[["B08"]]  # NIR
B8A <- r[["B8A"]]  # narrow NIR
B11 <- r[["B11"]]  # SWIR1
B12 <- r[["B12"]]  # SWIR2

# ---- indices ----
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