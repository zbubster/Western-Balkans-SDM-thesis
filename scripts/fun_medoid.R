# --- funkce pro medoid, vrací 8 bandů + 1x t ---
make_medoid_fun_with_t <- function(n_bands, t_by_row, strict_all_bands = TRUE) {
  
  # výpočet pro JEDEN pixel (v je numeric vektor délky n_times*n_bands)
  one_pixel <- function(v) {
    
    if (all(is.na(v))) {
      return(c(rep(NA_real_, n_bands), NA_real_))
    }
    
    # rows=time, cols=bands
    m <- matrix(v, ncol = n_bands, byrow = TRUE)
    
    # mediánový spektrální vektor (per band)
    med <- apply(m, 2, median, na.rm = TRUE)
    
    # squared euclidean distance od mediánu pro každý čas
    diff  <- m - matrix(med, nrow = nrow(m), ncol = n_bands, byrow = TRUE)
    dist2 <- rowSums(diff^2, na.rm = TRUE)
    
    # počet validních bandů v čase
    valid <- rowSums(!is.na(m))
    
    if (strict_all_bands) {
      dist2[valid < n_bands] <- Inf
    } else {
      dist2 <- dist2 + (n_bands - valid) * 1e12
      dist2[valid == 0] <- Inf
    }
    
    i <- which.min(dist2)
    
    if (!is.finite(dist2[i])) {
      return(c(rep(NA_real_, n_bands), NA_real_))
    }
    
    # návrat: bandy z vybraného času + t-kód
    c(as.numeric(m[i, ]), as.numeric(t_by_row[i]))
  }
  
  # wrapper: terra může poslat vektor (1 pixel) nebo matici (víc pixelů najednou)
  function(v) {
    if (is.matrix(v)) {
      out <- t(apply(v, 1, one_pixel))
      storage.mode(out) <- "double"
      return(out)
    } else {
      out <- one_pixel(v)
      storage.mode(out) <- "double"
      return(out)
    }
  }
}