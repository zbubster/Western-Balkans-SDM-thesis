// diplomka je věc
// 
// 
// zakladni udaje

#let author = "Jakub Rataj"
#let title_cz = "nazev"
#let title_en = "nazev AJ"

#let thesis_type = "Diplomová práce"
#let supervisor = "Mgr. Jan Smyčka PhD."
#let place = "Praha"
#let year = "2026"
#let submission_date = "[[[datum dokonceniiio]]]"

#let logo_path = "obj/pic/logo_uk.png"

// # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
// main settings for whole documnet

#set document(title: title_cz, author: author)
#set page(
  paper: "a4",
  margin: (left: 30mm, right: 25mm, top: 25mm, bottom: 25mm),
  numbering: none,
)
#set text(font: "Libertinus Serif", size: 12pt, lang: "cs")
#set par(justify: true, leading: 0.65em)

// chapter numbering
#set heading(numbering: "1.")

// # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
// helpers

// chapter pagebreak helper
#let chapter(title) = {
  pagebreak()
  heading(level: 1)[#title]
}

// # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
// main page

#align(center)[
  #text(size: 16pt)[*Univerzita Karlova*]
  #v(1.5mm)
  #text(size: 14pt)[*Přírodovědecká fakulta*]
]

#v(9mm)

#align(center)[
  Studijní program:
  #v(1.5mm)
  Botanika ‒ Geobotanika
]

#v(10mm)

#align(center)[#image(logo_path, width: 64mm)]

#v(8mm)

#align(center)[
  *Bc. Jakub Rataj*
]

#v(5mm)

#align(center)[
  [[[[nazev]]]]
  #v(1mm)
  [[[[nazev_AJ]]]]
]

#v(7mm)

#align(center)[
  Typ závěrečné práce:
  #v(1.5mm)
  Diplomová práce
]

#v(5mm)

#align(center)[
  Vedoucí práce/Školitel:
  #v(1.5mm)
  #supervisor
]

#v(1fr)

#align(center)[Praha, 2026]

#v(0.3fr)

// # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
// prohlaseni, podekovani

#pagebreak()
#heading(level: 1, numbering: none, outlined: false)[Prohlášení]
[[[prohlaseni]]]
//Prohlašuji, že jsem tuto diplomovou práci vypracoval samostatně, že jsem řádně citoval všechny použité prameny a literaturu a že práce nebyla využita k získání jiného nebo stejného titulu.

#v(16mm)

#grid(
  columns: (1fr, 1fr),
  gutter: 20mm,
  [V Praze dne #submission_date],
  [#align(right)[
    ........................................
    #v(1mm)
    Jakub Rataj
  ]],
)

#v(20mm)

#heading(level: 1, numbering: none, outlined: false)[Poděkování]
[[[podekovani]]]


// # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
// abstrakty

#pagebreak()
#heading(level: 1, numbering: none, outlined: false)[Abstrakt]
[[[abstrakt]]]

#v(4mm)
*Klíčová slova:* [[[klíčová slova]]]

#v(12mm)

#heading(level: 1, numbering: none, outlined: false)[Abstract]
[[[abstract]]]

#v(4mm)
*Keywords:* [[[key words]]]

// # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
// přehled použitých zkratek
#pagebreak()
#heading(level: 1, numbering: none, outlined: false)[Přehled použitých zkratek]

LGM ‒ last glacial maximum, poslední glaciální maximum

HCO ‒ holocene climatic optimum, holocénní klimatické optimum

// # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
// obsah

#pagebreak()
#outline(title: [Obsah], depth: 10)

// # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
// úvod

#pagebreak()
#set page(numbering: "1")
#counter(page).update(1)
#set par(justify: true, leading: 0.65em, first-line-indent: 0.75cm)

= Úvod
== x
== Cíle práce

// # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
// metodika
#pagebreak()
= Metodika
== Prostorové vymezení práce
== Druhy Rostlin
== Vstupní data
=== Data o výskytech druhů
=== Modelovací prediktory
==== CHELSA

bio01-bio19, scd, trace21k

==== Copernicus DEM
==== GLIM
==== WoSIS

bez využití v temporálních projekcích

==== Landcover

bez využití v temporálních projekcích

== Příprava dat
=== Modelovací měřítko GRAIN
=== Prostorová autokorelace výskytových dat CV folds
=== Kolinearita prediktorů
=== Datové sady pro modelování

druh, grain, colinearity set, purpose

== Modelování vhodnosti stanoviště

koncep ESM, fitování modelu, algoritmy

== Projekce
=== Projekce v prostoru
=== Projekce v prostoru a čase

Vypočítané modely byly promítnuty do dvou historických a jednoho budoucího časového řezu.
Jako reprezentativní body v minulosti jsem zvolil poslední glaciální maximum (LGM, 21k BP)
a holocénní klimatické optimum (HCO, 8k BP). Jelikož se v obou případech jedná o sporné vymezení
konkrétních událostí (např. @davis2003 ukazují, že HCO se v jižní Evropě neprojevovalo tak silně jako v Evropě severní),
je nutné vnímat zvolené časové řezy jako částečně arbitrární rozhodnutí.

== Metoda Shape jako odhad projekční extrpolace v prostoru

// # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
// výsledky
#pagebreak()
= Výsledky

// # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
// diskuse
#pagebreak()
= Diskuse

// # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
// závěr
#pagebreak()
= Závěr

// # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
// literatura
#pagebreak()
= Literatura

#bibliography(
  "lit/literatura.bib",
  style: "copernicus")