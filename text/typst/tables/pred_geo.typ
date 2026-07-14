#let pred_geo = [
  #figure(
  table(
    columns: (1fr, 1fr),
    inset: 4pt,
    align: left,
    stroke: none,
    
    table.hline(stroke: 1.2pt),

    table.header(
      [*Kategorie použité v této práci*
      #linebreak()
      podle #cite(<chauvier_2021>, form: "prose")],
      [*Původní kategorie GLIM*
      #linebreak()
      podle #cite(<GLIM>, form: "prose")],
    ),

    table.hline(stroke: 0.5pt),
    [Calcareous], [Carbonate sedimentary rocks],
    [_karbonáty_], [Basic plutonic rocks],
    [], [Basic volcanic rocks],

    table.hline(stroke: 0.5pt),
    [Siliceous], [Siliciclastic sedimentary rocks],
    [_silikáty_], [Metamorphic rocks],
    [], [Acid plutonic rocks],
    [], [Acid volcanic rocks],

    table.hline(stroke: 0.5pt),
    [Mixed], [Unconsolidated sediments],
    [_smíšené_], [Mixed sedimentary rocks],
    [], [Pyroclastics],
    [], [Evaporites],
    [], [Intermediate plutonic rocks],
    [], [Intermediate volcanic rocks],

    table.hline(stroke: 1.2pt),
  ),
  caption: [
    Přehled reklasifikace původních kategorií GLiM do tří základních typů geologického podloží podle práce #cite(<chauvier_2021>, form: "prose").]
) <tab:pred_geo>
]