# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# COMMON RESPONSE CURVES BY GRAIN
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
#
# Reads already calculated response_curves.rds files from the
# recent_noextrapol_weights_common branch and compares the final
# predictor-specific ensemble response curves among spatial grains.
#
# Outputs for each species:
#   - one combined line plot per numeric predictor,
#   - one combined grouped bar plot per factor predictor,
#   - fixed Y-axis from 0 to 1,
#   - colours distinguish individual grains.
#
# No models or response curves are recalculated.
#
# Expected directory structure:
# models/ESM/
#   recent_noextrapol_weights_common/
#     GD/
#       1000/response_curves.rds
#       500/response_curves.rds
#       200/response_curves.rds
#       100/response_curves.rds
#
# Output directory:
# models/ESM/
#   recent_noextrapol_weights_common/
#     GD/resp_curv_by_grain/
#
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# SETTINGS
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

modelling_id <- "recent_noextrapol_weights_common"

models_root <- here::here(
  "models",
  "ESM",
  modelling_id
)

# NULL = discover all species directories automatically
species <- NULL

# Order used in the legend and plot layers
grains <- base::c(1000L, 500L, 200L, 100L)

# TRUE = stop processing a species if any requested grain is missing
# FALSE = plot all available requested grains
require_all_grains <- TRUE

png_width <- 650L
png_height <- 450L
png_res <- 120L

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# CHECK INPUT DIRECTORY
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

if (!base::dir.exists(models_root)) {
  base::stop("Model directory does not exist: ", models_root)
}

if (base::is.null(species)) {
  species_paths <- base::list.dirs(
    path = models_root,
    full.names = TRUE,
    recursive = FALSE
  )
  
  species <- base::basename(species_paths)
  species <- species[base::nzchar(species)]
  species <- base::sort(species)
}

if (base::length(species) == 0L) {
  base::stop("No species directories found below: ", models_root)
}

# Ordered factor used by both numeric and factor plots
grain_levels <- base::paste0(grains, " m")

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# HELPERS
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

save_plot_png <- function(plot_object, filename) {
  grDevices::png(
    filename = filename,
    width = png_width,
    height = png_height,
    res = png_res
  )
  
  base::tryCatch(
    base::print(plot_object),
    finally = grDevices::dev.off()
  )
  
  base::invisible(filename)
}

read_species_response_curves <- function(species_code) {
  response_list <- base::vector(
    mode = "list",
    length = base::length(grains)
  )
  
  names(response_list) <- base::as.character(grains)
  missing_files <- base::character(0)
  
  for (grain in grains) {
    response_file <- base::file.path(
      models_root,
      species_code,
      base::as.character(grain),
      "response_curves.rds"
    )
    
    if (!base::file.exists(response_file)) {
      missing_files <- base::c(missing_files, response_file)
      next
    }
    
    rc <- base::readRDS(response_file)
    
    required_columns <- base::c(
      "variable",
      "var_type",
      "curve_level",
      "value_num",
      "value_chr",
      "prediction"
    )
    
    missing_columns <- base::setdiff(
      required_columns,
      base::names(rc)
    )
    
    if (base::length(missing_columns) > 0L) {
      base::stop(
        "File ", response_file,
        " is missing columns: ",
        base::paste(missing_columns, collapse = ", ")
      )
    }
    
    # Only the final predictor-specific ensemble curve is needed.
    rc <- rc[
      rc$curve_level == "ensemble",
      required_columns,
      drop = FALSE
    ]
    
    rc$grain <- grain
    rc$grain_label <- base::factor(
      base::paste0(grain, " m"),
      levels = grain_levels,
      ordered = TRUE
    )
    
    response_list[[base::as.character(grain)]] <- rc
  }
  
  if (
    require_all_grains &&
    base::length(missing_files) > 0L
  ) {
    base::stop(
      "Missing response_curves.rds for species ", species_code, ":\n",
      base::paste(missing_files, collapse = "\n")
    )
  }
  
  response_list <- response_list[
    !base::vapply(response_list, base::is.null, logical(1))
  ]
  
  if (base::length(response_list) == 0L) {
    base::stop(
      "No response_curves.rds files found for species: ",
      species_code
    )
  }
  
  result <- base::do.call(base::rbind, response_list)
  base::rownames(result) <- NULL
  result
}

plot_numeric_by_grain <- function(response_data, predictor) {
  df <- response_data[
    response_data$variable == predictor &
      response_data$var_type == "numeric" &
      base::is.finite(response_data$value_num) &
      base::is.finite(response_data$prediction),
    ,
    drop = FALSE
  ]
  
  if (base::nrow(df) == 0L) {
    base::stop(
      "No numeric ensemble response curves found for: ",
      predictor
    )
  }
  
  ggplot2::ggplot(
    data = df,
    mapping = ggplot2::aes(
      x = value_num,
      y = prediction,
      colour = grain_label,
      group = grain_label
    )
  ) +
    ggplot2::geom_line(linewidth = 1.05) +
    ggplot2::scale_colour_viridis_d(
      name = "Grain",
      direction = -1,
      end = 0.85,
      drop = FALSE
    ) +
    ggplot2::scale_y_continuous(
      breaks = base::seq(0, 1, by = 0.2),
      expand = ggplot2::expansion(mult = base::c(0, 0))
    ) +
    ggplot2::coord_cartesian(
      ylim = base::c(0, 1),
      expand = FALSE
    ) +
    ggplot2::labs(
      x = predictor,
      y = "Pravděpodobnost",
      title = base::paste(
        "Křivka odpovědi:",
        predictor
      )
    ) +
    ggplot2::theme_bw() +
    ggplot2::theme(
      legend.position = "right"
    )
}

plot_factor_by_grain <- function(response_data, predictor) {
  df <- response_data[
    response_data$variable == predictor &
      response_data$var_type == "factor" &
      !base::is.na(response_data$value_chr) &
      base::is.finite(response_data$prediction),
    ,
    drop = FALSE
  ]
  
  if (base::nrow(df) == 0L) {
    base::stop(
      "No factor ensemble response profiles found for: ",
      predictor
    )
  }
  
  ggplot2::ggplot(
    data = df,
    mapping = ggplot2::aes(
      x = value_chr,
      y = prediction,
      fill = grain_label
    )
  ) +
    ggplot2::geom_col(
      position = ggplot2::position_dodge(width = 0.8),
      width = 0.75
    ) +
    ggplot2::scale_fill_viridis_d(
      name = "Grain",
      direction = -1,
      end = 0.85,
      drop = FALSE
    ) +
    ggplot2::scale_y_continuous(
      breaks = base::seq(0, 1, by = 0.2),
      expand = ggplot2::expansion(mult = base::c(0, 0))
    ) +
    ggplot2::coord_cartesian(
      ylim = base::c(0, 1),
      expand = FALSE
    ) +
    ggplot2::labs(
      x = predictor,
      y = "Pravděpodobnost",
      title = base::paste(
        "Křivka odpovědi:",
        predictor
      )
    ) +
    ggplot2::theme_bw() +
    ggplot2::theme(
      legend.position = "right"
    )
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# CREATE PLOTS
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

run_summary <- base::vector(
  mode = "list",
  length = base::length(species)
)

for (i in base::seq_along(species)) {
  species_code <- species[[i]]
  start_time <- base::Sys.time()
  
  base::message(
    "__", modelling_id,
    "__", species_code,
    "__"
  )
  
  run_summary[[i]] <- base::tryCatch(
    {
      response_data <- read_species_response_curves(species_code)
      
      output_dir <- base::file.path(
        models_root,
        species_code,
        "resp_curv_by_grain"
      )
      
      if (!base::dir.exists(output_dir)) {
        base::dir.create(
          path = output_dir,
          recursive = TRUE,
          showWarnings = FALSE
        )
      }
      
      numeric_predictors <- base::sort(base::unique(
        response_data$variable[
          response_data$var_type == "numeric"
        ]
      ))
      
      factor_predictors <- base::sort(base::unique(
        response_data$variable[
          response_data$var_type == "factor"
        ]
      ))
      
      for (predictor in numeric_predictors) {
        plot_object <- plot_numeric_by_grain(
          response_data = response_data,
          predictor = predictor
        )
        
        save_plot_png(
          plot_object = plot_object,
          filename = base::file.path(
            output_dir,
            base::paste0(
              predictor,
              "_simple_by_grain.png"
            )
          )
        )
      }
      
      for (predictor in factor_predictors) {
        plot_object <- plot_factor_by_grain(
          response_data = response_data,
          predictor = predictor
        )
        
        save_plot_png(
          plot_object = plot_object,
          filename = base::file.path(
            output_dir,
            base::paste0(
              predictor,
              "_barplot_by_grain.png"
            )
          )
        )
      }
      
      elapsed_seconds <- base::as.numeric(base::difftime(
        base::Sys.time(),
        start_time,
        units = "secs"
      ))
      
      base::data.frame(
        modelling_id = modelling_id,
        species = species_code,
        status = "ok",
        n_grains = base::length(base::unique(response_data$grain)),
        n_numeric_predictors = base::length(numeric_predictors),
        n_factor_predictors = base::length(factor_predictors),
        elapsed_seconds = elapsed_seconds,
        message = NA_character_,
        stringsAsFactors = FALSE
      )
    },
    error = function(e) {
      elapsed_seconds <- base::as.numeric(base::difftime(
        base::Sys.time(),
        start_time,
        units = "secs"
      ))
      
      base::warning(
        "Failed for ", species_code, ": ",
        base::conditionMessage(e),
        call. = FALSE
      )
      
      base::data.frame(
        modelling_id = modelling_id,
        species = species_code,
        status = "error",
        n_grains = NA_integer_,
        n_numeric_predictors = NA_integer_,
        n_factor_predictors = NA_integer_,
        elapsed_seconds = elapsed_seconds,
        message = base::conditionMessage(e),
        stringsAsFactors = FALSE
      )
    }
  )
}

run_summary <- base::do.call(base::rbind, run_summary)
base::rownames(run_summary) <- NULL

summary_csv <- base::file.path(
  models_root,
  "response_curves_by_grain_summary.csv"
)

utils::write.csv(
  x = run_summary,
  file = summary_csv,
  row.names = FALSE,
  na = ""
)

base::print(run_summary)
base::message("Summary written to: ", summary_csv)