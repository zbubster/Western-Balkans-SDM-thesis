# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# PLOTS OF RELATIVE PREDICTOR CONTRIBUTIONS
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #


# -------------------------------------------------------------------------
# SETTINGS
# -------------------------------------------------------------------------

# Input table created by the predictor-contribution script
input_file <- here::here(
  "outputs",
  "tables",
  "predictor_contributions",
  "predictor_contributions_all_branches.csv"
)

# Main output directory
output_root <- here::here(
  "outputs",
  "figures",
  "predictor_contributions"
)

# Minimum contribution for displaying a value inside a heatmap cell
heatmap_label_threshold <- 3

# Grain order
grain_levels <- c(
  1000,
  500,
  200,
  100
)

# Species labels
species_labels <- c(
  GD = "Gentiana dinarica",
  GT = "Gentiana tergestina",
  PK = "Primula kitaibeliana",
  PO = "Phyteuma orbiculare",
  PP = "Phyteuma pseudorbiculare",
  SB = "Saxifraga blavii"
)

# Branch labels used in plot titles
branch_labels <- c(
  recent_extrapol_weights_all_selected =
    "recent_extrapol_weights_all_selected",
  
  recent_noextrapol_weights_all_selected =
    "recent_noextrapol_weights_all_selected",
  
  recent_noextrapol_weights_common =
    "recent_noextrapol_weights_common"
)

branches <- base::names(
  branch_labels
)


# -------------------------------------------------------------------------
# OUTPUT DIRECTORIES
# -------------------------------------------------------------------------

output_heatmaps <- base::file.path(
  output_root,
  "heatmaps"
)

output_dirs <- c(
  output_root,
  output_heatmaps,
  output_barplots
)

base::invisible(
  base::lapply(
    output_dirs,
    function(directory) {
      
      if (!base::dir.exists(directory)) {
        
        base::dir.create(
          directory,
          recursive = TRUE
        )
      }
    }
  )
)


# -------------------------------------------------------------------------
# HELPER FUNCTIONS
# -------------------------------------------------------------------------

safe_filename <- function(x) {
  
  x <- base::gsub(
    "[^[:alnum:]_-]+",
    "_",
    x
  )
  
  x <- base::gsub(
    "_+",
    "_",
    x
  )
  
  base::gsub(
    "^_|_$",
    "",
    x
  )
}


get_species_label <- function(
    species_code,
    species_name
) {
  
  result <- species_name
  
  valid_code <- !base::is.na(species_code) &
    species_code %in% base::names(species_labels)
  
  result[valid_code] <- species_labels[
    species_code[valid_code]
  ]
  
  result
}


# -------------------------------------------------------------------------
# READ DATA
# -------------------------------------------------------------------------

if (!base::file.exists(input_file)) {
  
  base::stop(
    "Input table does not exist:\n",
    input_file
  )
}

predictor_data <- readr::read_csv(
  input_file,
  show_col_types = FALSE
)

required_columns <- c(
  "branch",
  "species",
  "species_code",
  "grain",
  "predictor",
  "relative_contribution_pct"
)

missing_columns <- base::setdiff(
  required_columns,
  base::names(predictor_data)
)

if (base::length(missing_columns) > 0L) {
  
  base::stop(
    "Missing columns in input table: ",
    base::paste(
      missing_columns,
      collapse = ", "
    )
  )
}


# -------------------------------------------------------------------------
# PREPARE DATA
# -------------------------------------------------------------------------

predictor_data <- dplyr::mutate(
  predictor_data,
  
  grain = base::as.integer(
    .data$grain
  ),
  
  grain_factor = base::factor(
    .data$grain,
    levels = grain_levels,
    ordered = TRUE
  ),
  
  species_label = get_species_label(
    species_code = .data$species_code,
    species_name = .data$species
  )
)

predictor_data <- dplyr::filter(
  predictor_data,
  .data$branch %in% branches,
  base::is.finite(
    .data$relative_contribution_pct
  )
)


# -------------------------------------------------------------------------
# CHECK DUPLICATE PREDICTOR RECORDS
# -------------------------------------------------------------------------

duplicate_records <- dplyr::filter(
  dplyr::count(
    predictor_data,
    .data$branch,
    .data$species_label,
    .data$grain,
    .data$predictor,
    name = "n_records"
  ),
  .data$n_records > 1
)

if (base::nrow(duplicate_records) > 0L) {
  
  base::stop(
    "Duplicate branch × species × grain × predictor records were found. ",
    "Check the input table before plotting."
  )
}


# -------------------------------------------------------------------------
# 1. HEATMAPS
# -------------------------------------------------------------------------
#
# One heatmap is created for each branch × species combination.
#
# In the common branch, missing predictor × grain combinations are filled
# with zero because the predictor set should be shared among grains.
#
# In all_selected branches, missing combinations remain NA and are shown
# in grey because predictor sets can differ among grains.
# -------------------------------------------------------------------------

for (current_branch in branches) {
  
  branch_data <- dplyr::filter(
    predictor_data,
    .data$branch == current_branch
  )
  
  if (base::nrow(branch_data) == 0L) {
    next
  }
  
  branch_output_dir <- base::file.path(
    output_heatmaps,
    current_branch
  )
  
  if (!base::dir.exists(branch_output_dir)) {
    
    base::dir.create(
      branch_output_dir,
      recursive = TRUE
    )
  }
  
  branch_species <- base::sort(
    base::unique(
      branch_data$species_label
    )
  )
  
  # A common fill scale within the whole branch
  branch_fill_max <- base::max(
    branch_data$relative_contribution_pct,
    na.rm = TRUE
  )
  
  if (
    !base::is.finite(branch_fill_max) ||
    branch_fill_max <= 0
  ) {
    
    branch_fill_max <- 1
  }
  
  
  for (current_species in branch_species) {
    
    species_data <- dplyr::filter(
      branch_data,
      .data$species_label == current_species
    )
    
    current_grains <- grain_levels[
      grain_levels %in% species_data$grain
    ]
    
    current_predictors <- base::sort(
      base::unique(
        species_data$predictor
      )
    )
    
    heatmap_data <- tidyr::expand_grid(
      grain = current_grains,
      predictor = current_predictors
    )
    
    heatmap_data <- dplyr::left_join(
      heatmap_data,
      dplyr::select(
        species_data,
        grain,
        predictor,
        relative_contribution_pct
      ),
      by = c(
        "grain",
        "predictor"
      )
    )
    
    # Only the common branch receives zero for missing combinations
    if (
      current_branch ==
      "recent_noextrapol_weights_common"
    ) {
      
      heatmap_data <- dplyr::mutate(
        heatmap_data,
        
        relative_contribution_pct =
          tidyr::replace_na(
            .data$relative_contribution_pct,
            0
          )
      )
    }
    
    heatmap_data <- dplyr::mutate(
      heatmap_data,
      
      grain_factor = base::factor(
        .data$grain,
        levels = grain_levels,
        ordered = TRUE
      )
    )
    
    # Order predictors according to their mean contribution
    predictor_order <- dplyr::summarise(
      dplyr::group_by(
        heatmap_data,
        .data$predictor
      ),
      
      mean_contribution = base::mean(
        .data$relative_contribution_pct,
        na.rm = TRUE
      ),
      
      .groups = "drop"
    )
    
    predictor_order <- dplyr::arrange(
      predictor_order,
      .data$mean_contribution
    )
    
    heatmap_data <- dplyr::mutate(
      heatmap_data,
      
      predictor = base::factor(
        .data$predictor,
        levels = predictor_order$predictor
      ),
      
      contribution_label = dplyr::case_when(
        
        base::is.na(
          .data$relative_contribution_pct
        ) ~ "",
        
        .data$relative_contribution_pct >=
          heatmap_label_threshold ~
          base::sprintf(
            "%.1f",
            .data$relative_contribution_pct
          ),
        
        TRUE ~ ""
      )
    )
    
    heatmap_plot <- ggplot2::ggplot(
      heatmap_data,
      ggplot2::aes(
        x = .data$grain_factor,
        y = .data$predictor,
        fill = .data$relative_contribution_pct
      )
    ) +
      ggplot2::geom_tile(
        colour = "white",
        linewidth = 0.3
      ) +
      ggplot2::geom_text(
        ggplot2::aes(
          label = .data$contribution_label
        ),
        size = 3
      ) +
      ggplot2::scale_fill_viridis_c(
        name = "Relativní\npříspěvek [%]",
        limits = c(
          0,
          branch_fill_max
        ),
        na.value = "grey85"
      ) +
      ggplot2::labs(
        title = current_species,
        #subtitle = branch_labels[[current_branch]],
        x = "Rozlišení [m]",
        y = NULL
      ) +
      ggplot2::theme_minimal(
        base_size = 11
      ) +
      ggplot2::theme(
        panel.grid = ggplot2::element_blank(),
        
        plot.title = ggplot2::element_text(
          face = "italic"
        ),
        
        legend.position = "right"
      )
    
    figure_height <- base::max(
      4.5,
      0.38 * base::length(current_predictors) + 2
    )
    
    output_file <- base::file.path(
      branch_output_dir,
      base::paste0(
        safe_filename(current_species),
        "_predictor_contributions.png"
      )
    )
    
    ggplot2::ggsave(
      filename = output_file,
      plot = heatmap_plot,
      width = 7,
      height = figure_height,
      dpi = 300,
      bg = "white"
    )
  }
}


# -------------------------------------------------------------------------
# FINISHED
# -------------------------------------------------------------------------

base::message(
  "Predictor contribution plots were saved to:\n",
  output_root
)
