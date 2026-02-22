# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Occurence EDA, view
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Load data

# data dir
base_dir <- here("data", "occurence", "__analysis__")
# Extent
extent <- st_read(here("data", "extent_raw.gpkg"))

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
  "gen_tergestina","phy_orbiculare", "pri_kitaibeliana",
  "cam_velebitica", "sax_blavii","cam_albanica","gen_utriculosa","gen_dinarica", 
  "phy_pseudorbiculare"
)

# subset lists to focal species
speclist <- pres[wanted]
abslist  <- abs[wanted]

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
# Table

tab_pa <- purrr::imap_dfr(all_sf, \(x, nm) {
  
  dat <- sf::st_drop_geometry(x) |>
    dplyr::mutate(
      P_A = base::as.integer(P_A),
      source = base::toupper(base::trimws(base::as.character(source)))
    )
  
  n_total <- base::nrow(dat)
  n_pa1   <- base::sum(dat$P_A == 1L, na.rm = TRUE)
  n_pa0   <- base::sum(dat$P_A == 0L, na.rm = TRUE)
  n_pa_na <- base::sum(base::is.na(dat$P_A))
  
  # presences only (P_A == 1)
  n_pa1_fw <- base::sum(dat$P_A == 1L & dat$source == "FW", na.rm = TRUE)
  n_pa1_tn <- base::sum(dat$P_A == 1L & dat$source == "TN", na.rm = TRUE)
  
  tibble::tibble(
    species_id  = nm,  # list name (eg. "gen_tergestina")
    Total = n_total,
    Presences = n_pa1,
    Absences = n_pa0,
    #n_pa_na = n_pa_na,
    #Pres_FW = n_pa1_fw,
    Pres_TN = n_pa1_tn,
    #prop_pa1_fw = base::ifelse(n_pa1 > 0, n_pa1_fw / n_pa1, NA_real_),
    Proportion_TN = base::ifelse(n_pa1 > 0, n_pa1_tn / n_pa1, NA_real_),
    #pct_pa1_fw = base::ifelse(n_pa1 > 0, 100 * n_pa1_fw / n_pa1, NA_real_),
    #pct_pa1_tn = base::ifelse(n_pa1 > 0, 100 * n_pa1_tn / n_pa1, NA_real_)
  )
}) |>
  dplyr::arrange(desc(Presences))

# view
print(tab_pa)

# uložení do CSV (anglický oddělovač ,)
readr::write_csv(tab_pa, here("text", "obj", "tab","pa_summary.csv"))
