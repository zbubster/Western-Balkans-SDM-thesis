#let esm_shape_extrapol_all(
  species,
  grain,
  period: "recent",
  ssp: none,
  statistic: "mean",
  root: "/outputs",
  gap: 0pt,
  width: 100%,
) = {
  let grain = str(grain)

  // recentní projekce
  let paths = if period == "recent" {
    (
      esm: root + "/ESM/recent_extrapol_weights_all_selected/"
        + species + "/" + grain
        + "/ESM_projection.png",

      shape: root + "/Shape/recent_extrapol_weights_all_selected/"
        + species + "/" + grain
        + "/Shape_projection.png",
    )

  // hindcast 060 nebo 190
  } else if period == "060" or period == "190" {
    (
      esm: root + "/ESM/recent_extrapol_weights_all_selected/"
        + species + "/" + grain
        + "/projections/" + period + "_all_selected/"
        + "ESM_projection_" + period + "_all_selected.png",

      shape: root + "/Shape/hindcast_forecast_extrapol_weights_all_selected/"
        + species + "/" + grain
        + "/projections/hindcast/trace21k_-"
        + period + "/Shape_projection.png",
    )

  // agregované budoucí projekce
  } else {
    assert(
      ssp != none,
      message: "U budoucí projekce musí být zadán parametr ssp.",
    )

    let scenario = period + "_ssp" + str(ssp)

    (
      esm: root + "/ESM/recent_extrapol_weights_all_selected/"
        + "_future_aggregated/" + species + "/" + grain
        + "/" + scenario + "/"
        + statistic + "_predicted_suitability_"
        + species + "_" + grain + "_" + scenario + ".png",

      shape: root + "/Shape/hindcast_forecast_extrapol_weights_all_selected/"
        + "_forecast_aggregated/" + species + "/" + grain
        + "/" + scenario + "/"
        + statistic + "_shape_"
        + species + "_" + grain + "_" + scenario + ".png",
    )
  }

  grid(
    columns: (1fr, 1fr),
    column-gutter: gap,
    align: center,

    image(paths.esm, width: width),
    image(paths.shape, width: width),
  )
}


// # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
// # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

#let esm_shape_noextrapol(
  species,
  grain,
  root: "/outputs",
  gap: 0pt,
  width: 100%,
  colin: none
) = {
  let grain = str(grain)

  let paths = (
      esm: root + "/ESM/recent_noextrapol_weights_" + colin + "/"
        + species + "/" + grain
        + "/ESM_projection.png",

      shape: root + "/Shape/recent_noextrapol_weights_" + colin + "/"
        + species + "/" + grain
        + "/Shape_projection.png",
    )

  grid(
    columns: (1fr, 1fr),
    column-gutter: gap,
    align: center,

    image(paths.esm, width: width),
    image(paths.shape, width: width),
  )
}

// # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
// # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

#let response-curves-grid(
  species,
  grain,
  type,
  root: "/models",
  manifest: "/models/structure_models.txt",
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

// # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
// # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

#let shape-plots-grid(
  species,
  grain,
  period: "recent",
  root: "/models",
  manifest: "/models/structure_models.txt",
  extrapolation: "extrapol",
  colinearity: "all_selected",
  columns: 3,
  column-gap: 3pt,
  row-gap: 5pt,
) = {
  let grain = str(grain)
  let period = str(period)

  // Kontrola období
  if period != "recent" and period != "060" and period != "190" {
    panic(
      "Parametr period musí být \"recent\", \"060\" nebo \"190\"."
    )
  }

  // Společné označení modelovací větve
  let model-branch = (
    extrapolation
    + "_weights_"
    + colinearity
  )

  // Recentní Shape
  let relative-dir = if period == "recent" {
    (
      "./Shape/recent_"
      + model-branch
      + "/"
      + species
      + "/"
      + grain
      + "/"
    )

  // Hindcast Shape
  } else {
    (
      "./Shape/hindcast_forecast_"
      + model-branch
      + "/"
      + species
      + "/"
      + grain
      + "/projections/hindcast/trace21k_-"
      + period
      + "/"
    )
  }

  // Načtení cest z manifestu
  let files = read(manifest)
    .split("\n")
    .map(line => line.trim())

  // Výběr PNG grafů přímo v daném adresáři
  files = files.filter(line => {
    if line.starts-with(relative-dir) {
      let filename = line.slice(relative-dir.len())

      line.ends-with(".png") and not filename.contains("/")
    } else {
      false
    }
  })

  // Abecední seřazení podle dvojic prediktorů
  files = files.sorted()

  if files.len() == 0 {
    panic(
      "Nenalezeny žádné grafy metriky Shape pro species="
      + species
      + ", grain="
      + grain
      + ", period="
      + period
      + ", větev="
      + model-branch
      + ". Hledaný adresář: "
      + relative-dir
    )
  }

  // Převod relativních cest na úplné cesty
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

// # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
// # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #

// settings
#set heading(numbering: "1.")
#set text(font: "Libertinus Serif", size: 12pt, lang: "cs")



// # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
// # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #


#title([_Phyteum pseudorbiculare_])

#outline(title: [Obsah], depth: 5)

= Modely na extrapolovatelných prediktorech

#figure(
    grid(
    columns: 2,
    row-gutter: 10pt,

    image("outputs/ESM/recent_extrapol_weights_all_selected/PP/1000/OOF_prediction.png"),
    image("outputs/ESM/recent_extrapol_weights_all_selected/PP/500/OOF_prediction.png"),
    image("outputs/ESM/recent_extrapol_weights_all_selected/PP/200/OOF_prediction.png"),
    image("outputs/ESM/recent_extrapol_weights_all_selected/PP/100/OOF_prediction.png")
  ),
  caption: [Houslové grafy znázorňují rozložení predikcí vhodnosti stanoviště pro pozorované absence a presence druhu v daném prostorovém rozlišení. Jednotlivé body odpovídají predikcím modelu pro konkrétní pozorování, červeně je naznačen median a v popisku celkove Somersovo D celého modelu.]
)

#figure(
  image("outputs/summary/figures/predictor_contributions/recent_extrapol_weights_all_selected/PP/heatmap.png"),
  caption: [Relativní příspěvek jednotlivých prediktorů do finálního ESM. Jednotlivé příspěvky byly odvozeny z efektivních vah ponechaných bivariátních modelů ve finálním ensemble, přičemž váha každého bivariátního modelu byla rovným dílem rozdělena mezi oba prediktory.]
)

#set page(flipped: true)

== _Phyteum pseudorbiculare_, 1000 m
=== současnost

#figure(
  esm_shape_extrapol_all(
  "PP",
  1000,
  period: "recent",
  ssp: none
  ),
  caption: [Projekce ESM (vlevo) & projekce metriky Shape (vpravo).]
)

#set page(flipped: false)

==== Křivky odpovědí

#figure(
  response-curves-grid(
    "PP",
    1000,
    "complex",
    extrapolation: "extrapol",
    colinearity: "all_selected"
  ),
  caption: [Křivky odpovědí druhu: vyjadřují změnu průměrné pravděpodobnosti výskytu druhu na gradientu daného prediktoru (plná linka). Sestaveny byly z ponechaných bivariátních modelů (tenké linky) obsahujících příslušný prediktor, kdy jejich predikce byly nejprve váženě agregovány v rámci jednotlivých algoritmů a následně mezi algoritmy podle jejich vah v rámci finálního ESM.]
)

==== Bivariátní grafy Shape

#{
  show figure: set block(breakable: true)

  figure(
    shape-plots-grid(
      "PP",
      1000,
      period: "recent",
      extrapolation: "extrapol",
      colinearity: "all_selected",
      columns: 6,
    ),
    caption: [
      Bivariátní zobrazení metriky Shape. Data představují 5% vzorek
      prediktorových kombinací v daném rastru, na osách grafu jsou uvedeny hodnoty prediktorů, barevná škála velikost
      metriky Shape, kdy tmavší barva představuje kombinace vzdálenější
      od trénovacích dat než barva světlejší. Zaznačena jsou také
      pozorování druhu.
    ],
  )
}

=== 21k BP, LGM

#figure(
  esm_shape_extrapol_all(
    "PP",
    1000,
    period: "190"
  ),
  caption: [Projekce ESM (vlevo) & projekce metriky Shape (vpravo).]
)

==== Bivariátní grafy Shape

#{
  show figure: set block(breakable: true)

  figure(
    shape-plots-grid(
      "PP",
      1000,
      period: "190",
      extrapolation: "extrapol",
      colinearity: "all_selected",
      columns: 6,
    ),
    caption: [
      Bivariátní zobrazení metriky Shape. Data představují 5% vzorek
      prediktorových kombinací v daném rastru, na osách grafu jsou uvedeny hodnoty prediktorů, barevná škála velikost
      metriky Shape, kdy tmavší barva představuje kombinace vzdálenější
      od trénovacích dat než barva světlejší. Zaznačena jsou také
      pozorování druhu.
    ],
  )
}

=== 8k BP, HCO

#figure(
  esm_shape_extrapol_all(
    "PP",
    1000,
    period: "060"
  ),
  caption: [Projekce ESM (vlevo) & projekce metriky Shape (vpravo).]
)

==== Bivariátní grafy Shape

#{
  show figure: set block(breakable: true)

  figure(
    shape-plots-grid(
      "PP",
      1000,
      period: "060",
      extrapolation: "extrapol",
      colinearity: "all_selected",
      columns: 6,
    ),
    caption: [
      Bivariátní zobrazení metriky Shape. Data představují 5% vzorek
      prediktorových kombinací v daném rastru, na osách grafu jsou uvedeny hodnoty prediktorů, barevná škála velikost
      metriky Shape, kdy tmavší barva představuje kombinace vzdálenější
      od trénovacích dat než barva světlejší. Zaznačena jsou také
      pozorování druhu.
    ],
  )
}

=== 2041 ‒ 2070
==== SSP1.26
===== Průměr predikcí
#figure(
  esm_shape_extrapol_all(
    "PP",
    1000,
    period: "2041-2070",
    ssp: 126,
    statistic: "mean"
  ),
  caption: [Průměrná predikovaná vhodnost stanoviště napříč modely globální cirkulace pro daný scénář SSP (vlevo) a průměrná hodnota metriky Shape napříč týmiž modely (vpravo).]
)

===== Směrodatná odchylka predikcí

#figure(
  esm_shape_extrapol_all(
    "PP",
    1000,
    period: "2041-2070",
    ssp: 126,
    statistic: "sd"
  ),
  caption: [Směrodatná odchylka predikované vhodnosti stanoviště napříč modely globální cirkulace pro daný scénář SSP (vlevo) a směrodatná odchylka metriky Shape napříč týmiž modely (vpravo).]
)

==== SSP3.70
===== Průměr predikcí

#figure(
  esm_shape_extrapol_all(
    "PP",
    1000,
    period: "2041-2070",
    ssp: 370,
    statistic: "mean"
  ),
  caption: [Průměrná predikovaná vhodnost stanoviště napříč modely globální cirkulace pro daný scénář SSP (vlevo) a průměrná hodnota metriky Shape napříč týmiž modely (vpravo).]
)

===== Směrodatná odchylka predikcí

#figure(
  esm_shape_extrapol_all(
    "PP",
    1000,
    period: "2041-2070",
    ssp: 370,
    statistic: "sd"
  ),
  caption: [Směrodatná odchylka predikované vhodnosti stanoviště napříč modely globální cirkulace pro daný scénář SSP (vlevo) a směrodatná odchylka metriky Shape napříč týmiž modely (vpravo).]
)

==== SSP5.85
===== Průměr predikcí

#figure(
  esm_shape_extrapol_all(
    "PP",
    1000,
    period: "2041-2070",
    ssp: 585,
    statistic: "mean"
  ),
  caption: [Průměrná predikovaná vhodnost stanoviště napříč modely globální cirkulace pro daný scénář SSP (vlevo) a průměrná hodnota metriky Shape napříč týmiž modely (vpravo).]
)

===== Směrodatná odchylka predikcí

#figure(
  esm_shape_extrapol_all(
    "PP",
    1000,
    period: "2041-2070",
    ssp: 585,
    statistic: "sd"
  ),
  caption: [Směrodatná odchylka predikované vhodnosti stanoviště napříč modely globální cirkulace pro daný scénář SSP (vlevo) a směrodatná odchylka metriky Shape napříč týmiž modely (vpravo).]
)

=== 2071 ‒ 2100
==== SSP1.26
===== Průměr predikcí

#figure(
  esm_shape_extrapol_all(
    "PP",
    1000,
    period: "2071-2100",
    ssp: 126,
    statistic: "mean"
  ),
  caption: [Průměrná predikovaná vhodnost stanoviště napříč modely globální cirkulace pro daný scénář SSP (vlevo) a průměrná hodnota metriky Shape napříč týmiž modely (vpravo).]
)

===== Směrodatná odchylka predikcí

#figure(
  esm_shape_extrapol_all(
    "PP",
    1000,
    period: "2071-2100",
    ssp: 126,
    statistic: "sd"
  ),
  caption: [Směrodatná odchylka predikované vhodnosti stanoviště napříč modely globální cirkulace pro daný scénář SSP (vlevo) a směrodatná odchylka metriky Shape napříč týmiž modely (vpravo).]
)

==== SSP3.70
===== Průměr predikcí

#figure(
  esm_shape_extrapol_all(
    "PP",
    1000,
    period: "2071-2100",
    ssp: 370,
    statistic: "mean"
  ),
  caption: [Průměrná predikovaná vhodnost stanoviště napříč modely globální cirkulace pro daný scénář SSP (vlevo) a průměrná hodnota metriky Shape napříč týmiž modely (vpravo).]
)

===== Směrodatná odchylka predikcí

#figure(
  esm_shape_extrapol_all(
    "PP",
    1000,
    period: "2071-2100",
    ssp: 370,
    statistic: "sd"
  ),
  caption: [Směrodatná odchylka predikované vhodnosti stanoviště napříč modely globální cirkulace pro daný scénář SSP (vlevo) a směrodatná odchylka metriky Shape napříč týmiž modely (vpravo).]
)

==== SSP5.85
===== Průměr predikcí

#figure(
  esm_shape_extrapol_all(
    "PP",
    1000,
    period: "2071-2100",
    ssp: 585,
    statistic: "mean"
  ),
  caption: [Průměrná predikovaná vhodnost stanoviště napříč modely globální cirkulace pro daný scénář SSP (vlevo) a průměrná hodnota metriky Shape napříč týmiž modely (vpravo).]
)

===== Směrodatná odchylka predikcí

#figure(
  esm_shape_extrapol_all(
    "PP",
    1000,
    period: "2071-2100",
    ssp: 585,
    statistic: "sd"
  ),
  caption: [Směrodatná odchylka predikované vhodnosti stanoviště napříč modely globální cirkulace pro daný scénář SSP (vlevo) a směrodatná odchylka metriky Shape napříč týmiž modely (vpravo).]
)

#set page(flipped: true)

== _Phyteum pseudorbiculare_, 500 m
=== současnost

#figure(
  esm_shape_extrapol_all(
  "PP",
  500,
  period: "recent",
  ssp: none
  ),
  caption: [Projekce ESM (vlevo) & projekce metriky Shape (vpravo).]
)

#set page(flipped: false)

==== Křivky odpovědí

#figure(
  response-curves-grid(
    "PP",
    500,
    "complex",
    extrapolation: "extrapol",
    colinearity: "all_selected"
  ),
  caption: [Křivky odpovědí druhu: vyjadřují změnu průměrné pravděpodobnosti výskytu druhu na gradientu daného prediktoru (plná linka). Sestaveny byly z ponechaných bivariátních modelů (tenké linky) obsahujících příslušný prediktor, kdy jejich predikce byly nejprve váženě agregovány v rámci jednotlivých algoritmů a následně mezi algoritmy podle jejich vah v rámci finálního ESM.]
)

==== Bivariátní grafy Shape

#{
  show figure: set block(breakable: true)

  figure(
    shape-plots-grid(
      "PP",
      500,
      period: "recent",
      extrapolation: "extrapol",
      colinearity: "all_selected",
      columns: 6,
    ),
    caption: [
      Bivariátní zobrazení metriky Shape. Data představují 5% vzorek
      prediktorových kombinací v daném rastru, na osách grafu jsou uvedeny hodnoty prediktorů, barevná škála velikost
      metriky Shape, kdy tmavší barva představuje kombinace vzdálenější
      od trénovacích dat než barva světlejší. Zaznačena jsou také
      pozorování druhu.
    ],
  )
}


=== 21k BP, LGM

#figure(
  esm_shape_extrapol_all(
    "PP",
    500,
    period: "190"
  ),
  caption: [Projekce ESM (vlevo) & projekce metriky Shape (vpravo).]
)

==== Bivariátní grafy Shape

#{
  show figure: set block(breakable: true)

  figure(
    shape-plots-grid(
      "PP",
      500,
      period: "190",
      extrapolation: "extrapol",
      colinearity: "all_selected",
      columns: 6,
    ),
    caption: [
      Bivariátní zobrazení metriky Shape. Data představují 5% vzorek
      prediktorových kombinací v daném rastru, na osách grafu jsou uvedeny hodnoty prediktorů, barevná škála velikost
      metriky Shape, kdy tmavší barva představuje kombinace vzdálenější
      od trénovacích dat než barva světlejší. Zaznačena jsou také
      pozorování druhu.
    ],
  )
}

=== 8k BP, HCO

#figure(
  esm_shape_extrapol_all(
    "PP",
    500,
    period: "060"
  ),
  caption: [Projekce ESM (vlevo) & projekce metriky Shape (vpravo).]
)

==== Bivariátní grafy Shape

#{
  show figure: set block(breakable: true)

  figure(
    shape-plots-grid(
      "PP",
      500,
      period: "060",
      extrapolation: "extrapol",
      colinearity: "all_selected",
      columns: 6,
    ),
    caption: [
      Bivariátní zobrazení metriky Shape. Data představují 5% vzorek
      prediktorových kombinací v daném rastru, na osách grafu jsou uvedeny hodnoty prediktorů, barevná škála velikost
      metriky Shape, kdy tmavší barva představuje kombinace vzdálenější
      od trénovacích dat než barva světlejší. Zaznačena jsou také
      pozorování druhu.
    ],
  )
}

=== 2041 ‒ 2070
==== SSP1.26
===== Průměr predikcí

#figure(
  esm_shape_extrapol_all(
    "PP",
    500,
    period: "2041-2070",
    ssp: 126,
    statistic: "mean"
  ),
  caption: [Průměrná predikovaná vhodnost stanoviště napříč modely globální cirkulace pro daný scénář SSP (vlevo) a průměrná hodnota metriky Shape napříč týmiž modely (vpravo).]
)

===== Směrodatná odchylka predikcí

#figure(
  esm_shape_extrapol_all(
    "PP",
    500,
    period: "2041-2070",
    ssp: 126,
    statistic: "sd"
  ),
  caption: [Směrodatná odchylka predikované vhodnosti stanoviště napříč modely globální cirkulace pro daný scénář SSP (vlevo) a směrodatná odchylka metriky Shape napříč týmiž modely (vpravo).]
)

==== SSP3.70
===== Průměr predikcí

#figure(
  esm_shape_extrapol_all(
    "PP",
    500,
    period: "2041-2070",
    ssp: 370,
    statistic: "mean"
  ),
  caption: [Průměrná predikovaná vhodnost stanoviště napříč modely globální cirkulace pro daný scénář SSP (vlevo) a průměrná hodnota metriky Shape napříč týmiž modely (vpravo).]
)

===== Směrodatná odchylka predikcí

#figure(
  esm_shape_extrapol_all(
    "PP",
    500,
    period: "2041-2070",
    ssp: 370,
    statistic: "sd"
  ),
  caption: [Směrodatná odchylka predikované vhodnosti stanoviště napříč modely globální cirkulace pro daný scénář SSP (vlevo) a směrodatná odchylka metriky Shape napříč týmiž modely (vpravo).]
)

==== SSP5.85
===== Průměr predikcí

#figure(
  esm_shape_extrapol_all(
    "PP",
    500,
    period: "2041-2070",
    ssp: 585,
    statistic: "mean"
  ),
  caption: [Průměrná predikovaná vhodnost stanoviště napříč modely globální cirkulace pro daný scénář SSP (vlevo) a průměrná hodnota metriky Shape napříč týmiž modely (vpravo).]
)

===== Směrodatná odchylka predikcí

#figure(
  esm_shape_extrapol_all(
    "PP",
    500,
    period: "2041-2070",
    ssp: 585,
    statistic: "sd"
  ),
  caption: [Směrodatná odchylka predikované vhodnosti stanoviště napříč modely globální cirkulace pro daný scénář SSP (vlevo) a směrodatná odchylka metriky Shape napříč týmiž modely (vpravo).]
)

=== 2071 ‒ 2100
==== SSP1.26
===== Průměr predikcí

#figure(
  esm_shape_extrapol_all(
    "PP",
    500,
    period: "2071-2100",
    ssp: 126,
    statistic: "mean"
  ),
  caption: [Průměrná predikovaná vhodnost stanoviště napříč modely globální cirkulace pro daný scénář SSP (vlevo) a průměrná hodnota metriky Shape napříč týmiž modely (vpravo).]
)

===== Směrodatná odchylka predikcí

#figure(
  esm_shape_extrapol_all(
    "PP",
    500,
    period: "2071-2100",
    ssp: 126,
    statistic: "sd"
  ),
  caption: [Směrodatná odchylka predikované vhodnosti stanoviště napříč modely globální cirkulace pro daný scénář SSP (vlevo) a směrodatná odchylka metriky Shape napříč týmiž modely (vpravo).]
)

==== SSP3.70
===== Průměr predikcí

#figure(
  esm_shape_extrapol_all(
    "PP",
    500,
    period: "2071-2100",
    ssp: 370,
    statistic: "mean"
  ),
  caption: [Průměrná predikovaná vhodnost stanoviště napříč modely globální cirkulace pro daný scénář SSP (vlevo) a průměrná hodnota metriky Shape napříč týmiž modely (vpravo).]
)

===== Směrodatná odchylka predikcí

#figure(
  esm_shape_extrapol_all(
    "PP",
    500,
    period: "2071-2100",
    ssp: 370,
    statistic: "sd"
  ),
  caption: [Směrodatná odchylka predikované vhodnosti stanoviště napříč modely globální cirkulace pro daný scénář SSP (vlevo) a směrodatná odchylka metriky Shape napříč týmiž modely (vpravo).]
)

==== SSP5.85
===== Průměr predikcí

#figure(
  esm_shape_extrapol_all(
    "PP",
    500,
    period: "2071-2100",
    ssp: 585,
    statistic: "mean"
  ),
  caption: [Průměrná predikovaná vhodnost stanoviště napříč modely globální cirkulace pro daný scénář SSP (vlevo) a průměrná hodnota metriky Shape napříč týmiž modely (vpravo).]
)

===== Směrodatná odchylka predikcí

#figure(
  esm_shape_extrapol_all(
    "PP",
    500,
    period: "2071-2100",
    ssp: 585,
    statistic: "sd"
  ),
  caption: [Směrodatná odchylka predikované vhodnosti stanoviště napříč modely globální cirkulace pro daný scénář SSP (vlevo) a směrodatná odchylka metriky Shape napříč týmiž modely (vpravo).]
)

#set page(flipped: true)

== _Phyteum pseudorbiculare_, 200 m
=== současnost

#figure(
  esm_shape_extrapol_all(
  "PP",
  200,
  period: "recent",
  ssp: none
  ),
  caption: [Projekce ESM (vlevo) & projekce metriky Shape (vpravo).]
)

#set page(flipped: false)

==== Křivky odpovědí

#figure(
  response-curves-grid(
    "PP",
    200,
    "complex",
    extrapolation: "extrapol",
    colinearity: "all_selected"
  ),
  caption: [Křivky odpovědí druhu: vyjadřují změnu průměrné pravděpodobnosti výskytu druhu na gradientu daného prediktoru (plná linka). Sestaveny byly z ponechaných bivariátních modelů (tenké linky) obsahujících příslušný prediktor, kdy jejich predikce byly nejprve váženě agregovány v rámci jednotlivých algoritmů a následně mezi algoritmy podle jejich vah v rámci finálního ESM.]
)

==== Bivariátní grafy Shape

#{
  show figure: set block(breakable: true)

  figure(
    shape-plots-grid(
      "PP",
      200,
      period: "recent",
      extrapolation: "extrapol",
      colinearity: "all_selected",
      columns: 6,
    ),
    caption: [
      Bivariátní zobrazení metriky Shape. Data představují 5% vzorek
      prediktorových kombinací v daném rastru, na osách grafu jsou uvedeny hodnoty prediktorů, barevná škála velikost
      metriky Shape, kdy tmavší barva představuje kombinace vzdálenější
      od trénovacích dat než barva světlejší. Zaznačena jsou také
      pozorování druhu.
    ],
  )
}
=== 21k BP, LGM

#figure(
  esm_shape_extrapol_all(
    "PP",
    200,
    period: "190"
  ),
  caption: [Projekce ESM (vlevo) & projekce metriky Shape (vpravo).]
)

==== Bivariátní grafy Shape

#{
  show figure: set block(breakable: true)

  figure(
    shape-plots-grid(
      "PP",
      200,
      period: "190",
      extrapolation: "extrapol",
      colinearity: "all_selected",
      columns: 6,
    ),
    caption: [
      Bivariátní zobrazení metriky Shape. Data představují 5% vzorek
      prediktorových kombinací v daném rastru, na osách grafu jsou uvedeny hodnoty prediktorů, barevná škála velikost
      metriky Shape, kdy tmavší barva představuje kombinace vzdálenější
      od trénovacích dat než barva světlejší. Zaznačena jsou také
      pozorování druhu.
    ],
  )
}

=== 8k BP, HCO

#figure(
  esm_shape_extrapol_all(
    "PP",
    200,
    period: "060"
  ),
  caption: [Projekce ESM (vlevo) & projekce metriky Shape (vpravo).]
)

==== Bivariátní grafy Shape

#{
  show figure: set block(breakable: true)

  figure(
    shape-plots-grid(
      "PP",
      200,
      period: "060",
      extrapolation: "extrapol",
      colinearity: "all_selected",
      columns: 6,
    ),
    caption: [
      Bivariátní zobrazení metriky Shape. Data představují 5% vzorek
      prediktorových kombinací v daném rastru, na osách grafu jsou uvedeny hodnoty prediktorů, barevná škála velikost
      metriky Shape, kdy tmavší barva představuje kombinace vzdálenější
      od trénovacích dat než barva světlejší. Zaznačena jsou také
      pozorování druhu.
    ],
  )
}

=== 2041 ‒ 2070
==== SSP1.26
===== Průměr predikcí

#figure(
  esm_shape_extrapol_all(
    "PP",
    200,
    period: "2041-2070",
    ssp: 126,
    statistic: "mean"
  ),
  caption: [Průměrná predikovaná vhodnost stanoviště napříč modely globální cirkulace pro daný scénář SSP (vlevo) a průměrná hodnota metriky Shape napříč týmiž modely (vpravo).]
)

===== Směrodatná odchylka predikcí

#figure(
  esm_shape_extrapol_all(
    "PP",
    200,
    period: "2041-2070",
    ssp: 126,
    statistic: "sd"
  ),
  caption: [Směrodatná odchylka predikované vhodnosti stanoviště napříč modely globální cirkulace pro daný scénář SSP (vlevo) a směrodatná odchylka metriky Shape napříč týmiž modely (vpravo).]
)

==== SSP3.70
===== Průměr predikcí

#figure(
  esm_shape_extrapol_all(
    "PP",
    200,
    period: "2041-2070",
    ssp: 370,
    statistic: "mean"
  ),
  caption: [Průměrná predikovaná vhodnost stanoviště napříč modely globální cirkulace pro daný scénář SSP (vlevo) a průměrná hodnota metriky Shape napříč týmiž modely (vpravo).]
)

===== Směrodatná odchylka predikcí

#figure(
  esm_shape_extrapol_all(
    "PP",
    200,
    period: "2041-2070",
    ssp: 370,
    statistic: "sd"
  ),
  caption: [Směrodatná odchylka predikované vhodnosti stanoviště napříč modely globální cirkulace pro daný scénář SSP (vlevo) a směrodatná odchylka metriky Shape napříč týmiž modely (vpravo).]
)

==== SSP5.85
===== Průměr predikcí

#figure(
  esm_shape_extrapol_all(
    "PP",
    200,
    period: "2041-2070",
    ssp: 585,
    statistic: "mean"
  ),
  caption: [Průměrná predikovaná vhodnost stanoviště napříč modely globální cirkulace pro daný scénář SSP (vlevo) a průměrná hodnota metriky Shape napříč týmiž modely (vpravo).]
)

===== Směrodatná odchylka predikcí

#figure(
  esm_shape_extrapol_all(
    "PP",
    200,
    period: "2041-2070",
    ssp: 585,
    statistic: "sd"
  ),
  caption: [Směrodatná odchylka predikované vhodnosti stanoviště napříč modely globální cirkulace pro daný scénář SSP (vlevo) a směrodatná odchylka metriky Shape napříč týmiž modely (vpravo).]
)

=== 2071 ‒ 2100
==== SSP1.26
===== Průměr predikcí

#figure(
  esm_shape_extrapol_all(
    "PP",
    200,
    period: "2071-2100",
    ssp: 126,
    statistic: "mean"
  ),
  caption: [Průměrná predikovaná vhodnost stanoviště napříč modely globální cirkulace pro daný scénář SSP (vlevo) a průměrná hodnota metriky Shape napříč týmiž modely (vpravo).]
)

===== Směrodatná odchylka predikcí

#figure(
  esm_shape_extrapol_all(
    "PP",
    200,
    period: "2071-2100",
    ssp: 126,
    statistic: "sd"
  ),
  caption: [Směrodatná odchylka predikované vhodnosti stanoviště napříč modely globální cirkulace pro daný scénář SSP (vlevo) a směrodatná odchylka metriky Shape napříč týmiž modely (vpravo).]
)

==== SSP3.70
===== Průměr predikcí

#figure(
  esm_shape_extrapol_all(
    "PP",
    200,
    period: "2071-2100",
    ssp: 370,
    statistic: "mean"
  ),
  caption: [Průměrná predikovaná vhodnost stanoviště napříč modely globální cirkulace pro daný scénář SSP (vlevo) a průměrná hodnota metriky Shape napříč týmiž modely (vpravo).]
)

===== Směrodatná odchylka predikcí

#figure(
  esm_shape_extrapol_all(
    "PP",
    200,
    period: "2071-2100",
    ssp: 370,
    statistic: "sd"
  ),
  caption: [Směrodatná odchylka predikované vhodnosti stanoviště napříč modely globální cirkulace pro daný scénář SSP (vlevo) a směrodatná odchylka metriky Shape napříč týmiž modely (vpravo).]
)

==== SSP5.85
===== Průměr predikcí

#figure(
  esm_shape_extrapol_all(
    "PP",
    200,
    period: "2071-2100",
    ssp: 585,
    statistic: "mean"
  ),
  caption: [Průměrná predikovaná vhodnost stanoviště napříč modely globální cirkulace pro daný scénář SSP (vlevo) a průměrná hodnota metriky Shape napříč týmiž modely (vpravo).]
)

===== Směrodatná odchylka predikcí

#figure(
  esm_shape_extrapol_all(
    "PP",
    200,
    period: "2071-2100",
    ssp: 585,
    statistic: "sd"
  ),
  caption: [Směrodatná odchylka predikované vhodnosti stanoviště napříč modely globální cirkulace pro daný scénář SSP (vlevo) a směrodatná odchylka metriky Shape napříč týmiž modely (vpravo).]
)

#set page(flipped: true)

== _Phyteum pseudorbiculare_, 100 m

#figure(
  esm_shape_extrapol_all(
  "PP",
  100,
  period: "recent",
  ssp: none
  ),
  caption: [Projekce ESM (vlevo) & projekce metriky Shape (vpravo).]
)

#set page(flipped: false)

==== Křivky odpovědí

#figure(
  response-curves-grid(
    "PP",
    100,
    "complex",
    extrapolation: "extrapol",
    colinearity: "all_selected"
  ),
  caption: [Křivky odpovědí druhu: vyjadřují změnu průměrné pravděpodobnosti výskytu druhu na gradientu daného prediktoru (plná linka). Sestaveny byly z ponechaných bivariátních modelů (tenké linky) obsahujících příslušný prediktor, kdy jejich predikce byly nejprve váženě agregovány v rámci jednotlivých algoritmů a následně mezi algoritmy podle jejich vah v rámci finálního ESM.]
)

==== Bivariátní grafy Shape

#{
  show figure: set block(breakable: true)

  figure(
    shape-plots-grid(
      "PP",
      100,
      period: "recent",
      extrapolation: "extrapol",
      colinearity: "all_selected",
      columns: 6,
    ),
    caption: [
      Bivariátní zobrazení metriky Shape. Data představují 5% vzorek
      prediktorových kombinací v daném rastru, na osách grafu jsou uvedeny hodnoty prediktorů, barevná škála velikost
      metriky Shape, kdy tmavší barva představuje kombinace vzdálenější
      od trénovacích dat než barva světlejší. Zaznačena jsou také
      pozorování druhu.
    ],
  )
}

#pagebreak()
= Modely na všech prediktorech

#figure(
    grid(
    columns: 2,
    row-gutter: 10pt,

    image("outputs/ESM/recent_noextrapol_weights_all_selected/PP/1000/OOF_prediction.png"),
    image("outputs/ESM/recent_noextrapol_weights_all_selected/PP/500/OOF_prediction.png"),
    image("outputs/ESM/recent_noextrapol_weights_all_selected/PP/200/OOF_prediction.png"),
    image("outputs/ESM/recent_noextrapol_weights_all_selected/PP/100/OOF_prediction.png")
  ),
  caption: [Houslové grafy znázorňují rozložení predikcí vhodnosti stanoviště pro pozorované absence a presence druhu v daném prostorovém rozlišení. Jednotlivé body odpovídají predikcím modelu pro konkrétní pozorování, červeně je naznačen median a v popisku celkove Somersovo D celého modelu.]
)

#figure(
  image("outputs/summary/figures/predictor_contributions/recent_noextrapol_weights_all_selected/PP/heatmap.png"),
  caption: [Relativní příspěvek jednotlivých prediktorů do finálního ESM. Jednotlivé příspěvky byly odvozeny z efektivních vah ponechaných bivariátních modelů ve finálním ensemble, přičemž váha každého bivariátního modelu byla rovným dílem rozdělena mezi oba prediktory.]
)

#pagebreak()
#set page(flipped: true)

== _Phyteum pseudorbiculare_, 1000 m

#figure(
    esm_shape_noextrapol(
        "PP",
        1000,
        colin: "all_selected"
    ),
    caption: [Projekce ESM (vlevo) & projekce metriky Shape (vpravo).]
)

#pagebreak()
#set page(flipped: false)

==== Křivky odpovědí

#figure(
  response-curves-grid(
    "PP",
    1000,
    "complex",
    extrapolation: "noextrapol",
    colinearity: "all_selected"
  ),
  caption: [Křivky odpovědí druhu: vyjadřují změnu průměrné pravděpodobnosti výskytu druhu na gradientu daného prediktoru (plná linka). Sestaveny byly z ponechaných bivariátních modelů (tenké linky) obsahujících příslušný prediktor, kdy jejich predikce byly nejprve váženě agregovány v rámci jednotlivých algoritmů a následně mezi algoritmy podle jejich vah v rámci finálního ESM.]
)

==== Bivariátní grafy Shape

#{
  show figure: set block(breakable: true)

  figure(
    shape-plots-grid(
      "PP",
      1000,
      period: "recent",
      extrapolation: "noextrapol",
      colinearity: "all_selected",
      columns: 6,
    ),
    caption: [
      Bivariátní zobrazení metriky Shape. Data představují 5% vzorek
      prediktorových kombinací v daném rastru, na osách grafu jsou uvedeny hodnoty prediktorů, barevná škála velikost
      metriky Shape, kdy tmavší barva představuje kombinace vzdálenější
      od trénovacích dat než barva světlejší. Zaznačena jsou také
      pozorování druhu.
    ],
  )
}

#pagebreak()
#set page(flipped: true)

== _Phyteum pseudorbiculare_, 500 m

#figure(
    esm_shape_noextrapol(
        "PP",
        500,
        colin: "all_selected"
    ),
    caption: [Projekce ESM (vlevo) & projekce metriky Shape (vpravo).]
)

#pagebreak()
#set page(flipped: false)

==== Křivky odpovědí

#figure(
  response-curves-grid(
    "PP",
    500,
    "complex",
    extrapolation: "noextrapol",
    colinearity: "all_selected"
  ),
  caption: [Křivky odpovědí druhu: vyjadřují změnu průměrné pravděpodobnosti výskytu druhu na gradientu daného prediktoru (plná linka). Sestaveny byly z ponechaných bivariátních modelů (tenké linky) obsahujících příslušný prediktor, kdy jejich predikce byly nejprve váženě agregovány v rámci jednotlivých algoritmů a následně mezi algoritmy podle jejich vah v rámci finálního ESM.]
)

==== Bivariátní grafy Shape

#{
  show figure: set block(breakable: true)

  figure(
    shape-plots-grid(
      "PP",
      500,
      period: "recent",
      extrapolation: "noextrapol",
      colinearity: "all_selected",
      columns: 6,
    ),
    caption: [
      Bivariátní zobrazení metriky Shape. Data představují 5% vzorek
      prediktorových kombinací v daném rastru, na osách grafu jsou uvedeny hodnoty prediktorů, barevná škála velikost
      metriky Shape, kdy tmavší barva představuje kombinace vzdálenější
      od trénovacích dat než barva světlejší. Zaznačena jsou také
      pozorování druhu.
    ],
  )
}

#pagebreak()
#set page(flipped: true)

== _Phyteum pseudorbiculare_, 200 m

#figure(
    esm_shape_noextrapol(
        "PP",
        200,
        colin: "all_selected"
    ),
    caption: [Projekce ESM (vlevo) & projekce metriky Shape (vpravo).]
)

#pagebreak()
#set page(flipped: false)

==== Křivky odpovědí

#figure(
  response-curves-grid(
    "PP",
    200,
    "complex",
    extrapolation: "noextrapol",
    colinearity: "all_selected"
  ),
  caption: [Křivky odpovědí druhu: vyjadřují změnu průměrné pravděpodobnosti výskytu druhu na gradientu daného prediktoru (plná linka). Sestaveny byly z ponechaných bivariátních modelů (tenké linky) obsahujících příslušný prediktor, kdy jejich predikce byly nejprve váženě agregovány v rámci jednotlivých algoritmů a následně mezi algoritmy podle jejich vah v rámci finálního ESM.]
)

==== Bivariátní grafy Shape

#{
  show figure: set block(breakable: true)

  figure(
    shape-plots-grid(
      "PP",
      200,
      period: "recent",
      extrapolation: "noextrapol",
      colinearity: "all_selected",
      columns: 6,
    ),
    caption: [
      Bivariátní zobrazení metriky Shape. Data představují 5% vzorek
      prediktorových kombinací v daném rastru, na osách grafu jsou uvedeny hodnoty prediktorů, barevná škála velikost
      metriky Shape, kdy tmavší barva představuje kombinace vzdálenější
      od trénovacích dat než barva světlejší. Zaznačena jsou také
      pozorování druhu.
    ],
  )
}

#pagebreak()
#set page(flipped: true)

== _Phyteum pseudorbiculare_, 100 m

#figure(
    esm_shape_noextrapol(
        "PP",
        100,
        colin: "all_selected"
    ),
    caption: [Projekce ESM (vlevo) & projekce metriky Shape (vpravo).]
)

#pagebreak()
#set page(flipped: false)

==== Křivky odpovědí

#figure(
  response-curves-grid(
    "PP",
    100,
    "complex",
    extrapolation: "noextrapol",
    colinearity: "all_selected"
  ),
  caption: [Křivky odpovědí druhu: vyjadřují změnu průměrné pravděpodobnosti výskytu druhu na gradientu daného prediktoru (plná linka). Sestaveny byly z ponechaných bivariátních modelů (tenké linky) obsahujících příslušný prediktor, kdy jejich predikce byly nejprve váženě agregovány v rámci jednotlivých algoritmů a následně mezi algoritmy podle jejich vah v rámci finálního ESM.]
)

==== Bivariátní grafy Shape

#{
  show figure: set block(breakable: true)

  figure(
    shape-plots-grid(
      "PP",
      100,
      period: "recent",
      extrapolation: "noextrapol",
      colinearity: "all_selected",
      columns: 6,
    ),
    caption: [
      Bivariátní zobrazení metriky Shape. Data představují 5% vzorek
      prediktorových kombinací v daném rastru, na osách grafu jsou uvedeny hodnoty prediktorů, barevná škála velikost
      metriky Shape, kdy tmavší barva představuje kombinace vzdálenější
      od trénovacích dat než barva světlejší. Zaznačena jsou také
      pozorování druhu.
    ],
  )
}

#pagebreak()
#set page(flipped: false)

= Modely na společných prediktorech

#figure(
    grid(
    columns: 2,
    row-gutter: 10pt,

    image("outputs/ESM/recent_noextrapol_weights_common/PP/1000/OOF_prediction.png"),
    image("outputs/ESM/recent_noextrapol_weights_common/PP/500/OOF_prediction.png"),
    image("outputs/ESM/recent_noextrapol_weights_common/PP/200/OOF_prediction.png"),
    image("outputs/ESM/recent_noextrapol_weights_common/PP/100/OOF_prediction.png")
  ),
  caption: [Houslové grafy znázorňují rozložení predikcí vhodnosti stanoviště pro pozorované absence a presence druhu v daném prostorovém rozlišení. Jednotlivé body odpovídají predikcím modelu pro konkrétní pozorování, červeně je naznačen median a v popisku celkove Somersovo D celého modelu.]
)

#figure(
  image("outputs/ESM/recent_noextrapol_weights_common/PP/OOF_prediction_common_grains.png"),
  caption: [Krabicové grafy pro porovnání rozložení predikovaných hodnot mezi jednotlivými úrovněmi prostorového rozlišení. Predikce pro absence a presence jsou zobrazeny odděleně, přičemž barva reprezentuje dané prostorové rozlišení.]
)

#figure(
  image("outputs/summary/figures/predictor_contributions/recent_noextrapol_weights_common/PP/heatmap.png"),
  caption: [Relativní příspěvek jednotlivých prediktorů do finálního ESM. Jednotlivé příspěvky byly odvozeny z efektivních vah ponechaných bivariátních modelů ve finálním ensemble, přičemž váha každého bivariátního modelu byla rovným dílem rozdělena mezi oba prediktory.]
)

#pagebreak()
#set page(flipped: true)

== _Phyteum pseudorbiculare_, 1000 m

#figure(
    esm_shape_noextrapol(
        "PP",
        1000,
        colin: "common"
    ),
    caption: [Projekce ESM (vlevo) & projekce metriky Shape (vpravo).]
)

#pagebreak()
#set page(flipped: false)

==== Křivky odpovědí

#figure(
  response-curves-grid(
    "PP",
    1000,
    "complex",
    extrapolation: "noextrapol",
    colinearity: "common"
  ),
  caption: [Křivky odpovědí druhu: vyjadřují změnu průměrné pravděpodobnosti výskytu druhu na gradientu daného prediktoru (plná linka). Sestaveny byly z ponechaných bivariátních modelů (tenké linky) obsahujících příslušný prediktor, kdy jejich predikce byly nejprve váženě agregovány v rámci jednotlivých algoritmů a následně mezi algoritmy podle jejich vah v rámci finálního ESM.]
)

==== Bivariátní grafy Shape

#{
  show figure: set block(breakable: true)

  figure(
    shape-plots-grid(
      "PP",
      1000,
      period: "recent",
      extrapolation: "noextrapol",
      colinearity: "common",
      columns: 6,
    ),
    caption: [
      Bivariátní zobrazení metriky Shape. Data představují 5% vzorek
      prediktorových kombinací v daném rastru, na osách grafu jsou uvedeny hodnoty prediktorů, barevná škála velikost
      metriky Shape, kdy tmavší barva představuje kombinace vzdálenější
      od trénovacích dat než barva světlejší. Zaznačena jsou také
      pozorování druhu.
    ],
  )
}

#pagebreak()
#set page(flipped: true)

== _Phyteum pseudorbiculare_, 500 m

#figure(
    esm_shape_noextrapol(
        "PP",
        500,
        colin: "common"
    ),
    caption: [Projekce ESM (vlevo) & projekce metriky Shape (vpravo).]
)

#pagebreak()
#set page(flipped: false)

==== Křivky odpovědí

#figure(
  response-curves-grid(
    "PP",
    500,
    "complex",
    extrapolation: "noextrapol",
    colinearity: "common"
  ),
  caption: [Křivky odpovědí druhu: vyjadřují změnu průměrné pravděpodobnosti výskytu druhu na gradientu daného prediktoru (plná linka). Sestaveny byly z ponechaných bivariátních modelů (tenké linky) obsahujících příslušný prediktor, kdy jejich predikce byly nejprve váženě agregovány v rámci jednotlivých algoritmů a následně mezi algoritmy podle jejich vah v rámci finálního ESM.]
)

==== Bivariátní grafy Shape

#{
  show figure: set block(breakable: true)

  figure(
    shape-plots-grid(
      "PP",
      500,
      period: "recent",
      extrapolation: "noextrapol",
      colinearity: "common",
      columns: 6,
    ),
    caption: [
      Bivariátní zobrazení metriky Shape. Data představují 5% vzorek
      prediktorových kombinací v daném rastru, na osách grafu jsou uvedeny hodnoty prediktorů, barevná škála velikost
      metriky Shape, kdy tmavší barva představuje kombinace vzdálenější
      od trénovacích dat než barva světlejší. Zaznačena jsou také
      pozorování druhu.
    ],
  )
}

#pagebreak()
#set page(flipped: true)

== _Phyteum pseudorbiculare_, 200 m

#figure(
    esm_shape_noextrapol(
        "PP",
        200,
        colin: "common"
    ),
    caption: [Projekce ESM (vlevo) & projekce metriky Shape (vpravo).]
)

#pagebreak()
#set page(flipped: false)

==== Křivky odpovědí

#figure(
  response-curves-grid(
    "PP",
    200,
    "complex",
    extrapolation: "noextrapol",
    colinearity: "common"
  ),
  caption: [Křivky odpovědí druhu: vyjadřují změnu průměrné pravděpodobnosti výskytu druhu na gradientu daného prediktoru (plná linka). Sestaveny byly z ponechaných bivariátních modelů (tenké linky) obsahujících příslušný prediktor, kdy jejich predikce byly nejprve váženě agregovány v rámci jednotlivých algoritmů a následně mezi algoritmy podle jejich vah v rámci finálního ESM.]
)

==== Bivariátní grafy Shape

#{
  show figure: set block(breakable: true)

  figure(
    shape-plots-grid(
      "PP",
      200,
      period: "recent",
      extrapolation: "noextrapol",
      colinearity: "common",
      columns: 6,
    ),
    caption: [
      Bivariátní zobrazení metriky Shape. Data představují 5% vzorek
      prediktorových kombinací v daném rastru, na osách grafu jsou uvedeny hodnoty prediktorů, barevná škála velikost
      metriky Shape, kdy tmavší barva představuje kombinace vzdálenější
      od trénovacích dat než barva světlejší. Zaznačena jsou také
      pozorování druhu.
    ],
  )
}

#pagebreak()
#set page(flipped: true)

== _Phyteum pseudorbiculare_, 100 m

#figure(
    esm_shape_noextrapol(
        "PP",
        100,
        colin: "common"
    ),
    caption: [Projekce ESM (vlevo) & projekce metriky Shape (vpravo).]
)

#pagebreak()
#set page(flipped: false)

==== Křivky odpovědí

#figure(
  response-curves-grid(
    "PP",
    100,
    "complex",
    extrapolation: "noextrapol",
    colinearity: "common"
  ),
  caption: [Křivky odpovědí druhu: vyjadřují změnu průměrné pravděpodobnosti výskytu druhu na gradientu daného prediktoru (plná linka). Sestaveny byly z ponechaných bivariátních modelů (tenké linky) obsahujících příslušný prediktor, kdy jejich predikce byly nejprve váženě agregovány v rámci jednotlivých algoritmů a následně mezi algoritmy podle jejich vah v rámci finálního ESM.]
)

==== Bivariátní grafy Shape

#{
  show figure: set block(breakable: true)

  figure(
    shape-plots-grid(
      "PP",
      100,
      period: "recent",
      extrapolation: "noextrapol",
      colinearity: "common",
      columns: 6,
    ),
    caption: [
      Bivariátní zobrazení metriky Shape. Data představují 5% vzorek
      prediktorových kombinací v daném rastru, na osách grafu jsou uvedeny hodnoty prediktorů, barevná škála velikost
      metriky Shape, kdy tmavší barva představuje kombinace vzdálenější
      od trénovacích dat než barva světlejší. Zaznačena jsou také
      pozorování druhu.
    ],
  )
}
