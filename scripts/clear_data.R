# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Clear data & prepare PA
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

list.files("data/occurence/")

TN <- st_read(here("data", "occurence", "TN_accurate_merged.gpkg"))
field <- st_read(here("data", "occurence", "20_23_fieldworks.gpkg"))

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
      species %in% c("gentana tergestina", "gentian tergestina", "grntiana tergestina", "gentiana tergeatina") ~ "gentiana tergestina",
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

