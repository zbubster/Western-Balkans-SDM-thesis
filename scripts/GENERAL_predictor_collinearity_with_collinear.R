# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Collinearity EDA with collinear
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

rasters_dir <- here::here("data", "__COMPATIBILITY__", "STACKS", "__STACKS_MASKED__")
r_1000 <- terra::rast(file.path(rasters_dir, "r_1000.tif"))

set.seed(722085415)

vals <- terra::spatSample(
  r_1000,
  size = 50000,
  method = "random",
  na.rm = TRUE,
  as.df = TRUE
)

vals$glim <- base::factor(vals$glim)
vals$northness <- base::cos(vals$aspect * base::pi / 180)
vals$eastness  <- base::sin(vals$aspect * base::pi / 180)

# predictor sets
pred_all <- vals[, !base::names(vals) %in% "aspect", drop = FALSE]
pred_cont <- pred_all[, !base::names(pred_all) %in% "glim", drop = FALSE]

# ponech jen numerické kontinuální proměnné
is_num <- base::vapply(pred_cont, base::is.numeric, logical(1))
pred_cont <- pred_cont[, is_num, drop = FALSE]

# odstranění nulové variance
sd_ok <- base::vapply(
  pred_cont,
  function(x) stats::sd(x, na.rm = TRUE) > 0,
  logical(1)
)
pred_cont <- pred_cont[, sd_ok, drop = FALSE]

# complete cases
pred_all  <- pred_all[stats::complete.cases(pred_all), , drop = FALSE]
pred_cont <- pred_cont[stats::complete.cases(pred_cont), , drop = FALSE]

# -------------------------------------------------------------------------
# 1) čistá kolinearita kontinuálních prediktorů
# -------------------------------------------------------------------------

cor_cont <- collinear::cor_df(
  df = pred_cont,
  quiet = TRUE
)

cor_mat_cont <- collinear::cor_matrix(
  df = pred_cont,
  quiet = TRUE
)

cor_clusteres <- collinear::cor_clusters(
  df = pred_cont
)

vif_cont <- collinear::vif_df(
  df = pred_cont,
  quiet = TRUE
)

sel_cont <- collinear::collinear_select(
  df = pred_cont,
  max_cor = 0.7,
  max_vif = 5,
  quiet = TRUE
)

print(vif_cont)
print(sel_cont)

x <- cor_cont %>%
  filter(x %in% sel_cont, y %in% sel_cont)

xx <- cor_mat_cont %>%
  select(rownames(.) %in% sel_cont) %>%
  select(colnames(.) %in% sel_cont)

# -------------------------------------------------------------------------
# 2) orientačně i smíšený blok s glim
# -------------------------------------------------------------------------

cor_mixed <- collinear::cor_df(
  df = pred_all,
  quiet = TRUE
)

# -------------------------------------------------------------------------
# 3) jednoduchá vizualizace
# -------------------------------------------------------------------------

# heatmap kontinuálních korelací
cor_plot_df <- base::as.data.frame(
  base::as.table(cor_mat_cont),
  stringsAsFactors = FALSE
)
base::names(cor_plot_df) <- c("var1", "var2", "r")

p_cor <- ggplot2::ggplot(
  cor_plot_df,
  ggplot2::aes(x = var1, y = var2, fill = r)
) +
  ggplot2::geom_tile() +
  ggplot2::scale_fill_gradient2(
    low = "black",
    mid = "white",
    high = "red",
    midpoint = 0
  ) +
  ggplot2::coord_equal() +
  ggplot2::theme_minimal() +
  ggplot2::theme(
    axis.title = ggplot2::element_blank(),
    axis.text.x = ggplot2::element_text(angle = 45, hjust = 1),
    panel.grid = ggplot2::element_blank()
  ) +
  ggplot2::ggtitle("Korelace kontinuálních prediktorů")

print(p_cor)

# VIF barplot
p_vif <- ggplot2::ggplot(
  vif_cont,
  ggplot2::aes(
    x = stats::reorder(predictor, vif),
    y = vif
  )
) +
  ggplot2::geom_col() +
  ggplot2::geom_hline(yintercept = 5, linetype = 2) +
  ggplot2::coord_flip() +
  ggplot2::theme_minimal() +
  ggplot2::xlab(NULL) +
  ggplot2::ggtitle("VIF kontinuálních prediktorů")

print(p_vif)

# nejsilnější páry ve smíšeném bloku
cor_mixed2 <- cor_mixed
cor_mixed2 <- cor_mixed2[cor_mixed2$x != cor_mixed2$y, , drop = FALSE]
cor_mixed2 <- cor_mixed2[order(-base::abs(cor_mixed2$correlation)), ]

print(utils::head(cor_mixed2, 20))
