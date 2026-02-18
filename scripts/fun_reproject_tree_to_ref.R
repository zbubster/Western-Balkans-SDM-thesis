# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# FUNCTION: reproject .tif(f)
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# This function reprojects rasters to reference grid, results are saved in same
# dir structure as input.

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

reproject_tree_to_ref <- function(
    root_in,
    root_out,
    reference,
    method,
    tol = 1e-7
) {
  # check inputs
  if (!base::dir.exists(root_in)) base::stop("Invalid root: ", root_in)
  if (!base::dir.exists(root_out)) base::dir.create(root_out, recursive = TRUE, showWarnings = FALSE)
  
  ref_r <- if (base::inherits(reference, "SpatRaster")) {
    reference
  } else {
    if (!base::file.exists(reference)) base::stop("Invalid reference: ", reference)
    terra::rast(reference)
  }
  
  #-----------------------------#
  # List rasters
  #-----------------------------#
  tifs <- base::list.files(
    path        = root_in,
    pattern     = "\\.(tif|tiff)$",
    recursive   = TRUE,
    full.names  = TRUE,
    ignore.case = TRUE
  )
  
  if (base::length(tifs) == 0) {
    base::warning("Found no .tif/.tiff in dir: ", root_in)
    return(base::invisible(base::data.frame()))
  }
  
  #-----------------------------#
  # Relative path
  #-----------------------------#
  rel_path <- function(x, root) {
    root <- base::normalizePath(root, winslash = "/", mustWork = TRUE)
    x    <- base::normalizePath(x,    winslash = "/", mustWork = TRUE)
    base::sub(base::paste0("^", root, "/?"), "", x)
  }
  
  #-----------------------------#
  # Compare metadata
  #-----------------------------#
  same_meta <- function(r, ref, tol) {
    # CRS (string)
    crs_ok <- terra::crs(r, proj = TRUE) == terra::crs(ref, proj = TRUE)
    
    # res / origin / extent (numeric; s tolerancí)
    res_r  <- terra::res(r);   res_ref <- terra::res(ref)
    org_r  <- terra::origin(r); org_ref <- terra::origin(ref)
    ext_r  <- terra::ext(r);   ext_ref <- terra::ext(ref)
    
    res_ok <- base::all(base::abs(res_r - res_ref) < tol)
    org_ok <- base::all(base::abs(org_r - org_ref) < tol)
    ext_ok <- base::all(base::abs(
      c(ext_r[1], ext_r[2], ext_r[3], ext_r[4]) - c(ext_ref[1], ext_ref[2], ext_ref[3], ext_ref[4])
    ) < tol)
    
    base::isTRUE(crs_ok && res_ok && org_ok && ext_ok)
  }
  
  # GDAL write options
  wopt <- list(gdal = c("COMPRESS=LZW", "TILED=YES", "BIGTIFF=YES"))
  
  #-----------------------------#
  # Main loop
  #-----------------------------#
  out_files <- base::character(base::length(tifs))
  ok        <- base::logical(base::length(tifs))
  status    <- base::character(base::length(tifs))
  msg       <- base::character(base::length(tifs))
  
  for (i in base::seq_along(tifs)) {
    f <- tifs[i]
    
    rel   <- rel_path(f, root_in)
    out_f <- base::file.path(root_out, rel)
    out_files[i] <- out_f
    
    base::dir.create(base::dirname(out_f), recursive = TRUE, showWarnings = FALSE)
    base::message(base::sprintf("[%04d/%04d] %s", i, base::length(tifs), rel))
    
    res <- base::try({
      r <- terra::rast(f)
      
      if (same_meta(r, ref_r, tol = tol)) {
        ok[i]     <- TRUE
        status[i] <- "skipped"
        msg[i]    <- ""
      } else {
        terra::project(
          r, ref_r,
          method    = method,
          filename  = out_f,
          overwrite = TRUE,
          wopt      = wopt
        )
        ok[i]     <- TRUE
        status[i] <- "reprojected"
        msg[i]    <- ""
      }
      
      base::rm(r); base::gc()
      TRUE
    }, silent = TRUE)
    
    if (!base::isTRUE(res)) {
      ok[i]     <- FALSE
      status[i] <- "error"
      msg[i]    <- base::as.character(res)
      base::warning("Error in file: ", f, "\n", msg[i])
    }
  }
  
  base::data.frame(
    in_file  = tifs,
    out_file = out_files,
    ok       = ok,
    status   = status,
    message  = msg,
    stringsAsFactors = FALSE
  )
}
