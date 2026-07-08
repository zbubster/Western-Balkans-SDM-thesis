# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Aggregate future ESM projections
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# concept:
# for each species × grain × period × SSP:
#   1) find all ESM_projection_<period>_<ESM>_<ssp>.tif files
#   2) stack projections from all ESMs
#   3) calculate mean predicted suitability
#   4) calculate SD of predicted suitability
#   5) write both outputs as single-layer GeoTIFFs

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# main config
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# set this to the directory that directly contains species folders:
# e.g. ".../GD", ".../GT", ".../PK", etc.
base_dir <- here::here(
  "data",
  "__ESM_OUTPUTS__",
  "recent_noextrapol_weights_common"
)

out_base_dir <- file.path(base_dir, "_future_aggregated")

periods_keep <- c("2041-2070", "2071-2100")
ssps_keep <- c("ssp126", "ssp370", "ssp585")

expected_esms <- c(
  "GFDL-ESM4",
  "IPSL-CM6A-LR",
  "MPI-ESM1-2-HR",
  "MRI-ESM2-0",
  "UKESM1-0-LL"
)

overwrite <- TRUE

terra::terraOptions(
  progress = 1,
  memfrac = 0.75
)

write_options <- list(
  datatype = "FLT4S",
  gdal = c(
    "COMPRESS=LZW",
    "TILED=YES",
    "BIGTIFF=IF_SAFER"
  )
)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# helper functions
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

parse_future_projection_paths <- function(base_dir) {
  tif_paths <- base::list.files(
    path = base_dir,
    pattern = "\\.tif$",
    recursive = TRUE,
    full.names = TRUE
  )
  
  if (length(tif_paths) == 0) {
    stop("No .tif files found in base_dir: ", base_dir)
  }
  
  base_norm <- base::normalizePath(base_dir, winslash = "/", mustWork = TRUE)
  path_norm <- base::normalizePath(tif_paths, winslash = "/", mustWork = TRUE)
  
  rel_paths <- base::sub(
    pattern = paste0("^", base_norm, "/?"),
    replacement = "",
    x = path_norm
  )
  
  parsed <- base::lapply(seq_along(rel_paths), function(i) {
    rel_path <- rel_paths[i]
    full_path <- path_norm[i]
    
    parts <- base::strsplit(rel_path, "/", fixed = TRUE)[[1]]
    
    # expected relative path:
    # species/grain/projections/projection_id/ESM_projection_projection_id.tif
    if (length(parts) != 5) {
      return(NULL)
    }
    
    species <- parts[1]
    grain <- parts[2]
    folder_type <- parts[3]
    projection_id <- parts[4]
    file_name <- parts[5]
    
    if (folder_type != "projections") {
      return(NULL)
    }
    
    expected_file_name <- paste0("ESM_projection_", projection_id, ".tif")
    
    if (file_name != expected_file_name) {
      return(NULL)
    }
    
    id_match <- base::regexec(
      pattern = "^(\\d{4}-\\d{4})_(.+)_(ssp\\d{3})$",
      text = projection_id,
      perl = TRUE
    )
    
    id_parts <- base::regmatches(projection_id, id_match)[[1]]
    
    # skips hindcast-like IDs such as 060_all_selected or 190_all_selected
    if (length(id_parts) != 4) {
      return(NULL)
    }
    
    data.frame(
      species = species,
      grain = as.integer(grain),
      period = id_parts[2],
      esm = id_parts[3],
      ssp = id_parts[4],
      projection_id = projection_id,
      path = full_path,
      stringsAsFactors = FALSE
    )
  })
  
  parsed <- parsed[!base::vapply(parsed, is.null, logical(1))]
  
  if (length(parsed) == 0) {
    stop("No future projection files matching expected naming pattern were found.")
  }
  
  projection_table <- base::do.call(rbind, parsed)
  
  projection_table <- projection_table[
    projection_table$period %in% periods_keep &
      projection_table$ssp %in% ssps_keep,
  ]
  
  if (nrow(projection_table) == 0) {
    stop("No projection files remained after period/SSP filtering.")
  }
  
  projection_table <- projection_table[base::order(
    projection_table$species,
    projection_table$grain,
    projection_table$period,
    projection_table$ssp,
    projection_table$esm
  ), ]
  
  rownames(projection_table) <- NULL
  
  return(projection_table)
}


check_same_geometry <- function(paths) {
  reference_raster <- terra::rast(paths[1])
  
  if (length(paths) == 1) {
    return(invisible(TRUE))
  }
  
  for (i in 2:length(paths)) {
    compared_raster <- terra::rast(paths[i])
    
    is_same <- terra::compareGeom(
      reference_raster,
      compared_raster,
      lyrs = FALSE,
      crs = TRUE,
      ext = TRUE,
      rowcol = TRUE,
      res = TRUE,
      stopOnError = FALSE
    )
    
    if (!is_same) {
      stop(
        "Raster geometry mismatch detected:\n",
        "reference: ", paths[1], "\n",
        "compared:  ", paths[i]
      )
    }
  }
  
  invisible(TRUE)
}


mean_na <- function(x) {
  ok <- !is.na(x)
  
  if (!any(ok)) {
    return(NA_real_)
  }
  
  base::mean(x[ok])
}


sd_na <- function(x) {
  ok <- !is.na(x)
  
  if (sum(ok) <= 1) {
    return(NA_real_)
  }
  
  stats::sd(x[ok])
}


aggregate_one_group <- function(task, out_base_dir, expected_esms, overwrite, write_options) {
  task <- task[base::order(task$esm), ]
  
  species <- unique(task$species)
  grain <- unique(task$grain)
  period <- unique(task$period)
  ssp <- unique(task$ssp)
  
  if (length(species) != 1 || length(grain) != 1 || length(period) != 1 || length(ssp) != 1) {
    stop("Task contains more than one species/grain/period/SSP combination.")
  }
  
  missing_esms <- base::setdiff(expected_esms, task$esm)
  extra_esms <- base::setdiff(task$esm, expected_esms)
  
  if (length(missing_esms) > 0) {
    warning(
      "Missing ESMs for ",
      species, " / ", grain, " / ", period, " / ", ssp, ": ",
      paste(missing_esms, collapse = ", ")
    )
  }
  
  if (length(extra_esms) > 0) {
    warning(
      "Unexpected ESMs for ",
      species, " / ", grain, " / ", period, " / ", ssp, ": ",
      paste(extra_esms, collapse = ", ")
    )
  }
  
  message(
    "Aggregating: ",
    species, " / ", grain, " / ", period, " / ", ssp,
    " | n ESM = ", nrow(task)
  )
  
  check_same_geometry(task$path)
  
  projection_stack <- terra::rast(task$path)
  names(projection_stack) <- task$esm
  
  out_dir <- file.path(
    out_base_dir,
    species,
    as.character(grain),
    paste(period, ssp, sep = "_")
  )
  
  base::dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  
  mean_file <- file.path(
    out_dir,
    paste0("mean_predicted_suitability_", species, "_", grain, "_", period, "_", ssp, ".tif")
  )
  
  sd_file <- file.path(
    out_dir,
    paste0("sd_predicted_suitability_", species, "_", grain, "_", period, "_", ssp, ".tif")
  )
  
  mean_raster <- terra::app(
    projection_stack,
    fun = mean_na
  )
  
  names(mean_raster) <- "mean_predicted_suitability"
  
  terra::writeRaster(
    mean_raster,
    filename = mean_file,
    overwrite = overwrite,
    datatype = write_options$datatype,
    gdal = write_options$gdal
  )
  
  sd_raster <- terra::app(
    projection_stack,
    fun = sd_na
  )
  
  names(sd_raster) <- "sd_predicted_suitability"
  
  terra::writeRaster(
    sd_raster,
    filename = sd_file,
    overwrite = overwrite,
    datatype = write_options$datatype,
    gdal = write_options$gdal
  )
  
  data.frame(
    species = species,
    grain = grain,
    period = period,
    ssp = ssp,
    n_esm = nrow(task),
    used_esms = paste(task$esm, collapse = ";"),
    mean_file = mean_file,
    sd_file = sd_file,
    stringsAsFactors = FALSE
  )
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# create tasks
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

projection_table <- parse_future_projection_paths(base_dir)

base::dir.create(out_base_dir, recursive = TRUE, showWarnings = FALSE)

utils::write.csv(
  projection_table,
  file = file.path(out_base_dir, "future_projection_inventory.csv"),
  row.names = FALSE
)

task_id <- paste(
  projection_table$species,
  projection_table$grain,
  projection_table$period,
  projection_table$ssp,
  sep = "__"
)

tasks <- split(projection_table, task_id)

message("Number of aggregation tasks: ", length(tasks))

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# run aggregation
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

aggregation_report <- base::lapply(
  tasks,
  aggregate_one_group,
  out_base_dir = out_base_dir,
  expected_esms = expected_esms,
  overwrite = overwrite,
  write_options = write_options
)

aggregation_report <- base::do.call(rbind, aggregation_report)
rownames(aggregation_report) <- NULL

utils::write.csv(
  aggregation_report,
  file = file.path(out_base_dir, "future_aggregation_report.csv"),
  row.names = FALSE
)

message("Done. Outputs written to: ", out_base_dir)