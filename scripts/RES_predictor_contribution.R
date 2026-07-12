# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# RELATIVE PREDICTOR CONTRIBUTIONS IN FINAL ESM
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #


# -------------------------------------------------------------------------
# SETTINGS
# -------------------------------------------------------------------------

# Root directory containing model branches
model_root <- here::here("models")

# Output directory
output_dir <- here::here(
  "outputs",
  "tables",
  "predictor_contributions"
)

if (!base::dir.exists(output_dir)) {
  base::dir.create(
    output_dir,
    recursive = TRUE
  )
}

# Production branches
branches <- c(
  "recent_extrapol_weights_all_selected",
  "recent_noextrapol_weights_all_selected",
  "recent_noextrapol_weights_common"
)

# Expected spatial resolutions
allowed_grains <- c(
  "1000",
  "500",
  "200",
  "100"
)

# Pattern used to find model RDS files
#
# Narrow this pattern if directories contain additional unrelated RDS files.
rds_pattern <- "\\.rds$"


# -------------------------------------------------------------------------
# HELPER: EXTRACT BRANCH FROM FILE PATH
# -------------------------------------------------------------------------

extract_branch <- function(
    file_path,
    branches
) {
  
  hits <- branches[
    base::vapply(
      branches,
      FUN = function(branch) {
        base::grepl(
          branch,
          file_path,
          fixed = TRUE
        )
      },
      FUN.VALUE = logical(1)
    )
  ]
  
  if (base::length(hits) != 1L) {
    return(NA_character_)
  }
  
  hits[[1]]
}


# -------------------------------------------------------------------------
# HELPER: EXTRACT GRAIN AND SPECIES CODE FROM FILE PATH
# -------------------------------------------------------------------------

extract_path_metadata <- function(
    file_path,
    allowed_grains
) {
  
  path_clean <- base::gsub(
    "\\\\",
    "/",
    file_path
  )
  
  path_parts <- base::strsplit(
    path_clean,
    split = "/",
    fixed = TRUE
  )[[1]]
  
  grain_positions <- base::which(
    path_parts %in% allowed_grains
  )
  
  if (base::length(grain_positions) == 0L) {
    
    return(
      base::list(
        grain = NA_character_,
        species_code = NA_character_
      )
    )
  }
  
  # Use the last matching directory in the path
  grain_position <- utils::tail(
    grain_positions,
    1
  )
  
  grain <- path_parts[[grain_position]]
  
  species_code <- if (grain_position > 1L) {
    path_parts[[grain_position - 1L]]
  } else {
    NA_character_
  }
  
  base::list(
    grain = grain,
    species_code = species_code
  )
}


# -------------------------------------------------------------------------
# CALCULATE PREDICTOR CONTRIBUTIONS FOR ONE ESM OBJECT
# -------------------------------------------------------------------------

calculate_predictor_contributions <- function(
    esm_object,
    source_file = NA_character_,
    branch = NA_character_,
    grain = NA_character_,
    species_code = NA_character_,
    weight_tolerance = 1e-10
) {
  
  # -----------------------------------------------------------------------
  # Basic checks
  # -----------------------------------------------------------------------
  
  if (base::is.null(esm_object$model_scores)) {
    base::stop(
      "The object does not contain model_scores."
    )
  }
  
  model_scores <- esm_object$model_scores
  
  required_columns <- c(
    "algo",
    "pred1",
    "pred2",
    "keep",
    "refit_ok",
    "weight"
  )
  
  missing_columns <- base::setdiff(
    required_columns,
    base::names(model_scores)
  )
  
  if (base::length(missing_columns) > 0L) {
    
    base::stop(
      "Missing columns in model_scores: ",
      base::paste(
        missing_columns,
        collapse = ", "
      )
    )
  }
  
  # -----------------------------------------------------------------------
  # Optional check of effective model weights
  # -----------------------------------------------------------------------
  
  can_check_weights <-
    "weight_within_algo_refit" %in% base::names(model_scores) &&
    !base::is.null(esm_object$algorithm_scores) &&
    base::all(
      c(
        "algo",
        "weight_between_algos"
      ) %in% base::names(esm_object$algorithm_scores)
    )
  
  if (can_check_weights) {
    
    weight_check <- dplyr::left_join(
      model_scores,
      dplyr::select(
        esm_object$algorithm_scores,
        algo,
        weight_between_algos
      ),
      by = "algo"
    )
    
    weight_check <- dplyr::mutate(
      weight_check,
      reconstructed_weight =
        .data$weight_within_algo_refit *
        .data$weight_between_algos
    )
    
    weight_check <- dplyr::filter(
      weight_check,
      base::is.finite(.data$weight),
      base::is.finite(.data$reconstructed_weight)
    )
    
    if (base::nrow(weight_check) > 0L) {
      
      maximum_difference <- base::max(
        base::abs(
          weight_check$weight -
            weight_check$reconstructed_weight
        ),
        na.rm = TRUE
      )
      
      if (
        base::is.finite(maximum_difference) &&
        maximum_difference > weight_tolerance
      ) {
        
        base::warning(
          "Stored model weights differ from reconstructed weights. ",
          "Maximum absolute difference: ",
          base::format(
            maximum_difference,
            scientific = TRUE
          )
        )
      }
    }
  }
  
  # -----------------------------------------------------------------------
  # Keep only models entering the final ensemble
  # -----------------------------------------------------------------------
  
  kept_models <- dplyr::filter(
    model_scores,
    .data$keep %in% TRUE,
    .data$refit_ok %in% TRUE,
    base::is.finite(.data$weight),
    .data$weight > 0
  )
  
  if (base::nrow(kept_models) == 0L) {
    base::stop(
      "No positively weighted models entered the final ensemble."
    )
  }
  
  kept_models <- dplyr::mutate(
    kept_models,
    model_id = dplyr::row_number()
  )
  
  # -----------------------------------------------------------------------
  # Allocate one half of each bivariate model weight to each predictor
  # -----------------------------------------------------------------------
  
  predictor_1 <- dplyr::transmute(
    kept_models,
    model_id = .data$model_id,
    algo = .data$algo,
    predictor = .data$pred1,
    model_weight = .data$weight,
    allocated_weight = .data$weight / 2
  )
  
  predictor_2 <- dplyr::transmute(
    kept_models,
    model_id = .data$model_id,
    algo = .data$algo,
    predictor = .data$pred2,
    model_weight = .data$weight,
    allocated_weight = .data$weight / 2
  )
  
  predictor_weights <- dplyr::bind_rows(
    predictor_1,
    predictor_2
  )
  
  # -----------------------------------------------------------------------
  # Sum allocated weights for each predictor
  # -----------------------------------------------------------------------
  
  contributions <- dplyr::summarise(
    dplyr::group_by(
      predictor_weights,
      .data$predictor
    ),
    raw_contribution = base::sum(
      .data$allocated_weight,
      na.rm = TRUE
    ),
    n_kept_models = dplyr::n_distinct(
      .data$model_id
    ),
    n_algorithms = dplyr::n_distinct(
      .data$algo
    ),
    .groups = "drop"
  )
  
  # Normalize contributions to sum to one
  total_contribution <- base::sum(
    contributions$raw_contribution,
    na.rm = TRUE
  )
  
  contributions <- dplyr::mutate(
    contributions,
    relative_contribution =
      .data$raw_contribution /
      total_contribution,
    relative_contribution_pct =
      100 *
      .data$relative_contribution
  )
  
  # -----------------------------------------------------------------------
  # Model-level metadata
  # -----------------------------------------------------------------------
  
  species_name <- if (
    !base::is.null(esm_object$species) &&
    base::length(esm_object$species) > 0L
  ) {
    base::as.character(
      esm_object$species[[1]]
    )
  } else {
    NA_character_
  }
  
  n_input_predictors <- if (
    !base::is.null(esm_object$predictors)
  ) {
    base::length(
      base::unique(
        esm_object$predictors
      )
    )
  } else {
    base::length(
      base::unique(
        base::c(
          model_scores$pred1,
          model_scores$pred2
        )
      )
    )
  }
  
  n_kept_algorithms <- if (
    !base::is.null(esm_object$algorithm_scores) &&
    "keep" %in% base::names(esm_object$algorithm_scores)
  ) {
    base::sum(
      esm_object$algorithm_scores$keep %in% TRUE
    )
  } else {
    base::length(
      base::unique(
        kept_models$algo
      )
    )
  }
  
  sum_effective_model_weights <- base::sum(
    kept_models$weight,
    na.rm = TRUE
  )
  
  # -----------------------------------------------------------------------
  # Add metadata to every predictor
  # -----------------------------------------------------------------------
  
  contributions <- dplyr::mutate(
    contributions,
    branch = branch,
    species = species_name,
    species_code = species_code,
    grain = base::as.integer(grain),
    n_input_predictors = n_input_predictors,
    n_candidate_models = base::nrow(model_scores),
    n_kept_models_total = base::nrow(kept_models),
    n_kept_algorithms = n_kept_algorithms,
    sum_effective_model_weights =
      sum_effective_model_weights,
    source_file = source_file
  )
  
  contributions <- dplyr::select(
    contributions,
    branch,
    species,
    species_code,
    grain,
    predictor,
    relative_contribution,
    relative_contribution_pct,
    raw_contribution,
    n_kept_models,
    n_algorithms,
    n_input_predictors,
    n_candidate_models,
    n_kept_models_total,
    n_kept_algorithms,
    sum_effective_model_weights,
    source_file
  )
  
  contributions <- dplyr::arrange(
    contributions,
    dplyr::desc(
      .data$relative_contribution
    )
  )
  
  # -----------------------------------------------------------------------
  # Final sanity check
  # -----------------------------------------------------------------------
  
  contribution_sum <- base::sum(
    contributions$relative_contribution,
    na.rm = TRUE
  )
  
  if (
    !base::isTRUE(
      base::all.equal(
        contribution_sum,
        1,
        tolerance = 1e-10
      )
    )
  ) {
    
    base::warning(
      "Relative predictor contributions do not sum to one: ",
      contribution_sum
    )
  }
  
  contributions
}


# -------------------------------------------------------------------------
# FIND MODEL FILES
# -------------------------------------------------------------------------

rds_files <- base::list.files(
  path = model_root,
  pattern = rds_pattern,
  recursive = TRUE,
  full.names = TRUE
)

# Retain only files belonging to the selected production branches
rds_files <- rds_files[
  base::vapply(
    rds_files,
    FUN = function(file_path) {
      
      base::any(
        base::vapply(
          branches,
          FUN = function(branch) {
            base::grepl(
              branch,
              file_path,
              fixed = TRUE
            )
          },
          FUN.VALUE = logical(1)
        )
      )
    },
    FUN.VALUE = logical(1)
  )
]

if (base::length(rds_files) == 0L) {
  base::stop(
    "No RDS files were found in the selected production branches."
  )
}


# -------------------------------------------------------------------------
# PROCESS ALL RDS FILES
# -------------------------------------------------------------------------

predictor_contributions <- purrr::map_dfr(
  rds_files,
  function(file_path) {
    
    base::message(
      "Processing: ",
      file_path
    )
    
    esm_object <- base::tryCatch(
      base::readRDS(
        file_path
      ),
      error = function(error) {
        
        base::warning(
          "Could not read file: ",
          file_path,
          "\n",
          error$message
        )
        
        return(NULL)
      }
    )
    
    if (base::is.null(esm_object)) {
      return(NULL)
    }
    
    # Skip unrelated RDS objects
    if (
      !base::is.list(esm_object) ||
      base::is.null(esm_object$model_scores)
    ) {
      
      base::message(
        "Skipped: object does not contain model_scores."
      )
      
      return(NULL)
    }
    
    branch <- extract_branch(
      file_path = file_path,
      branches = branches
    )
    
    path_metadata <- extract_path_metadata(
      file_path = file_path,
      allowed_grains = allowed_grains
    )
    
    base::tryCatch(
      calculate_predictor_contributions(
        esm_object = esm_object,
        source_file = file_path,
        branch = branch,
        grain = path_metadata$grain,
        species_code = path_metadata$species_code
      ),
      error = function(error) {
        
        base::warning(
          "Could not process file: ",
          file_path,
          "\n",
          error$message
        )
        
        return(NULL)
      }
    )
  }
)

if (base::nrow(predictor_contributions) == 0L) {
  base::stop(
    "No predictor contributions were calculated."
  )
}


# -------------------------------------------------------------------------
# CHECK FOR MULTIPLE RDS FILES PER MODEL COMBINATION
# -------------------------------------------------------------------------

model_files <- dplyr::distinct(
  predictor_contributions,
  .data$branch,
  .data$species,
  .data$species_code,
  .data$grain,
  .data$source_file
)

duplicate_models <- dplyr::filter(
  dplyr::count(
    model_files,
    .data$branch,
    .data$species,
    .data$species_code,
    .data$grain,
    name = "n_rds_files"
  ),
  .data$n_rds_files > 1
)

if (base::nrow(duplicate_models) > 0L) {
  
  base::warning(
    "Multiple RDS files were found for some branch × species × grain ",
    "combinations. Inspect duplicate_models before interpreting results."
  )
  
  readr::write_csv(
    duplicate_models,
    base::file.path(
      output_dir,
      "duplicate_model_files.csv"
    )
  )
}


# -------------------------------------------------------------------------
# SAVE LONG-FORM TABLE
# -------------------------------------------------------------------------

readr::write_csv(
  predictor_contributions,
  base::file.path(
    output_dir,
    "predictor_contributions_all_branches.csv"
  )
)


# -------------------------------------------------------------------------
# SAVE ONE TABLE PER PRODUCTION BRANCH
# -------------------------------------------------------------------------

purrr::walk(
  branches,
  function(branch_name) {
    
    branch_table <- dplyr::filter(
      predictor_contributions,
      .data$branch == branch_name
    )
    
    if (base::nrow(branch_table) == 0L) {
      return(invisible(NULL))
    }
    
    readr::write_csv(
      branch_table,
      base::file.path(
        output_dir,
        base::paste0(
          "predictor_contributions_",
          branch_name,
          ".csv"
        )
      )
    )
  }
)


# -------------------------------------------------------------------------
# SAVE WIDE-FORM TABLE FOR TABLES AND HEATMAPS
# -------------------------------------------------------------------------

predictor_contributions_wide <- tidyr::pivot_wider(
  dplyr::select(
    predictor_contributions,
    branch,
    species,
    species_code,
    grain,
    predictor,
    relative_contribution_pct
  ),
  names_from = predictor,
  values_from = relative_contribution_pct
)

readr::write_csv(
  predictor_contributions_wide,
  base::file.path(
    output_dir,
    "predictor_contributions_wide.csv"
  )
)


# -------------------------------------------------------------------------
# PRINT BASIC CHECK
# -------------------------------------------------------------------------

contribution_check <- dplyr::summarise(
  dplyr::group_by(
    predictor_contributions,
    .data$branch,
    .data$species,
    .data$species_code,
    .data$grain,
    .data$source_file
  ),
  sum_relative_contribution = base::sum(
    .data$relative_contribution,
    na.rm = TRUE
  ),
  sum_relative_contribution_pct = base::sum(
    .data$relative_contribution_pct,
    na.rm = TRUE
  ),
  .groups = "drop"
)

base::print(
  contribution_check
)
