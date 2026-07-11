# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# MAP ‒ selected hindcast Shape projections (060 and 190)
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
# FUN ‒ create one PNG map from one hindcast Shape projection
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

make_shape_hindcast_map <- function(
    species,
    grain,
    projection,
    model_id = "hindcast_forecast_extrapol_weights_all_selected",
    models_dir = here::here("models", "Shape"),
    outputs_dir = here::here("outputs", "Shape"),
    input_filename = "shape.tif",
    output_filename = "Shape_projection.png",
    mask_function_path = here::here(
      "scripts",
      "fun_mask_visualization.R"
    ),
    aoi_path = here::here(
      "data",
      "extent_raw.gpkg"
    ),
    target_epsg = 3035,
    aoi_negative_buffer_m = 1000,
    osm_type = "opentopomap",
    osm_zoomin = -1,
    raster_alpha = 0.75,
    palette = "inferno",
    fill_limits = NULL,
    inset_xlim = c(-11, 47),
    inset_ylim = c(27, 62),
    width_mm = 180,
    height_mm = 180,
    dpi = 200,
    show_title = TRUE,
    overwrite = TRUE
) {
  
  species <- base::toupper(species)
  grain <- base::as.integer(grain)
  projection_number <- suppressWarnings(
    base::as.integer(projection)
  )
  
  
  # Check hindcast projection
  if (base::is.na(projection_number)) {
    stop(
      "Projection must be either 060 or 190."
    )
  }
  
  projection <- base::sprintf(
    "%03d",
    projection_number
  )
  
  if (!projection %in% c("060", "190")) {
    stop(
      "Unsupported projection: ",
      projection,
      ". Expected 060 or 190."
    )
  }
  
  projection_id <- base::paste0(
    "trace21k_-",
    projection
  )
  
  
  # Check species code
  if (!species %in% names(species_names)) {
    stop(
      "Unknown species code: ",
      species,
      ". Expected one of: ",
      paste(
        names(species_names),
        collapse = ", "
      ),
      "."
    )
  }
  
  
  # Check raster grain
  if (!grain %in% c(200, 500, 1000)) {
    stop(
      "Unsupported grain: ",
      grain,
      ". Expected 200, 500 or 1000 m."
    )
  }
  
  
  # Input raster path
  input_path <- base::file.path(
    models_dir,
    model_id,
    species,
    base::as.character(grain),
    "projections",
    "hindcast",
    projection_id,
    input_filename
  )
  
  
  # Output directory
  output_dir <- base::file.path(
    outputs_dir,
    model_id,
    species,
    base::as.character(grain),
    "projections",
    "hindcast",
    projection_id
  )
  
  
  # Output PNG path
  output_path <- base::file.path(
    output_dir,
    output_filename
  )
  
  
  # Check input file
  if (!base::file.exists(input_path)) {
    stop(
      "Input raster does not exist: ",
      input_path
    )
  }
  
  
  # Check output file
  if (
    base::file.exists(output_path) &&
    !overwrite
  ) {
    stop(
      "Output already exists and overwrite = FALSE: ",
      output_path
    )
  }
  
  
  # Create output directory
  base::dir.create(
    output_dir,
    recursive = TRUE,
    showWarnings = FALSE
  )
  
  
  # OSM cache
  osm_cache <- here::here(
    "data",
    "__CACHE__",
    "osm"
  )
  
  base::dir.create(
    osm_cache,
    recursive = TRUE,
    showWarnings = FALSE
  )
  
  
  # Reload the masking function so the script always uses the selected file.
  base::source(mask_function_path)
  
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # LOAD SHAPE RASTER
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  
  shape <- terra::rast(input_path)
  
  
  if (terra::nlyr(shape) != 1) {
    stop(
      "Shape projection must contain exactly one raster layer."
    )
  }
  
  
  if (terra::crs(shape) == "") {
    stop(
      "Input raster has no coordinate reference system."
    )
  }
  
  
  target_crs <- paste0(
    "EPSG:",
    target_epsg
  )
  
  
  # Shape is a continuous variable.
  # Bilinear resampling is used only if reprojection is necessary.
  if (!terra::same.crs(shape, target_crs)) {
    
    shape <- terra::project(
      shape,
      target_crs,
      method = "bilinear"
    )
  }
  
  
  # Crop to the buffered AOI and mask sea cells.
  shape <- crop_mask_aoi_land(
    raster_input = shape,
    aoi_path = aoi_path,
    epsg = target_epsg,
    aoi_negative_buffer_m = aoi_negative_buffer_m
  )
  
  
  names(shape) <- "shape"
  
  
  # Check whether valid cells remain after cropping and masking.
  has_valid_cells <- terra::global(
    !is.na(shape),
    fun = "max",
    na.rm = TRUE
  )[1, 1]
  
  
  if (
    base::is.na(has_valid_cells) ||
    has_valid_cells == 0
  ) {
    stop(
      "The raster contains no valid cells after cropping and masking."
    )
  }
  
  
  # Determine the actual range of the Shape raster.
  # The values are reported but are not modified.
  shape_min <- terra::global(
    shape,
    fun = "min",
    na.rm = TRUE
  )[1, 1]
  
  shape_max <- terra::global(
    shape,
    fun = "max",
    na.rm = TRUE
  )[1, 1]
  
  
  if (
    !base::is.finite(shape_min) ||
    !base::is.finite(shape_max)
  ) {
    stop(
      "Unable to determine the Shape value range."
    )
  }
  
  
  message(
    "Shape range: ",
    base::format(
      shape_min,
      digits = 6
    ),
    " – ",
    base::format(
      shape_max,
      digits = 6
    )
  )
  
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # REGIONAL INSET
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  
  # Bounding box of the displayed raster.
  raster_bbox <- sf::st_as_sfc(
    sf::st_bbox(
      c(
        xmin = terra::xmin(shape),
        ymin = terra::ymin(shape),
        xmax = terra::xmax(shape),
        ymax = terra::ymax(shape)
      ),
      crs = sf::st_crs(
        terra::crs(shape)
      )
    )
  )
  
  
  raster_bbox_wgs84 <- sf::st_transform(
    raster_bbox,
    4326
  )
  
  
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
      fill = scales::alpha(
        "#D73027",
                 0.20
      ),
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
      
      plot.margin = ggplot2::margin(
        2,
        2,
        2,
        2
      )
    )
  
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # MAIN MAP
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  
  projection_label <- base::switch(
    projection,
    "060" = "8k BP",
    "190" = "21k BP"
  )
  
  plot_title <- base::paste0(
    species_names[[species]],
    " — ",
    grain,
    " m — ",
    projection_label
  )
  
  
  main_map <- ggplot2::ggplot() +
    
    ggspatial::annotation_map_tile(
      type = osm_type,
      zoomin = osm_zoomin,
      cachedir = osm_cache,
      progress = "none"
    ) +
    
    ggspatial::layer_spatial(
      data = shape,
      mapping = ggplot2::aes(
        fill = ggplot2::after_stat(band1)
      ),
      alpha = raster_alpha
    ) +
    
    # No limits or transformations are specified.
    # Each map therefore uses the actual range of its Shape raster.
    ggplot2::scale_fill_viridis_c(
      option = palette,
      limits = fill_limits,
      oob = scales::squish,
      breaks = scales::breaks_pretty(
        n = 6
      ),
      labels = scales::label_number(
        accuracy = NULL,
        big.mark = " ",
        decimal.mark = ",",
        trim = TRUE
      ),
      na.value = NA,
      name = "Míra extrapolace (Shape)",
      guide = ggplot2::guide_colourbar(
        title.position = "top",
        title.hjust = 0.5,
        barwidth = grid::unit(
          75,
          "mm"
        ),
        barheight = grid::unit(
          4,
          "mm"
        ),
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
      title = if (show_title) {
        plot_title
      } else {
        NULL
      },
      x = "Zeměpisná délka",
      y = "Zeměpisná šířka"
    ) +
    
    ggplot2::theme_bw(
      base_size = 9
    ) +
    
    ggplot2::theme(
      
      panel.ontop = TRUE,
      
      panel.background = ggplot2::element_blank(),
      
      panel.grid.major = ggplot2::element_line(
        colour = scales::alpha(
          "white",
                 0.65
        ),
        linewidth = 0.18,
        linetype = "solid"
      ),
      
      panel.grid.minor = ggplot2::element_blank(),
      
      panel.border = ggplot2::element_rect(
        colour = "black",
        fill = NA,
        linewidth = 0.7
      ),
      
      axis.text = ggplot2::element_text(
        colour = "black",
        size = 8
      ),
      
      axis.title = ggplot2::element_text(
        size = 9
      ),
      
      plot.title = ggplot2::element_text(
        face = "italic",
        size = 11,
        hjust = 0
      ),
      
      legend.position = "bottom",
      
      legend.title = ggplot2::element_text(
        size = 8
      ),
      
      legend.text = ggplot2::element_text(
        size = 7.5
      ),
      
      legend.background = ggplot2::element_rect(
        fill = scales::alpha(
          "white",
                 0.88
        ),
        colour = "black",
        linewidth = 0.35
      ),
      
      legend.margin = ggplot2::margin(
        4,
        7.5,
        3,
        7.5
      ),
      
      plot.margin = ggplot2::margin(
        8,
        5,
        5,
        5
      )
    )
  
  
  # Extract the horizontal colour bar and remove it from below the map.
  shape_legend <- cowplot::get_legend(
    main_map
  )
  
  
  main_map <- main_map +
    ggplot2::theme(
      legend.position = "none"
    )
  
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # FINAL MAP
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  
  # Compose the final map:
  # - legend inside the lower-left corner,
  # - regional inset inside the upper-right corner,
  # - OSM attribution above the map frame on the right.
  final_map <- cowplot::ggdraw(
    main_map
  ) +
    
    cowplot::draw_grob(
      shape_legend,
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
        "© OpenStreetMap;",
        "SRTM, Sonny;",
        "© OpenTopoMap"
      ),
      x = 0.97,
      y = 0.97,
      hjust = 1,
      vjust = 1,
      size = 6.5,
      colour = "grey30"
    )
  
  
  # Use ragg if available.
  output_device <- if (
    requireNamespace(
      "ragg",
      quietly = TRUE
    )
  ) {
    ragg::agg_png
  } else {
    "png"
  }
  
  
  # Save PNG.
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
  
  
  message(
    "Map saved to: ",
    output_path
  )
  
  
  invisible(
    list(
      input = input_path,
      output = output_path,
      raster = shape,
      raster_range = c(
        minimum = shape_min,
        maximum = shape_max
      ),
      plot = final_map
    )
  )
}


# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# RUN ‒ selected hindcast periods
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

sp <- c(
  "GT",
  "GD",
  "PK",
  "PO",
  "PP",
  "SB"
)

gr <- c(
  1000,
  500,
  200
)

projections <- c(
  "060",
  "190"
)


for (i in base::seq_along(projections)) {
  
  # set hindcast projection
  projection <- projections[[i]]
  
  
  for (j in base::seq_along(gr)) {
    
    # set grain
    grain <- gr[[j]]
    
    
    for (k in base::seq_along(sp)) {
      
      # set species
      spec <- sp[[k]]
      
      
      # WHERE AM I?
      message(
        "__",
        projection,
        "__",
        grain,
        "__",
        spec,
        "__"
      )
      
      
      make_shape_hindcast_map(
        species = spec,
        grain = grain,
        projection = projection,
        model_id = "hindcast_forecast_extrapol_weights_all_selected",
        aoi_negative_buffer_m = 4000,
        palette = "turbo",
        raster_alpha = 1
      )
    }
  }
}
