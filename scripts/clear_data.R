# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Clear data & prepare PA
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Clean field data

# config
field <- st_read(here("data", "occurence", "20_23_fieldworks.gpkg"))
dir_out <- here("data", "occurence", "field_cleared")
if (!dir.exists(dir_out)) dir.create(dir_out, recursive = TRUE)


# first cleaning (spaces, ?, whitespaces)
field$species <- trimws(field$species) # remove spaces on beginig or ending of the character vector
field$species <- gsub("\\s+", " ", field$species) # remove multiple spaces
field$species <- gsub("\\s*\\?$", "", field$species) # remove ? with spaces
field$species <- tolower(field$species) # low letters

# correct typos
field <- field %>%
  mutate(
    species = case_when(
      # all focal absent
      species %in% c("absence all focal", "absent all focal", "all focal absent") ~ "AFA",
      # gen ter
      species %in% c("gentana tergestina", "gentian tergestina", "grntiana tergestina", "gentiana tergeatina", "gentiana sp") ~ "gentiana tergestina",
      # gen cru
      species == "gentiana crutiata" ~ "gentiana cruciata",
      # phyt pseudo
      species == "phyteuma psedorbiculare" ~ "phyteuma pseudorbiculare",
      # sax bla
      species %in% c("sacifraga blavii", "saxifraga blavi") ~ "saxifraga blavii",
      # sax oppo
      species == "saxifraga opppsitifolia" ~ "saxifraga oppositifolia",
      # camp mar
      species == "campanula marchesetti" ~ "campanula marchesettii",
      # all others (correct ones)
      TRUE ~ species
    )
  )

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Produce single layers for each species

# In this case points represent presences of mentioned species AND absences for all other species

# species list
spec_list <- sort(unique(field$species))
spec_list <- setdiff(spec_list, "AFA")  # drop "all focal absent"

# loop over species
for (sp in spec_list) {
  
  message("Starting species:", sp)
  
  tmp <- field
  tmp$P_A <- as.integer(tmp$species == sp)
  
  words <- unlist(strsplit(sp, "\\s+"))
  filename <- paste0(substr(words[1], 1, 3), "_", paste(words[-1], collapse = "_"), ".gpkg")
  out_file <- file.path(dir_out, filename)
  if (file.exists(out_file)) file.remove(out_file)
  
  st_write(tmp, out_file, layer = "points", quiet = TRUE)
  message("Done and saved in", out_file)
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Merge with TN data

# In this case I dont have explicit information about absences, so those data will be only merged with already existing layers

TN <- st_read(here("data", "occurence", "TN_accurate_merged.gpkg"))
TN
TN$IMENALAT
sort(unique(TN$IMENALAT))

TN <- TN %>%
  mutate(
    species = str_extract(tolower(IMENALAT), "^[a-z]+\\s+[a-z]+"),
    species = str_replace_all(species, "\\s+", " "),
    P_A = 1L
  ) %>%
  select(IDREF, species, P_A, geom)
  

TN_list <- split(TN, TN$species)
str(TN_list)

# Campanula marchesettii

f <- st_read(here("data", "occurence", "field_cleared", "cam_marchesettii.gpkg"))

stopifnot(
  st_crs(TN_list$`campanula marchesettii`) == st_crs(f)
)

merged <- TN_list$`campanula marchesettii` %>%
  dplyr::bind_rows(f)

st_write(merged, here("data", "occurence", "field_cleared", "cam_marchesettii.gpkg"), delete_dsn = T)

# Campanula velebitica

f <- st_read(here("data", "occurence", "field_cleared", "cam_velebitica.gpkg"))

stopifnot(
  st_crs(TN_list$`campanula velebitica`) == st_crs(f)
)

merged <- TN_list$`campanula velebitica` %>%
  dplyr::bind_rows(f)

st_write(merged, here("data", "occurence", "field_cleared", "cam_velebitica.gpkg"), delete_dsn = T)

# Gentiana tergestina

f <- st_read(here("data", "occurence", "field_cleared", "gen_tergestina.gpkg"))

stopifnot(
  st_crs(TN_list$`gentiana tergestina`) == st_crs(f)
)

merged <- TN_list$`gentiana tergestina` %>%
  dplyr::bind_rows(f)

st_write(merged, here("data", "occurence", "field_cleared", "gen_tergestina.gpkg"), delete_dsn = T)

# Gentiana utriculosa

f <- st_read(here("data", "occurence", "field_cleared", "gen_utriculosa.gpkg"))

stopifnot(
  st_crs(TN_list$`gentiana utriculosa`) == st_crs(f)
)

merged <- TN_list$`gentiana utriculosa` %>%
  dplyr::bind_rows(f)

st_write(merged, here("data", "occurence", "field_cleared", "gen_utriculosa.gpkg"), delete_dsn = T)

# Phyteuma orbiculare

f <- st_read(here("data", "occurence", "field_cleared", "phy_orbiculare.gpkg"))

stopifnot(
  st_crs(TN_list$`phyteuma orbiculare`) == st_crs(f)
)

merged <- TN_list$`phyteuma orbiculare` %>%
  dplyr::bind_rows(f)

st_write(merged, here("data", "occurence", "field_cleared", "phy_orbiculare.gpkg"), delete_dsn = T)

# Primula kitaibeliana

merged <- TN_list$`primula kitaibeliana`

st_write(merged, here("data", "occurence", "field_cleared", "pri_kitaibeliana.gpkg"), driver = "GPKG", delete_dsn = T)
