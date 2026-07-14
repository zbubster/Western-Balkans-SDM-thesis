#let response-curves-grid(
  species,
  grain,
  type,
  root: "../../models",
  manifest: "../../models/structure_models.txt",
  extrapolation: none,
  colinearity: none,
  columns: 3,
  column-gap: 3pt,
  row-gap: 5pt,
  include-barplots: true,
) = {
  let grain = str(grain)

  // Kontrola typu response curves
  if type != "simple" and type != "complex" {
    panic(
      "Parametr type musí být \"simple\" nebo \"complex\"."
    )
  }

  // structure_models.txt
  let relative-dir = ("./ESM/recent_"
    + extrapolation + "_weights_"
    + colinearity + "/"
    + species + "/"
    + grain + "/resp_curv/"
  )
  // Načtení všech cest z manifestu
  let files = read(manifest).split("\n")

  // Odstranění případných mezer a znaků konce řádku
  files = files.map(line => line.trim())

  // Výběr požadovaných response curves
  files = files.filter(line => {
    let correct-type = line.ends-with("_" + type + ".png")

    let categorical = include-barplots and line.ends-with("_barplot.png")

    line.starts-with(relative-dir) and (correct-type or categorical)
  })

  // Abecední seřazení podle názvu souboru
  files = files.sorted()

  if files.len() == 0 {
    panic(
      "Nenalezeny žádné response curves pro species="
      + species
      + ", grain="
      + grain
      + ", type="
      + type
      + "."
    )
  }

  // Převod cest z:
  // ./ESM/...
  // na:
  // /outputs/ESM/...
  let plots = files.map(file => {
    let full-path = root + file.slice(1)

    image(
      full-path,
      width: 100%,
    )
  })

  // Výsledná mřížka
  grid(
    columns: (1fr,) * columns,
    column-gutter: column-gap,
    row-gutter: row-gap,
    align: center + horizon,
    inset: 0pt,
    stroke: none,
    ..plots,
  )
}