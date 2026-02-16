# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# FUNCTION: chelsa_trace21k_crop_aoi
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# 
# This function is downloading CHELSA ‒ Trace21k data.
# Those data represent downscaled model of past climate on the centiennal steps.
# It returns desired bioclimatic variables and Snow cover days (if TRUE)
# for AOI and time selected timesteps.
#
# Example usage:
#
# chelsa_trace21k_crop_aoi(
#     aoi_sf = extent_polygon,
#     out_dir = "save/data/here",
#     bios = 1:19,
#     include_scd = TRUE, # I want scd layers 
#     steps = -50:20, # I am interested only in part of the model time span
#     base_url = "https://os.zhdk.cloud.switch.ch/chelsa01/chelsa_trace21k/global/bioclim",
#     overwrite = TRUE
# )
# 
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

chelsa_trace21k_crop_aoi <- function(
    aoi_sf,
    out_dir,
    bios = 1:19,
    include_scd = TRUE,
    steps = -200:20,
    base_url = "https://os.zhdk.cloud.switch.ch/chelsa01/chelsa_trace21k/global/bioclim",
    overwrite = FALSE
) {
  # creates dir
  if (!base::dir.exists(out_dir)) base::dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  
  # AOI -> WGS84
  aoi_v <- terra::vect(sf::st_transform(aoi_sf, 4326))
  
  # variables list: bio01..bio19 + scd
  vars <- base::sprintf("bio%02d", base::as.integer(bios))
  if (isTRUE(include_scd)) vars <- base::c(vars, "scd")
  
  # format TraCE21k timestep token:
  #  - negatives look like "-001" .. "-200"
  #  - nonnegatives look like "0000" .. "0020"
  fmt_step <- function(x) {
    x <- base::as.integer(x)
    if (x < 0L) {
      base::sprintf("-%03d", base::abs(x))
    } else {
      base::sprintf("%04d", x)
    }
  }
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # URL builder for your described structure:
  # <base_url>/<var>/CHELSA_TraCE21k_<var>_<step>_V.1.0.tif
  chelsa_url <- function(var, step_token) {
    file <- base::sprintf("CHELSA_TraCE21k_%s_%s_V.1.0.tif", var, step_token)
    base::sprintf("%s/%s/%s", base_url, var, file)
  }
  
  # open remote COG via GDAL VSI Curl
  open_remote <- function(url) {
    terra::rast(base::paste0("/vsicurl/", url))
  }
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # main loop
  for (var in vars) {
    for (st in steps) {
      step_token <- fmt_step(st)
      url <- chelsa_url(var, step_token)
      
      out_path <- base::file.path(
        out_dir,
        var,
        base::sprintf("CHELSA_TraCE21k_%s_%s_AOI.tif", var, step_token)
      )
      base::dir.create(base::dirname(out_path), recursive = TRUE, showWarnings = FALSE)
      if (!overwrite && base::file.exists(out_path)) next
      
      base::message("trace21k: ", var, " step=", step_token)
      
      r <- open_remote(url)
      r_aoi <- terra::mask(terra::crop(r, aoi_v), aoi_v)
      
      terra::writeRaster(
        r_aoi,
        filename = out_path,
        overwrite = TRUE,
        gdal = c("COMPRESS=LZW", "TILED=YES", "BIGTIFF=IF_SAFER")
      )
    }
  }
  
  invisible(TRUE)
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #