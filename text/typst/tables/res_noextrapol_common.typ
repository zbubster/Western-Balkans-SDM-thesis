#let noextrapol_common_result_table = [

#figure(
  text(size: 8pt)[
    #table(
      columns: (13%, 8%, 43%, 10%, 8%, 8%, 10%),
      align: (
        left + horizon,
        center + horizon,
        left + horizon,
        center + horizon,
        center + horizon,
        center + horizon,
        center + horizon,
      ),
      inset: (3pt),
      stroke: none,

      table.header(
        [*Druh*],
        [*$P_"pred"$*],
        [*Prediktory*],
        [*Rozlišení*],
        [*$M_"biv"$*],
        [*$M_"TRUE"$*],
        [*Somersovo $D$*],
      ),

      table.hline(stroke: 1.3pt),

      table.cell(
        rowspan: 4,
        align: left + horizon,
      )[_Gentiana \ dinarica_],

      table.cell(
        rowspan: 4,
        align: center + horizon,
      )[10],

      table.cell(
        rowspan: 4,
        align: left + horizon,
      )[
        #text("depth_to_bedrock, soil_water_cap, landcover, bedrock, HLI, northness, TWI, bio06, bio12, bio14")
      ],

      [1000],
      [270],
      [181],
      [0,640],

      table.hline(start: 3, end: 7, stroke: 0.25pt),
      

      [500],
      [270],
      [225],
      [0,688],

      table.hline(start: 3, end: 7, stroke: 0.25pt),
      

      [200],
      [270],
      [215],
      [0,590],

      table.hline(start: 3, end: 7, stroke: 0.25pt),
      

      [100],
      [270],
      [223],
      [0,702],

      table.hline(stroke: 0.8pt),

      table.cell(
        rowspan: 4,
        align: left + horizon,
      )[_Gentiana \ tergestina_],

      table.cell(
        rowspan: 4,
        align: center + horizon,
      )[11],

      table.cell(
        rowspan: 4,
        align: left + horizon,
      )[
        #text("soil_water_cap, dem_range, eastness, landcover, bedrock, HLI, northness, TWI, bio06, bio12, bio14")
      ],

      [1000],
      [330],
      [254],
      [0,358],

      table.hline(start: 3, end: 7, stroke: 0.25pt),
      

      [500],
      [330],
      [247],
      [0,412],

      table.hline(start: 3, end: 7, stroke: 0.25pt),
      

      [200],
      [330],
      [269],
      [0,467],

      table.hline(start: 3, end: 7, stroke: 0.25pt),
      

      [100],
      [330],
      [259],
      [0,426],

      table.hline(stroke: 0.8pt),

      table.cell(
        rowspan: 4,
        align: left + horizon,
      )[_Primula \ kitaibeliana_],

      table.cell(
        rowspan: 4,
        align: center + horizon,
      )[11],

      table.cell(
        rowspan: 4,
        align: left + horizon,
      )[
        #text("depth_to_bedrock, soil_water_cap, dem_range, eastness, landcover, HLI, northness, TWI, bio06, bio12, bio14")
      ],

      [1000],
      [330],
      [262],
      [0,514],

      table.hline(start: 3, end: 7, stroke: 0.25pt),
      

      [500],
      [330],
      [260],
      [0,665],

      table.hline(start: 3, end: 7, stroke: 0.25pt),
      

      [200],
      [330],
      [248],
      [0,895],

      table.hline(start: 3, end: 7, stroke: 0.25pt),
      

      [100],
      [330],
      [253],
      [0,895],

      table.hline(stroke: 0.8pt),

      table.cell(
        rowspan: 4,
        align: left + horizon,
      )[_Phyteuma \ orbiculare_],

      table.cell(
        rowspan: 4,
        align: center + horizon,
      )[10],

      table.cell(
        rowspan: 4,
        align: left + horizon,
      )[
        #text("depth_to_bedrock, soil_water_cap, landcover, bedrock, HLI, northness, TWI, bio06, bio12, bio14")
      ],

      [1000],
      [270],
      [182],
      [0,661],

      table.hline(start: 3, end: 7, stroke: 0.25pt),
      

      [500],
      [270],
      [202],
      [0,573],

      table.hline(start: 3, end: 7, stroke: 0.25pt),
      

      [200],
      [270],
      [193],
      [0,479],

      table.hline(start: 3, end: 7, stroke: 0.25pt),
      

      [100],
      [270],
      [212],
      [0,618],

      table.hline(stroke: 0.8pt),

      table.cell(
        rowspan: 4,
        align: left + horizon,
      )[_Phyteuma \ pseudorbiculare_],

      table.cell(
        rowspan: 4,
        align: center + horizon,
      )[10],

      table.cell(
        rowspan: 4,
        align: left + horizon,
      )[
        #text("depth_to_bedrock, soil_water_cap, landcover, bedrock, HLI, northness, TWI, bio06, bio12, bio14")
      ],

      [1000],
      [270],
      [189],
      [0,588],

      table.hline(start: 3, end: 7, stroke: 0.25pt),
      

      [500],
      [270],
      [207],
      [0,639],

      table.hline(start: 3, end: 7, stroke: 0.25pt),
      

      [200],
      [270],
      [204],
      [0,674],

      table.hline(start: 3, end: 7, stroke: 0.25pt),
      

      [100],
      [270],
      [205],
      [0,556],

      table.hline(stroke: 0.8pt),

      table.cell(
        rowspan: 4,
        align: left + horizon,
      )[_Saxifraga \ blavii_],

      table.cell(
        rowspan: 4,
        align: center + horizon,
      )[10],

      table.cell(
        rowspan: 4,
        align: left + horizon,
      )[
        #text("depth_to_bedrock, soil_water_cap, landcover, bedrock, HLI, northness, TWI, bio06, bio12, bio14")
      ],

      [1000],
      [270],
      [213],
      [0,635],

      table.hline(start: 3, end: 7, stroke: 0.25pt),
      

      [500],
      [270],
      [221],
      [0,555],

      table.hline(start: 3, end: 7, stroke: 0.25pt),
      

      [200],
      [270],
      [203],
      [0,628],

      table.hline(start: 3, end: 7, stroke: 0.25pt),
      

      [100],
      [270],
      [210],
      [0,406],

      table.hline(stroke: 1.2pt),
    )
  ],
  caption: [
    Souhrnná tabulka modelů založených na sadách prediktorů společných pro všechna prostorová rozlišení daného druhu. *$P_"pred"$* představuje absolutní počet prediktorů využitých k modelování, *$M_"biv"$* počet trénovaných bivariátních modelů (počet unikátních dvojic (PRED#sub("i") × PRED#sub("j")) × počet algoritmů), *$M_"TRUE"$* počet bivariátních modelů využitých k fitování finálního ESM, tj. modelů prošlých všemi filtry během trénování, & *Somersovo $D$* představuje souhrnný výkon modelu.
  ],
) <tab:noextrapol_common_result_table>
]