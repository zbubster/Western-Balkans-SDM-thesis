# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Collinearity ‒ extract results
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Config

# results dir
res_dir <- here::here("data", "predictors_collinearity", "results")

# load all lists into list
all_res <- list(
  random <- readRDS(here::here(res_dir, "RES_random.rds")),
  res_1000 <- readRDS(here::here(res_dir, "RES_1000.rds")),
  res_500 <- readRDS(here::here(res_dir, "RES_500.rds")),
  res_200 <- readRDS(here::here(res_dir, "RES_200.rds")),
  res_100 <- readRDS(here::here(res_dir, "RES_100.rds"))
)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# FUNCTION to extract $selected_predictors from lists
extract_selected_predictors <- function(x, set_name) {
  
  out <- base::lapply(base::names(x), function(nm) {
    sel <- x[[nm]]$selected_predictors
    
    # name of the item
    if (base::grepl("^r_[0-9]+\\.tif$", nm)) {
      # random
      species <- NA_character_
      grain_m <- base::as.integer(base::sub("^r_([0-9]+)\\.tif$", "\\1", nm))
      source_type <- "random"
    } else {
      # species
      species <- base::sub("_.*$", "", nm)
      grain_m <- base::as.integer(base::sub("^.*_([0-9]+)m\\.rds$", "\\1", nm))
      source_type <- "species"
    }
    
    # create a df
    base::data.frame(
      set_name = set_name,
      item_name = nm,
      source_type = source_type,
      species = species,
      grain_m = grain_m,
      predictor_order = base::seq_along(sel),
      predictor = base::as.character(sel),
      stringsAsFactors = FALSE
    )
  })
  
  out <- out[!base::vapply(out, base::is.null, logical(1))]
  out <- base::do.call(base::rbind, out)
  rownames(out) <- NULL
  return(out)
}

# apply function over all list items
selected_df <- base::lapply(
  base::names(all_res),
  function(nm) extract_selected_predictors(all_res[[nm]], nm)
)

# create a df from list
selected_df <- base::do.call(base::rbind, selected_df)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# create list of selected preditors
selected_df_list <- dplyr::summarise(
  dplyr::group_by(selected_df, set_name, item_name, source_type, species, grain_m),
  selected_predictors = list(predictor),
  n_predictors = dplyr::n(),
  .groups = "drop"
)

selected_df_list
saveRDS(selected_df_list, file = file.path(res_dir, "selected_list.rds"))

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# create table of selected predictors
selected_df_wide <- selected_df %>%
  dplyr::mutate(present = TRUE) %>%
  tidyr::pivot_wider(
    id_cols = c(set_name, item_name, source_type, species, grain_m),
    names_from = predictor,
    values_from = present,
    values_fill = FALSE
  )

selected_df_wide

write_csv(selected_df_wide, file = file.path(res_dir, "selected_truefalse.csv"))

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #