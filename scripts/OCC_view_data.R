# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Occurence EDA, view
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Load data

# data dir
base_dir <- "data/occurence/__analysis__"

# get filenames and species names (from filenames)
files <- base::list.files(base_dir, pattern = "\\.gpkg$", full.names = TRUE)
nm <- tools::file_path_sans_ext(base::basename(files))

# get all sf layers
all_sf <- purrr::set_names(files, nm) |>
  purrr::map(sf::st_read, quiet = TRUE)

# presences, absences (keep species & geometry)
pres <- purrr::map(all_sf, \(x) dplyr::filter(x, .data$P_A == 1) |> dplyr::select(species))
abs  <- purrr::map(all_sf, \(x) dplyr::filter(x, .data$P_A == 0) |> dplyr::select(species))

# focal plants
wanted <- c(
  "gen_tergestina","phy_orbiculare",#"pri_kitaibeliana",
  "cam_velebitica", "sax_blavii","cam_albanica","gen_utriculosa","gen_dinarica"
)

# subset lists to focal species
speclist <- pres[wanted]
abslist  <- abs[wanted]

# Extent
extent <- st_read("data/extent_raw.gpkg")

# Base map
tiles <- maptiles::get_tiles(
  x = extent,
  provider = "Esri.WorldShadedRelief",
  zoom = 6,
  crop = TRUE,
  project = TRUE
)

# Borders
m <- maps::map("world", plot = FALSE, fill = TRUE)
m_3035_bound <- m %>% 
  st_as_sf() %>%
  st_transform(crs(tiles)) %>% # transform
  st_boundary() # extract lines only

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Prep dirs
out_dir <- here("text", "obj", "pic", "occurence_EDA")
base::dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

# Loop
for (i in seq_along(speclist)) {
  # spec name
  spec <- dplyr::first(speclist[[i]]$species)
  
  # out file
  spec_file <- gsub("[^A-Za-z0-9_\\-]+", "_", spec)
  out <- file.path(out_dir, paste0(spec_file, ".jpeg"))
  
  message("Working on: ", spec, " -> ", out)
  
  # grapbhic dev
  grDevices::jpeg(filename = out, width = 2000, height = 2000, res = 300, quality = 95)
  
  # for the case of fail, close graphdev
  base::on.exit(grDevices::dev.off(), add = TRUE)
  
  # plot
  terra::plot(tiles)
  terra::plot(m_3035_bound, add = TRUE, col = "grey30")
  terra::plot(sf::st_boundary(extent), add = TRUE, col = "firebrick", lwd = 4, lty = 3)
  
  # absences
  terra::plot(abslist[[i]], add = TRUE, pch = 16, col = "black", cex = 0.7)
    
  # presences
  terra::plot(speclist[[i]], add = TRUE, pch = 16, col = "green", cex = 1)
  
  # legend
  graphics::legend(
    "bottomleft",
    legend = c(spec, "State borders", "Study extent", "Occurrences", "Absences"),
    col    = c(NA, "grey30", "firebrick", "green", "black"),
    lwd    = c(NA, 1, 4, NA, NA),
    lty    = c(NA, 1, 3, NA, NA),
    pch    = c(NA, NA, NA, 16, 16),
    pt.cex = c(NA, NA, NA, 1, 1),
    bg     = "white"
  )
  
  # close graphdev
  grDevices::dev.off()
  message("DONE")
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #