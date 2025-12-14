# chelsa

library(here)

extent <- vect("data/extent_raw.gpkg")
extent2 <- vect("data/extent_raw_2.gpkg")

chelsa_dir <- "/media/zbub/DATA/CHELSA/bio"
dir.create(chelsa_dir, showWarnings = FALSE, recursive = TRUE)
chelsa_dir

# volitelně: zkontrolujeme, že je k dispozici wget
system("wget --version")

# základní část URL pro CHELSA v2.1 (1981–2010, složka bio)
base_url <- "https://os.zhdk.cloud.switch.ch/chelsav2/GLOBAL/climatologies/1981-2010/bio/"

# všechny TIFF soubory, které jsi vypsal
chelsa_files <- c(
  "CHELSA_ai_1981-2010_V.2.1.tif",
  "CHELSA_bio10_1981-2010_V.2.1.tif",
  "CHELSA_bio11_1981-2010_V.2.1.tif",
  "CHELSA_bio12_1981-2010_V.2.1.tif",
  "CHELSA_bio13_1981-2010_V.2.1.tif",
  "CHELSA_bio14_1981-2010_V.2.1.tif",
  "CHELSA_bio15_1981-2010_V.2.1.tif",
  "CHELSA_bio16_1981-2010_V.2.1.tif",
  "CHELSA_bio17_1981-2010_V.2.1.tif",
  "CHELSA_bio18_1981-2010_V.2.1.tif",
  "CHELSA_bio19_1981-2010_V.2.1.tif",
  "CHELSA_bio1_1981-2010_V.2.1.tif",
  "CHELSA_bio2_1981-2010_V.2.1.tif",
  "CHELSA_bio3_1981-2010_V.2.1.tif",
  "CHELSA_bio4_1981-2010_V.2.1.tif",
  "CHELSA_bio5_1981-2010_V.2.1.tif",
  "CHELSA_bio6_1981-2010_V.2.1.tif",
  "CHELSA_bio7_1981-2010_V.2.1.tif",
  "CHELSA_bio8_1981-2010_V.2.1.tif",
  "CHELSA_bio9_1981-2010_V.2.1.tif",
  "CHELSA_clt_max_1981-2010_V.2.1.tif",
  "CHELSA_clt_mean_1981-2010_V.2.1.tif",
  "CHELSA_clt_min_1981-2010_V.2.1.tif",
  "CHELSA_clt_range_1981-2010_V.2.1.tif",
  "CHELSA_cmi_max_1981-2010_V.2.1.tif",
  "CHELSA_cmi_mean_1981-2010_V.2.1.tif",
  "CHELSA_cmi_min_1981-2010_V.2.1.tif",
  "CHELSA_cmi_range_1981-2010_V.2.1.tif",
  "CHELSA_fcf_1981-2010_V.2.1.tif",
  "CHELSA_fgd_1981-2010_V.2.1.tif",
  "CHELSA_gdd0_1981-2010_V.2.1.tif",
  "CHELSA_gdd10_1981-2010_V.2.1.tif",
  "CHELSA_gdd5_1981-2010_V.2.1.tif",
  "CHELSA_gddlgd0_1981-2010_V.2.1.tif",
  "CHELSA_gddlgd10_1981-2010_V.2.1.tif",
  "CHELSA_gddlgd5_1981-2010_V.2.1.tif",
  "CHELSA_gdgfgd0_1981-2010_V.2.1.tif",
  "CHELSA_gdgfgd10_1981-2010_V.2.1.tif",
  "CHELSA_gdgfgd5_1981-2010_V.2.1.tif",
  "CHELSA_gsl_1981-2010_V.2.1.tif",
  "CHELSA_gsp_1981-2010_V.2.1.tif",
  "CHELSA_gst_1981-2010_V.2.1.tif",
  "CHELSA_hurs_max_1981-2010_V.2.1.tif",
  "CHELSA_hurs_mean_1981-2010_V.2.1.tif",
  "CHELSA_hurs_min_1981-2010_V.2.1.tif",
  "CHELSA_hurs_range_1981-2010_V.2.1.tif",
  "CHELSA_kg0_1981-2010_V.2.1.tif",
  "CHELSA_kg1_1981-2010_V.2.1.tif",
  "CHELSA_kg2_1981-2010_V.2.1.tif",
  "CHELSA_kg3_1981-2010_V.2.1.tif",
  "CHELSA_kg4_1981-2010_V.2.1.tif",
  "CHELSA_kg5_1981-2010_V.2.1.tif",
  "CHELSA_lgd_1981-2010_V.2.1.tif",
  "CHELSA_ngd0_1981-2010_V.2.1.tif",
  "CHELSA_ngd10_1981-2010_V.2.1.tif",
  "CHELSA_ngd5_1981-2010_V.2.1.tif",
  "CHELSA_npp_1981-2010_V.2.1.tif",
  "CHELSA_pet_penman_max_1981-2010_V.2.1.tif",
  "CHELSA_pet_penman_mean_1981-2010_V.2.1.tif",
  "CHELSA_pet_penman_min_1981-2010_V.2.1.tif",
  "CHELSA_pet_penman_range_1981-2010_V.2.1.tif",
  "CHELSA_rsds_1981-2010_max_V.2.1.tif",
  "CHELSA_rsds_1981-2010_mean_V.2.1.tif",
  "CHELSA_rsds_1981-2010_min_V.2.1.tif",
  "CHELSA_rsds_1981-2010_range_V.2.1.tif",
  "CHELSA_scd_1981-2010_V.2.1.tif",
  "CHELSA_sfcWind_max_1981-2010_V.2.1.tif",
  "CHELSA_sfcWind_mean_1981-2010_V.2.1.tif",
  "CHELSA_sfcWind_min_1981-2010_V.2.1.tif",
  "CHELSA_sfcWind_range_1981-2010_V.2.1.tif",
  "CHELSA_swb_1981-2010_V.2.1.tif",
  "CHELSA_swe_1981-2010_V.2.1.tif",
  "CHELSA_vpd_max_1981-2010_V.2.1.tif",
  "CHELSA_vpd_mean_1981-2010_V.2.1.tif",
  "CHELSA_vpd_min_1981-2010_V.2.1.tif",
  "CHELSA_vpd_range_1981-2010_V.2.1.tif"
)

length(chelsa_files)  # pro kontrolu, kolik jich stahujeme

# smyčka přes všechny soubory
for (fname in chelsa_files) {
  url  <- paste0(base_url, fname)
  dest <- file.path(chelsa_dir, fname)
  
  if (!file.exists(dest)) {
    message("Stahuju ", fname, " ...")
    # -q = tichý režim, -O = výstupní soubor
    cmd_status <- system2("wget", args = c("-q", "-O", dest, url))
    
    if (!identical(cmd_status, 0L)) {
      warning("wget selhal pro: ", url, " (status = ", cmd_status, ")")
    }
  } else {
    message("Už existuje, přeskakuju: ", fname)
  }
}

files <- list.files(
  path = chelsa_dir,
  pattern = "\\.tif$",
  full.names = TRUE
)
files

# x <- rast(files[3])
# plot(x)
# plot(extent2, add = T)
# crs(extent2) == crs(x)
# crs(extent) == crs(x)
# x <- crop(x, extent2)
# plot(x)
# xx <- project(extent, x)
# plot(xx, add = T)


for(i in seq_along(files)){
  print(paste0("R_", i, "_load"))
  r <- rast(files[i])
  print(paste0("R_", i, "_crop_2"))
  r <- crop(r, extent2)
  print(paste0("R_", i, "_project"))
  r <- project(r, extent)
  print(paste0("R_", i, "_crop"))
  r <- crop(r, extent)
  print(paste0("R_", i, "_mask"))
  r <- mask(r, extent)
  n <- substr(files[i], 29, nchar(files[i]))
  print(paste0("R_", i, "_write"))
  writeRaster(r, filename = paste0("/media/zbub/DATA/CHELSA/processed/", n)) # dir out
  print("GC")
  rm(r, n); gc()
}

dir_in  <- "/media/zbub/DATA/CHELSA/processed"
dir_out <- "/media/zbub/DATA/CHELSA/pngs_out"

if (!dir.exists(dir_out)) dir.create(dir_out, recursive = TRUE)

raster_files <- list.files(dir_in, pattern = "\\.tif$", full.names = TRUE)

for (f in raster_files) {
  r <- rast(f)
  base_name <- tools::file_path_sans_ext(basename(f))
  out_png   <- file.path(dir_out, paste0(base_name, ".png"))
  png(out_png, width = 1200, height = 1000, res = 120)
  plot(r, main = base_name)
  dev.off()
}
