# medoid

nc <- terra::rast("SCLmasked_ALL_80_2022.nc")
nc
nlyr(nc)

bands <- c("B02","B03","B04","B05","B08","B8A","B11","B12")

nms <- names(nc)

band_vec <- sub("^(B0[2-8]|B8A|B1[12])_t=.*$", "\\1", nms)
t_vec    <- as.integer(sub("^.*_t=(\\d+).*$", "\\1", nms))

# jen požadované bandy (kdyby tam bylo něco navíc)
keep <- band_vec %in% bands & !is.na(t_vec)
nc2 <- nc[[which(keep)]]
band_vec <- band_vec[keep]
t_vec <- t_vec[keep]

# seřadit: čas -> band (v pořadí bands)
band_fac <- factor(band_vec, levels = bands)
ord <- order(t_vec, band_fac)
nc2 <- nc2[[ord]]
band_fac <- band_fac[ord]
t_vec <- t_vec[ord]

# kontrola, že to sedí po blocích (každý čas má 8 bandů)
stopifnot(nlyr(nc2) %% length(bands) == 0)

##################################
# pro orientaci data
dates <- as.Date(t_vec[seq(1, nlyr(nc2), by = length(bands))], origin = "1990-01-01")
dates
##################################

make_medoid_fun <- function(n_bands, strict_all_bands = TRUE) {
  function(v) {
    
    # v = numeric vector délky (n_times * n_bands) pro JEDEN pixel
    # obsahuje všechny bandy přes všechny časy (v pořadí "čas, band")
    
    # 1) pokud je pixel úplně prázdný (samé NA napříč všemi časy i bandy),
    #    vrať NA pro všechny bandy ve výsledku
    if (all(is.na(v))) return(rep(NA_real_, n_bands))
    
    # 2) přebal vektor do matice:
    #    řádky = jednotlivé časy (pozorování)
    #    sloupce = bandy
    #
    # byrow=TRUE je klíč: protože v je poskládané po blocích "čas1: 8 bandů, čas2: 8 bandů..."
    m <- matrix(v, ncol = n_bands, byrow = TRUE)  # řádky=čas, sloupce=band
    
    # 3) spočti "typický" spektrální vektor pro pixel:
    #    pro každý band medián přes čas (robustní vůči outlierům)
    #
    # med je vektor délky n_bands: (median_B02, median_B03, ..., median_B12)
    med <- apply(m, 2, median, na.rm = TRUE)
    
    # 4) spočti vzdálenost každého času od mediánového vektoru
    #
    # nejdřív m - med (broadcast přes řádky), pak druhá mocnina a suma přes bandy:
    # dist2[t] = Σ_b (m[t,b] - med[b])^2
    #
    # používáme squared distance (bez odmocniny) — pořadí minim je stejné
    diff <- m - matrix(med, nrow = nrow(m), ncol = n_bands, byrow = TRUE)
    dist2 <- rowSums(diff^2, na.rm = TRUE)
    
    
    # 5) zjisti, kolik bandů je validních (ne-NA) v každém čase
    valid <- rowSums(!is.na(m))
    
    # 6) ošetření chybějících bandů:
    #
    # strict_all_bands = TRUE:
    #   medoid vybíráme POUZE z časů, kde je všech n_bands dostupných.
    #   Pokud v daném čase chybí některý band, ten čas zakážeme (Inf).
    #
    # strict_all_bands = FALSE:
    #   dovolíme i časy s chybějícími bandy, ale penalizujeme je,
    #   aby se preferovaly kompletní pozorování.
    if (strict_all_bands) {
      dist2[valid < n_bands] <- Inf
    } else {
      dist2 <- dist2 + (n_bands - valid) * 1e12 # velká penalizace za každý chybějící band
      dist2[valid == 0] <- Inf # čas bez jediné hodnoty je nepoužitelný
    }
    
    # 7) index času s minimální vzdáleností (tj. medoid)
    i <- which.min(dist2)
    
    # 8) pokud žádný čas neprošel filtrem (vše Inf), vrať NA bandy
    if (!is.finite(dist2[i])) return(rep(NA_real_, n_bands))
    
    # návrat
    as.numeric(m[i, ])
  }
}

bands   <- c("B02","B03","B04","B05","B08","B8A","B11","B12")
n_bands <- length(bands)

fun <- make_medoid_fun(n_bands = n_bands, strict_all_bands = TRUE)

medoid <- app(
  nc2,
  fun = fun,
  filename = "SCLmasked_ALL_80_2022_medoid.tif",
  overwrite = TRUE,
  wopt = list(gdal = c("COMPRESS=LZW", "TILED=YES"))
)

names(medoid) <- bands
medoid
plot(medoid[[5]])
writeRaster(medoid, "80_medoid.tiff")
rm(medoid); gc()
