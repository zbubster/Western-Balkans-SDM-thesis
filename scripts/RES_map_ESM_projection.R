# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# MAP ‒ current ESM projection
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Packages required by this script and by fun_mask_visualization.R
required_packages <- c(
  "terra",
  "sf",
  "ggplot2",
  "ggspatial",
  "cowplot",
  "rnaturalearth",
  "rnaturalearthdata",
  "here",
  "scales",
  "rosm",
  "prettymapr"
)

missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]

if (length(missing_packages) > 0) {
  stop(
    "Missing packages: ",
    paste(missing_packages, collapse = ", "),
    "."
  )
}

# Load crop/mask function
source(here::here("scripts", "fun_mask_visualization.R"))

if (!exists("crop_mask_aoi_land", mode = "function")) {
  stop("Function crop_mask_aoi_land() was not loaded.")
}

# Full species names used in map titles
species_names <- c(
  GD = "Gentiana dinarica",
  GT = "Gentiana tergestina",
  SB = "Saxifraga blavii",
  PK = "Primula kitaibeliana",
  PO = "Phyteuma orbiculare",
  PP = "Phyteuma pseudorbiculare"
)

rosm::register_tile_source(
  opentopomap = rosm::source_from_url_format(
    url_format = "https://tile.opentopomap.org/${z}/${x}/${y}.png",
    max_zoom = 17,
    attribution = paste(
      "Map data © OpenStreetMap contributors;",
      "DEM: SRTM, Sonny;",
      "map style © OpenTopoMap (CC-BY-SA)"
    )
  )
)

rosm::osm.types()

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# FUN ‒ create one PNG map from one ESM_projection.tif
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

make_esm_projection_map <- function(
    species,
    grain,
    model_id = "recent_extrapol_weights_all_selected",
    models_dir = here::here("models", "ESM"),
    outputs_dir = here::here("outputs", "ESM"),
    mask_function_path = here::here("scripts", "fun_mask_visualization.R"),
    aoi_path = here::here("data", "extent_raw.gpkg"),
    target_epsg = 3035,
    aoi_negative_buffer_m = 1000,
    osm_type = "opentopomap",
    osm_zoomin = -1,
    raster_alpha = 0.72,
    palette = "magma",
    inset_xlim = c(6, 32),
    inset_ylim = c(33, 50),
    width_mm = 180,
    height_mm = 180,
    dpi = 300,
    show_title = TRUE,
    overwrite = TRUE
) {
  
  species <- toupper(species)
  grain <- as.integer(grain)
  
  if (!species %in% names(species_names)) {
    stop(
      "Unknown species code: ", species,
      ". Expected one of: ", paste(names(species_names), collapse = ", "), "."
    )
  }
  
  if (!grain %in% c(100, 200, 500, 1000)) {
    stop("Unsupported grain: ", grain, ".")
  }
  
  input_path <- file.path(
    models_dir,
    model_id,
    species,
    as.character(grain),
    "ESM_projection.tif"
  )
  
  output_dir <- file.path(
    outputs_dir,
    model_id,
    species,
    as.character(grain)
  )
  
  output_path <- file.path(output_dir, "ESM_projection.png")
  
  if (!file.exists(input_path)) {
    stop("Input raster does not exist: ", input_path)
  }
  
  if (file.exists(output_path) && !overwrite) {
    stop("Output already exists and overwrite = FALSE: ", output_path)
  }
  
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  
  osm_cache <- here::here("data", "__CACHE__", "osm")
  dir.create(osm_cache, recursive = TRUE, showWarnings = FALSE)
  
  # Reload the masking function so the script always uses the selected file.
  source(mask_function_path)
  
  # Load projection
  esm <- terra::rast(input_path)
  
  if (terra::nlyr(esm) != 1) {
    stop("ESM projection must contain exactly one raster layer.")
  }
  
  if (terra::crs(esm) == "") {
    stop("Input raster has no coordinate reference system.")
  }
  
  target_crs <- paste0("EPSG:", target_epsg)
  
  # The visualization mask is prepared in EPSG:3035. Continuous suitability
  # is resampled bilinearly only if the source raster uses another CRS.
  if (!terra::same.crs(esm, target_crs)) {
    esm <- terra::project(esm, target_crs, method = "bilinear")
  }
  
  # Crop to the buffered AOI and mask sea cells.
  esm <- crop_mask_aoi_land(
    raster_input = esm,
    aoi_path = aoi_path,
    epsg = target_epsg,
    aoi_negative_buffer_m = aoi_negative_buffer_m
  )
  
  # ESM suitability is expected to already be expressed from 0 to 1.
  # Clamp only possible numerical spillover; do not min-max rescale each map.
  esm <- terra::clamp(
    esm,
    lower = 0,
    upper = 1,
    values = TRUE
  )
  
  names(esm) <- "suitability"
  
  has_valid_cells <- terra::global(
    !is.na(esm),
    fun = "max",
    na.rm = TRUE
  )[1, 1]
  
  if (is.na(has_valid_cells) || has_valid_cells == 0) {
    stop("The raster contains no valid cells after cropping and masking.")
  }
  
  # Bounding box of the displayed raster, used in the regional inset.
  raster_bbox <- sf::st_as_sfc(
    sf::st_bbox(
      c(
        xmin = terra::xmin(esm),
        ymin = terra::ymin(esm),
        xmax = terra::xmax(esm),
        ymax = terra::ymax(esm)
      ),
      crs = sf::st_crs(terra::crs(esm))
    )
  )
  
  raster_bbox_wgs84 <- sf::st_transform(raster_bbox, 4326)
  
  # Regional context map.
  countries <- rnaturalearth::ne_countries(
    scale = 50,
    returnclass = "sf"
  )
  
  inset_map <- ggplot2::ggplot() +
    ggplot2::geom_sf(
      data = countries,
      fill = "grey92",
      colour = "grey55",
      linewidth = 0.18
    ) +
    ggplot2::geom_sf(
      data = raster_bbox_wgs84,
      fill = scales::alpha("#D73027", 0.20),
      colour = "#D73027",
      linewidth = 0.65
    ) +
    ggplot2::coord_sf(
      xlim = inset_xlim,
      ylim = inset_ylim,
      expand = FALSE
    ) +
    ggplot2::theme_void() +
    ggplot2::theme(
      panel.background = ggplot2::element_rect(
        fill = "white",
        colour = "black",
        linewidth = 0.5
      ),
      panel.border = ggplot2::element_rect(
        fill = NA,
        colour = "black",
        linewidth = 0.5
      ),
      plot.margin = ggplot2::margin(2, 2, 2, 2)
    )
  
  plot_title <- paste0(species_names[[species]], " — ", grain, " m")
  
  main_map <- ggplot2::ggplot() +
    ggspatial::annotation_map_tile(
      type = osm_type,
      zoomin = osm_zoomin,
      cachedir = osm_cache,
      progress = "none"
    ) +
    ggspatial::layer_spatial(
      data = esm,
      mapping = ggplot2::aes(
        fill = ggplot2::after_stat(band1)
      ),
      alpha = raster_alpha
    ) +
    ggplot2::scale_fill_viridis_c(
      option = palette,
      limits = c(0, 1),
      breaks = seq(0, 1, by = 0.2),
      labels = scales::label_number(accuracy = 0.1),
      oob = scales::squish,
      na.value = NA,
      name = "Vhodnost stanoviště",
      guide = ggplot2::guide_colourbar(
        title.position = "top",
        title.hjust = 0.5,
        barwidth = grid::unit(75, "mm"),
        barheight = grid::unit(4, "mm"),
        ticks.colour = "black",
        frame.colour = "black"
      )
    ) +
    ggplot2::coord_sf(
      crs = sf::st_crs(target_epsg),
      datum = sf::st_crs(4326),
      expand = FALSE
    ) +
    ggplot2::labs(
      title = if (show_title) plot_title else NULL,
      x = "Zeměpisná délka",
      y = "Zeměpisná šířka"
    ) +
    ggplot2::theme_bw(base_size = 9) +
    ggplot2::theme(
      panel.grid.major = ggplot2::element_line(
        colour = "grey72",
        linewidth = 0.25,
        linetype = "dashed"
      ),
      panel.grid.minor = ggplot2::element_blank(),
      panel.border = ggplot2::element_rect(
        colour = "black",
        fill = NA,
        linewidth = 0.7
      ),
      axis.text = ggplot2::element_text(colour = "black", size = 8),
      axis.title = ggplot2::element_text(size = 9),
      plot.title = ggplot2::element_text(
        face = "italic",
        size = 11,
        hjust = 0
      ),
      legend.position = "bottom",
      legend.title = ggplot2::element_text(size = 8),
      legend.text = ggplot2::element_text(size = 7.5),
      legend.background = ggplot2::element_rect(
        fill = scales::alpha("white", 0.88),
        colour = "black",
        linewidth = 0.35
      ),
      legend.margin = ggplot2::margin(4, 7.5, 3, 7.5),
      plot.margin = ggplot2::margin(8, 5, 5, 5)
    )
  
  # Extract the horizontal colour bar and remove it from below the map.
  suitability_legend <- cowplot::get_legend(main_map)
  main_map <- main_map +
    ggplot2::theme(legend.position = "none")
  
  # Compose the final map:
  # - legend inside the lower-left corner,
  # - regional inset inside the upper-right corner,
  # - OSM attribution above the map frame on the right.
  final_map <- cowplot::ggdraw(main_map) +
    cowplot::draw_grob(
      suitability_legend,
      x = 0.05,
      y = 0.06,
      width = 0.52,
      height = 0.105
    ) +
    cowplot::draw_plot(
      inset_map,
      x = 0.715,
      y = 0.69,
      width = 0.27,
      height = 0.27
    ) +
    cowplot::draw_label(
      paste(
        "Map data © OpenStreetMap contributors;",
        "DEM: SRTM, Sonny;",
        "© OpenTopoMap"
      ),
      x = 0.97,
      y = 0.97,
      hjust = 1,
      vjust = 1,
      size = 6.5,
      colour = "grey30"
    )
  
  output_device <- if (requireNamespace("ragg", quietly = TRUE)) {
    ragg::agg_png
  } else {
    "png"
  }
  
  ggplot2::ggsave(
    filename = output_path,
    plot = final_map,
    device = output_device,
    width = width_mm,
    height = height_mm,
    units = "mm",
    dpi = dpi,
    bg = "white"
  )
  
  message("Map saved to: ", output_path)
  
  invisible(
    list(
      input = input_path,
      output = output_path,
      raster = esm,
      plot = final_map
    )
  )
}


# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# RUN ‒ edit these two values while tuning the map
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

result <- make_esm_projection_map(
  species = "GT",
  grain = 1000
)





result <- make_esm_projection_map(
  species = "GD",
  grain = 1000
)
