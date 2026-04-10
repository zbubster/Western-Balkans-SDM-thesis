# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# Compute observation weights
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# 
# This script takes RDS files with data about species and computes
# weights for each observation class.
# 
# It works with PA data, where P came from different source. At the first it
# 'splits' main weigts between presences and absences (param presence_share).
# Than it is able to favor one type of presences at the cost of the other source.
# 
# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #


presence_share <- 0.5 # inicial PA prevalence
fw_tn_ratio <- 2 # FW presences are 2 times valueable than TN data
normalize_to_n <- TRUE

dir_in  <- here::here("data", "__ANALYSIS__", "OCC")
dir_out <- here::here("data", "__ANALYSIS__", "OCC", "weights")

if(!dir.exists(dir_out))dir.create(dir_out)

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# function

compute_weights <- function(
    data, 
    presence_share = 0.5, 
    fw_tn_ratio = 2,
    normalize_to_n = TRUE
) {
  
  # get vectors of observations and datasources
  obs <- data$observations
  src <- data$source
  
  n <- length(obs)
  
  # get TF vectors and their totals
  idx_0 <- obs == 0 # abs
  idx_1 <- obs == 1 # pres
  idx_1_fw <- obs == 1 & src == "FW" # FW pres
  idx_1_tn <- obs == 1 & src == "TN" # TN pres
  
  n0 <- sum(idx_0)
  n1 <- sum(idx_1)
  n1_fw <- sum(idx_1_fw)
  n1_tn <- sum(idx_1_tn)
  
  # normalize to N?
  if(normalize_to_n == TRUE){
    total_presence_weight <- n*presence_share
    total_absence_weight <- n*(1-presence_share)
  }else{
    total_presence_weight <- presence_share
    total_absence_weight <- 1-presence_share
  }
  
  # set ABSENCE weights
  w0 <- total_absence_weight/n0
  
  # set PRESENCE weights
  if(n1_tn == 0){
    # no TN data, all pres same
    w1_fw <- total_presence_weight/n1_fw
    w1_tn <- NA_real_
  }else if(n1_fw == 0){
    # no FW data, all pres same
    w1_tn <- total_presence_weight/n1_tn
    w1_fw <- NA_real_
  }else{
    # when there are both FW and TN data
    # difference in presence weights is made by fw_tn_ratio
    # but also:
    # n1_fw * w1_fw + n1_tn * w1_tn = total_presence_weight
    w1_tn <- total_presence_weight/(n1_tn+(n1_fw*fw_tn_ratio))
    w1_fw <- fw_tn_ratio*w1_tn
    # this means:
    # FWpres_weight = fw_tn_ratio times bigger then TNpres_weight
  }
  
  # set weights to data
  weights <- numeric(n)
  weights[idx_0] <- w0 # ABSENCES
  weights[idx_1_fw] <- w1_fw # FW PRESENCES
  weights[idx_1_tn] <- w1_tn # TN PRESENCES
  
  # summary df
  summary <- data.frame(
    n_total = n,
    n_abs = n0,
    n_pres = n1,
    n_pres_fw = n1_fw,
    n_pres_tn = n1_tn,
    presence_share = presence_share,
    fw_tn_ratio = fw_tn_ratio,
    w_abs = w0,
    w_pres_fw = w1_fw,
    w_pres_tn = w1_tn,
    sum_w_total = sum(weights),
    sum_w_abs = sum(weights[idx_0]),
    sum_w_pres = sum(weights[idx_1]),
    stringsAsFactors = FALSE
  )
  
  # return objects
  list(
    weights = weights,
    summary = summary
  )
}


# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
# apply over all files

files <- list.files(
  path = dir_in,
  pattern = "\\.rds$",
  full.names = TRUE
)

# prepare empty list
summary_list <- vector(mode = "list", length = length(files))

for (i in seq_along(files)) {
  
  # get file
  file <- files[i]
  name <- tools::file_path_sans_ext(basename(file))
  
  # load data
  data <- readRDS(file)
  
  # apply function
  out <- compute_weights(
    data = data,
    presence_share = presence_share, # inicial PA prevalence
    fw_tn_ratio = fw_tn_ratio, # FW presences are 2 times valueable than TN data
    normalize_to_n = normalize_to_n
  )
  
  # add weights to original data
  data$weights <- out$weights
  
  # add summary to summary list
  summary_list[[i]] <- cbind(
    file = basename(file),
    species = if ("species" %in% names(data)) data$species[1] else NA_character_,
    out$summary,
    stringsAsFactors = FALSE
  )
  
  # save updated dataset
  saveRDS(
    object = data,
    file = file.path(dir_out, paste0(name, ".rds"))
  )
}

weights_summary <- do.call(rbind, summary_list)
utils::write.csv(weights_summary, file = file.path(dir_out, "weights_summary.csv"))

# - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #