# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# ESM
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# load functions
source(here::here("scripts", "fun_ESM_functions.R"))

# main config

grains <- c(1000, 500, 200, 100)
species <- c("GD", "GT", "SB", "PK", "PO", "PP")
modelling_id <- "recent_noextrapol_weights_common"
occ_base_dir <- here::here("data", "__ANALYSIS__", "OCC", "weights")
pred_base_dir <- here::here("data", "__PREDICTORS_STACKS__", "recent", "selected_predictors_stacks", "noextrapol")
collinearity_type <- "_common"

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# LOOP

for(i in seq_along(grains)){
  
  # set grain
  grain <- grains[[i]]
  
  for(j in seq_along(species)){
    
    # set species
    sp <- species[[j]]
    
    # WHERE AM I?
    message("__", grain, "__", sp, "__")
    
    # load objects
    path_to_occ <- here::here(occ_base_dir, paste0(sp, "_", grain, "m.rds"))
    occ <- base::readRDS(path_to_occ)
    path_to_pred <- here::here(pred_base_dir, paste0(sp, collinearity_type), paste0("r_", grain, ".tif"))
    pred <- terra::rast(path_to_pred)
    
    # define output directories
    mod_dir <- here::here("models", "ESM", modelling_id, sp, grain)
    if(!dir.exists(mod_dir)) dir.create(mod_dir, recursive = T)
    resp_curv_dir <- here::here("models", "ESM", modelling_id, sp, grain, "resp_curv")
    if(!dir.exists(resp_curv_dir)) dir.create(resp_curv_dir, recursive = T)
    
    # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
    
    # prepare data for modelling
    cats <- dplyr::intersect(names(pred), c("landcover", "bedrock"))
    
    # mask unwanted landcover class before modelling and projection
    if ("landcover" %in% base::names(pred)) {
      pred[["landcover"]] <- terra::ifel(
        pred[["landcover"]] == 80,
        NA,
        pred[["landcover"]]
      )
    }
    
    # prepare data for modelling
    prep <- prepare_occ_for_modeling(occ = occ, pred = pred, factor_cols = cats)
    
    saveRDS(prep, file = file.path(mod_dir, "prepared_data.rds"))
    message("Prepared data saved.")
    
    # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
    
    # fit models
    esm <- esm_fit_bivariate(
      prep = prep,
      algorithms = base::c("glm", "gbm", "gam", "cta", "mars", "rf"),
      threshold = 0,
      weight_transform = "identity",
      seed = 722085415
    )
    
    saveRDS(esm, file = file.path(mod_dir, "esm_fit_bivariate.rds"))
    message("ESM saved.")
    
    # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
    
    # projection
    proj <- esm_project_bivariate(
      esm = esm,
      new_env = pred
    )
    
    terra::writeRaster(
      proj,
      filename = file.path(mod_dir, "ESM_projection.tif"),
      wopt = list(gdal = c("COMPRESS=LZW", "TILED=YES", "BIGTIFF=YES"))
    )
    message("Raster projection saved.")
    
    # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
    
    # response curves
    rc <- esm_response_curves_bivariate(
      esm = esm,
      vars = esm$predictors,
      ref_data = esm$data,
      n_points = 100
    )
    
    saveRDS(rc, file = file.path(mod_dir, "response_curves.rds"))
    message("Response curves RDS file saved.")
    
    # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
    
    # plot response curves
    prediktoraky <- base::unique(rc$variable)
    prediktoraky_con <- prediktoraky[!(prediktoraky %in% base::c("landcover", "bedrock"))]
    prediktoraky_fac <- prediktoraky[prediktoraky %in% base::c("landcover", "bedrock")]

    # numeric predictors
    for(k in seq_along(prediktoraky_con)){
      p <- prediktoraky_con[[k]]
      
      grDevices::png(filename = base::file.path(resp_curv_dir, base::paste0(p, "_simple.png")), width = 500, height = 400)
      print(plot_esm_response_numeric(rc, p))
      grDevices::dev.off()
      
      grDevices::png(filename = base::file.path(resp_curv_dir, base::paste0(p, "_complex.png")), width = 500, height = 400)
      print(plot_esm_response_numeric_with_small(rc, p))
      grDevices::dev.off()
    }
    
    # factor predictors
    for(l in seq_along(prediktoraky_fac)){
      p <- prediktoraky_fac[[l]]
      
      grDevices::png(file = base::file.path(resp_curv_dir, base::paste0(p, "_barplot.png")), width = 500, height = 400)
      print(plot_esm_response_factor(rc, p))
      grDevices::dev.off()
    }
    
    gc()
  }
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #