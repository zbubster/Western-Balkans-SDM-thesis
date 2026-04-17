# ------------------------------------------------------------
# ESM workflow with ecospat for presence-absence data
# root-only version
# ------------------------------------------------------------

run_ecospat_esm <- function(
    occ,
    pred,
    vars = base::names(pred),
    models = c("RF", "GBM"),
    weighting.score = "SomersD",
    ensemble.threshold = 0,
    prevalence = 0.5,
    yweights = NULL,
    categorical_layers = NULL,
    tune = FALSE,
    parallel = FALSE,
    fixed.var.metric = "mean",
    modeling_id = NULL,
    proj_name = "current_1000m"
) {
  
  # -----------------------------
  # basic checks
  # -----------------------------
  if (!inherits(pred, "SpatRaster")) {
    base::stop("'pred' musí být terra::SpatRaster.")
  }
  
  req_names <- c("species", "observations", "coor", "CV.user.table")
  miss_names <- req_names[!req_names %in% base::names(occ)]
  
  if (base::length(miss_names) > 0) {
    base::stop(
      paste0("V objektu 'occ' chybí: ", paste(miss_names, collapse = ", "))
    )
  }
  
  if (!all(vars %in% base::names(pred))) {
    base::stop("Některé 'vars' nejsou mezi vrstvami rastru 'pred'.")
  }
  
  if (base::length(occ$observations) != base::nrow(occ$coor)) {
    base::stop("Počet observations a počet řádků v 'coor' se neshoduje.")
  }
  
  if (base::length(occ$observations) != base::nrow(occ$CV.user.table)) {
    base::stop("Počet observations a počet řádků v 'CV.user.table' se neshoduje.")
  }
  
  # -----------------------------
  # species name and predictor subset
  # -----------------------------
  sp_name <- occ$species
  sp_name_safe <- gsub("[^[:alnum:]_]+", "_", sp_name)
  
  if (base::is.null(modeling_id)) {
    modeling_id <- paste0(sp_name_safe, "_ESM")
  }
  
  pred_use <- pred[[vars]]
  
  # -----------------------------
  # categorical predictors
  # -----------------------------
  if (!base::is.null(categorical_layers)) {
    categorical_layers <- base::intersect(categorical_layers, base::names(pred_use))
    
    if (base::length(categorical_layers) > 0) {
      pred_use[[categorical_layers]] <- terra::as.factor(pred_use[[categorical_layers]])
    }
  }
  
  # -----------------------------
  # BIOMOD formatting
  # -----------------------------
  base::message("Formatting:")
  
  bm_data <- biomod2::BIOMOD_FormatingData(
    resp.var = occ$observations,
    expl.var = pred_use,
    resp.xy = occ$coor,
    resp.name = sp_name_safe,
    filter.raster = FALSE,
    na.rm = FALSE
  )
  
  # -----------------------------
  # ESM calibration
  # -----------------------------
  base::message("ESM modelling:")
  
  esm_mod <- ecospat::ecospat.ESM.Modeling(
    data = bm_data,
    DataSplitTable = occ$CV.user.table,
    Prevalence = prevalence,
    weighting.score = weighting.score,
    models = models,
    tune = tune,
    modeling.id = modeling_id,
    parallel = parallel,
    Yweights = yweights
  )
  
  # -----------------------------
  # ensemble of bivariate models
  # -----------------------------
  base::message("ESM ensemble modelling:")
  
  esm_ens <- ecospat::ecospat.ESM.EnsembleModeling(
    ESM.modeling.output = esm_mod,
    weighting.score = weighting.score,
    threshold = ensemble.threshold,
    models = models
  )
  
  # -----------------------------
  # pooled evaluation
  # -----------------------------
  base::message("ESM ensemble evaluation:")
  
  esm_pool <- ecospat::ecospat.ESM.EnsembleEvaluation(
    ESM.modeling.output = esm_mod,
    ESM.EnsembleModeling.output = esm_ens,
    metrics = c("SomersD", "AUC", "MaxTSS", "MaxKappa", "Boyce"),
    EachSmallModels = FALSE
  )
  
  # -----------------------------
  # thresholds
  # -----------------------------
  base::message("ESM threshold:")
  
  esm_th <- ecospat::ecospat.ESM.threshold(
    ESM.EnsembleModeling.output = esm_ens,
    PEplot = FALSE
  )
  
  # -----------------------------
  # projection of all bivariate models
  # WORKAROUND:
  # project via data.frame, not via SpatRaster
  # -----------------------------
  base::message("ESM projection via data.frame workaround:")
  
  # keep a raster template for back-conversion at the end
  template_r <- pred_use[[1]]
  
  # convert predictors to data.frame in raster cell order
  # na.rm = FALSE is important, we need all cells preserved
  proj_df <- terra::as.data.frame(
    pred_use,
    xy = FALSE,
    cells = FALSE,
    na.rm = FALSE
  )
  
  esm_proj <- ecospat::ecospat.ESM.Projection(
    ESM.modeling.output = esm_mod,
    new.env = proj_df,
    name.env = proj_name,
    parallel = FALSE
  )
  
  # -----------------------------
  # final ensemble projection
  # returns a data.frame in this branch
  # -----------------------------
  base::message("ESM ensemble projection:")
  
  esm_ens_proj <- ecospat::ecospat.ESM.EnsembleProjection(
    ESM.prediction.output = esm_proj,
    ESM.EnsembleModeling.output = esm_ens,
    chosen.models = "all"
  )
  
  # some versions may return the data.frame directly;
  # others may wrap it in a named list-like object
  if (base::is.list(esm_ens_proj) && "ESM.projections" %in% base::names(esm_ens_proj)) {
    esm_ens_proj <- esm_ens_proj$ESM.projections
  }
  
  if (!base::is.data.frame(esm_ens_proj)) {
    base::stop("ESM ensemble projection nevrátil data.frame, jak bylo očekáváno.")
  }
  
  # -----------------------------
  # convert projected data.frame back to raster layers
  # projections are typically on 0-1000 scale
  # -----------------------------
  esm_rasters <- lapply(base::names(esm_ens_proj), function(nm) {
    r <- template_r
    terra::values(r) <- esm_ens_proj[[nm]]
    base::names(r) <- nm
    r
  })
  
  esm_ens_proj_rast <- do.call(c, esm_rasters)
  
  # -----------------------------
  # variable contribution
  # -----------------------------
  base::message("ESM variable contribution:")
  
  esm_varcontrib <- ecospat::ecospat.ESM.VarContrib(
    ESM.modeling.output = esm_mod,
    ESM_EF.output = esm_ens
  )
  
  # -----------------------------
  # response curves
  # -----------------------------
  # -----------------------------
  # response curves
  # ecospat currently fails for ESMs with categorical predictors
  # -----------------------------
  base::message("Response curves:")
  
  esm_response <- NULL
  
  has_categorical <- !base::is.null(categorical_layers) &&
    base::length(base::intersect(categorical_layers, base::names(pred_use))) > 0
  
  if (has_categorical) {
    base::message(
      "Skipping ecospat::ecospat.ESM.responsePlot() because categorical predictors ",
      "trigger a known ecospat error."
    )
  } else {
    pdf_file <- paste0(sp_name_safe, "_ESM_response_curves.pdf")
    
    grDevices::pdf(
      file = pdf_file,
      width = 10,
      height = 8
    )
    
    esm_response <- ecospat::ecospat.ESM.responsePlot(
      ESM.EnsembleModeling.output = esm_ens,
      ESM.modeling.output = esm_mod,
      fixed.var.metric = fixed.var.metric
    )
    
    grDevices::dev.off()
  }
  
  # -----------------------------
  # write final projection to disk
  # note:
  # thresholds are on 0-1 scale
  # projections are usually on 0-1000 scale
  # -----------------------------
  out_prob <- paste0(sp_name_safe, "_ESM_ensemble_projection.tif")
  out_bin_tss <- paste0(sp_name_safe, "_ESM_ensemble_binary_TSS.tif")
  
  esm_binary_tss <- NULL
  
  terra::writeRaster(
    x = esm_ens_proj_rast,
    filename = out_prob,
    overwrite = TRUE
  )
  
  if ("TSS.th" %in% base::names(esm_th) && "EF" %in% base::names(esm_ens_proj_rast)) {
    esm_binary_tss <- esm_ens_proj_rast[["EF"]] > (esm_th$TSS.th[1] * 1000)
    esm_binary_tss <- esm_binary_tss * 1
    base::names(esm_binary_tss) <- "EF_TSS_binary"
    
    terra::writeRaster(
      x = esm_binary_tss,
      filename = out_bin_tss,
      overwrite = TRUE
    )
  }
  
  return(list(
    biomod_data = bm_data,
    esm_modeling = esm_mod,
    esm_ensemble = esm_ens,
    esm_pooling_evaluation = esm_pool,
    esm_thresholds = esm_th,
    esm_projection = esm_proj,
    esm_ensemble_projection_df = esm_ens_proj,
    esm_ensemble_projection = esm_ens_proj_rast,
    esm_binary_tss = esm_binary_tss,
    esm_varcontrib = esm_varcontrib,
    esm_response = esm_response
  ))
}

getwd()

res_esm_w <- run_ecospat_esm(
  occ = occ,
  pred = pred,
  vars = base::names(pred),
  models = c("RF", "GBM"),
  weighting.score = "SomersD",
  ensemble.threshold = 0,
  prevalence = NULL,
  yweights = occ$weights,
  # prevalence = 0.5,
  # yweights = NULL,
  categorical_layers = c("landcover", "bedrock"),
  tune = FALSE,
  parallel = FALSE,
  fixed.var.metric = "mean",
  modeling_id = "Gentiana_dinarica_ESM_weighted_100",
  proj_name = "current_100m"
)

res_test <- run_ecospat_esm(
  occ = occ,
  pred = pred,
  vars = base::names(pred),
  models = c("RF", "GBM"),
  weighting.score = "SomersD",
  ensemble.threshold = 0,
  prevalence = 0.5,
  yweights = NULL,
  categorical_layers = NULL,
  tune = FALSE,
  parallel = FALSE
)
