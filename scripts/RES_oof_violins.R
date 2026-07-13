# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# OOF PREDICTIONS VS. OBSERVATIONS
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Input and output directories
input_root <- here::here(
  "models",
  "ESM"
)

output_root <- here::here(
  "outputs",
  "ESM"
)

# Output plot settings
plot_filename <- "OOF_prediction.png"

plot_width <- 5
plot_height <- 5
plot_dpi <- 300

# Full species names used in map titles
species_names <- c(
  GD = "Gentiana dinarica",
  GT = "Gentiana tergestina",
  SB = "Saxifraga blavii",
  PK = "Primula kitaibeliana",
  PO = "Phyteuma orbiculare",
  PP = "Phyteuma pseudorbiculare"
)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# CHECK DIRECTORIES
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

if (!dir.exists(input_root)) {
  stop(
    "Input directory does not exist: ",
    input_root
  )
}

if (!dir.exists(output_root)) {
  dir.create(
    output_root,
    recursive = TRUE
  )
}


# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# HELPER FUNCTIONS
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Convert presence/absence values safely to 0/1 numeric values
convert_observations <- function(x) {
  
  if (is.logical(x)) {
    return(as.integer(x))
  }
  
  if (is.factor(x)) {
    x <- as.character(x)
  }
  
  suppressWarnings(
    as.numeric(x)
  )
}


# Create one OOF prediction plot
make_oof_plot <- function(
    model_file,
    input_root,
    output_root,
    plot_filename = "OOF_prediction.png",
    width = 5,
    height = 5,
    dpi = 300
) {
  
  # Normalize paths so that the relative model directory can be extracted
  input_root_normalized <- normalizePath(
    input_root,
    winslash = "/",
    mustWork = TRUE
  )
  
  model_file_normalized <- normalizePath(
    model_file,
    winslash = "/",
    mustWork = TRUE
  )
  
  # Relative path below models/ESM/
  relative_file <- substring(
    model_file_normalized,
    nchar(input_root_normalized) + 2
  )
  
  relative_directory <- dirname(
    relative_file
  )
  
  # Equivalent output directory below outputs/ESM/
  output_directory <- file.path(
    output_root,
    relative_directory
  )
  
  if (!dir.exists(output_directory)) {
    dir.create(
      output_directory,
      recursive = TRUE
    )
  }
  
  output_file <- file.path(
    output_directory,
    plot_filename
  )
  
  # Read model object
  model_data <- readRDS(
    model_file
  )
  
  # Check required model components
  if (
    is.null(model_data$data) ||
    is.null(model_data$data$observ)
  ) {
    stop(
      "Object does not contain model_data$data$observ."
    )
  }
  
  if (is.null(model_data$oof_pred)) {
    stop(
      "Object does not contain model_data$oof_pred."
    )
  }
  
  observ <- convert_observations(
    model_data$data$observ
  )
  
  oof_pred <- as.numeric(
    model_data$oof_pred
  )
  
  if (length(observ) != length(oof_pred)) {
    stop(
      "Lengths of observ and oof_pred differ: ",
      length(observ),
      " versus ",
      length(oof_pred),
      "."
    )
  }
  
  # Prepare data for plotting
  df <- data.frame(
    observ = observ,
    oof_pred = oof_pred
  )
  
  # Retain only valid observations and predictions
  df <- df[
    stats::complete.cases(
      df[, c("observ", "oof_pred")]
    ) &
      is.finite(df$observ) &
      is.finite(df$oof_pred),
    ,
    drop = FALSE
  ]
  
  # Retain only binary observations
  df <- df[
    df$observ %in% c(0, 1),
    ,
    drop = FALSE
  ]
  
  if (nrow(df) == 0) {
    stop(
      "No valid OOF predictions remain after filtering."
    )
  }
  
  if (!all(c(0, 1) %in% df$observ)) {
    stop(
      "Valid data do not contain both absences and presences."
    )
  }
  
  # Number of valid absence and presence observations
  n_absence <- sum(
    df$observ == 0
  )
  
  n_presence <- sum(
    df$observ == 1
  )
  
  # Median OOF prediction for each observed class
  median_df <- stats::aggregate(
    oof_pred ~ observ,
    data = df,
    FUN = stats::median
  )
  
  median_df$x <- match(
    median_df$observ,
    c(0, 1)
  )
  
  # Extract species and grain from the directory structure:
  # .../ESM/<model_branch>/<species>/<grain>/esm_fit_bivariate.rds
  
  model_directory <- dirname(
    model_file_normalized
  )
  
  grain <- basename(
    model_directory
  )
  
  species <- basename(
    dirname(model_directory)
  )
  
  # Map species code to full species name
  species_full <- if (
    species %in% names(species_names)
  ) {
    unname(species_names[[species]])
  } else {
    species
  }
  
  # Extract final OOF Somers' D from the model object
  somers_d <- if (
    !is.null(model_data$oof_somers_d) &&
    length(model_data$oof_somers_d) == 1 &&
    is.finite(as.numeric(model_data$oof_somers_d))
  ) {
    sprintf(
      "%.3f",
      as.numeric(model_data$oof_somers_d)
    )
  } else {
    "NA"
  }
  
  # Construct plot
  oof_plot <- ggplot2::ggplot(
    data = df,
    ggplot2::aes(
      x = factor(
        observ,
        levels = c(0, 1),
        labels = c("Absence", "Presence")
      ),
      y = oof_pred,
      fill = factor(
        observ,
        levels = c(0, 1),
        labels = c("Absence", "Presence")
      )
    )
  ) +
    ggplot2::geom_violin(
      trim = FALSE,
      alpha = 0.75
    ) +
    ggplot2::geom_segment(
      data = median_df,
      ggplot2::aes(
        x = x - 0.325,
        xend = x + 0.325,
        y = oof_pred,
        yend = oof_pred,
        linetype = "Median"
      ),
      inherit.aes = FALSE,
      colour = "firebrick",
      linewidth = 0.5
    ) +
    ggplot2::geom_jitter(
      width = 0.08,
      height = 0,
      alpha = 0.4
    ) +
    ggplot2::scale_x_discrete(
      labels = c(
        "Absence" = paste0(
          "Absence\nn = ",
          n_absence
        ),
        "Presence" = paste0(
          "Presence\nn = ",
          n_presence
        )
      )
    ) +
    ggplot2::scale_fill_manual(
      values = c(
        "Absence" = "steelblue",
        "Presence" = "orange"
      ),
      guide = "none"
    ) +
    ggplot2::scale_linetype_manual(
      name = NULL,
      values = c(
        "Median" = "solid"
      )
    ) +
    ggplot2::guides(
      linetype = ggplot2::guide_legend(
        override.aes = list(
          colour = "firebrick",
          linewidth = 0.5
        )
      )
    ) +
    ggplot2::coord_cartesian(
      ylim = c(0, 1)
    ) +
    ggplot2::labs(
      title = paste0(
        species_full,
        "; ",
        grain,
        " m; Somersovo D: ",
        somers_d
      ),
      x = "Reference",
      y = "Predikovaná vhodnost"
    ) +
    ggplot2::theme_linedraw() +
    ggplot2::theme(
      plot.title = ggplot2::element_text(
        hjust = 0.5
      ),
      legend.position = "inside",
      legend.position.inside = c(0.97, 0.97),
      legend.justification = c(1, 1),
      legend.key.width = grid::unit(
        0.8,
        "cm"
      ),
      legend.background = ggplot2::element_rect(
        fill = "white",
        colour = "grey",
        linewidth = 0.4
      )
    )
  
  # Save plot
  ggplot2::ggsave(
    filename = output_file,
    plot = oof_plot,
    width = width,
    height = height,
    units = "in",
    dpi = dpi,
    bg = "white"
  )
  
  invisible(output_file)
}


# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# FIND MODEL OBJECTS
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

model_files <- list.files(
  path = input_root,
  pattern = "^esm_fit_bivariate\\.rds$",
  recursive = TRUE,
  full.names = TRUE
)

if (length(model_files) == 0) {
  stop(
    "No esm_fit_bivariate.rds files were found in: ",
    input_root
  )
}

message(
  "Found ",
  length(model_files),
  " model objects."
)


# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# CREATE PLOTS
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

successful_models <- character(0)
failed_models <- character(0)

for (i in seq_along(model_files)) {
  
  model_file <- model_files[[i]]
  
  message(
    "[",
    i,
    "/",
    length(model_files),
    "] ",
    model_file
  )
  
  result <- tryCatch(
    {
      output_file <- make_oof_plot(
        model_file = model_file,
        input_root = input_root,
        output_root = output_root,
        plot_filename = plot_filename,
        width = plot_width,
        height = plot_height,
        dpi = plot_dpi
      )
      
      successful_models <- c(
        successful_models,
        model_file
      )
      
      message(
        "  Saved: ",
        output_file
      )
      
      TRUE
    },
    error = function(e) {
      
      failed_models <<- c(
        failed_models,
        model_file
      )
      
      warning(
        "Plot could not be created for:\n",
        model_file,
        "\nReason: ",
        conditionMessage(e),
        call. = FALSE
      )
      
      FALSE
    }
  )
}


# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# SUMMARY
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

message(
  "\nFinished."
)

message(
  "Successfully processed: ",
  length(successful_models)
)

message(
  "Failed: ",
  length(failed_models)
)

if (length(failed_models) > 0) {
  
  message(
    "\nFailed model objects:"
  )
  
  for (failed_file in failed_models) {
    message(
      "  - ",
      failed_file
    )
  }
}
