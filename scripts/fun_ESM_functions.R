# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# FUN ‒ ESM functions
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# FUN 1 ‒ prepare_occ_for_modeling
# FUN 2 ‒ esm_get_factor_levels
# FUN 3 ‒ esm_prepare_newdata
# FUN 4 ‒ esm_make_weights
# FUN 5 ‒ esm_somers_d
# FUN 6 ‒ esm_fit_small_model
# FUN 7 ‒ esm_predict_small_model
# FUN 8 ‒ esm_validate_prep
# FUN 9 ‒ esm_fit_bivariate
# FUN 10 ‒ esm_project_bivariate
# FUN 11 ‒ esm_response_curves_bivariate
# FUN 12 ‒ plot_esm_response_numeric
# FUN 13 ‒ plot_esm_response_numeric_with_algorithms
# FUN 14 ‒ plot_esm_response_numeric_with_small
# FUN 15 ‒ plot_esm_response_factor
# FUN 16 ‒ esm_weighted_mean_matrix

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# FUN 1 ‒ prepare_occ_for_modeling

prepare_occ_for_modeling <- function(occ,
                                     pred,
                                     factor_cols = NULL) {
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # Convert coors to SpatVector and extract predictor values
  
  n <- base::length(occ$observations)
  pts <- terra::vect(as.data.frame(occ$coor), geom = base::c("X", "Y"), crs = terra::crs(pred))
  
  # Extract predictors
  env_df <- terra::extract(pred, pts)
  
  # drop ID column
  if ("ID" %in% base::names(env_df)) {
    env_df <- env_df[, base::setdiff(base::names(env_df), "ID"), drop = FALSE]
  }
  
  # factor conversion
  if (!base::is.null(factor_cols)) {
    bad_factor_cols <- base::setdiff(factor_cols, base::names(env_df))
    if (base::length(bad_factor_cols) > 0) {
      base::stop(
        "These factor_cols are not present in extracted predictors: ",
        base::paste(bad_factor_cols, collapse = ", ")
      )
    }
    for (nm in factor_cols) {
      env_df[[nm]] <- base::as.factor(env_df[[nm]])
    }
  }
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # Drop occurences with any NA in predictors
  
  keep <- stats::complete.cases(env_df)
  
  occ_out <- occ
  occ_out$observations <- occ$observations[keep]
  occ_out$coor <- occ$coor[keep, , drop = FALSE]
  occ_out$CV.user.table <- occ$CV.user.table[keep, , drop = FALSE]
  occ_out$weights <- occ$weights[keep]
  
  if ("source" %in% base::names(occ)) {
    occ_out$source <- occ$source[keep]
  }
  
  env_out <- env_df[keep, , drop = FALSE]
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # prepare output object
  
  data_out <- base::data.frame(
    observ = occ_out$observations,
    weight = occ_out$weights,
    env_out,
    check.names = FALSE
  )
  
  if ("source" %in% base::names(occ_out)) {
    data_out$source <- occ_out$source
  }
  
  data_out$X <- occ_out$coor$X
  data_out$Y <- occ_out$coor$Y
  
  # reorder a bit
  first_cols <- base::intersect(
    base::c("observ", "weight", "source", "X", "Y"),
    base::names(data_out)
  )
  other_cols <- base::setdiff(base::names(data_out), first_cols)
  data_out <- data_out[, base::c(first_cols, other_cols), drop = FALSE]
  
  # output
  return(list(
    species = occ_out$species,
    occ = occ_out,
    env = env_out,
    data = data_out,
    keep = keep,
    dropped = !keep,
    n_input = n,
    n_output = base::sum(keep),
    n_dropped = base::sum(!keep),
    predictor_names = base::names(env_out)
  ))
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# FUN 2 ‒ esm_get_factor_levels

esm_get_factor_levels <- function(df, pair) {
  out <- list()
  
  for (nm in pair) {
    if (base::is.factor(df[[nm]])) {
      out[[nm]] <- base::levels(df[[nm]])
    } else {
      out[[nm]] <- NULL
    }
  }
  
  return(out)
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# FUN 3 ‒ esm_prepare_newdata
# prep for forecasting

esm_prepare_newdata <- function(newdata, pair, factor_levels) {
  nd <- base::as.data.frame(newdata)[, pair, drop = FALSE]
  
  for (nm in pair) {
    if (!base::is.null(factor_levels[[nm]])) {
      nd[[nm]] <- base::factor(nd[[nm]], levels = factor_levels[[nm]])
    }
  }
  
  return(nd)
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# FUN 4 ‒ esm_make_weights

# weights of relative contribution of small models into final ensemble

esm_make_weights <- function(x, transform = "identity") {
  x <- base::pmax(x, 0)
  if (transform == "square") {
    x <- x^2
  }
  s <- base::sum(x, na.rm = TRUE)
  if (base::is.na(s) || s <= 0) {
    return(rep(NA_real_, base::length(x)))
  }
  x / s
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# FUN 5 ‒ esm_somers_d

# compute Sommers'D

esm_somers_d <- function(obs, pred) {
  ok <- !base::is.na(obs) & !base::is.na(pred)
  
  if (base::sum(ok) < 2) {
    return(NA_real_)
  }
  
  if (base::length(base::unique(obs[ok])) < 2) {
    return(NA_real_)
  }
  # sommersD
  s <- Hmisc::somers2(x = pred[ok], y = obs[ok])
  base::as.numeric(s["Dxy"])
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# FUN 6 ‒ esm_fit_small_model

# fit models with different algos

esm_fit_small_model <- function(df,
                                resp,
                                pair,
                                algo,
                                weight_col = "weight",
                                rf_num_trees = 500,
                                gbm_n_trees = 2000,
                                gbm_interaction_depth = 2,
                                gam_k = 5,
                                cta_cp = 0.001,
                                cta_maxdepth = 3,
                                mars_degree = 1,
                                mars_nprune = NULL) {
  
  factor_levels <- esm_get_factor_levels(df = df, pair = pair)
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # GLM
  
  if (algo == "glm") {
    f <- stats::as.formula(
      base::paste(resp, "~", base::paste(pair, collapse = " + "))
    )
    
    fit <- stats::glm(
      formula = f,
      data = df[, base::c(resp, weight_col, pair), drop = FALSE],
      family = stats::binomial(),
      weights = df[[weight_col]]
    )
    
    return(list(
      fit = fit,
      algo = algo,
      pair = pair,
      factor_levels = factor_levels
    ))
  }
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # GBM
  
  if (algo == "gbm") {
    f <- stats::as.formula(
      base::paste(resp, "~", base::paste(pair, collapse = " + "))
    )
    
    fit <- gbm::gbm(
      formula = f,
      data = df[, base::c(resp, weight_col, pair), drop = FALSE],
      distribution = "bernoulli",
      weights = df[[weight_col]],
      n.trees = gbm_n_trees,
      interaction.depth = gbm_interaction_depth,
      shrinkage = 0.01,
      n.minobsinnode = 5,
      bag.fraction = 0.7,
      train.fraction = 1,
      verbose = FALSE
    )
    
    return(list(
      fit = fit,
      algo = algo,
      pair = pair,
      factor_levels = factor_levels
    ))
  }
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # GAM
  
  if (algo == "gam") {
    gam_terms <- base::character(base::length(pair))
    
    for (i in base::seq_along(pair)) {
      v <- pair[i]
      
      if (base::is.factor(df[[v]])) {
        # factors stay parametric
        gam_terms[i] <- v
      } else {
        # numeric predictors are fitted as smooth terms
        gam_terms[i] <- base::paste0("s(", v, ", k = ", gam_k, ")")
      }
    }
    
    f <- stats::as.formula(
      base::paste(resp, "~", base::paste(gam_terms, collapse = " + "))
    )
    
    fit <- mgcv::gam(
      formula = f,
      data = df[, base::c(resp, weight_col, pair), drop = FALSE],
      family = stats::binomial(),
      weights = df[[weight_col]],
      method = "REML"
    )
    
    return(list(
      fit = fit,
      algo = algo,
      pair = pair,
      factor_levels = factor_levels
    ))
  }
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # CTA
  
  if (algo == "cta") {
    df_cta <- df[, base::c(resp, weight_col, pair), drop = FALSE]
    df_cta[[resp]] <- base::factor(df_cta[[resp]], levels = base::c(0, 1))
    
    f <- stats::as.formula(
      base::paste(resp, "~", base::paste(pair, collapse = " + "))
    )
    
    fit <- rpart::rpart(
      formula = f,
      data = df_cta,
      method = "class",
      weights = df_cta[[weight_col]],
      control = rpart::rpart.control(
        cp = cta_cp,
        maxdepth = cta_maxdepth,
        minsplit = 10,
        minbucket = 5,
        xval = 0
      )
    )
    
    return(list(
      fit = fit,
      algo = algo,
      pair = pair,
      factor_levels = factor_levels
    ))
  }
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # MARS
  
  if (algo == "mars") {
    f <- stats::as.formula(
      base::paste(resp, "~", base::paste(pair, collapse = " + "))
    )
    
    fit <- earth::earth(
      formula = f,
      data = df[, base::c(resp, weight_col, pair), drop = FALSE],
      glm = base::list(family = stats::binomial()),
      degree = mars_degree,
      nprune = mars_nprune,
      weights = df[[weight_col]]
    )
    
    return(list(
      fit = fit,
      algo = algo,
      pair = pair,
      factor_levels = factor_levels
    ))
  }
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # RF
  
  if (algo == "rf") {
    df_rf <- df[, base::c(resp, weight_col, pair), drop = FALSE]
    df_rf[[resp]] <- base::factor(df_rf[[resp]], levels = base::c(0, 1))
    
    f <- stats::as.formula(
      base::paste(resp, "~", base::paste(pair, collapse = " + "))
    )
    
    fit <- ranger::ranger(
      formula = f,
      data = df_rf[, base::c(resp, pair), drop = FALSE],
      probability = TRUE,
      num.trees = rf_num_trees,
      case.weights = df_rf[[weight_col]]
    )
    
    return(list(
      fit = fit,
      algo = algo,
      pair = pair,
      factor_levels = factor_levels
    ))
  }
  
  base::stop("Unsupported algo: ", algo)
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# FUN 7 ‒ esm_predict_small_model

# predict 

esm_predict_small_model <- function(model_obj, newdata) {
  
  # prepare new data
  nd <- esm_prepare_newdata(
    newdata = newdata,
    pair = model_obj$pair,
    factor_levels = model_obj$factor_levels
  )
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # GLM
  
  if (model_obj$algo == "glm") {
    return(
      base::as.numeric(
        stats::predict(
          object = model_obj$fit,
          newdata = nd,
          type = "response"
        )
      )
    )
  }
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # GBM
  
  if (model_obj$algo == "gbm") {
    return(
      base::as.numeric(
        stats::predict(
          object = model_obj$fit,
          newdata = nd,
          n.trees = model_obj$fit$n.trees,
          type = "response"
        )
      )
    )
  }
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # GAM
  
  if (model_obj$algo == "gam") {
    return(
      base::as.numeric(
        stats::predict(
          object = model_obj$fit,
          newdata = nd,
          type = "response"
        )
      )
    )
  }
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # CTA
  
  if (model_obj$algo == "cta") {
    p <- stats::predict(
      object = model_obj$fit,
      newdata = nd,
      type = "prob"
    )
    
    if (base::is.matrix(p) || base::is.data.frame(p)) {
      if ("1" %in% base::colnames(p)) {
        return(base::as.numeric(p[, "1"]))
      } else {
        return(base::as.numeric(p[, base::ncol(p)]))
      }
    }
    
    return(base::as.numeric(p))
  }
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # MARS
  
  if (model_obj$algo == "mars") {
    return(
      base::as.numeric(
        stats::predict(
          object = model_obj$fit,
          newdata = nd,
          type = "response"
        )
      )
    )
  }
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # RF
  
  if (model_obj$algo == "rf") {
    p <- ranger::predict(
      object = model_obj$fit,
      data = nd
    )$predictions
    
    if (base::is.matrix(p) || base::is.data.frame(p)) {
      if ("1" %in% base::colnames(p)) {
        return(base::as.numeric(p[, "1"]))
      } else {
        return(base::as.numeric(p[, base::ncol(p)]))
      }
    }
    
    return(base::as.numeric(p))
  }
  
  base::stop("Unsupported algo: ", model_obj$algo)
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# FUN 8 ‒ esm_validate_prep

# validate and prepare data for model fitting

esm_validate_prep <- function(prep, predictors = NULL) {
  
  if (!base::is.list(prep)) {
    base::stop("prep must be a list returned by prepare_occ_for_modeling().")
  }
  
  needed <- base::c("occ", "data")
  miss <- base::setdiff(needed, base::names(prep))
  
  if (base::length(miss) > 0) {
    base::stop(
      "prep is missing required elements: ",
      base::paste(miss, collapse = ", ")
    )
  }
  
  if (!"CV.user.table" %in% base::names(prep$occ)) {
    base::stop("prep$occ$CV.user.table is missing.")
  }
  
  data <- base::as.data.frame(prep$data)
  cv <- base::as.data.frame(prep$occ$CV.user.table)
  
  if (base::nrow(data) != base::nrow(cv)) {
    base::stop("prep$data and prep$occ$CV.user.table must have the same number of rows.")
  }
  
  if (!"observ" %in% base::names(data)) {
    base::stop("prep$data must contain column 'observ'.")
  }
  
  if (!"weight" %in% base::names(data)) {
    base::stop("prep$data must contain column 'weight'.")
  }
  
  if (!base::all(data$observ %in% base::c(0, 1))) {
    base::stop("prep$data$observ must be coded as 0/1.")
  }
  
  if (!base::all(base::vapply(cv, base::is.logical, logical(1)))) {
    base::stop("All columns in prep$occ$CV.user.table must be logical.")
  }
  
  if (base::any(base::is.na(cv))) {
    base::stop("NA values in CV.user.table are not supported in this simple version.")
  }
  
  if (base::is.null(predictors)) {
    predictors <- base::setdiff(
      base::names(data),
      base::c("observ", "weight", "source", "X", "Y")
    )
  }
  
  if (!base::all(predictors %in% base::names(data))) {
    base::stop("Some predictors are missing in prep$data.")
  }
  
  if (base::length(predictors) < 2) {
    base::stop("Need at least two predictors.")
  }
  
  return(list(
    data = data,
    cv = cv,
    predictors = predictors
  ))
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# FUN 9 ‒ esm_fit_bivariate

# this function incorporates functions above and produces one ensemble model

# 1) fit and evaluate all bivariate models in CV;
# 2) compute weights for bivariate models within each algorithm;
# 3) build one ESM per algorithm;
# 4) if more algorithms are used, build a second-level ensemble across algorithm ESMs.

esm_fit_bivariate <- function(prep,
                              predictors = NULL,
                              algorithms = c("glm", "rf"),
                              threshold = 0,
                              weight_transform = "identity",
                              rf_num_trees = 1000,
                              gbm_n_trees = 2000,
                              gbm_interaction_depth = 2,
                              seed = 722085415) {
  
  base::set.seed(seed)
  
  # Validate prep object and get data, CV table and predictors
  valid <- esm_validate_prep(prep = prep, predictors = predictors)
  
  data <- valid$data
  cv <- valid$cv
  predictors <- valid$predictors
  
  n <- base::nrow(data)
  pairs <- utils::combn(predictors, 2, simplify = FALSE)
  
  cv_scores <- list()
  cv_predictions <- list()
  
  row_id <- 0L
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # Phase 1: fit all CV bivariate models and store validation predictions
  
  for (run_name in base::names(cv)) {
    
    message("Running CV fold: ", run_name)
    
    train_idx <- cv[[run_name]]
    test_idx <- !cv[[run_name]]
    
    y_train <- data$observ[train_idx]
    y_test <- data$observ[test_idx]
    
    # Skip invalid folds
    if (base::sum(y_train == 1) < 5) next
    if (base::sum(y_train == 0) < 5) next
    if (base::sum(y_test == 1) < 1) next
    if (base::sum(y_test == 0) < 1) next
    
    run_scores <- list()
    run_predictions <- list()
    
    for (pair in pairs) {
      
      pair_label <- base::paste(pair, collapse = " + ")
      
      for (algo in algorithms) {
        
        model_key <- base::paste(algo, pair_label, sep = "___")
        
        fit_obj <- base::tryCatch(
          esm_fit_small_model(
            df = data[train_idx, , drop = FALSE],
            resp = "observ",
            pair = pair,
            algo = algo,
            weight_col = "weight",
            rf_num_trees = rf_num_trees,
            gbm_n_trees = gbm_n_trees,
            gbm_interaction_depth = gbm_interaction_depth
          ),
          error = function(e) NULL
        )
        
        if (base::is.null(fit_obj)) next
        
        pred_test <- base::tryCatch(
          esm_predict_small_model(
            model_obj = fit_obj,
            newdata = data[test_idx, , drop = FALSE]
          ),
          error = function(e) base::rep(NA_real_, base::sum(test_idx))
        )
        
        dxy <- base::tryCatch(
          esm_somers_d(obs = y_test, pred = pred_test),
          error = function(e) NA_real_
        )
        
        row_id <- row_id + 1L
        
        run_scores[[base::length(run_scores) + 1L]] <- base::data.frame(
          row_id = row_id,
          run = run_name,
          algo = algo,
          pred1 = pair[1],
          pred2 = pair[2],
          pair_label = pair_label,
          model_key = model_key,
          somers_d = dxy,
          n_train = base::sum(train_idx),
          n_test = base::sum(test_idx),
          stringsAsFactors = FALSE
        )
        
        run_predictions[[model_key]] <- pred_test
      }
    }
    
    if (base::length(run_scores) == 0L) next
    
    cv_scores[[run_name]] <- base::do.call(base::rbind, run_scores)
    cv_predictions[[run_name]] <- run_predictions
  }
  
  cv_scores_df <- base::do.call(base::rbind, cv_scores)
  
  if (base::is.null(cv_scores_df) || base::nrow(cv_scores_df) == 0) {
    base::stop("No valid CV models were fitted.")
  }
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # Phase 2: aggregate bivariate model scores across CV runs
  
  group_levels <- base::unique(cv_scores_df$model_key)
  model_scores_list <- vector(mode = "list", length = base::length(group_levels))
  
  for (i in base::seq_along(group_levels)) {
    
    g <- group_levels[[i]]
    sub <- cv_scores_df[cv_scores_df$model_key == g, , drop = FALSE]
    
    mean_dxy <- base::mean(sub$somers_d, na.rm = TRUE)
    if (base::is.nan(mean_dxy)) mean_dxy <- NA_real_
    
    model_scores_list[[i]] <- base::data.frame(
      algo = sub$algo[1],
      pred1 = sub$pred1[1],
      pred2 = sub$pred2[1],
      pair_label = sub$pair_label[1],
      model_key = sub$model_key[1],
      mean_somers_d = mean_dxy,
      sd_somers_d = stats::sd(sub$somers_d, na.rm = TRUE),
      n_valid_runs = base::sum(!base::is.na(sub$somers_d)),
      stringsAsFactors = FALSE
    )
  }
  
  model_scores <- base::do.call(base::rbind, model_scores_list)
  
  # ecospat logic: models no better than random are assigned zero weight
  model_scores$keep <- !base::is.na(model_scores$mean_somers_d) &
    model_scores$mean_somers_d > threshold
  
  if (!base::any(model_scores$keep)) {
    base::stop("No pair-algorithm combination passed the threshold.")
  }
  
  model_scores$weight_within_algo <- 0
  
  for (algo in base::unique(model_scores$algo)) {
    
    idx <- model_scores$algo == algo & model_scores$keep
    
    if (!base::any(idx)) next
    
    model_scores$weight_within_algo[idx] <- esm_make_weights(
      x = model_scores$mean_somers_d[idx],
      transform = weight_transform
    )
  }
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # Phase 3: build one cross-validated ESM per algorithm
  
  oof_algo_pred <- base::matrix(
    NA_real_,
    nrow = n,
    ncol = base::length(algorithms),
    dimnames = list(NULL, algorithms)
  )
  
  run_ensemble_scores <- list()
  
  for (run_name in base::names(cv_predictions)) {
    
    train_idx <- cv[[run_name]]
    test_idx <- !train_idx
    test_rows <- base::which(test_idx)
    y_test <- data$observ[test_idx]
    
    run_pred_list <- cv_predictions[[run_name]]
    
    for (algo in algorithms) {
      
      sub_scores <- model_scores[
        model_scores$algo == algo &
          model_scores$keep &
          model_scores$model_key %in% base::names(run_pred_list),
        ,
        drop = FALSE
      ]
      
      if (base::nrow(sub_scores) == 0L) next
      
      pred_mat <- base::sapply(
        sub_scores$model_key,
        function(x) run_pred_list[[x]]
      )
      
      if (base::is.null(base::dim(pred_mat))) {
        pred_mat <- base::matrix(pred_mat, ncol = 1)
      }
      
      ens_algo <- esm_weighted_mean_matrix(
        pred_mat = pred_mat,
        weights = sub_scores$weight_within_algo
      )
      
      oof_algo_pred[test_rows, algo] <- ens_algo
      
      run_dxy <- esm_somers_d(obs = y_test, pred = ens_algo)
      
      run_ensemble_scores[[base::length(run_ensemble_scores) + 1L]] <-
        base::data.frame(
          run = run_name,
          algo = algo,
          ensemble_level = "within_algorithm",
          ensemble_somers_d = run_dxy,
          n_test = base::sum(test_idx),
          stringsAsFactors = FALSE
        )
    }
  }
  
  run_ensemble_scores_df <- base::do.call(base::rbind, run_ensemble_scores)
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # Phase 4: compute second-level weights across algorithm ESMs
  
  algorithm_scores_list <- list()
  
  for (algo in algorithms) {
    
    sub <- run_ensemble_scores_df[
      run_ensemble_scores_df$algo == algo &
        run_ensemble_scores_df$ensemble_level == "within_algorithm",
      ,
      drop = FALSE
    ]
    
    mean_dxy <- base::mean(sub$ensemble_somers_d, na.rm = TRUE)
    if (base::is.nan(mean_dxy)) mean_dxy <- NA_real_
    
    algorithm_scores_list[[base::length(algorithm_scores_list) + 1L]] <-
      base::data.frame(
        algo = algo,
        mean_somers_d = mean_dxy,
        sd_somers_d = stats::sd(sub$ensemble_somers_d, na.rm = TRUE),
        n_valid_runs = base::sum(!base::is.na(sub$ensemble_somers_d)),
        stringsAsFactors = FALSE
      )
  }
  
  algorithm_scores <- base::do.call(base::rbind, algorithm_scores_list)
  algorithm_scores$keep <- !base::is.na(algorithm_scores$mean_somers_d) &
    algorithm_scores$mean_somers_d > threshold
  
  if (!base::any(algorithm_scores$keep)) {
    base::stop("No algorithm-level ESM passed the threshold.")
  }
  
  algorithm_scores$weight_between_algos <- 0
  algorithm_scores$weight_between_algos[algorithm_scores$keep] <- esm_make_weights(
    x = algorithm_scores$mean_somers_d[algorithm_scores$keep],
    transform = weight_transform
  )
  
  algo_weights <- stats::setNames(
    algorithm_scores$weight_between_algos,
    algorithm_scores$algo
  )
  
  kept_algorithms <- algorithm_scores$algo[algorithm_scores$keep]
  
  oof_pred <- esm_weighted_mean_matrix(
    pred_mat = oof_algo_pred[, kept_algorithms, drop = FALSE],
    weights = algo_weights[kept_algorithms]
  )
  
  # Evaluate the final second-level ensemble per CV run
  final_run_scores <- list()
  
  for (run_name in base::names(cv)) {
    
    test_idx <- !cv[[run_name]]
    
    if (base::sum(test_idx) == 0L) next
    
    final_run_scores[[base::length(final_run_scores) + 1L]] <-
      base::data.frame(
        run = run_name,
        algo = "EF",
        ensemble_level = "between_algorithms",
        ensemble_somers_d = esm_somers_d(
          obs = data$observ[test_idx],
          pred = oof_pred[test_idx]
        ),
        n_test = base::sum(test_idx),
        stringsAsFactors = FALSE
      )
  }
  
  run_ensemble_scores_df <- base::rbind(
    run_ensemble_scores_df,
    base::do.call(base::rbind, final_run_scores)
  )
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # Phase 5: refit kept bivariate models on full data for projection
  
  full_models <- list()
  model_scores$refit_ok <- FALSE
  
  for (i in base::which(model_scores$keep)) {
    
    pair <- base::c(model_scores$pred1[i], model_scores$pred2[i])
    algo <- model_scores$algo[i]
    
    message("Refitting full model: ", algo, " | ", base::paste(pair, collapse = " + "))
    
    fit_obj <- base::tryCatch(
      esm_fit_small_model(
        df = data,
        resp = "observ",
        pair = pair,
        algo = algo,
        weight_col = "weight",
        rf_num_trees = rf_num_trees,
        gbm_n_trees = gbm_n_trees,
        gbm_interaction_depth = gbm_interaction_depth
      ),
      error = function(e) NULL
    )
    
    if (!base::is.null(fit_obj)) {
      nm <- model_scores$model_key[i]
      full_models[[nm]] <- fit_obj
      model_scores$refit_ok[i] <- TRUE
    }
  }
  
  if (base::length(full_models) == 0) {
    base::stop("All kept full models failed during refit.")
  }
  
  # If some full refits failed, renormalise bivariate weights within algorithm.
  model_scores$weight_within_algo_refit <- 0
  
  for (algo in base::unique(model_scores$algo)) {
    
    idx <- model_scores$algo == algo & model_scores$keep & model_scores$refit_ok
    
    if (!base::any(idx)) next
    
    model_scores$weight_within_algo_refit[idx] <- esm_make_weights(
      x = model_scores$mean_somers_d[idx],
      transform = weight_transform
    )
  }
  
  # Remove algorithm ESMs that have no usable full models after refit.
  for (algo in algorithm_scores$algo) {
    has_full <- base::any(
      model_scores$algo == algo &
        model_scores$keep &
        model_scores$refit_ok
    )
    if (!has_full) {
      algorithm_scores$keep[algorithm_scores$algo == algo] <- FALSE
      algorithm_scores$weight_between_algos[algorithm_scores$algo == algo] <- 0
    }
  }
  
  if (!base::any(algorithm_scores$keep)) {
    base::stop("No algorithm-level ESM has usable full models after refit.")
  }
  
  algorithm_scores$weight_between_algos[algorithm_scores$keep] <- esm_make_weights(
    x = algorithm_scores$mean_somers_d[algorithm_scores$keep],
    transform = weight_transform
  )
  
  # Backwards-compatible final flattened weights.
  # These are not used internally for projection, but they are useful for
  # older helper functions that expect esm$model_scores$weight.
  algo_weight_lookup <- stats::setNames(
    algorithm_scores$weight_between_algos,
    algorithm_scores$algo
  )
  
  model_scores$weight <- model_scores$weight_within_algo_refit *
    algo_weight_lookup[model_scores$algo]
  
  algorithm_scores$weight <- algorithm_scores$weight_between_algos
  
  oof_somers_d <- esm_somers_d(obs = data$observ, pred = oof_pred)
  
  return(list(
    species = prep$species,
    data = data,
    predictors = predictors,
    algorithms = algorithms,
    threshold = threshold,
    weight_transform = weight_transform,
    cv_scores = cv_scores_df,
    run_ensemble_scores = run_ensemble_scores_df,
    model_scores = model_scores,
    algorithm_scores = algorithm_scores,
    full_models = full_models,
    oof_algo_pred = oof_algo_pred,
    oof_pred = oof_pred,
    oof_somers_d = oof_somers_d,
    ensemble_logic = "bivariate models -> algorithm-specific ESMs -> optional algorithm ensemble"
  ))
}
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# FUN 10 ‒ esm_project_bivariate

esm_project_bivariate <- function(esm, new_env, return_algorithms = FALSE) {
  
  if (!base::is.list(esm)) {
    base::stop("esm must be an object returned by esm_fit_bivariate().")
  }
  
  if (base::is.null(esm$full_models) || base::length(esm$full_models) == 0) {
    base::stop("esm$full_models is empty.")
  }
  
  if (base::is.null(esm$algorithm_scores)) {
    base::stop("esm$algorithm_scores is missing. Refit the model with the Breiner-style esm_fit_bivariate().")
  }
  
  model_scores <- esm$model_scores
  algorithm_scores <- esm$algorithm_scores
  
  kept_algorithms <- algorithm_scores$algo[
    algorithm_scores$keep &
      algorithm_scores$weight_between_algos > 0
  ]
  
  if (base::length(kept_algorithms) == 0L) {
    base::stop("No kept algorithm-level ESMs available for projection.")
  }
  
  algo_weights <- stats::setNames(
    algorithm_scores$weight_between_algos,
    algorithm_scores$algo
  )
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # data.frame projection

  if (base::is.data.frame(new_env)) {
    
    algo_pred <- base::matrix(
      NA_real_,
      nrow = base::nrow(new_env),
      ncol = base::length(kept_algorithms),
      dimnames = list(NULL, kept_algorithms)
    )
    
    for (algo in kept_algorithms) {
      
      sub_scores <- model_scores[
        model_scores$algo == algo &
          model_scores$keep &
          model_scores$refit_ok &
          model_scores$weight_within_algo_refit > 0,
        ,
        drop = FALSE
      ]
      
      if (base::nrow(sub_scores) == 0L) next
      
      pred_mat <- base::sapply(
        sub_scores$model_key,
        function(nm) {
          esm_predict_small_model(
            model_obj = esm$full_models[[nm]],
            newdata = new_env
          )
        }
      )
      
      if (base::is.null(base::dim(pred_mat))) {
        pred_mat <- base::matrix(pred_mat, ncol = 1)
      }
      
      algo_pred[, algo] <- esm_weighted_mean_matrix(
        pred_mat = pred_mat,
        weights = sub_scores$weight_within_algo_refit
      )
    }
    
    final_pred <- esm_weighted_mean_matrix(
      pred_mat = algo_pred[, kept_algorithms, drop = FALSE],
      weights = algo_weights[kept_algorithms]
    )
    
    if (return_algorithms) {
      return(base::data.frame(esm = final_pred, algo_pred, check.names = FALSE))
    }
    
    return(final_pred)
  }
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # SpatRaster projection
  
  if (inherits(new_env, "SpatRaster")) {
    
    algo_rasters <- list()
    
    for (algo in kept_algorithms) {
      
      sub_scores <- model_scores[
        model_scores$algo == algo &
          model_scores$keep &
          model_scores$refit_ok &
          model_scores$weight_within_algo_refit > 0,
        ,
        drop = FALSE
      ]
      
      if (base::nrow(sub_scores) == 0L) next
      
      sum_r <- NULL
      den_r <- NULL
      
      for (i in base::seq_len(base::nrow(sub_scores))) {
        
        nm <- sub_scores$model_key[i]
        w <- sub_scores$weight_within_algo_refit[i]
        model_obj <- esm$full_models[[nm]]
        
        r_sub <- terra::subset(new_env, model_obj$pair)
        
        pred_r <- terra::predict(
          object = r_sub,
          model = model_obj,
          fun = function(model, data) {
            esm_predict_small_model(
              model_obj = model,
              newdata = base::as.data.frame(data)
            )
          },
          na.rm = FALSE
        )
        
        num_add <- terra::ifel(base::is.na(pred_r), 0, pred_r * w)
        den_add <- terra::ifel(base::is.na(pred_r), 0, w)
        
        if (base::is.null(sum_r)) {
          sum_r <- num_add
          den_r <- den_add
        } else {
          sum_r <- sum_r + num_add
          den_r <- den_r + den_add
        }
      }
      
      algo_out <- terra::ifel(den_r == 0, NA, sum_r / den_r)
      base::names(algo_out) <- algo
      algo_rasters[[algo]] <- algo_out
    }
    
    if (base::length(algo_rasters) == 0L) {
      base::stop("No algorithm-level projections could be created.")
    }
    
    algo_stack <- do.call(c, algo_rasters)
    
    sum_r <- NULL
    den_r <- NULL
    
    for (algo in base::names(algo_rasters)) {
      
      w <- algo_weights[[algo]]
      pred_r <- algo_stack[[algo]]
      
      num_add <- terra::ifel(base::is.na(pred_r), 0, pred_r * w)
      den_add <- terra::ifel(base::is.na(pred_r), 0, w)
      
      if (base::is.null(sum_r)) {
        sum_r <- num_add
        den_r <- den_add
      } else {
        sum_r <- sum_r + num_add
        den_r <- den_r + den_add
      }
    }
    
    final_r <- terra::ifel(den_r == 0, NA, sum_r / den_r)
    base::names(final_r) <- "esm"
    
    if (return_algorithms) {
      return(c(final_r, algo_stack))
    }
    
    return(final_r)
  }
  
  base::stop("new_env must be either a data.frame or a terra::SpatRaster.")
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# FUN 11 - esm_response_curves_bivariate
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# Compute predictor-specific marginal response curves.
#
# For each predictor, only retained and successfully refitted bivariate models
# containing that predictor are used. Their predictions are first combined
# within each retained algorithm and then across algorithms.
#
# The weights of bivariate models are renormalised separately for every
# predictor within every algorithm. Algorithm weights are subsequently
# renormalised among algorithms that have at least one usable model containing
# the predictor.

esm_response_curves_bivariate <- function(
    esm,
    vars = esm$predictors,
    ref_data = esm$data,
    n_points = 100,
    probs = base::c(0.01, 0.99),
    include_small_models = TRUE,
    include_algorithm_curves = TRUE
) {
  
  if (!base::is.list(esm)) {
    base::stop("esm must be an object returned by esm_fit_bivariate().")
  }
  
  if (base::is.null(esm$full_models) || base::length(esm$full_models) == 0L) {
    base::stop("esm$full_models is empty.")
  }
  
  if (base::is.null(esm$model_scores)) {
    base::stop("esm$model_scores is missing.")
  }
  
  if (base::is.null(esm$algorithm_scores)) {
    base::stop("esm$algorithm_scores is missing.")
  }
  
  if (!base::is.numeric(n_points) ||
      base::length(n_points) != 1L ||
      !base::is.finite(n_points) ||
      n_points < 2) {
    base::stop("n_points must be one finite number >= 2.")
  }
  
  if (!base::is.numeric(probs) ||
      base::length(probs) != 2L ||
      base::any(!base::is.finite(probs)) ||
      probs[1] < 0 ||
      probs[2] > 1 ||
      probs[1] >= probs[2]) {
    base::stop(
      "probs must contain two increasing finite probabilities between 0 and 1."
    )
  }
  
  ref_data <- base::as.data.frame(ref_data)
  vars <- base::intersect(vars, base::names(ref_data))
  
  if (base::length(vars) == 0L) {
    base::stop("None of vars is present in ref_data.")
  }
  
  model_scores <- base::as.data.frame(esm$model_scores)
  algorithm_scores <- base::as.data.frame(esm$algorithm_scores)
  
  required_model_cols <- base::c(
    "algo",
    "model_key",
    "keep",
    "refit_ok",
    "weight_within_algo_refit"
  )
  
  missing_model_cols <- base::setdiff(
    required_model_cols,
    base::names(model_scores)
  )
  
  if (base::length(missing_model_cols) > 0L) {
    base::stop(
      "esm$model_scores is missing: ",
      base::paste(missing_model_cols, collapse = ", ")
    )
  }
  
  required_algorithm_cols <- base::c(
    "algo",
    "keep",
    "weight_between_algos"
  )
  
  missing_algorithm_cols <- base::setdiff(
    required_algorithm_cols,
    base::names(algorithm_scores)
  )
  
  if (base::length(missing_algorithm_cols) > 0L) {
    base::stop(
      "esm$algorithm_scores is missing: ",
      base::paste(missing_algorithm_cols, collapse = ", ")
    )
  }
  
  kept_algorithm_scores <- algorithm_scores[
    !base::is.na(algorithm_scores$keep) &
      algorithm_scores$keep &
      base::is.finite(algorithm_scores$weight_between_algos) &
      algorithm_scores$weight_between_algos > 0,
    ,
    drop = FALSE
  ]
  
  if (base::nrow(kept_algorithm_scores) == 0L) {
    base::stop("No retained algorithm-level ESM is available.")
  }
  
  model_info <- model_scores[
    model_scores$algo %in% kept_algorithm_scores$algo &
      !base::is.na(model_scores$keep) &
      model_scores$keep &
      !base::is.na(model_scores$refit_ok) &
      model_scores$refit_ok &
      base::is.finite(model_scores$weight_within_algo_refit) &
      model_scores$weight_within_algo_refit > 0 &
      model_scores$model_key %in% base::names(esm$full_models),
    ,
    drop = FALSE
  ]
  
  if (base::nrow(model_info) == 0L) {
    base::stop("No usable retained and refitted bivariate models are available.")
  }
  
  safe_mean <- function(x) {
    if (base::length(x) == 0L || base::all(base::is.na(x))) {
      return(NA_real_)
    }
    base::mean(x, na.rm = TRUE)
  }
  
  safe_predict <- function(model_obj, newdata) {
    pred <- base::tryCatch(
      esm_predict_small_model(
        model_obj = model_obj,
        newdata = newdata
      ),
      error = function(e) {
        base::warning(
          "Prediction failed for one bivariate model: ",
          base::conditionMessage(e),
          call. = FALSE
        )
        base::rep(NA_real_, base::nrow(newdata))
      }
    )
    
    if (base::length(pred) != base::nrow(newdata)) {
      base::warning(
        "A bivariate model returned an unexpected number of predictions.",
        call. = FALSE
      )
      return(base::rep(NA_real_, base::nrow(newdata)))
    }
    
    base::as.numeric(pred)
  }
  
  algorithm_original_weight_lookup <- stats::setNames(
    kept_algorithm_scores$weight_between_algos,
    kept_algorithm_scores$algo
  )
  
  out <- list()
  out_id <- 0L
  
  for (v in vars) {
    
    x <- ref_data[[v]]
    is_fac <- base::is.factor(x)
    
    if (is_fac) {
      grid_vals <- base::levels(x)
      var_type <- "factor"
    } else {
      finite_x <- x[base::is.finite(x)]
      
      if (base::length(finite_x) == 0L) {
        base::warning(
          "Predictor '", v, "' has no finite values and was skipped.",
          call. = FALSE
        )
        next
      }
      
      rng <- stats::quantile(
        x = finite_x,
        probs = probs,
        na.rm = TRUE,
        names = FALSE
      )
      
      if (rng[1] == rng[2]) {
        grid_vals <- rng[1]
      } else {
        grid_vals <- base::seq(
          from = rng[1],
          to = rng[2],
          length.out = base::as.integer(n_points)
        )
      }
      
      var_type <- "numeric"
    }
    
    contains_variable <- base::vapply(
      model_info$model_key,
      function(model_key) {
        v %in% esm$full_models[[model_key]]$pair
      },
      logical(1)
    )
    
    variable_model_info <- model_info[
      contains_variable,
      ,
      drop = FALSE
    ]
    
    if (base::nrow(variable_model_info) == 0L) {
      base::warning(
        "No usable bivariate model contains predictor '", v, "'.",
        call. = FALSE
      )
      next
    }
    
    variable_algorithms <- kept_algorithm_scores$algo[
      kept_algorithm_scores$algo %in% base::unique(variable_model_info$algo)
    ]
    
    variable_algorithm_scores <- kept_algorithm_scores[
      base::match(variable_algorithms, kept_algorithm_scores$algo),
      ,
      drop = FALSE
    ]
    
    # Predictor-specific second-level weights. Relative algorithm performance
    # is retained, but weights sum to one only among algorithms that have at
    # least one usable model containing the focal predictor.
    variable_algorithm_scores$weight_between_algos_variable <- esm_make_weights(
      x = variable_algorithm_scores$weight_between_algos,
      transform = "identity"
    )
    
    algorithm_variable_weight_lookup <- stats::setNames(
      variable_algorithm_scores$weight_between_algos_variable,
      variable_algorithm_scores$algo
    )
    
    variable_model_info$weight_within_algo_original <-
      variable_model_info$weight_within_algo_refit
    variable_model_info$weight_within_algo_variable <- 0
    
    # Predictor-specific first-level weights. Within every algorithm, only
    # bivariate models containing the focal predictor are normalised to one.
    for (algo in variable_algorithms) {
      idx <- variable_model_info$algo == algo
      
      variable_model_info$weight_within_algo_variable[idx] <- esm_make_weights(
        x = variable_model_info$weight_within_algo_refit[idx],
        transform = "identity"
      )
    }
    
    variable_model_info$weight_between_algos_original <-
      algorithm_original_weight_lookup[variable_model_info$algo]
    variable_model_info$weight_between_algos_variable <-
      algorithm_variable_weight_lookup[variable_model_info$algo]
    variable_model_info$effective_weight_variable <-
      variable_model_info$weight_within_algo_variable *
      variable_model_info$weight_between_algos_variable
    
    for (grid_id in base::seq_along(grid_vals)) {
      
      g <- grid_vals[grid_id]
      newdata <- ref_data
      
      if (is_fac) {
        newdata[[v]] <- base::factor(
          g,
          levels = base::levels(x)
        )
        value_num <- NA_real_
        value_chr <- base::as.character(g)
      } else {
        newdata[[v]] <- base::as.numeric(g)
        value_num <- base::as.numeric(g)
        value_chr <- base::as.character(g)
      }
      
      model_predictions <- stats::setNames(
        vector(
          mode = "list",
          length = base::nrow(variable_model_info)
        ),
        variable_model_info$model_key
      )
      
      for (model_key in variable_model_info$model_key) {
        model_predictions[[model_key]] <- safe_predict(
          model_obj = esm$full_models[[model_key]],
          newdata = newdata
        )
      }
      
      algorithm_row_predictions <- stats::setNames(
        vector(
          mode = "list",
          length = base::length(variable_algorithms)
        ),
        variable_algorithms
      )
      
      for (algo in variable_algorithms) {
        idx <- variable_model_info$algo == algo
        model_keys <- variable_model_info$model_key[idx]
        
        pred_mat <- base::do.call(
          base::cbind,
          model_predictions[model_keys]
        )
        
        if (base::is.null(base::dim(pred_mat))) {
          pred_mat <- base::matrix(pred_mat, ncol = 1L)
        }
        
        algorithm_row_predictions[[algo]] <- esm_weighted_mean_matrix(
          pred_mat = pred_mat,
          weights = variable_model_info$weight_within_algo_variable[idx]
        )
      }
      
      algorithm_pred_mat <- base::do.call(
        base::cbind,
        algorithm_row_predictions[variable_algorithms]
      )
      
      if (base::is.null(base::dim(algorithm_pred_mat))) {
        algorithm_pred_mat <- base::matrix(
          algorithm_pred_mat,
          ncol = 1L
        )
      }
      
      final_row_prediction <- esm_weighted_mean_matrix(
        pred_mat = algorithm_pred_mat,
        weights = variable_algorithm_scores$weight_between_algos_variable
      )
      
      common <- base::data.frame(
        variable = v,
        var_type = var_type,
        grid_id = grid_id,
        value_num = value_num,
        value_chr = value_chr,
        stringsAsFactors = FALSE
      )
      
      # Predictor-specific ensemble curve.
      out_id <- out_id + 1L
      out[[out_id]] <- base::cbind(
        common,
        base::data.frame(
          curve_level = "ensemble",
          curve_id = "predictor_ensemble",
          algorithm = NA_character_,
          prediction = safe_mean(final_row_prediction),
          contains_variable = TRUE,
          weight_within_algo_original = NA_real_,
          weight_within_algo_variable = NA_real_,
          weight_between_algos_original = 1,
          weight_between_algos_variable = 1,
          effective_weight_variable = 1,
          stringsAsFactors = FALSE
        )
      )
      
      # Predictor-specific algorithm curves.
      if (include_algorithm_curves) {
        algorithm_values <- base::vapply(
          algorithm_row_predictions[variable_algorithms],
          safe_mean,
          numeric(1)
        )
        
        out_id <- out_id + 1L
        out[[out_id]] <- base::cbind(
          common[
            base::rep(1L, base::length(variable_algorithms)),
            ,
            drop = FALSE
          ],
          base::data.frame(
            curve_level = "algorithm",
            curve_id = variable_algorithms,
            algorithm = variable_algorithms,
            prediction = base::as.numeric(algorithm_values),
            contains_variable = TRUE,
            weight_within_algo_original = NA_real_,
            weight_within_algo_variable = NA_real_,
            weight_between_algos_original =
              variable_algorithm_scores$weight_between_algos,
            weight_between_algos_variable =
              variable_algorithm_scores$weight_between_algos_variable,
            effective_weight_variable =
              variable_algorithm_scores$weight_between_algos_variable,
            stringsAsFactors = FALSE
          )
        )
      }
      
      # Curves of individual retained bivariate models containing v.
      if (include_small_models) {
        small_values <- base::vapply(
          model_predictions[variable_model_info$model_key],
          safe_mean,
          numeric(1)
        )
        
        out_id <- out_id + 1L
        out[[out_id]] <- base::cbind(
          common[
            base::rep(1L, base::nrow(variable_model_info)),
            ,
            drop = FALSE
          ],
          base::data.frame(
            curve_level = "small_model",
            curve_id = variable_model_info$model_key,
            algorithm = variable_model_info$algo,
            prediction = base::as.numeric(small_values),
            contains_variable = TRUE,
            weight_within_algo_original =
              variable_model_info$weight_within_algo_original,
            weight_within_algo_variable =
              variable_model_info$weight_within_algo_variable,
            weight_between_algos_original =
              variable_model_info$weight_between_algos_original,
            weight_between_algos_variable =
              variable_model_info$weight_between_algos_variable,
            effective_weight_variable =
              variable_model_info$effective_weight_variable,
            stringsAsFactors = FALSE
          )
        )
      }
    }
  }
  
  if (base::length(out) == 0L) {
    base::stop("No response curve could be calculated.")
  }
  
  result <- base::do.call(base::rbind, out)
  base::rownames(result) <- NULL
  result
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# FUN 12 - plot_esm_response_numeric
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

plot_esm_response_numeric <- function(rc, var) {
  
  df <- rc[
    rc$variable == var &
      rc$var_type == "numeric" &
      rc$curve_level == "ensemble",
    ,
    drop = FALSE
  ]
  
  if (base::nrow(df) == 0L) {
    base::stop("No numeric ensemble response curve found for: ", var)
  }
  
  ggplot2::ggplot(
    df,
    ggplot2::aes(x = value_num, y = prediction)
  ) +
    ggplot2::geom_line(linewidth = 1.1) +
    ggplot2::scale_y_continuous(
      breaks = base::seq(0, 1, by = 0.2),
      expand = ggplot2::expansion(mult = base::c(0, 0))
    ) +
    ggplot2::coord_cartesian(
      ylim = base::c(0, 1),
      expand = FALSE
    ) +
    ggplot2::labs(
      x = var,
      y = "Pravděpodobnost",
      title = base::paste("Křivka odpovědi:", var)
    ) +
    ggplot2::theme_bw()
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# FUN 13 - plot_esm_response_numeric_with_algorithms
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

plot_esm_response_numeric_with_algorithms <- function(rc, var) {
  
  df_algorithm <- rc[
    rc$variable == var &
      rc$var_type == "numeric" &
      rc$curve_level == "algorithm",
    ,
    drop = FALSE
  ]
  
  df_ensemble <- rc[
    rc$variable == var &
      rc$var_type == "numeric" &
      rc$curve_level == "ensemble",
    ,
    drop = FALSE
  ]
  
  if (base::nrow(df_ensemble) == 0L) {
    base::stop("No numeric ensemble response curve found for: ", var)
  }
  
  ggplot2::ggplot() +
    ggplot2::geom_line(
      data = df_algorithm,
      mapping = ggplot2::aes(
        x = value_num,
        y = prediction,
        group = curve_id,
        colour = algorithm
      ),
      linewidth = 0.8,
      alpha = 0.85
    ) +
    ggplot2::geom_line(
      data = df_ensemble,
      mapping = ggplot2::aes(
        x = value_num,
        y = prediction
      ),
      linewidth = 1.3
    ) +
    ggplot2::scale_y_continuous(
      breaks = base::seq(0, 1, by = 0.2),
      expand = ggplot2::expansion(mult = base::c(0, 0))
    ) +
    ggplot2::coord_cartesian(
      ylim = base::c(0, 1),
      expand = FALSE
    ) +
    ggplot2::labs(
      x = var,
      y = "Pravděpodobnost",
      colour = "Algoritmus",
      title = base::paste("Algoritmická křivka:", var)
    ) +
    ggplot2::theme_bw()
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# FUN 14 - plot_esm_response_numeric_with_small
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

plot_esm_response_numeric_with_small <- function(rc, var) {
  
  df_small <- rc[
    rc$variable == var &
      rc$var_type == "numeric" &
      rc$curve_level == "small_model",
    ,
    drop = FALSE
  ]
  
  df_ensemble <- rc[
    rc$variable == var &
      rc$var_type == "numeric" &
      rc$curve_level == "ensemble",
    ,
    drop = FALSE
  ]
  
  df_small$small_curve_group <- base::interaction(
    df_small$algorithm,
    df_small$curve_id,
    drop = TRUE
  )
  
  if (base::nrow(df_ensemble) == 0L) {
    base::stop("No numeric ensemble response curve found for: ", var)
  }
  
  ggplot2::ggplot() +
    ggplot2::geom_line(
      data = df_small,
      mapping = ggplot2::aes(
        x = value_num,
        y = prediction,
        group = small_curve_group
      ),
      linewidth = 0.35,
      alpha = 0.14
    ) +
    ggplot2::geom_line(
      data = df_ensemble,
      mapping = ggplot2::aes(
        x = value_num,
        y = prediction
      ),
      linewidth = 1.4
    ) +
    ggplot2::scale_y_continuous(
      breaks = base::seq(0, 1, by = 0.2),
      expand = ggplot2::expansion(mult = base::c(0, 0))
    ) +
    ggplot2::coord_cartesian(
      ylim = base::c(0, 1),
      expand = FALSE
    ) +
    ggplot2::labs(
      x = var,
      y = "Pravděpodobnost",
      title = base::paste("Křivka odpovědi:", var)
    ) +
    ggplot2::theme_bw()
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# FUN 15 - plot_esm_response_factor
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

plot_esm_response_factor <- function(rc, var) {
  
  df <- rc[
    rc$variable == var &
      rc$var_type == "factor" &
      rc$curve_level == "ensemble",
    ,
    drop = FALSE
  ]
  
  if (base::nrow(df) == 0L) {
    base::stop("No factor ensemble response profile found for: ", var)
  }
  
  ggplot2::ggplot(
    df,
    ggplot2::aes(x = value_chr, y = prediction)
  ) +
    ggplot2::geom_col() +
    ggplot2::scale_y_continuous(
      breaks = base::seq(0, 1, by = 0.2),
      expand = ggplot2::expansion(mult = base::c(0, 0))
    ) +
    ggplot2::coord_cartesian(
      ylim = base::c(0, 1),
      expand = FALSE
    ) +
    ggplot2::labs(
      x = var,
      y = "Pravděpodobnost",
      title = base::paste("Křivka odpovědi:", var)
    ) +
    ggplot2::theme_bw()
}

# FUN 16 ‒ ESM_weighted_mean_matrix

esm_weighted_mean_matrix <- function(pred_mat, weights) {
  
  pred_mat <- base::as.matrix(pred_mat)
  weights <- base::as.numeric(weights)
  
  if (base::ncol(pred_mat) != base::length(weights)) {
    base::stop("Number of prediction columns must match number of weights.")
  }
  
  num <- base::rowSums(base::sweep(pred_mat, 2, weights, `*`), na.rm = TRUE)
  den <- base::rowSums(base::sweep(!base::is.na(pred_mat), 2, weights, `*`), na.rm = TRUE)
  
  base::ifelse(den > 0, num / den, NA_real_)
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #