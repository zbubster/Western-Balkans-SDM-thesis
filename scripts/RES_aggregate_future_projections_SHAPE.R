# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# RES ‒ Aggregate future Shape projections
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# concept:
# for each species × grain × period × SSP:
#   1) find all forecast shape.tif files
#   2) group them across Earth System Models
#   3) calculate mean Shape
#   4) calculate SD Shape
#   5) write outputs as GeoTIFFs

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# config
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

base_dir <- here::here(
  "models",
  "Shape",
  "hindcast_forecast_extrapol_weights_all_selected"
)

out_base_dir <- file.path(base_dir, "_forecast_aggregated")

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

# if TRUE, tasks with missing ESMs are skipped
# if FALSE, mean/sd are calculated from available ESMs and warning is written
require_complete_esm <- FALSE

write_separate_files <- TRUE
write_combined_stack <- FALSE

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

parse_shape_paths <- function(
    base_dir,
    periods_keep = NULL,
    ssps_keep = NULL
) {
  
  shape_paths <- base::list.files(
    path = base_dir,
    pattern = "^shape\\.tif$",
    recursive = TRUE,
    full.names = TRUE
  )
  
  if (length(shape_paths) == 0) {
    stop("No shape.tif files found in base_dir: ", base_dir)
  }
  
  base_norm <- base::normalizePath(base_dir, winslash = "/", mustWork = TRUE)
  path_norm <- base::normalizePath(shape_paths, winslash = "/", mustWork = TRUE)
  
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
    # species/grain/projections/forecast/projection_id/shape.tif
    if (length(parts) != 6) {
      return(NULL)
    }
    
    species <- parts[1]
    grain <- parts[2]
    folder_type <- parts[3]
    projection_type <- parts[4]
    projection_id <- parts[5]
    file_name <- parts[6]
    
    if (folder_type != "projections") {
      return(NULL)
    }
    
    # skip hindcast; here we aggregate only forecast across climate models
    if (projection_type != "forecast") {
      return(NULL)
    }
    
    if (file_name != "shape.tif") {
      return(NULL)
    }
    
    id_match <- base::regexec(
      pattern = "^(\\d{4}-\\d{4})_(.+)_(ssp\\d{3})$",
      text = projection_id,
      perl = TRUE
    )
    
    id_parts <- base::regmatches(projection_id, id_match)[[1]]
    
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
    stop("No forecast shape.tif files matching expected structure were found.")
  }
  
  shape_table <- base::do.call(rbind, parsed)
  
  if (!is.null(periods_keep)) {
    shape_table <- shape_table[shape_table$period %in% periods_keep, ]
  }
  
  if (!is.null(ssps_keep)) {
    shape_table <- shape_table[shape_table$ssp %in% ssps_keep, ]
  }
  
  if (nrow(shape_table) == 0) {
    stop("No Shape files remained after period/SSP filtering.")
  }
  
  shape_table <- shape_table[base::order(
    shape_table$species,
    shape_table$grain,
    shape_table$period,
    shape_table$ssp,
    shape_table$esm
  ), ]
  
  rownames(shape_table) <- NULL
  
  return(shape_table)
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


aggregate_one_shape_group <- function(
    task,
    out_base_dir,
    expected_esms,
    overwrite,
    write_options,
    require_complete_esm,
    write_separate_files,
    write_combined_stack
) {
  
  task <- task[base::order(match(task$esm, expected_esms)), ]
  
  species <- unique(task$species)
  grain <- unique(task$grain)
  period <- unique(task$period)
  ssp <- unique(task$ssp)
  
  if (
    length(species) != 1 ||
    length(grain) != 1 ||
    length(period) != 1 ||
    length(ssp) != 1
  ) {
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
    
    if (require_complete_esm) {
      return(data.frame(
        species = species,
        grain = grain,
        period = period,
        ssp = ssp,
        n_esm = nrow(task),
        status = "skipped_missing_esm",
        missing_esms = paste(missing_esms, collapse = ";"),
        extra_esms = paste(extra_esms, collapse = ";"),
        used_esms = paste(task$esm, collapse = ";"),
        mean_file = NA_character_,
        sd_file = NA_character_,
        stack_file = NA_character_,
        stringsAsFactors = FALSE
      ))
    }
  }
  
  if (length(extra_esms) > 0) {
    warning(
      "Unexpected ESMs for ",
      species, " / ", grain, " / ", period, " / ", ssp, ": ",
      paste(extra_esms, collapse = ", ")
    )
  }
  
  message(
    "Aggregating Shape: ",
    species, " / ", grain, " / ", period, " / ", ssp,
    " | n ESM = ", nrow(task)
  )
  
  check_same_geometry(task$path)
  
  shape_stack <- terra::rast(task$path)
  names(shape_stack) <- task$esm
  
  out_dir <- file.path(
    out_base_dir,
    species,
    as.character(grain),
    paste(period, ssp, sep = "_")
  )
  
  base::dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
  
  mean_file <- file.path(
    out_dir,
    paste0("mean_shape_", species, "_", grain, "_", period, "_", ssp, ".tif")
  )
  
  sd_file <- file.path(
    out_dir,
    paste0("sd_shape_", species, "_", grain, "_", period, "_", ssp, ".tif")
  )
  
  stack_file <- file.path(
    out_dir,
    paste0("shape_mean_sd_", species, "_", grain, "_", period, "_", ssp, ".tif")
  )
  
  mean_shape <- terra::app(
    shape_stack,
    fun = mean_na
  )
  
  names(mean_shape) <- "mean_shape"
  
  sd_shape <- terra::app(
    shape_stack,
    fun = sd_na
  )
  
  names(sd_shape) <- "sd_shape"
  
  if (write_separate_files) {
    
    terra::writeRaster(
      mean_shape,
      filename = mean_file,
      overwrite = overwrite,
      datatype = write_options$datatype,
      gdal = write_options$gdal
    )
    
    terra::writeRaster(
      sd_shape,
      filename = sd_file,
      overwrite = overwrite,
      datatype = write_options$datatype,
      gdal = write_options$gdal
    )
  }
  
  if (write_combined_stack) {
    
    shape_mean_sd <- c(mean_shape, sd_shape)
    names(shape_mean_sd) <- c("mean_shape", "sd_shape")
    
    terra::writeRaster(
      shape_mean_sd,
      filename = stack_file,
      overwrite = overwrite,
      datatype = write_options$datatype,
      gdal = write_options$gdal
    )
  }
  
  data.frame(
    species = species,
    grain = grain,
    period = period,
    ssp = ssp,
    n_esm = nrow(task),
    status = "done",
    missing_esms = paste(missing_esms, collapse = ";"),
    extra_esms = paste(extra_esms, collapse = ";"),
    used_esms = paste(task$esm, collapse = ";"),
    mean_file = ifelse(write_separate_files, mean_file, NA_character_),
    sd_file = ifelse(write_separate_files, sd_file, NA_character_),
    stack_file = ifelse(write_combined_stack, stack_file, NA_character_),
    stringsAsFactors = FALSE
  )
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# create task table
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

shape_table <- parse_shape_paths(
  base_dir = base_dir,
  periods_keep = periods_keep,
  ssps_keep = ssps_keep
)

base::dir.create(out_base_dir, recursive = TRUE, showWarnings = FALSE)

utils::write.csv(
  shape_table,
  file = file.path(out_base_dir, "forecast_shape_inventory.csv"),
  row.names = FALSE
)

task_id <- paste(
  shape_table$species,
  shape_table$grain,
  shape_table$period,
  shape_table$ssp,
  sep = "__"
)

tasks <- split(shape_table, task_id)

message("Number of Shape aggregation tasks: ", length(tasks))

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# run aggregation
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

aggregation_report <- base::lapply(
  tasks,
  aggregate_one_shape_group,
  out_base_dir = out_base_dir,
  expected_esms = expected_esms,
  overwrite = overwrite,
  write_options = write_options,
  require_complete_esm = require_complete_esm,
  write_separate_files = write_separate_files,
  write_combined_stack = write_combined_stack
)

aggregation_report <- base::do.call(rbind, aggregation_report)
rownames(aggregation_report) <- NULL

utils::write.csv(
  aggregation_report,
  file = file.path(out_base_dir, "forecast_shape_aggregation_report.csv"),
  row.names = FALSE
)

message("Done. Aggregated Shape outputs written to: ", out_base_dir)