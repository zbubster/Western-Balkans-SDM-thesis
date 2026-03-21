

r <- terra::rast("data/__ANALYSIS__/STACKS_FULL/SB_common/r_500.tif")
s <- readRDS("data/__ANALYSIS__/OCC/weights/SB_500m.rds")

mod_dir <- here::here("models", "grain", "SB")
if(!dir.exists(mod_dir)) dir.create(mod_dir, recursive = T)

data <- biomod2::BIOMOD_FormatingData(
  resp.name = "Saxbla_100m",
  resp.var = s$observations,
  resp.xy = s$coor,
  expl.var = r,
  dir.name = mod_dir,
  data.type = "binary",
  na.rm = FALSE,
  filter.raster = FALSE,
  seed.val = 722085415
)

models <- biomod2::BIOMOD_Modeling(
  bm.format = data,
  #modeling.id = 1,
  models = c("RFd", "GLM", "GBM"),
  CV.strategy = "user.defined",
  CV.user.table = s$CV.user.table,
  CV.do.full.models = FALSE,
  OPT.strategy = "bigboss",
  metric.eval = c("AUCroc", "TSS"),
  var.import = 10,
  weights = s$weights,
  scale.models = FALSE,
  nb.cpu = 12,
  seed.val = 722085415,
  do.progress = TRUE
)

# Get evaluation scores & variables importance
get_evaluations(models)
get_variables_importance(models)

# Represent evaluation scores & variables importance
bm_PlotEvalMean(bm.out = models, dataset = 'calibration')
bm_PlotEvalMean(bm.out = models, dataset = 'validation')
bm_PlotEvalBoxplot(bm.out = models, dataset = 'calibration', group.by = c('algo', 'algo'))
bm_PlotEvalBoxplot(bm.out = models, dataset = 'validation', group.by = c('algo', 'algo'))
bm_PlotEvalBoxplot(bm.out = models, dataset = 'calibration', group.by = c('algo', 'run'))
bm_PlotEvalBoxplot(bm.out = models, dataset = 'validation', group.by = c('algo', 'run'))
bm_PlotVarImpBoxplot(bm.out = models, group.by = c('expl.var', 'algo', 'algo'))
bm_PlotVarImpBoxplot(bm.out = models, group.by = c('expl.var', 'algo', 'run'))
bm_PlotVarImpBoxplot(bm.out = models, group.by = c('algo', 'expl.var', 'run'))

# Represent response curves
bm_PlotResponseCurves(bm.out = models, 
                      models.chosen = get_built_models(models)[c(6:24)],
                      fixed.var = 'median')
bm_PlotResponseCurves(bm.out = models, 
                      models.chosen = get_built_models(models)[c(1, 4, 8, 10, 13)],
                      fixed.var = 'mean')
bm_PlotResponseCurves(bm.out = models, 
                      models.chosen = get_built_models(models)[4],
                      fixed.var = 'median',
                      do.bivariate = TRUE)

# Explore models' outliers & residuals
bm_ModelAnalysis(bm.mod = models,
                 models.chosen = get_built_models(models)[c(1, 4, 8, 10, 13)])

# Model ensemble models
myBiomodEM <- BIOMOD_EnsembleModeling(bm.mod = models,
                                      models.chosen = 'all',
                                      em.by = 'all',
                                      em.algo = c('EMmedian', 'EMmean', 'EMwmean',
                                                  'EMca', 'EMci', 'EMcv'),
                                      metric.select = c('AUCroc'),
                                      metric.select.thresh = c(0.7),
                                      metric.eval = c('TSS', 'AUCroc'),
                                      var.import = 3,
                                      EMci.alpha = 0.05,
                                      EMwmean.decay = 'proportional')
myBiomodEM

# Get evaluation scores & variables importance
get_evaluations(myBiomodEM)
get_variables_importance(myBiomodEM)

# Represent evaluation scores & variables importance
bm_PlotEvalMean(bm.out = myBiomodEM, dataset = 'calibration', group.by = 'full.name')
bm_PlotEvalBoxplot(bm.out = myBiomodEM, dataset = 'calibration', group.by = c('full.name', 'full.name'))
bm_PlotVarImpBoxplot(bm.out = myBiomodEM, group.by = c('expl.var', 'full.name', 'full.name'))
bm_PlotVarImpBoxplot(bm.out = myBiomodEM, group.by = c('expl.var', 'algo', 'merged.by.run'))
bm_PlotVarImpBoxplot(bm.out = myBiomodEM, group.by = c('algo', 'expl.var', 'merged.by.run'))

# Represent response curves
bm_PlotResponseCurves(bm.out = myBiomodEM, 
                      models.chosen = get_built_models(myBiomodEM)[c(1, 6, 7)],
                      fixed.var = 'median')
bm_PlotResponseCurves(bm.out = myBiomodEM, 
                      models.chosen = get_built_models(myBiomodEM)[c(1, 6, 7)],
                      fixed.var = 'min')
bm_PlotResponseCurves(bm.out = myBiomodEM, 
                      models.chosen = get_built_models(myBiomodEM)[7],
                      fixed.var = 'median',
                      do.bivariate = TRUE)


# Project single models
myBiomodProj <- BIOMOD_Projection(bm.mod = models,
                                  proj.name = 'Current',
                                  new.env = r,
                                  models.chosen = 'all',
                                  metric.binary = 'all',
                                  metric.filter = 'all',
                                  build.clamping.mask = TRUE,
                                  nb.cpu = 12, 
                                  seed.val = 722085415)
myBiomodProj
plot(myBiomodProj)


# Project ensemble models (from single projections)
myBiomodEMProj <- BIOMOD_EnsembleForecasting(bm.em = myBiomodEM, 
                                             bm.proj = myBiomodProj,
                                             models.chosen = 'all',
                                             metric.binary = 'all',
                                             metric.filter = 'all')

get_built_models(myBiomodEM)

# Project ensemble models (building single projections)
myBiomodEMProj <- BIOMOD_EnsembleForecasting(bm.em = myBiomodEM,
                                             proj.name = 'CurrentEM',
                                             new.env = r,
                                             models.chosen = "Saxbla.100m_EMwmeanByAUCroc_mergedData_mergedRun_mergedAlgo",
                                             metric.binary = 'all',
                                             metric.filter = 'all',
                                             nb.cpu = 2,
                                             keep.in.memory = FALSE)
myBiomodEMProj
plot(myBiomodEMProj)
