#let pred_clim = [
  #figure(
  table(
    //columns: (0.8fr, 1.2fr, 4.5fr),
    columns: (10%, 20%, 70%),
    inset: 5pt,
    align: (left + horizon, center + horizon, left),
    stroke: none,

    table.hline(stroke: 1.2pt),

    table.header(
      [*Kód*],
      [*Jednotky*],
      [*Význam*],
    ),

    table.hline(stroke: 0.5pt),

    [bio01], [°C], [Průměrná roční teplota vypočítaná jako průměr průměrných měsíčních teplot za celý rok.],
    table.hline(start: 2, end: 3, stroke: 0.25pt),
    [bio02], [°C], [Průměrný denní teplotní rozsah vypočítaný jako průměr měsíčních rozdílů mezi maximální a minimální denní teplotou (_tasmax − tasmin_).],
    table.hline(start: 2, end: 3, stroke: 0.25pt),
    [bio03], [-], [Isotermalita: 100 × bio02 / bio07; porovnává denní teplotní variabilitu s ročním teplotním rozsahem.],
    table.hline(start: 2, end: 3, stroke: 0.25pt),
    [bio04], [°C/100], [Teplotní sezonalita vyjádřená směrodatnou odchylkou průměrných měsíčních teplot.],
    table.hline(start: 2, end: 3, stroke: 0.25pt),
    [bio05], [°C], [Nejvyšší měsíční průměr denních maximálních teplot (_tasmax_) v průběhu roku.],
    table.hline(start: 2, end: 3, stroke: 0.25pt),
    [bio06], [°C], [Nejnižší měsíční průměr denních minimálních teplot (_tasmin_) v průběhu roku.],
    table.hline(start: 2, end: 3, stroke: 0.25pt),
    [bio07], [°C], [Roční teplotní rozsah vypočítaný jako bio05 − bio06; vyjadřuje rozdíl mezi nejteplejším a nejchladnějším měsícem.],
    table.hline(start: 2, end: 3, stroke: 0.25pt),
    [bio08], [°C], [Průměrná měsíční teplota během nejvlhčího kvartálu.],
    table.hline(start: 2, end: 3, stroke: 0.25pt),
    [bio09], [°C], [Průměrná měsíční teplota během nejsuššího kvartálu.],
    table.hline(start: 2, end: 3, stroke: 0.25pt),
    [bio10], [°C], [Průměrná měsíční teplota během nejteplejšího kvartálu.],
    table.hline(start: 2, end: 3, stroke: 0.25pt),
    [bio11], [°C], [Průměrná měsíční teplota během nejchladnějšího kvartálu.],

    table.hline(stroke: 0.75pt),

    [bio12], [$"kg" m^(-2) "rok"^(-1)$], [Součet měsíčních úhrnů srážek za celý rok.],
    table.hline(start: 2, end: 3, stroke: 0.25pt),
    [bio13], [$"kg" m^(-2) "měsíc"^(-1)$], [Nejvyšší měsíční úhrn srážek.],
    table.hline(start: 2, end: 3, stroke: 0.25pt),
    [bio14], [$"kg" m^(-2) "měsíc"^(-1)$], [Nejnižší měsíční úhrn srážek.],
    table.hline(start: 2, end: 3, stroke: 0.25pt),
    [bio15], [$"kg" m^(-2)$], [Koeficient variability měsíčních úhrnů srážek vypočítaný jako 100 × směrodatná odchylka / průměr.],
    table.hline(start: 2, end: 3, stroke: 0.25pt),
    [bio16], [$"kg" m^(-2) "měsíc"^(-1)$], [Průměrný měsíční úhrn srážek během nejvlhčího kvartálu.],
    table.hline(start: 2, end: 3, stroke: 0.25pt),
    [bio17], [$"kg" m^(-2) "měsíc"^(-1)$], [Průměrný měsíční úhrn srážek během nejsuššího kvartálu.],
    table.hline(start: 2, end: 3, stroke: 0.25pt),
    [bio18], [$"kg" m^(-2) "měsíc"^(-1)$], [Průměrný měsíční úhrn srážek během nejteplejšího kvartálu.],
    table.hline(start: 2, end: 3, stroke: 0.25pt),
    [bio19], [$"kg" m^(-2) "měsíc"^(-1)$], [Průměrný měsíční úhrn srážek během nejchladnějšího kvartálu.],

    table.hline(stroke: 0.75pt),

    [scd], [dny], [Počet dní v roce, kdy je na povrchu přítomna sněhová pokrývka.],

    table.hline(stroke: 1.2pt),
  ),
  caption: [Přehled použitých bioklimatických prediktorů datasetů CHELSA-BIOCLIM a CHELSA-TraCE21k-bioclim.]
) <tab:pred_clim>
]