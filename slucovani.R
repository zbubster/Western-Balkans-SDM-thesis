

# 1. Zadej kořenový adresář, kde chceš hledat
cesta <- "/home/zbub/diplomka/data/occurence"

# 2. Najdi všechny soubory *.gpkg, které obsahují "acc" v názvu (rekurzivně)
gpkg_soubory <- list.files(path = cesta,
                           pattern = "acc.*\\.gpkg$", 
                           full.names = TRUE,
                           recursive = TRUE,
                           ignore.case = TRUE)

# 3. Načti vrstvy (předpoklad: každý .gpkg má jen jednu vrstvu)
#    Pokud je více vrstev v jednom .gpkg, upravíme (viz níže)
vektory <- lapply(gpkg_soubory, function(f) vect(f))

# 4. (Volitelné) přidej název souboru jako identifikátor
names(vektory) <- basename(gpkg_soubory)


# 1. Zjisti všechny názvy sloupců napříč všemi vrstvami
vsechny_sloupce <- unique(unlist(lapply(vektory, names)))

# 2. Doplnění chybějících sloupců (NA) a sjednocení pořadí
vektory_sjednocene <- lapply(vektory, function(x) {
  chybi <- setdiff(vsechny_sloupce, names(x))
  for (col in chybi) {
    x[[col]] <- NA
  }
  # Sjednotit pořadí
  x <- x[, vsechny_sloupce]
  return(x)
})

# 3. Sloučení všech vrstev
sloucena <- Reduce(function(x, y) rbind(x, y), vektory_sjednocene)

# 4. Volitelně ulož jako GPKG
writeVector(sloucena, "sloucena_vrstva.gpkg", filetype = "GPKG", overwrite = TRUE)
