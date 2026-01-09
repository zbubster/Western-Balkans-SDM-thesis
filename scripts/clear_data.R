# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Clear data & prepare PA
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

list.files("data/occurence/")

TN <- vect(here("data", "occurence", "TN_accurate_merged.gpkg"))
field <- vect(here("data", "occurence", "20_23_fieldworks.gpkg"))

sort(unique(field$species))

# first cleaning (spaces, ?, whitespaces)
field$species <- trimws(field$species) # remove spaces on beginig or ending of the character vector
field$species <- gsub("\\s+", " ", field$species) # remove multiple spaces
field$species <- gsub("\\s*\\?$", "", field$species) # remove ? with spaces
field$species <- tolower(field$species) # low letters

# all focal absent
field$species[field$species %in% c("absence all focal", "absent all focal", "all focal absent")] <- "AFA"
