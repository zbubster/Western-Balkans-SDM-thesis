
# Replotting script

source("scripts/fun_ESM_functions.R")

grains <- c(1000, 500, 200, 100)
species <- c("GD", "GT", "SB", "PK", "PO", "PP")

modelling_id <- "recent_noextrapol_weights_common"
occ_base_dir <- here::here("data", "__ANALYSIS__", "OCC", "weights")
pred_base_dir <- here::here("data", "__PREDICTORS_STACKS__", "recent", "selected_predictors_stacks", "noextrapol")
collinearity_type <- "_common"


for(i in seq_along(grains)){
  
  # set grain
  grain <- grains[[i]]
  
  for(j in seq_along(species)){
    
    # set species
    sp <- species[[j]]
    
    # WHERE AM I?
    message("__", grain, "__", sp, "__")
    
    # define output directories
    mod_dir <- here::here("models", "ESM", modelling_id, sp, grain)
    if(!dir.exists(mod_dir)) dir.create(mod_dir, recursive = T)
    resp_curv_dir <- here::here("models", "ESM", modelling_id, sp, grain, "resp_curv")
    if(!dir.exists(resp_curv_dir)) dir.create(resp_curv_dir, recursive = T)
    
    print(mod_dir)
    print(resp_curv_dir)
    
    # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
    
    rc <- readRDS(file.path(mod_dir, "response_curves.rds"))

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

  }
}
