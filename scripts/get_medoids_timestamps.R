# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# MEDOIDS
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #


# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Settings

# focal bands
bands <- c("B02","B03","B04","B05","B08","B8A","B11","B12")
n_bands <- length(bands)

# prepare cluster for parallel computation within terra::app
# run this chunk only once! it creates cluster, which should not be overwritten
# --
# cl <- makeCluster(14)
# on.exit(stopCluster(cl), add = TRUE)
# --

# set dir with NetCDF input files & output dir
dir_in <- "/media/zbub/DATA/Sentinel2_datacubes/TODO/"
dir_out <- "/media/zbub/DATA/Sentinel2_medoids/"
datacubes_names <- list.files(dir_in)
out_files_names <- sub("\\.nc$", "_medoid_with_time.tif", datacubes_names)

# load medoid function
source(here("scripts", "fun_medoid.R"))

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Loop

# loop over all files within dir_in
for(i in seq_along(datacubes_names)){
  
  # load layers
  nc <- terra::rast(paste0(dir_in, datacubes_names[i]))
  message("Loaded NetCDF file: ", datacubes_names[i])
  
  # extract names & dates of observation
  nms <- names(nc)
  band_vec <- sub("^(B0[2-8]|B8A|B1[12])_t=.*$", "\\1", nms)
  t_vec    <- as.integer(sub("^.*_t=(\\d+).*$", "\\1", nms))
  
  # order band layers acording to dates of observation
  band_fac <- factor(band_vec, levels = bands)
  ord <- order(t_vec, band_fac)
  nc <- nc[[ord]]
  band_fac <- band_fac[ord]
  t_vec <- t_vec[ord]
  
  # check
  stopifnot(nlyr(nc) %% n_bands == 0)
  
  t_by_row <- t_vec[seq(1, nlyr(nc), by = n_bands)]
  
  # prepare function object with correct arguments
  fun <- make_medoid_fun_with_t(n_bands = n_bands, t_by_row = t_by_row, strict_all_bands = TRUE)
  
  # apply function over spatially partioned raster
  terra::app(
    nc,
    fun = fun,
    filename = paste0(dir_out, out_files_names[i]), # set output dir & obj name
    overwrite = TRUE,
    wopt = list(gdal = c("COMPRESS=LZW", "TILED=YES")), # loseless compresion, tiled raster for faster visualization
    cores = cl # parallel computation
  )
  
  rm(nc, fun, t_by_row, t_vec, band_fac, band_vec, ord, nms)
  gc()
}


