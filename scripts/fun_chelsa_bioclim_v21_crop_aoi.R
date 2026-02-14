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
    periods = c("1981-2010", "2011-2040", "2041-2070", "2071-2100"),
    models = c("GFDL-ESM4", "IPSL-CM6A-LR", "MPI-ESM1-2-HR", "MRI-ESM2-0", "UKESM1-0-LL"),
    ssps = c("ssp126", "ssp370", "ssp585"),
    base_url = "https://os.unil.cloud.switch.ch/chelsa02/chelsa/global/bioclim",
    overwrite = FALSE
) {
  # creates dir
  if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  
  # get AOI, reproject to WGS 84 (as CHELSA operates in this CRS)
  aoi_v <- terra::vect(sf::st_transform(aoi_sf, 4326))
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # URL builder
  chelsa_url <- function(bio, period, model = NULL, ssp = NULL) {
    
    bio_tag <- sprintf("bio%02d", as.integer(bio)) # bio01..bio19
    
    # baseline
    if (period == "1981-2010") {
      file <- sprintf("CHELSA_%s_%s_V.2.1.tif", bio_tag, period)
      return(sprintf("%s/%s/%s/%s", base_url, bio_tag, period, file))
    }
    
    # if you want model prediction
    model_l <- tolower(model)
    file <- sprintf("CHELSA_%s_%s_%s_%s_V.2.1.tif", model_l, ssp, bio_tag, period)
    sprintf("%s/%s/%s/%s/%s/%s", base_url, bio_tag, period, model, ssp, file)
  }
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # open remote COG via GDAL VSI Curl
  open_remote <- function(url) {
    terra::rast(paste0("/vsicurl/", url))
  }
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # get baseline rasters
  for (bio in bios) {
    period <- "1981-2010"
    url <- chelsa_url(bio, period)
    
    # path out
    out_path <- file.path(
      out_dir,
      period,
      sprintf("CHELSA_%s_%s_AOI.tif", sprintf("bio%02d", bio), period)
    )
    dir.create(dirname(out_path), recursive = TRUE, showWarnings = FALSE)
    
    # overwrite argument
    if (!overwrite && file.exists(out_path)) next
    
    # get baseline result and crop it
    message("baseline: ", sprintf("bio%02d", bio), " ", period)
    r <- open_remote(url)
    r_aoi <- terra::mask(terra::crop(r, aoi_v), aoi_v)
    
    # write result
    terra::writeRaster(
      r_aoi,
      filename = out_path,
      overwrite = TRUE,
      gdal = c("COMPRESS=LZW", "TILED=YES", "BIGTIFF=IF_SAFER")
    )
  }
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # get projections rasters
  proj_periods <- setdiff(periods, "1981-2010") # exclude baseline
  
  # loop over periods
  for (period in proj_periods) {
    # loop over models
    for (model in models) {
      # loop over ssp
      for (ssp in ssps) {
        # loop over bios
        for (bio in bios) {
          url <- chelsa_url(bio, period, model, ssp)
          
          out_path <- file.path(
            out_dir,
            period, model, ssp,
            sprintf("CHELSA_%s_%s_%s_%s_AOI.tif",
                    sprintf("bio%02d", bio), period, tolower(model), ssp)
          )
          dir.create(dirname(out_path), recursive = TRUE, showWarnings = FALSE)
          if (!overwrite && file.exists(out_path)) next
          
          message("proj: ", sprintf("bio%02d", bio), " ", period, " ", model, " ", ssp)
          
          # open URL remote
          r <- open_remote(url)
          
          # crop and mask raster to AOI
          r_aoi <- terra::mask(terra::crop(r, aoi_v), aoi_v)
          
          # write result
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
  
  # let ther be less printed rows!
  invisible(TRUE)
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #