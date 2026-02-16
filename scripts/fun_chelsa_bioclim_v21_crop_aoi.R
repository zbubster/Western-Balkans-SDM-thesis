# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# FUNCTION: chelsa_bioclim_v21_crop_aoi
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# 
# This function is for downloading CHELSA v2.1 data.
# It returns tiff files of desired bioclim variables for selected time periods,
# global climatic models and shared socioeconomic pathwyas. By default it downloads all combinations.
# 
# Example usage:
#   chelsa_bioclim_v21_crop_aoi(
#     aoi_sf = sf::st_read("your/AOI.gpkg"),
#     out_dir = "where/should/be/results/saved",
#     include_scd = T, # should snow cover days be included?
#     overwrite = F,
#     bios = 1:19,
#     models = "GFDL-ESM4",
#     ssps = c("ssp126", "ssp370", "ssp585")
#   )
#
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

chelsa_bioclim_v21_crop_aoi <- function(
    aoi_sf,
    out_dir,
    bios = 1:19,
    include_scd = TRUE,
    periods = c("1981-2010", "2011-2040", "2041-2070", "2071-2100"),
    models = c("GFDL-ESM4", "IPSL-CM6A-LR", "MPI-ESM1-2-HR", "MRI-ESM2-0", "UKESM1-0-LL"),
    ssps = c("ssp126", "ssp370", "ssp585"),
    base_url = "https://os.unil.cloud.switch.ch/chelsa02/chelsa/global/bioclim",
    overwrite = FALSE
) {
  # creates dir
  if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  
  # AOI -> WGS84
  aoi_v <- terra::vect(sf::st_transform(aoi_sf, 4326))
  
  # build variable list: bio01..bio19 + optional scd
  vars <- sprintf("bio%02d", as.integer(bios))
  if (isTRUE(include_scd)) vars <- c(vars, "scd")
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # URL builder (var = "bio01".."bio19" or "scd")
  chelsa_url <- function(var, period, model = NULL, ssp = NULL) {
    
    # baseline
    if (period == "1981-2010") {
      file <- sprintf("CHELSA_%s_%s_V.2.1.tif", var, period)
      return(sprintf("%s/%s/%s/%s", base_url, var, period, file))
    }
    
    # projections
    model_l <- tolower(model)
    file <- sprintf("CHELSA_%s_%s_%s_%s_V.2.1.tif", model_l, ssp, var, period)
    sprintf("%s/%s/%s/%s/%s/%s", base_url, var, period, model, ssp, file)
  }
  
  # open remote COG via GDAL VSI Curl
  open_remote <- function(url) {
    terra::rast(paste0("/vsicurl/", url))
  }
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # baseline
  for (var in vars) {
    period <- "1981-2010"
    url <- chelsa_url(var, period)
    
    out_path <- file.path(
      out_dir,
      period,
      sprintf("CHELSA_%s_%s_AOI.tif", var, period)
    )
    dir.create(dirname(out_path), recursive = TRUE, showWarnings = FALSE)
    if (!overwrite && file.exists(out_path)) next
    
    message("baseline: ", var, " ", period)
    
    r <- open_remote(url)
    r_aoi <- terra::mask(terra::crop(r, aoi_v), aoi_v)
    
    terra::writeRaster(
      r_aoi,
      filename = out_path,
      overwrite = TRUE,
      gdal = c("COMPRESS=LZW", "TILED=YES", "BIGTIFF=IF_SAFER")
    )
  }
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # projections
  proj_periods <- setdiff(periods, "1981-2010")
  
  for (period in proj_periods) {
    for (model in models) {
      for (ssp in ssps) {
        for (var in vars) {
          
          url <- chelsa_url(var, period, model, ssp)
          
          out_path <- file.path(
            out_dir,
            period, model, ssp,
            sprintf("CHELSA_%s_%s_%s_%s_AOI.tif", var, period, tolower(model), ssp)
          )
          dir.create(dirname(out_path), recursive = TRUE, showWarnings = FALSE)
          if (!overwrite && file.exists(out_path)) next
          
          message("proj: ", var, " ", period, " ", model, " ", ssp)
          
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
    }
  }
  
  invisible(TRUE)
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #