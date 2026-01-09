# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Clear data & prepare PA
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

list.files("data/occurence/")

TN <- st_read(here("data", "occurence", "TN_accurate_merged.gpkg"))
field <- st_read(here("data", "occurence", "20_23_fieldworks.gpkg"))
dir_out <- here("data", "occurence", "field_cleared")
if (!dir.exists(dir_out)) dir.create(dir_out, recursive = TRUE)

sort(unique(field$species))

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
      # all others (correct ones)
      TRUE ~ species
    )
  )

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
