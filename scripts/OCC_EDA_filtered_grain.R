# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# OCC ‒ EDA filtered species dataset
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# This script takes grain filtered RDS files, creates .gpkg files from
# them and produces summary tables with number of observations.

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Config

# filtered RDS fles
dir_in  <- "~/diplomka/data/occurence/_ANALYSIS_FOCAL_/_FILTER_"
# where to save GPKG files
dir_out <- "~/diplomka/data/occurence/_ANALYSIS_FOCAL_/_FILTER_GPKG_"
# where to save tables
dir_tab <- "~/diplomka/data/occurence/_ANALYSIS_FOCAL_/_FILTER_TABLES_"

if (!base::dir.exists(dir_out)) {
  base::dir.create(dir_out, recursive = TRUE)
}
if (!base::dir.exists(dir_tab)) {
  base::dir.create(dir_tab, recursive = TRUE)
}

# load files
files <- list.files(
  path = dir_in,
  pattern = "\\.rds$",
  full.names = TRUE
)

# prepare empty list
summary_list <- vector("list", length(files))

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Loop

for (i in seq_along(files)) {
  
  f <- files[i]
  obj <- readRDS(f)
  
  fname <- basename(f)
  # extract spec code and grain from filename
  species_code <- stringr::str_match(fname, "^([A-Za-z]+)_")[, 2]
  grain        <- stringr::str_match(fname, "_([0-9]+m)\\.rds$")[, 2]
  # species name
  species_name <- obj$species
  
  # prapare DF for analysis
  df <- obj$coor
  df$species_code <- species_code
  df$species_name <- species_name
  df$grain <- grain
  df$observation <- as.integer(obj$observations)
  
  # make sf object
  pts <- sf::st_as_sf(df, coords = c("X", "Y"), crs = 3035, remove = FALSE)
  
  # save as gpkg
  out_gpkg <- file.path(dir_out, sub("\\.rds$", ".gpkg", fname))
  sf::st_write(pts, out_gpkg, delete_dsn = TRUE, quiet = TRUE)
  
  # summary
  presence_n <- sum(df$observation == 1, na.rm = TRUE)
  absence_n  <- sum(df$observation == 0, na.rm = TRUE)
  
  summary_list[[i]] <- data.frame(
    file = fname,
    species_code = species_code,
    species_name = species_name,
    grain = grain,
    presence_n = presence_n,
    absence_n = absence_n,
    stringsAsFactors = FALSE
  )
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Tables

# grain order
grain_levels <- c("20m", "100m", "200m", "500m", "1000m")

# merge outputs into one table
# long table
summary_long <- dplyr::bind_rows(summary_list)
summary_long$grain <- factor(summary_long$grain, levels = grain_levels)
summary_long <- summary_long %>%
  arrange(species_code, grain)

# create wide table
# GRAIN* SPECIES, presence | absence
summary_wide <- summary_long %>%
  mutate(value = paste0(presence_n, " | ", absence_n)) %>%
  select(species_code, species_name, grain, value) %>%
  tidyr::pivot_wider(
    names_from = grain,
    values_from = value
  ) %>%
  arrange(species_code)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# save tables

readr::write_csv(summary_long, file.path(dir_tab, "summary_presence_absence_long.csv"))
readr::write_csv(summary_wide, file.path(dir_tab, "summary_presence_absence_wide.csv"))

print(summary_long)
print(summary_wide)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #