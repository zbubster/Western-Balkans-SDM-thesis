# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Collinearity
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Config

# where should be cormats and other info stored
out_dir <- here::here("data", "predictors_collinearity")
if(!dir.exists(out_dir)){dir.create(out_dir)}

rasters_dir <- here::here("data", "__COMPATIBILITY__", "STACKS", "__STACKS_MASKED__")
r <- list()
for(i in seq_along(list.files(rasters_dir))){
  n <- list.files(rasters_dir)[i]
  r[[i]] <- terra::rast(file.path(rasters_dir, n))
  names(r)[i] <- n
}

species_dir <- here::here("data", "occurence", "_ANALYSIS_FOCAL_", "_FILTER_")
s <- list()
for(i in seq_along(list.files(species_dir))){
  n <- list.files(species_dir)[i]
  s[[i]] <- base::readRDS(file.path(species_dir, n))
  names(s)[i] <- n
}

# load species spatially
spatialspec <- function(l){
  coords <- l$coor
  obs <- l$observations
  out <- terra::vect(
    x = coords,
    geom = c("X", "Y"),
    crs = terra::crs("epsg:3035")
  )
  out$observ <- obs
  return(out)
}

s <- lapply(s, spatialspec)

# divide species list into lists based on grain
s_1000 <- s[grepl("_1000m\\.rds$", names(s))]
s_500 <- s[grepl("_500m\\.rds$",  names(s))]
s_200 <- s[grepl("_200m\\.rds$",  names(s))]
s_100 <- s[grepl("_100m\\.rds$",  names(s))]

str(r)
str(s)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# sample values, extract

seed <- 722085415
set.seed(seed)

# RANDOM

# random spat sample function
spsam <- function(l){
  vals <- terra::spatSample(
    l,
    size = 130000,
    method = "random",
    na.rm = TRUE,
    as.df = TRUE
  )
  return(vals) # returns sampled predictor values
}
# apply function over grain levels
v <- lapply(r, spsam)

# OBSERVATIONS

# extract raster values on observation points
extract_predictor_values_on_observations <- function(spec_list, raster){
  stopifnot(class(raster) == "SpatRaster")
  out <- list()
  out <- lapply(spec_list, terra::extract, x = raster, bind = TRUE)
  out <- lapply(out, as.data.frame)
  out <- lapply(out, drop_na)
  return(out)
}

# apply extract function over different grain levels and different species
v_1000 <- extract_predictor_values_on_observations(s_1000, raster = r$r_1000.tif)
v_500 <- extract_predictor_values_on_observations(s_500, raster = r$r_500.tif)
v_200 <- extract_predictor_values_on_observations(s_200, raster = r$r_200.tif)
v_100 <- extract_predictor_values_on_observations(s_100, raster = r$r_100.tif)


# convert selected predictors
specpred <- function(l){
  # geo to factor 
  l$glim <- as.factor(l$glim)
  # aspect to orientation
  l$northness <- cos(l$aspect*pi/180)
  l$eastness <- sin(l$aspect*pi/180)
  
  return(l)
}

v_random <- lapply(v, specpred)
v_1000 <- lapply(v_1000, specpred)
v_500 <- lapply(v_500, specpred)
v_200 <- lapply(v_200, specpred)
v_100 <- lapply(v_100, specpred)


# define prefered order of predictors based on ecological knowledge
predictors <- c(
  "glim", 
  "TPI", "TRI", "TRIriley", "TRIrmsd", "roughness", 
  "slope", "northness", "eastness", "aspect", "hli", "twi", "scd",
  "bio04", "bio05", "bio06", "bio13", "bio14", "bio18", "bio19",
  "bio09", "bio10", "bio11", "bio12", "bio07", "bio08", "bio01", "bio15", "bio16", 
  "bio17", "bio02", "bio03")



f <- function(l){
  out <- list()
  if("observ" %in% names(l)){
    out$main <- collinear::collinear(
      df = l,
      responses = "observ",
      preference_order = predictors,
      max_cor = 0.7,
      max_vif = 7,
      quiet = T
    )
  } else {
    out$main <- collinear::collinear(
      df = l,
      preference_order = predictors,
      max_cor = 0.7,
      max_vif = 7,
      quiet = T
    )
  }
  
  sel <- summary(out$main)$selected_predictors
  sel <- base::intersect(sel, predictors)
  out$selected_predictors <- sel
  
  out$cor_mat <- collinear::cor_matrix(
    df = l,
    predictors = predictors,
    quiet = T
  )
  out$cor_mat_selected <- collinear::cor_matrix(
    df = l,
    predictors = sel,
    quiet = T
  )
  grDevices::png(
    filename = file.path(out_dir, paste0(nm, "_all.png")),
    width = 2200,
    height = 2200,
    res = 220
  )
  corrplot::corrplot(
    out$cor_mat,
    method = "ellipse",
    type = "upper",
    order = "alphabet",
    diag = TRUE,
    tl.col = "black",
    tl.cex = 0.8,
    title = "All predictors"
  )
  grDevices::dev.off()
  
  grDevices::png(
    filename = file.path(out_dir, paste0(nm, "_selected.png")),
    width = 2200,
    height = 2200,
    res = 220
  )
  corrplot::corrplot(
    out$cor_mat_selected,
    method = "ellipse",
    type = "upper",
    order = "alphabet",
    diag = TRUE,
    tl.col = "black",
    tl.cex = 0.8,
    title = "Selected predictors"
  )
  grDevices::dev.off()
  return(out)
}

res_v_1000 <- vector(mode = "list", length = base::length(v_1000))
base::names(res_v_1000) <- base::names(v_1000)

for(i in base::seq_along(v_1000)){
  nm <- sub("\\.rds$", "", base::names(v_1000)[i])
  res_v_1000[[i]] <- f(v_1000[[i]])
}


#######################################





# # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# # pairwise correlations
# # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# 
# cor_mat <- stats::cor(
#   cont_cc,
#   use = "pairwise.complete.obs",
#   method = "pearson"
# )
# 
# # table of highly correlated pairs
# cor_df_full <- base::as.data.frame(base::as.table(cor_mat), stringsAsFactors = FALSE)
# base::names(cor_df_full) <- c("var1", "var2", "r")
# 
# high_cor_tab <- cor_df_full[
#   cor_df_full$var1 != cor_df_full$var2 &
#     base::abs(cor_df_full$r) >= 0.7,
# ]
# 
# # keep each pair only once
# high_cor_tab <- high_cor_tab[
#   base::as.character(high_cor_tab$var1) < base::as.character(high_cor_tab$var2),
# ]
# 
# high_cor_tab <- high_cor_tab[order(-base::abs(high_cor_tab$r)), ]
# 
# print(high_cor_tab)
# 
# # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# # PCA
# # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# 
# pca_res <- stats::prcomp(cont_cc, center = TRUE, scale. = TRUE)
# 
# pca_var <- (pca_res$sdev^2) / base::sum(pca_res$sdev^2)
# pca_var_tab <- base::data.frame(
#   PC = base::paste0("PC", base::seq_along(pca_var)),
#   variance_explained = pca_var,
#   cumulative_variance = base::cumsum(pca_var)
# )
# 
# print(pca_var_tab)
# 
# # loadings
# pca_loadings <- base::as.data.frame(pca_res$rotation)
# pca_loadings$variable <- base::rownames(pca_loadings)
# pca_loadings <- pca_loadings[, c("variable", base::setdiff(base::names(pca_loadings), "variable"))]
# 
# print(pca_loadings)
# 
# # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# # VIF
# # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# 
# vif_res <- usdm::vifstep(cont_cc, th = 10)
# 
# vif_tab <- methods::slot(vif_res, "results")
# vif_excluded <- methods::slot(vif_res, "excluded")
# 
# print(vif_tab)
# print(vif_excluded)
# 
# # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# # GLIM vs continuous variables
# # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# 
# kw_res <- base::lapply(
#   base::names(cont_cc),
#   function(nm) {
#     stats::kruskal.test(
#       stats::as.formula(base::paste(nm, "~ glim")),
#       data = vals_cc
#     )
#   }
# )
# base::names(kw_res) <- base::names(cont_cc)
# 
# # helper: epsilon-squared effect size for Kruskal-Wallis
# kw_tab <- base::do.call(
#   rbind,
#   base::lapply(
#     base::names(kw_res),
#     function(nm) {
#       kt <- kw_res[[nm]]
#       n <- base::sum(stats::complete.cases(vals_cc[, c(nm, "glim")]))
#       k <- base::nlevels(vals_cc$glim)
#       H <- base::as.numeric(kt$statistic)
#       eps2 <- (H - k + 1) / (n - k)
#       
#       base::data.frame(
#         variable = nm,
#         statistic = H,
#         df = base::as.numeric(kt$parameter),
#         p_value = kt$p.value,
#         epsilon2 = eps2
#       )
#     }
#   )
# )
# 
# kw_tab <- kw_tab[order(kw_tab$p_value), ]
# print(kw_tab)
# 
# # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# # GLIM frequencies
# # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# 
# glim_freq <- base::as.data.frame(base::table(vals_cc$glim))
# base::names(glim_freq) <- c("glim", "n")
# glim_freq$prop <- glim_freq$n / base::sum(glim_freq$n)
# 
# print(glim_freq)
# 
# # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# # VISUALIZATION
# # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# 
# # 1) correlation heatmap
# ord <- stats::hclust(stats::as.dist(1 - base::abs(cor_mat)))$order
# cor_ord <- cor_mat[ord, ord]
# 
# cor_plot_df <- base::as.data.frame(base::as.table(cor_ord), stringsAsFactors = FALSE)
# base::names(cor_plot_df) <- c("var1", "var2", "r")
# 
# p_cor <- ggplot2::ggplot(cor_plot_df, ggplot2::aes(x = var1, y = var2, fill = r)) +
#   ggplot2::geom_tile() +
#   ggplot2::scale_fill_gradient2(low = "black", mid = "white", high = "red", midpoint = 0) +
#   ggplot2::coord_equal() +
#   ggplot2::theme_minimal() +
#   ggplot2::theme(
#     axis.title = ggplot2::element_blank(),
#     axis.text.x = ggplot2::element_text(angle = 45, hjust = 1),
#     panel.grid = ggplot2::element_blank()
#   ) +
#   ggplot2::ggtitle("Pearson correlation matrix")
# 
# print(p_cor)
# 
# # 2) PCA scree plot
# p_scree <- ggplot2::ggplot(
#   pca_var_tab[1:min(10, nrow(pca_var_tab)), ],
#   ggplot2::aes(x = PC, y = variance_explained)
# ) +
#   ggplot2::geom_col() +
#   ggplot2::geom_line(
#     ggplot2::aes(group = 1, y = cumulative_variance)
#   ) +
#   ggplot2::geom_point(
#     ggplot2::aes(y = cumulative_variance)
#   ) +
#   ggplot2::theme_minimal() +
#   ggplot2::ylab("Proportion of variance explained") +
#   ggplot2::xlab(NULL) +
#   ggplot2::ggtitle("PCA scree plot")
# 
# print(p_scree)
# 
# # 3) PCA scatterplot (subset for readability)
# pca_scores <- base::as.data.frame(pca_res$x[, 1:2, drop = FALSE])
# pca_scores$glim <- vals_cc$glim
# 
# set.seed(722085415)
# idx_plot <- base::sample(
#   x = base::seq_len(nrow(pca_scores)),
#   size = base::min(10000, nrow(pca_scores))
# )
# 
# p_pca <- ggplot2::ggplot(
#   pca_scores[idx_plot, , drop = FALSE],
#   ggplot2::aes(x = PC1, y = PC2, color = glim)
# ) +
#   ggplot2::geom_point(alpha = 0.35, size = 0.8) +
#   ggplot2::theme_minimal() +
#   ggplot2::ggtitle("PCA of continuous predictors")
# 
# print(p_pca)
# 
# # 4) VIF barplot
# p_vif <- ggplot2::ggplot(
#   vif_tab,
#   ggplot2::aes(
#     x = stats::reorder(Variables, VIF),
#     y = VIF
#   )
# ) +
#   ggplot2::geom_col() +
#   ggplot2::geom_hline(yintercept = 10, linetype = 2) +
#   ggplot2::coord_flip() +
#   ggplot2::theme_minimal() +
#   ggplot2::xlab(NULL) +
#   ggplot2::ggtitle("VIF values")
# 
# print(p_vif)
# 
# # 5) boxplots for top variables differing among GLIM classes
# top_kw_vars <- utils::head(kw_tab$variable, 6)
# 
# box_df <- vals_cc[, c("glim", top_kw_vars), drop = FALSE]
# 
# box_long <- tidyr::pivot_longer(
#   box_df,
#   cols = -glim,
#   names_to = "variable",
#   values_to = "value"
# )
# 
# p_box <- ggplot2::ggplot(
#   box_long,
#   ggplot2::aes(x = glim, y = value)
# ) +
#   ggplot2::geom_boxplot(outlier.shape = NA) +
#   ggplot2::facet_wrap(~ variable, scales = "free_y") +
#   ggplot2::theme_minimal() +
#   ggplot2::theme(
#     axis.text.x = ggplot2::element_text(angle = 45, hjust = 1)
#   ) +
#   ggplot2::xlab("GLIM class") +
#   ggplot2::ggtitle("Top variables differing among GLIM classes")
# 
# print(p_box)
# 
# # 6) GLIM frequency barplot
# p_glim <- ggplot2::ggplot(
#   glim_freq,
#   ggplot2::aes(x = glim, y = n)
# ) +
#   ggplot2::geom_col() +
#   ggplot2::theme_minimal() +
#   ggplot2::theme(
#     axis.text.x = ggplot2::element_text(angle = 45, hjust = 1)
#   ) +
#   ggplot2::xlab("GLIM class") +
#   ggplot2::ggtitle("Frequency of GLIM classes in sampled cells")
# 
# print(p_glim)
