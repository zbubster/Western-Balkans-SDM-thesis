# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# OOF PREDICTIONS VS. OBSERVATIONS — COMMON BRANCHES
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
plot_filename <- "OOF_prediction_common_grains.png"

plot_width <- 6
plot_height <- 5
plot_dpi <- 300

# Full species names used in plot titles
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


# Extract model branch, species and grain from the directory structure
extract_model_information <- function(model_file) {
  
  model_file_normalized <- normalizePath(
    model_file,
    winslash = "/",
    mustWork = TRUE
  )
  
  model_directory <- dirname(
    model_file_normalized
  )
  
  grain <- basename(
    model_directory
  )
  
  species <- basename(
    dirname(model_directory)
  )
  
  model_branch <- basename(
    dirname(
      dirname(model_directory)
    )
  )
  
  data.frame(
    model_file = model_file_normalized,
    model_branch = model_branch,
    species = species,
    grain = grain,
    stringsAsFactors = FALSE
  )
}


# Read and prepare OOF predictions from one model object
read_oof_predictions <- function(
    model_file,
    grain
) {
  
  model_data <- readRDS(
    model_file
  )
  
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
  
  df <- data.frame(
    observ = observ,
    oof_pred = oof_pred,
    grain = as.character(grain),
    stringsAsFactors = FALSE
  )
  
  # Retain only complete and finite values
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
  
  df
}


# Create one combined plot for all grains of one species and branch
make_common_grain_plot <- function(
    model_information,
    output_root,
    plot_filename = "OOF_prediction_common_grains.png",
    width = 6,
    height = 5,
    dpi = 300
) {
  
  model_branch <- unique(
    model_information$model_branch
  )
  
  species <- unique(
    model_information$species
  )
  
  if (length(model_branch) != 1) {
    stop(
      "More than one model branch was supplied."
    )
  }
  
  if (length(species) != 1) {
    stop(
      "More than one species was supplied."
    )
  }
  
  # Read all available grains
  plot_data_list <- vector(
    mode = "list",
    length = nrow(model_information)
  )
  
  for (i in seq_len(nrow(model_information))) {
    
    plot_data_list[[i]] <- read_oof_predictions(
      model_file = model_information$model_file[[i]],
      grain = model_information$grain[[i]]
    )
  }
  
  plot_data <- do.call(
    what = rbind,
    args = plot_data_list
  )
  
  if (!all(c(0, 1) %in% plot_data$observ)) {
    stop(
      "Combined data do not contain both absences and presences."
    )
  }
  
  # Order grains from coarsest to finest
  grain_numeric <- suppressWarnings(
    as.numeric(
      unique(plot_data$grain)
    )
  )
  
  if (all(is.finite(grain_numeric))) {
    
    grain_levels <- as.character(
      sort(
        grain_numeric,
        decreasing = TRUE
      )
    )
    
  } else {
    
    grain_levels <- sort(
      unique(plot_data$grain)
    )
  }
  
  plot_data$grain <- factor(
    plot_data$grain,
    levels = grain_levels
  )
  
  plot_data$reference <- factor(
    plot_data$observ,
    levels = c(0, 1),
    labels = c(
      "Absence",
      "Presence"
    )
  )
  
  # Full species name
  species_full <- if (
    species %in% names(species_names)
  ) {
    unname(
      species_names[[species]]
    )
  } else {
    species
  }
  
  # Colours are generated according to the number of available grains
  grain_colours <- stats::setNames(
    grDevices::hcl.colors(
      n = length(grain_levels),
      palette = "Dark 3"
    ),
    grain_levels
  )
  
  dodge_position <- ggplot2::position_dodge(
    width = 0.8
  )
  
  # Construct plot
  oof_plot <- ggplot2::ggplot(
    data = plot_data,
    ggplot2::aes(
      x = reference,
      y = oof_pred,
      fill = grain,
      group = interaction(
        reference,
        grain
      )
    )
  ) +
    ggplot2::geom_boxplot(
      width = 0.68,
      alpha = 0.85,
      position = dodge_position,
      outlier.alpha = 0.45,
      outlier.size = 1.2,
      linewidth = 0.45
    ) +
    
    # Overlay the median with a firebrick line
    ggplot2::stat_summary(
      fun = stats::median,
      fun.min = stats::median,
      fun.max = stats::median,
      geom = "crossbar",
      width = 0.52,
      position = dodge_position,
      colour = "firebrick",
      linewidth = 0.65,
      show.legend = FALSE
    ) +
    ggplot2::scale_fill_manual(
      name = "Rozlišení [m]",
      values = grain_colours,
      breaks = grain_levels
    ) +
    ggplot2::coord_cartesian(
      ylim = c(0, 1)
    ) +
    ggplot2::labs(
      title = species_full,
      #subtitle = model_branch,
      x = "Reference",
      y = "Predikovaná vhodnost"
    ) +
    ggplot2::theme_linedraw() +
    ggplot2::theme(
      plot.title = ggplot2::element_text(
        hjust = 0.5
      ),
      plot.subtitle = ggplot2::element_text(
        hjust = 0.5
      ),
      legend.position = "bottom",
      legend.box = "horizontal",
      legend.key.width = grid::unit(
        0.8,
        "cm"
      )
    )
  
  # Output is stored above the individual grain directories
  output_directory <- file.path(
    output_root,
    model_branch,
    species
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
# FIND COMMON MODEL OBJECTS
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

model_information_list <- lapply(
  model_files,
  extract_model_information
)

model_information <- do.call(
  what = rbind,
  args = model_information_list
)

# Retain only model branches ending in "_common"
model_information <- model_information[
  grepl(
    pattern = "_common$",
    x = model_information$model_branch
  ),
  ,
  drop = FALSE
]

if (nrow(model_information) == 0) {
  stop(
    "No model objects from branches ending in '_common' were found."
  )
}

message(
  "Found ",
  nrow(model_information),
  " model objects in common branches."
)


# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# GROUP MODELS BY BRANCH AND SPECIES
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

model_groups <- split(
  model_information,
  interaction(
    model_information$model_branch,
    model_information$species,
    drop = TRUE,
    lex.order = TRUE
  )
)

message(
  "Plots to create: ",
  length(model_groups)
)


# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# CREATE PLOTS
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

successful_groups <- character(0)
failed_groups <- character(0)

for (i in seq_along(model_groups)) {
  
  current_group <- model_groups[[i]]
  
  group_name <- paste0(
    unique(current_group$model_branch),
    " / ",
    unique(current_group$species)
  )
  
  message(
    "[",
    i,
    "/",
    length(model_groups),
    "] ",
    group_name
  )
  
  tryCatch(
    {
      output_file <- make_common_grain_plot(
        model_information = current_group,
        output_root = output_root,
        plot_filename = plot_filename,
        width = plot_width,
        height = plot_height,
        dpi = plot_dpi
      )
      
      successful_groups <- c(
        successful_groups,
        group_name
      )
      
      message(
        "  Saved: ",
        output_file
      )
    },
    error = function(e) {
      
      failed_groups <<- c(
        failed_groups,
        group_name
      )
      
      warning(
        "Plot could not be created for:\n",
        group_name,
        "\nReason: ",
        conditionMessage(e),
        call. = FALSE
      )
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
  length(successful_groups)
)

message(
  "Failed: ",
  length(failed_groups)
)

if (length(failed_groups) > 0) {
  
  message(
    "\nFailed model groups:"
  )
  
  for (failed_group in failed_groups) {
    message(
      "  - ",
      failed_group
    )
  }
}