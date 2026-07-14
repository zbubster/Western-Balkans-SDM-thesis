#let response-curves-common-grid(
  species,
  root: "../../models",
  manifest: "../../models/structure_models.txt",
  columns: 2,
  column-gap: 3pt,
  row-gap: 5pt,
  include-barplots: true,
) = {
  // structure_models.txt
  let relative-dir = ("./ESM/recent_noextrapol_weights_common/"
    + species + "/resp_curv_by_grain/"
  )
  // Načtení všech cest z manifestu
  let files = read(manifest).split("\n")

  // Odstranění případných mezer a znaků konce řádku
  files = files.map(line => line.trim())

  // Výběr požadovaných response curves
  files = files.filter(line => {
    let correct-type = line.ends-with("_by_grain.png")

    let categorical = include-barplots and line.ends-with("_barplot.png")

    line.starts-with(relative-dir) and (correct-type or categorical)
  })

  // Abecední seřazení podle názvu souboru
  files = files.sorted()

  if files.len() == 0 {
    panic(
      "Nenalezeny žádné response curves pro species="
      + species
    )
  }

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