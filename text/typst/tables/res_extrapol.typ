#let extrapol_result_table = [
  #figure(
  text(size: 8pt)[
    #table(
      //columns: ( 1.45fr,0.65fr, 0.65fr, 4.2fr, 0.95fr, 0.95fr, 0.85fr ),
      columns: ( 14%, 9%, 8%, 45%, 6%, 8%, 10% ),
      align: (left + horizon, center + horizon, center + horizon, left + horizon, center + horizon, center + horizon, center + horizon),
      inset: (3pt),
      //stroke: 0.35pt + luma(180),
      stroke: none,
      //fill: (x, y) => if y == 0 { luma(235) } else { none },

      table.header(
        [*Druh*],
        [*Rozlišení*],
        [*$P_"pred"$*],
        [*Prediktory*],
        [*$M_"biv"$*],
        [*$M_"TRUE"$*],
        [*Somersovo $D$*],
      ),

      table.hline(stroke: 1.3pt),

      table.cell(
        rowspan: 4,
        align: left + horizon,
      )[_Gentiana \ dinarica_],
      [1000],
      [10],
      [#text("dem_sd, eastness, bedrock, northness, slope, TPI, bio04, bio10, bio18, bio19")],
      [270],
      [189],
      [0,671],

      table.hline(start: 1, end: 7, stroke: 0.25pt),

      [500],
      [9],
      [#text("dem_sd, eastness, bedrock, northness, TPI, bio04, bio10, bio18, bio19")],
      [216],
      [173],
      [0,721],

      table.hline(start: 1, end: 7, stroke: 0.25pt),

      [200],
      [9],
      [#text("dem_sd, eastness, bedrock, northness, TPI, bio04, bio10, bio18, bio19")],
      [216],
      [151],
      [0,453],

      table.hline(start: 1, end: 7, stroke: 0.25pt),

      [100],
      [9],
      [#text("dem_sd, eastness, bedrock, northness, TPI, bio04, bio10, bio18, bio19")],
      [216],
      [173],
      [0,616],

      table.hline(stroke: 0.8pt),

      table.cell(
        rowspan: 4,
        align: left + horizon,
      )[_Gentiana \ tergestina_],
      [1000],
      [10],
      [#text("dem_sd, eastness, bedrock, northness, slope, TPI, bio04, bio10, bio18, bio19")],
      [270],
      [208],
      [0,390],

      table.hline(start: 1, end: 7, stroke: 0.25pt),

      [500],
      [9],
      [#text("dem_sd, eastness, bedrock, northness, TPI, bio04, bio10, bio18, bio19")],
      [216],
      [160],
      [0,437],

      table.hline(start: 1, end: 7, stroke: 0.25pt),

      [200],
      [9],
      [#text("dem_sd, eastness, bedrock, northness, TPI, bio04, bio10, bio18, bio19")],
      [216],
      [164],
      [0,480],

      table.hline(start: 1, end: 7, stroke: 0.25pt),

      [100],
      [9],
      [#text("dem_sd, eastness, bedrock, northness, TPI, bio04, bio10, bio18, bio19")],
      [216],
      [163],
      [0,404],

      table.hline(stroke: 0.8pt),

      table.cell(
        rowspan: 4,
        align: left + horizon,
      )[_Primula \ kitaibeliana_],
      [1000],
      [11],
      [#text("dem_sd, eastness, bedrock, northness, slope, TPI, TRI, bio04, bio10, bio18, bio19")],
      [330],
      [250],
      [−0,137],

      table.hline(start: 1, end: 7, stroke: 0.25pt),

      [500],
      [10],
      [#text("dem_sd, eastness, bedrock, northness, slope, TPI, bio04, bio10, bio18, bio19")],
      [270],
      [212],
      [0,697],

      table.hline(start: 1, end: 7, stroke: 0.25pt),

      [200],
      [9],
      [#text("dem_sd, eastness, bedrock, northness, TPI, bio04, bio10, bio18, bio19")],
      [216],
      [172],
      [0,839],

      table.hline(start: 1, end: 7, stroke: 0.25pt),

      [100],
      [9],
      [#text("dem_sd, eastness, bedrock, northness, TPI, bio04, bio10, bio18, bio19")],
      [216],
      [174],
      [0,787],

      table.hline(stroke: 0.8pt),

      table.cell(
        rowspan: 4,
        align: left + horizon,
      )[_Phyteuma \ orbiculare_],
      [1000],
      [10],
      [#text("dem_sd, eastness, bedrock, northness, slope, TPI, bio04, bio10, bio18, bio19")],
      [270],
      [202],
      [0,778],

      table.hline(start: 1, end: 7, stroke: 0.25pt),

      [500],
      [9],
      [#text("dem_sd, eastness, bedrock, northness, TPI, bio04, bio10, bio18, bio19")],
      [216],
      [168],
      [0,702],

      table.hline(start: 1, end: 7, stroke: 0.25pt),

      [200],
      [9],
      [#text("dem_sd, eastness, bedrock, northness, TPI, bio04, bio10, bio18, bio19")],
      [216],
      [177],
      [0,627],

      table.hline(start: 1, end: 7, stroke: 0.25pt),

      [100],
      [9],
      [#text("dem_sd, eastness, bedrock, northness, TPI, bio04, bio10, bio18, bio19")],
      [216],
      [175],
      [0,691],

      table.hline(stroke: 0.8pt),

      table.cell(
        rowspan: 4,
        align: left + horizon,
      )[_Phyteuma \ pseudorbiculare_],
      [1000],
      [10],
      [#text("dem_sd, eastness, bedrock, northness, slope, TPI, bio04, bio10, bio18, bio19")],
      [270],
      [196],
      [0,694],

      table.hline(start: 1, end: 7, stroke: 0.25pt),

      [500],
      [9],
      [#text("dem_sd, eastness, bedrock, northness, TPI, bio04, bio10, bio18, bio19")],
      [216],
      [135],
      [0,565],

      table.hline(start: 1, end: 7, stroke: 0.25pt),

      [200],
      [9],
      [#text("dem_sd, eastness, bedrock, northness, TPI, bio04, bio10, bio18, bio19")],
      [216],
      [149],
      [0,706],

      table.hline(start: 1, end: 7, stroke: 0.25pt),

      [100],
      [9],
      [#text("dem_sd, eastness, bedrock, northness, TPI, bio04, bio10, bio18, bio19")],
      [216],
      [155],
      [0,616],

      table.hline(stroke: 0.8pt),

      table.cell(
        rowspan: 4,
        align: left + horizon,
      )[_Saxifraga \ blavii_],
      [1000],
      [10],
      [#text("dem_sd, eastness, bedrock, northness, slope, TPI, bio04, bio10, bio18, bio19")],
      [270],
      [202],
      [0,693],

      table.hline(start: 1, end: 7, stroke: 0.25pt),

      [500],
      [9],
      [#text("dem_sd, eastness, bedrock, northness, TPI, bio04, bio10, bio18, bio19")],
      [216],
      [164],
      [0,564],

      table.hline(start: 1, end: 7, stroke: 0.25pt),

      [200],
      [9],
      [#text("dem_sd, eastness, bedrock, northness, TPI, bio04, bio10, bio18, bio19")],
      [216],
      [152],
      [0,649],

      table.hline(start: 1, end: 7, stroke: 0.25pt),

      [100],
      [9],
      [#text("dem_sd, eastness, bedrock, northness, TPI, bio04, bio10, bio18, bio19")],
      [216],
      [166],
      [0,462],

      table.hline(stroke: 1.2pt),
    )
  ],
  caption: [
    Souhrnná tabulka pro modely určené k extrapolaci odvozené závislosti mezi výskytem druhu a prostředím v čase. *$P_"pred"$* představuje absoultní počet prediktorů využitých k modelování, *$M_"biv"$* počet trénovaných bivariátních modelů (počet unikátních dvojic (PRED#sub("i") × PRED#sub("j")) × počet algoritmů), *$M_"TRUE"$* počet bivariátních modelů využitých k fitování finálního ESM, tj. modelů prošlých všemi filtry během trénování, & *Somersovo $D$* představuje souhrnný výkon modelu.
  ],
) <tab:extrapol_result_table>
]