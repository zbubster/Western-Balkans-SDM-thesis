# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Align S2 tiles ‒ main workflow
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

terraOptions(progress = 1)

# Settings
in_dir  <- "/media/zbub/DATA/Sentinel2_medoids/"
out_dir <- "/media/zbub/DATA/Sentinel2_aligned_medoids/"
ref_id  <- 42 # reference tile
pattern <- "\\.tif$"

if(!dir.exists(out_dir)){
  dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
}

# List files
files <- list.files(in_dir, pattern = pattern, full.names = TRUE)
stopifnot(length(files) == 81)

# (volitelně) seřaď: když mají tiles v názvu číslo, je to často užitečné
files <- sort(files)

message("Tiles loaded: ", length(files))

# --- 2) reference raster (tile 42) ---
ref <- rast(files[ref_id])
ref1 <- ref[[1]]   # jen 1 vrstva pro grid/extent operace

message("Reference file: ", basename(files[ref_id]))
message("Reference CRS: ", crs(ref1))
message("Reference res: ", paste(res(ref1), collapse = " x "))

# --- 3) union extent of all tiles (metadata only) ---
ext_all <- Reduce(terra::union, lapply(files, function(f) ext(rast(f))))

# --- 4) global template: grid of tile 42 extended to whole AOI ---
template <- extend(ref1, ext_all)
template <- init(template, 1)  # vyplň konstantou (důležité pro pozdější crop/resample a převody)

# --- 5) checks for band count + unify names ---
ref_nlyr <- nlyr(ref)
ref_names <- names(ref)

# --- 6) align each tile to template using NN and mask footprint ---
aligned_files <- character(length(files))

# GDAL write options (tune as you like)
wopt <- list(
  datatype = "INT2S",  # <-- změň podle dat (viz poznámka níž)
  gdal = c("COMPRESS=DEFLATE", "TILED=YES", "BIGTIFF=YES")
)

# Poznámka k datatype:
# - pokud máš reflectance jako integer škálovaný (např. 0-10000), INT2S/INT4S je OK
# - pokud máš float reflectance, dej "FLT4S"
# Mrkni na: terra::minmax(ref) / terra::datatype(ref)

for (i in seq_along(files)) {
  f <- files[i]
  message(sprintf("[%02d/%02d] %s", i, length(files), basename(f)))
  
  r <- rast(f)
  
  # kontrola vrstev
  if (nlyr(r) != ref_nlyr) {
    stop("Tile has different number of layers than reference: ",
         basename(f), " (", nlyr(r), " vs ", ref_nlyr, ")")
  }
  
  # sjednoť názvy vrstev (aby vrstvy odpovídaly)
  names(r) <- ref_names
  
  # footprint maska z 1. bandu (kde jsou reálná data)
  m <- !is.na(r[[1]])
  
  # 6a) align data (NN)
  # pokud CRS sedí, stačí resample; když by nesedělo, použij project
  if (!same.crs(r, template)) {
    r_al <- project(r, template, method = "near")
    m_al <- project(m, template, method = "near")
  } else {
    r_al <- resample(r, template, method = "near")
    m_al <- resample(m, template, method = "near")
  }
  
  # 6b) mask outside original footprint to NA
  m_al <- as.int(m_al)  # 1/0
  r_al <- mask(r_al, m_al, maskvalues = 0, updatevalue = NA)
  
  # 6c) write aligned tile
  out_file <- file.path(out_dir, sprintf("tile_%03d_aligned_nn.tif", i))
  writeRaster(r_al, out_file, overwrite = TRUE, wopt = wopt)
  
  aligned_files[i] <- out_file
  
  # uvolnění paměti (u velkých rastrů pomáhá)
  rm(r, m, r_al, m_al)
  gc()
}

message("Done. Aligned tiles written to: ", out_dir)

# --- 7) optional: quick sanity check ---
# compare one random tile extent to template
# rast(aligned_files[1])
