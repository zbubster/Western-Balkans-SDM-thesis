# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# RES ‒ ESM MODEL SUMMARY TABLES
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Full species names and codes used in output tables.
species_lookup <- c(
  GD = "Gentiana dinarica",
  GT = "Gentiana tergestina",
  PK = "Primula kitaibeliana",
  PO = "Phyteuma orbiculare",
  PP = "Phyteuma pseudorbiculare",
  SB = "Saxifraga blavii"
)

# Production branches to process.
branches <- c(
  "recent_extrapol_weights_all_selected",
  "recent_noextrapol_weights_all_selected",
  "recent_noextrapol_weights_common"
)

# Root directory containing the three production branches.
esm_root <- here::here("models", "ESM")

# Output directory for summary tables.
output_dir <- here::here("outputs", "tables", "ESM_model_summary")

# Grains expected in file paths or file names.
allowed_grains <- c(1000L, 500L, 200L, 100L)

# Order used in the output tables.
grain_order <- c(1000L, 500L, 200L, 100L)

# Number of decimal places used for Somers' D in the exported table.
somers_digits <- 3L


# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# FUNCTIONS
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

extract_grain <- function(path, allowed_grains) {
  pattern <- base::paste0(
    "(?<![0-9])(",
    base::paste(allowed_grains, collapse = "|"),
    ")(?![0-9])"
  )

  hits <- stringr::str_extract_all(path, pattern)[[1]]
  hits <- base::unique(base::as.integer(hits))
  hits <- hits[!base::is.na(hits)]

  if (base::length(hits) != 1L) {
    base::stop(
      "Could not identify exactly one grain in path:\n",
      path,
      "\nDetected values: ",
      base::paste(hits, collapse = ", ")
    )
  }

  hits[[1]]
}


extract_species_code <- function(path, species_name, species_lookup) {
  normalized_path <- base::normalizePath(
    path,
    winslash = "/",
    mustWork = FALSE
  )

  path_parts <- base::strsplit(normalized_path, "/", fixed = TRUE)[[1]]
  code_hits <- base::intersect(path_parts, base::names(species_lookup))

  if (base::length(code_hits) == 1L) {
    return(code_hits[[1]])
  }

  name_hits <- base::names(species_lookup)[species_lookup == species_name]

  if (base::length(name_hits) == 1L) {
    return(name_hits[[1]])
  }

  NA_character_
}


is_esm_model <- function(x) {
  required_items <- c(
    "species",
    "predictors",
    "algorithms",
    "model_scores",
    "oof_somers_d"
  )

  base::is.list(x) && base::all(required_items %in% base::names(x))
}


summarise_esm_file <- function(
    path,
    branch,
    species_lookup,
    allowed_grains,
    somers_digits = 3L
) {
  model <- base::readRDS(path)

  # Recursive branch directories may contain other RDS files.
  # These are skipped rather than treated as ESM model objects.
  if (!is_esm_model(model)) {
    base::message("Skipping non-ESM RDS: ", path)
    return(NULL)
  }

  if (!base::is.data.frame(model$model_scores)) {
    base::stop("model_scores is not a data.frame in: ", path)
  }

  required_score_columns <- c("pred1", "pred2", "keep")
  missing_score_columns <- base::setdiff(
    required_score_columns,
    base::names(model$model_scores)
  )

  if (base::length(missing_score_columns) > 0L) {
    base::stop(
      "Missing model_scores columns in ", path, ": ",
      base::paste(missing_score_columns, collapse = ", ")
    )
  }

  model_scores <- model$model_scores
  predictors <- base::as.character(model$predictors)
  algorithms <- base::as.character(model$algorithms)

  n_predictors <- base::length(predictors)
  n_algorithms <- base::length(algorithms)

  # Unique predictor pairs, irrespective of modelling algorithm.
  predictor_pairs <- model_scores |>
    dplyr::transmute(
      pred_a = base::pmin(.data$pred1, .data$pred2),
      pred_b = base::pmax(.data$pred1, .data$pred2)
    ) |>
    dplyr::distinct()

  n_candidate_pairs <- base::nrow(predictor_pairs)

  # Algorithm-specific bivariate candidates.
  # Example: choose(14, 2) predictor pairs * 6 algorithms = 546 models.
  n_candidate_biv_models <- base::nrow(model_scores)

  # A model is counted as retained only when it passed CV filtering and,
  # where available, was successfully refitted on the complete dataset.
  kept <- !base::is.na(model_scores$keep) & model_scores$keep

  if ("refit_ok" %in% base::names(model_scores)) {
    kept <- kept & !base::is.na(model_scores$refit_ok) & model_scores$refit_ok
  }

  n_kept_biv_models <- base::sum(kept)

  # Optional diagnostic: number of retained models with a positive effective
  # weight in the final all-algorithm ensemble.
  if ("weight" %in% base::names(model_scores)) {
    contributing <- kept &
      base::is.finite(model_scores$weight) &
      model_scores$weight > 0

    n_contributing_biv_models <- base::sum(contributing)
  } else {
    n_contributing_biv_models <- NA_integer_
  }

  expected_pairs <- if (n_predictors >= 2L) {
    base::choose(n_predictors, 2L)
  } else {
    0
  }

  expected_models <- expected_pairs * n_algorithms

  if (!base::isTRUE(base::all.equal(n_candidate_pairs, expected_pairs))) {
    base::warning(
      "Unexpected number of predictor pairs in ", path,
      ": found ", n_candidate_pairs,
      ", expected ", expected_pairs
    )
  }

  if (!base::isTRUE(base::all.equal(n_candidate_biv_models, expected_models))) {
    base::warning(
      "Unexpected number of candidate models in ", path,
      ": found ", n_candidate_biv_models,
      ", expected ", expected_models
    )
  }

  species_name <- base::as.character(model$species)[[1]]
  species_code <- extract_species_code(
    path = path,
    species_name = species_name,
    species_lookup = species_lookup
  )

  grain <- extract_grain(
    path = path,
    allowed_grains = allowed_grains
  )

  tibble::tibble(
    branch = branch,
    species_code = species_code,
    species = species_name,
    grain = grain,
    n_predictors = n_predictors,
    predictors = base::paste(predictors, collapse = ", "),
    n_candidate_pairs = base::as.integer(n_candidate_pairs),
    n_candidate_biv_models = base::as.integer(n_candidate_biv_models),
    n_kept_biv_models = base::as.integer(n_kept_biv_models),
    n_contributing_biv_models = base::as.integer(n_contributing_biv_models),
    oof_somers_d = base::round(
      base::as.numeric(model$oof_somers_d)[[1]],
      digits = somers_digits
    ),
    model_file = base::normalizePath(
      path,
      winslash = "/",
      mustWork = FALSE
    )
  )
}


build_branch_summary <- function(
    branch,
    esm_root,
    species_lookup,
    allowed_grains,
    grain_order,
    somers_digits = 3L
) {
  branch_dir <- base::file.path(esm_root, branch)

  if (!base::dir.exists(branch_dir)) {
    base::stop("Branch directory does not exist: ", branch_dir)
  }

  rds_files <- base::list.files(
    path = branch_dir,
    pattern = "\\.rds$",
    recursive = TRUE,
    full.names = TRUE,
    ignore.case = TRUE
  )

  if (base::length(rds_files) == 0L) {
    base::stop("No RDS files found in: ", branch_dir)
  }

  summary <- purrr::map_dfr(
    rds_files,
    summarise_esm_file,
    branch = branch,
    species_lookup = species_lookup,
    allowed_grains = allowed_grains,
    somers_digits = somers_digits
  )

  if (base::nrow(summary) == 0L) {
    base::stop("No valid ESM model objects found in: ", branch_dir)
  }

  duplicates <- summary |>
    dplyr::count(.data$species, .data$grain, name = "n") |>
    dplyr::filter(.data$n > 1L)

  if (base::nrow(duplicates) > 0L) {
    duplicate_text <- duplicates |>
      dplyr::mutate(
        label = base::paste0(.data$species, " / ", .data$grain, " m")
      ) |>
      dplyr::pull(.data$label) |>
      base::paste(collapse = ", ")

    base::stop(
      "Multiple ESM RDS files were found for the same species * grain: ",
      duplicate_text,
      "\nInspect the model_file column or remove obsolete copies."
    )
  }

  summary |>
    dplyr::mutate(
      species_code = base::factor(
        .data$species_code,
        levels = base::names(species_lookup)
      ),
      grain = base::factor(
        .data$grain,
        levels = grain_order,
        ordered = TRUE
      )
    ) |>
    dplyr::arrange(.data$species_code, .data$grain) |>
    dplyr::mutate(
      species_code = base::as.character(.data$species_code),
      grain = base::as.integer(base::as.character(.data$grain))
    )
}


export_branch_summary <- function(summary, branch, output_dir) {
  if (!base::dir.exists(output_dir)) {
    base::dir.create(output_dir, recursive = TRUE)
  }

  # Thesis-oriented table: requested columns plus the number of unique pairs.
  thesis_table <- summary |>
    dplyr::select(
      .data$species_code,
      .data$species,
      .data$grain,
      .data$n_predictors,
      .data$predictors,
      .data$n_candidate_pairs,
      .data$n_candidate_biv_models,
      .data$n_kept_biv_models,
      .data$oof_somers_d
    )

  # Full diagnostic output retains branch, effective model counts and paths.
  readr::write_csv(
    thesis_table,
    base::file.path(
      output_dir,
      base::paste0(branch, "_model_summary.csv")
    ),
    na = ""
  )

  readr::write_csv(
    summary,
    base::file.path(
      output_dir,
      base::paste0(branch, "_model_summary_diagnostics.csv")
    ),
    na = ""
  )

  base::saveRDS(
    summary,
    base::file.path(
      output_dir,
      base::paste0(branch, "_model_summary.rds")
    )
  )

  thesis_table
}


# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# RUN
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

branch_tables <- purrr::set_names(branches) |>
  purrr::map(function(branch) {
    base::message("Processing branch: ", branch)

    summary <- build_branch_summary(
      branch = branch,
      esm_root = esm_root,
      species_lookup = species_lookup,
      allowed_grains = allowed_grains,
      grain_order = grain_order,
      somers_digits = somers_digits
    )

    export_branch_summary(
      summary = summary,
      branch = branch,
      output_dir = output_dir
    )
  })

# Optional combined table for checking all branches at once.
combined_table <- dplyr::bind_rows(
  branch_tables,
  .id = "branch"
)

readr::write_csv(
  combined_table,
  base::file.path(output_dir, "all_branches_model_summary.csv"),
  na = ""
)

base::message("Finished. Tables saved to: ", output_dir)
