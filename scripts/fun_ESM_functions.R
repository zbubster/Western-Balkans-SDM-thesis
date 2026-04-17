# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# FUN ‒ ESM complete function workflow
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
# FUN 13 ‒ plot_esm_response_numeric_with_small
# FUN 14 ‒ plot_esm_response_factor

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

esm_fit_bivariate <- function(prep,
                              predictors = NULL,
                              algorithms = c("glm", "rf"),
                              threshold = 0,
                              weight_transform = "identity",
                              rf_num_trees = 1000,
                              gbm_n_trees = 2000,
                              gbm_interaction_depth = 2,
                              seed = 722085415) {
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # Validate prep object and get data, cv table and predictors
  
  valid <- esm_validate_prep(prep = prep, predictors = predictors)
  
  data <- valid$data
  cv <- valid$cv
  predictors <- valid$predictors
  n <- base::nrow(data)
  
  # get predictors pairs
  pairs <- utils::combn(predictors, 2, simplify = FALSE)
  n <- base::nrow(data)
  
  # prepare outputs
  oof_pred <- base::rep(NA_real_, n)
  run_ensemble_scores <- list()
  cv_scores <- list()
  row_id <- 0L
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # CV
  
  # check, if CV fold have enough obs
  
  for (run_name in base::names(cv)) {
    
    message("Running CV fold: ", run_name)
    
    train_idx <- cv[[run_name]]
    test_idx <- !cv[[run_name]]
    
    test_rows <- base::which(test_idx)
    
    y_train <- data$observ[train_idx]
    y_test <- data$observ[test_idx]
    
    # check if there is enough observations
    if (base::sum(y_train == 1) < 5) next
    if (base::sum(y_train == 0) < 5) next
    if (base::sum(y_test == 1) < 1) next
    if (base::sum(y_test == 0) < 1) next
    
    run_pred_list <- list()
    run_score_df <- NULL
    
    # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
    # loop over predictor pairs
    
    for (pair in pairs) {
      pair_label <- base::paste(pair, collapse = " + ")
      
      message("__", pair_label)
      
      # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
      # loop over algos
      
      for (algo in algorithms) {
        
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
        
        # if fit failed, moveon
        if (base::is.null(fit_obj)) {
          next
        }
        
        # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
        # predict small model
        
        pred_test <- base::tryCatch(
          esm_predict_small_model(
            model_obj = fit_obj,
            newdata = data[test_idx, , drop = FALSE]
          ),
          error = function(e) rep(NA_real_, base::sum(test_idx))
        )
        
        # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
        # get sommersD
        
        dxy <- base::tryCatch(
          esm_somers_d(obs = y_test, pred = pred_test),
          error = function(e) NA_real_
        )
        
        # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
        # add result to loop output object
        row_id <- row_id + 1L
        
        run_pred_list[[row_id]] <- list(
          run = run_name,
          algo = algo,
          pair = pair,
          pred = pred_test
        )
        
        score_row <- base::data.frame(
          row_id = row_id,
          run = run_name,
          algo = algo,
          pred1 = pair[1],
          pred2 = pair[2],
          pair_label = pair_label,
          somers_d = dxy,
          n_train = base::sum(train_idx),
          n_test = base::sum(test_idx),
          stringsAsFactors = FALSE
        )
        
        if (base::is.null(run_score_df)) {
          run_score_df <- score_row
        } else {
          run_score_df <- base::rbind(run_score_df, score_row)
        }
      }
    }
    
    # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
    # which models keep for final ensemble
    
    if (base::is.null(run_score_df) || base::nrow(run_score_df) == 0) {
      next
    }
    
    keep_run <- !base::is.na(run_score_df$somers_d) & run_score_df$somers_d > threshold
    
    if (base::sum(keep_run) > 0) {
      w_run <- esm_make_weights(
        x = run_score_df$somers_d[keep_run],
        transform = weight_transform
      )
      
      pred_mat <- base::sapply(
        run_score_df$row_id[keep_run],
        function(id) run_pred_list[[id]]$pred
      )
      
      if (base::is.null(base::dim(pred_mat))) {
        pred_mat <- base::matrix(pred_mat, ncol = 1)
      }
      
      ens_run <- base::as.numeric(pred_mat %*% w_run)
      oof_pred[test_rows] <- ens_run
      
      run_dxy <- esm_somers_d(obs = y_test, pred = ens_run)
    } else {
      ens_run <- rep(NA_real_, base::sum(test_idx))
      run_dxy <- NA_real_
    }
    
    run_ensemble_scores[[run_name]] <- base::data.frame(
      run = run_name,
      ensemble_somers_d = run_dxy,
      n_test = base::sum(test_idx),
      stringsAsFactors = FALSE
    )
    
    cv_scores[[run_name]] <- run_score_df
  }
  
  cv_scores_df <- base::do.call(base::rbind, cv_scores)
  run_ensemble_scores_df <- base::do.call(base::rbind, run_ensemble_scores)
  
  if (base::is.null(cv_scores_df) || base::nrow(cv_scores_df) == 0) {
    base::stop("No valid CV models were fitted.")
  }
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # aggregate scores across runs
  
  group_key <- base::paste(cv_scores_df$algo, cv_scores_df$pair_label, sep = "___")
  group_levels <- base::unique(group_key)
  
  model_scores_list <- vector(mode = "list", length = base::length(group_levels))
  
  for (i in base::seq_along(group_levels)) {
    g <- group_levels[i]
    idx <- group_key == g
    
    sub <- cv_scores_df[idx, , drop = FALSE]
    mean_dxy <- base::mean(sub$somers_d, na.rm = TRUE)
    
    if (base::is.nan(mean_dxy)) {
      mean_dxy <- NA_real_
    }
    
    model_scores_list[[i]] <- base::data.frame(
      algo = sub$algo[1],
      pred1 = sub$pred1[1],
      pred2 = sub$pred2[1],
      pair_label = sub$pair_label[1],
      mean_somers_d = mean_dxy,
      sd_somers_d = stats::sd(sub$somers_d, na.rm = TRUE),
      n_valid_runs = base::sum(!base::is.na(sub$somers_d)),
      stringsAsFactors = FALSE
    )
  }
  
  model_scores <- base::do.call(base::rbind, model_scores_list)
  model_scores$keep <- !base::is.na(model_scores$mean_somers_d) & model_scores$mean_somers_d > threshold
  
  if (!base::any(model_scores$keep)) {
    base::stop("No pair-algorithm combination passed the threshold.")
  }
  
  model_scores$weight <- 0
  model_scores$weight[model_scores$keep] <- esm_make_weights(
    x = model_scores$mean_somers_d[model_scores$keep],
    transform = weight_transform
  )
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # Refit kept models on full data
  
  full_models <- list()
  
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
      nm <- base::paste(algo, model_scores$pair_label[i], sep = "___")
      full_models[[nm]] <- fit_obj
    }
  }
  
  if (base::length(full_models) == 0) {
    base::stop("All kept full models failed during refit.")
  }
  
  # final SommersD for model
  oof_somers_d <- esm_somers_d(obs = data$observ, pred = oof_pred)
  
  return(list(
    species = prep$species,
    data = data,
    predictors = predictors,
    threshold = threshold,
    weight_transform = weight_transform,
    cv_scores = cv_scores_df,
    run_ensemble_scores = run_ensemble_scores_df,
    model_scores = model_scores,
    full_models = full_models,
    oof_pred = oof_pred,
    oof_somers_d = oof_somers_d
  ))
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# FUN 10 ‒ esm_project_bivariate

esm_project_bivariate <- function(esm, new_env) {
  
  if (!base::is.list(esm)) {
    base::stop("esm must be an object returned by esm_fit_bivariate().")
  }
  
  if (base::is.null(esm$full_models) || base::length(esm$full_models) == 0) {
    base::stop("esm$full_models is empty.")
  }
  
  keep_scores <- esm$model_scores[esm$model_scores$keep, , drop = FALSE]
  
  if (base::nrow(keep_scores) == 0) {
    base::stop("No kept models available for projection.")
  }
  
  model_names <- base::paste(
    keep_scores$algo,
    keep_scores$pair_label,
    sep = "___"
  )
  
  weights <- stats::setNames(keep_scores$weight, model_names)
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # data.frame projection
  
  if (base::is.data.frame(new_env)) {
    num <- base::rep(0, base::nrow(new_env))
    den <- base::rep(0, base::nrow(new_env))
    
    for (nm in model_names) {
      model_obj <- esm$full_models[[nm]]
      w <- weights[[nm]]
      
      pred <- esm_predict_small_model(
        model_obj = model_obj,
        newdata = new_env
      )
      
      ok <- !base::is.na(pred)
      num[ok] <- num[ok] + pred[ok] * w
      den[ok] <- den[ok] + w
    }
    
    return(base::ifelse(den > 0, num / den, NA_real_))
  }
  
  # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
  # SpatRaster projection
  
  if (inherits(new_env, "SpatRaster")) {
    sum_r <- NULL
    den_r <- NULL
    
    for (nm in model_names) {
      model_obj <- esm$full_models[[nm]]
      w <- weights[[nm]]
      
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
      
      num_add <- terra::ifel(is.na(pred_r), 0, pred_r * w)
      den_add <- terra::ifel(is.na(pred_r), 0, w)
      
      if (base::is.null(sum_r)) {
        sum_r <- num_add
        den_r <- den_add
      } else {
        sum_r <- sum_r + num_add
        den_r <- den_r + den_add
      }
    }
    
    out <- terra::ifel(den_r == 0, NA, sum_r / den_r)
    base::names(out) <- "esm"
    
    return(out)
  }
  
  base::stop("new_env must be either a data.frame or a terra::SpatRaster.")
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# FUN 11 ‒ esm_response_curves_bivariate

# compute response curves

esm_response_curves_bivariate <- function(esm,
                                          vars = esm$predictors,
                                          ref_data = esm$data,
                                          n_points = 100,
                                          probs = c(0.01, 0.99),
                                          include_small_models = TRUE) {
  
  if (!base::is.list(esm)) {
    base::stop("esm must be an object returned by esm_fit_bivariate().")
  }
  
  if (base::is.null(esm$full_models) || base::length(esm$full_models) == 0) {
    base::stop("esm$full_models is empty.")
  }
  
  ref_data <- base::as.data.frame(ref_data)
  
  keep_scores <- esm$model_scores[esm$model_scores$keep, , drop = FALSE]
  if (base::nrow(keep_scores) == 0) {
    base::stop("No kept models available.")
  }
  
  model_names <- base::paste(
    keep_scores$algo,
    keep_scores$pair_label,
    sep = "___"
  )
  
  weights <- stats::setNames(keep_scores$weight, model_names)
  
  out <- list()
  out_id <- 0L
  
  for (v in vars) {
    
    if (!v %in% base::names(ref_data)) {
      next
    }
    
    x <- ref_data[[v]]
    is_fac <- base::is.factor(x)
    
    if (is_fac) {
      grid_vals <- base::levels(x)
      var_type <- "factor"
    } else {
      rng <- stats::quantile(x, probs = probs, na.rm = TRUE)
      grid_vals <- base::seq(rng[1], rng[2], length.out = n_points)
      var_type <- "numeric"
    }
    
    res_list <- vector(mode = "list", length = base::length(grid_vals))
    
    for (i in base::seq_along(grid_vals)) {
      g <- grid_vals[i]
      
      newdata <- ref_data
      
      if (is_fac) {
        newdata[[v]] <- base::factor(g, levels = base::levels(x))
        value_num <- NA_real_
        value_chr <- base::as.character(g)
      } else {
        newdata[[v]] <- g
        value_num <- base::as.numeric(g)
        value_chr <- base::as.character(g)
      }
      
      small_vals <- base::rep(NA_real_, base::length(model_names))
      base::names(small_vals) <- model_names
      
      for (nm in model_names) {
        model_obj <- esm$full_models[[nm]]
        
        if (!v %in% model_obj$pair) {
          next
        }
        
        pred <- esm_predict_small_model(
          model_obj = model_obj,
          newdata = newdata
        )
        
        small_vals[nm] <- base::mean(pred, na.rm = TRUE)
      }
      
      ok <- !base::is.na(small_vals)
      
      ensemble_val <- if (base::any(ok)) {
        stats::weighted.mean(
          x = small_vals[ok],
          w = weights[ok],
          na.rm = TRUE
        )
      } else {
        NA_real_
      }
      
      base_row <- base::data.frame(
        variable = v,
        var_type = var_type,
        grid_id = i,
        value_num = value_num,
        value_chr = value_chr,
        ensemble = ensemble_val,
        stringsAsFactors = FALSE
      )
      
      if (include_small_models) {
        small_df <- base::data.frame(
          variable = v,
          var_type = var_type,
          grid_id = i,
          value_num = value_num,
          value_chr = value_chr,
          model = base::names(small_vals),
          small_model = base::as.numeric(small_vals),
          stringsAsFactors = FALSE
        )
        
        res_list[[i]] <- base::merge(
          base_row,
          small_df,
          by = base::c("variable", "var_type", "grid_id", "value_num", "value_chr"),
          all = TRUE
        )
      } else {
        res_list[[i]] <- base_row
      }
    }
    
    out_id <- out_id + 1L
    out[[out_id]] <- dplyr::bind_rows(res_list)
  }
  
  dplyr::bind_rows(out)
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# FUN 12 ‒ plot_esm_response_numeric

plot_esm_response_numeric <- function(rc, var) {
  df <- rc[rc$variable == var & rc$var_type == "numeric", , drop = FALSE]
  
  ggplot2::ggplot(df, ggplot2::aes(x = value_num, y = ensemble)) +
    ggplot2::geom_line(linewidth = 1) +
    ggplot2::labs(
      x = var,
      y = "Predicted suitability",
      title = base::paste("Ensemble response curve:", var)
    ) +
    ggplot2::theme_bw()
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# FUN 13 ‒ plot_esm_response_numeric_with_small

plot_esm_response_numeric_with_small <- function(rc, var) {
  df <- rc[rc$variable == var & rc$var_type == "numeric", , drop = FALSE]
  
  ggplot2::ggplot(df, ggplot2::aes(x = value_num)) +
    ggplot2::geom_line(
      ggplot2::aes(y = small_model, group = model),
      alpha = 0.15
    ) +
    ggplot2::geom_line(
      ggplot2::aes(y = ensemble),
      linewidth = 1.2
    ) +
    ggplot2::labs(
      x = var,
      y = "Predicted suitability",
      title = base::paste("Ensemble response curve:", var)
    ) +
    ggplot2::theme_bw()
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

# FUN 14 ‒ plot_esm_response_factor

plot_esm_response_factor <- function(rc, var) {
  df <- rc[rc$variable == var & rc$var_type == "factor", , drop = FALSE]
  df <- df[!base::duplicated(df$grid_id), , drop = FALSE]
  
  ggplot2::ggplot(df, ggplot2::aes(x = value_chr, y = ensemble)) +
    ggplot2::geom_col() +
    ggplot2::labs(
      x = var,
      y = "Predicted suitability",
      title = base::paste("Ensemble response profile:", var)
    ) +
    ggplot2::theme_bw()
}

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #