# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# MAP ‒ aggregated future ESM projections
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Load crop+mask function
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

# Human-readable SSP labels used in map titles
ssp_names <- c(
  `126` = "SSP1-2.6",
  `370` = "SSP3-7.0",
  `585` = "SSP5-8.5"
)

# Add OpenTopoMap
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
# FUN ‒ create one PNG map from one aggregated future projection raster
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

make_future_aggregated_projection_map <- function(
    species,
    grain,
    period,
    ssp,
    statistic = c("mean", "sd"),
    model_id = "recent_extrapol_weights_all_selected",
    aggregated_dir_name = "_future_aggregated",
    models_dir = here::here("models", "ESM"),
    outputs_dir = here::here("outputs", "ESM"),
    mask_function_path = here::here("scripts", "fun_mask_visualization.R"),
    aoi_path = here::here("data", "extent_raw.gpkg"),
    target_epsg = 3035,
    aoi_negative_buffer_m = 1000,
    osm_type = "opentopomap",
    osm_zoomin = -1,
    raster_alpha = 0.75,
    palette = "inferno",
    palette_direction = 1,
    value_limits = NULL,
    value_breaks = scales::breaks_pretty(n = 5),
    legend_label_accuracy = 0.1,
    legend_title = NULL,
    legend_barwidth_mm = 75,
    legend_barheight_mm = 4,
    inset_xlim = c(-11, 47),
    inset_ylim = c(27, 62),
    width_mm = 180,
    height_mm = 180,
    dpi = 200,
    show_title = TRUE,
    title_text = NULL,
    overwrite = TRUE
) {
  
  statistic <- match.arg(statistic)
  species <- toupper(species)
  grain <- as.integer(grain)
  period <- as.character(period)
  ssp <- tolower(as.character(ssp))
  ssp <- sub("^ssp", "", ssp)
  
  if (!species %in% names(species_names)) {
    stop(
      "Unknown species code: ", species,
      ". Expected one of: ", paste(names(species_names), collapse = ", "), "."
    )
  }
  
  if (!grain %in% c(200, 500, 1000)) {
    stop("Unsupported grain: ", grain, ". Expected 200, 500 or 1000 m.")
  }
  
  if (!period %in% c("2041-2070", "2071-2100")) {
    stop(
      "Unsupported period: ", period,
      ". Expected 2041-2070 or 2071-2100."
    )
  }
  
  if (!ssp %in% names(ssp_names)) {
    stop(
      "Unsupported SSP: ", ssp,
      ". Expected 126, 370 or 585; optionally prefixed with 'ssp'."
    )
  }
  
  projection_id <- paste0(period, "_ssp", ssp)
  filename_prefix <- paste0(statistic, "_predicted_suitability")
  
  input_filename <- paste0(
    filename_prefix, "_",
    species, "_",
    grain, "_",
    projection_id,
    ".tif"
  )
  
  input_path <- file.path(
    models_dir,
    model_id,
    aggregated_dir_name,
    species,
    as.character(grain),
    projection_id,
    input_filename
  )
  
  output_dir <- file.path(
    outputs_dir,
    model_id,
    aggregated_dir_name,
    species,
    as.character(grain),
    projection_id
  )
  
  output_filename <- paste0(
    filename_prefix, "_",
    species, "_",
    grain, "_",
    projection_id,
    ".png"
  )
  
  output_path <- file.path(output_dir, output_filename)
  
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
  
  if (!exists("crop_mask_aoi_land", mode = "function")) {
    stop("Function crop_mask_aoi_land() was not loaded.")
  }
  
  # Load aggregated projection raster.
  esm <- terra::rast(input_path)
  
  if (terra::nlyr(esm) != 1) {
    stop("The aggregated projection must contain exactly one raster layer.")
  }
  
  if (terra::crs(esm) == "") {
    stop("Input raster has no coordinate reference system.")
  }
  
  target_crs <- paste0("EPSG:", target_epsg)
  
  # The visualization mask is prepared in EPSG:3035. Continuous values are
  # resampled bilinearly only if the source raster uses another CRS.
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
  
  # Mean suitability must lie between 0 and 1. For SD, only very small
  # negative numerical spillover is removed; the upper range is left intact.
  if (statistic == "mean") {
    esm <- terra::clamp(
      esm,
      lower = 0,
      upper = 1,
      values = TRUE
    )
  } else {
    esm <- terra::ifel(esm < 0, 0, esm)
  }
  
  names(esm) <- "value"
  
  has_valid_cells <- terra::global(
    !is.na(esm),
    fun = "max",
    na.rm = TRUE
  )[1, 1]
  
  if (is.na(has_valid_cells) || has_valid_cells == 0) {
    stop("The raster contains no valid cells after cropping and masking.")
  }
  
  if (!is.null(value_limits)) {
    if (!is.numeric(value_limits) || length(value_limits) != 2) {
      stop("value_limits must be NULL or a numeric vector of length 2.")
    }
    
    if (value_limits[1] >= value_limits[2]) {
      stop("The lower value_limits value must be smaller than the upper value.")
    }
  }
  
  if (is.null(legend_title)) {
    legend_title <- if (statistic == "mean") {
      "Průměrná vhodnost stanoviště"
    } else {
      "Směrodatná odchylka"
    }
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
  
  period_title <- gsub("-", "–", period, fixed = TRUE)
  
  if (is.null(title_text)) {
    title_text <- paste0(
      species_names[[species]],
      " — ", grain, " m",
      " — ", period_title,
      " — ", ssp_names[[ssp]]
    )
  }
  
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
      direction = palette_direction,
      limits = value_limits,
      breaks = value_breaks,
      labels = scales::label_number(accuracy = legend_label_accuracy),
      oob = scales::squish,
      na.value = NA,
      name = legend_title,
      guide = ggplot2::guide_colourbar(
        title.position = "top",
        title.hjust = 0.5,
        barwidth = grid::unit(legend_barwidth_mm, "mm"),
        barheight = grid::unit(legend_barheight_mm, "mm"),
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
      title = if (show_title) title_text else NULL,
      x = "Zeměpisná délka",
      y = "Zeměpisná šířka"
    ) +
    ggplot2::theme_bw(base_size = 9) +
    ggplot2::theme(
      panel.ontop = TRUE,
      
      panel.background = ggplot2::element_blank(),
      
      panel.grid.major = ggplot2::element_line(
        colour = scales::alpha("white", 0.65),
        linewidth = 0.18,
        linetype = "solid"
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
  value_legend <- cowplot::get_legend(main_map)
  main_map <- main_map +
    ggplot2::theme(legend.position = "none")
  
  # Compose the final map:
  # - legend inside the lower-left corner,
  # - regional inset inside the upper-right corner,
  # - OSM attribution above the map frame on the right.
  final_map <- cowplot::ggdraw(main_map) +
    cowplot::draw_grob(
      value_legend,
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
     )# +
    # cowplot::draw_label(
    #   paste(
    #     "© OpenStreetMap;",
    #     "SRTM, Sonny;",
    #     "© OpenTopoMap"
    #   ),
    #   x = 0.97,
    #   y = 0.97,
    #   hjust = 1,
    #   vjust = 1,
    #   size = 6.5,
    #   colour = "grey30"
    # )
  
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
      species = species,
      grain = grain,
      period = period,
      ssp = ssp,
      statistic = statistic,
      input = input_path,
      output = output_path,
      raster = esm,
      plot = final_map
    )
  )
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# RUN ‒ all mean maps
# This block processes only mean rasters.
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

if (FALSE) {
  sp <- c("GT", "GD", "PK", "PO", "PP", "SB")
  gr <- c(1000, 500, 200)
  periods <- c("2041-2070", "2071-2100")
  ssps <- c("126", "370", "585")
  
  for (period in periods) {
    for (ssp in ssps) {
      for (grain in gr) {
        for (spec in sp) {
          message(
            "__mean__",
            period,
            "__ssp", ssp,
            "__", grain,
            "__", spec,
            "__"
          )
          
          make_future_aggregated_projection_map(
            species = spec,
            grain = grain,
            period = period,
            ssp = ssp,
            statistic = "mean",
            palette = "inferno",
            value_limits = c(0, 1),
            value_breaks = seq(0, 1, by = 0.2),
            legend_label_accuracy = 0.1,
            legend_title = "Průměrná vhodnost stanoviště"
          )
        }
      }
    }
  }
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# RUN ‒ all SD maps
# This block processes only SD rasters.
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

if (TRUE) {
  sp <- c("GT", "GD", "PK", "PO", "PP", "SB")
  gr <- c(1000, 500, 200)
  periods <- c("2041-2070", "2071-2100")
  ssps <- c("126", "370", "585")
  
  for (period in periods) {
    for (ssp in ssps) {
      for (grain in gr) {
        for (spec in sp) {
          message(
            "__sd__",
            period,
            "__ssp", ssp,
            "__", grain,
            "__", spec,
            "__"
          )
          
          make_future_aggregated_projection_map(
            species = spec,
            grain = grain,
            period = period,
            ssp = ssp,
            statistic = "sd",
            palette = "viridis",
            raster_alpha = 1,
            value_limits = NULL,
            value_breaks = scales::breaks_pretty(n = 5),
            legend_label_accuracy = 0.01,
            legend_title = "Směrodatná odchylka predikcí"
          )
        }
      }
    }
  }
}
