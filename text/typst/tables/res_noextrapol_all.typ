#let noextrapol_all_result_table = [
  #figure(
  text(size: 8pt)[
    #table(
      columns: (13%, 7%, 7%, 52%, 6%, 7%, 8%),
      align: (
        left + horizon,
        center + horizon,
        center + horizon,
        left + horizon,
        center + horizon,
        center + horizon,
        center + horizon,
      ),
      inset: (4pt),
      stroke: none,

      table.header(
        [*Druh*],
        [*Rozlišení*],
        [*$N_"pred"$*],
        [*Prediktory*],
        [*$N_"biv"$*],
        [*$N_"TRUE"$*],
        [*Somersovo $D$*],
      ),

      table.hline(stroke: 1.3pt),

      table.cell(
        rowspan: 4,
        align: left + horizon,
      )[_Gentiana \ dinarica_],
      [1000],
      [14],
      [#text("depth_to_bedrock, soil_water_cap, eastness, landcover, bedrock, HLI, northness, TPI, TRI, TWI, bio04, bio06, bio12, bio14")],
      [546],
      [375],
      [0,733],

      table.hline(start: 1, end: 7, stroke: 0.25pt),

      [500],
      [13],
      [#text("depth_to_bedrock, soil_water_cap, dem_range, eastness, landcover, bedrock, HLI, northness, TWI, bio06, bio07, bio12, bio14")],
      [468],
      [382],
      [0,722],

      table.hline(start: 1, end: 7, stroke: 0.25pt),

      [200],
      [14],
      [#text("depth_to_bedrock, soil_water_cap, dem_range, eastness, landcover, bedrock, HLI, northness, TPI, TWI, bio06, bio07, bio12, bio14")],
      [546],
      [406],
      [0,597],

      table.hline(start: 1, end: 7, stroke: 0.25pt),

      [100],
      [13],
      [#text("depth_to_bedrock, aspect, soil_water_cap, dem_range, landcover, bedrock, HLI, northness, TPI, TWI, bio06, bio12, bio14")],
      [468],
      [373],
      [0,702],

      table.hline(stroke: 0.8pt),

      table.cell(
        rowspan: 4,
        align: left + horizon,
      )[_Gentiana \ tergestina_],
      [1000],
      [14],
      [#text("depth_to_bedrock, soil_water_cap, dem_range, eastness, landcover, bedrock, HLI, northness, TPI, TWI, bio04, bio06, bio12, bio14")],
      [546],
      [394],
      [0,356],

      table.hline(start: 1, end: 7, stroke: 0.25pt),

      [500],
      [12],
      [#text("depth_to_bedrock, soil_water_cap, dem_range, eastness, landcover, bedrock, HLI, northness, TWI, bio06, bio12, bio14")],
      [396],
      [274],
      [0,412],

      table.hline(start: 1, end: 7, stroke: 0.25pt),

      [200],
      [13],
      [#text("depth_to_bedrock, soil_water_cap, dem_range, eastness, landcover, bedrock, HLI, northness, TWI, bio04, bio06, bio12, bio14")],
      [468],
      [368],
      [0,519],

      table.hline(start: 1, end: 7, stroke: 0.25pt),

      [100],
      [11],
      [#text("soil_water_cap, dem_range, eastness, landcover, bedrock, HLI, northness, TWI, bio06, bio12, bio14")],
      [330],
      [259],
      [0,426],

      table.hline(stroke: 0.8pt),

      table.cell(
        rowspan: 4,
        align: left + horizon,
      )[_Primula \ kitaibeliana_],
      [1000],
      [14],
      [#text("depth_to_bedrock, soil_water_cap, dem_range, eastness, landcover, bedrock, HLI, northness, TPI, TWI, bio04, bio06, bio12, bio14")],
      [546],
      [440],
      [0,433],

      table.hline(start: 1, end: 7, stroke: 0.25pt),

      [500],
      [12],
      [#text("depth_to_bedrock, soil_water_cap, dem_range, eastness, landcover, bedrock, HLI, northness, TWI, bio06, bio12, bio14")],
      [396],
      [315],
      [0,690],

      table.hline(start: 1, end: 7, stroke: 0.25pt),

      [200],
      [13],
      [#text("depth_to_bedrock, soil_water_cap, dem_range, eastness, landcover, bedrock, HLI, northness, TWI, bio04, bio06, bio12, bio14")],
      [468],
      [362],
      [0,904],

      table.hline(start: 1, end: 7, stroke: 0.25pt),

      [100],
      [11],
      [#text("depth_to_bedrock, soil_water_cap, dem_range, eastness, landcover, HLI, northness, TWI, bio06, bio12, bio14")],
      [330],
      [253],
      [0,895],

      table.hline(stroke: 0.8pt),

      table.cell(
        rowspan: 4,
        align: left + horizon,
      )[_Phyteuma \ orbiculare_],
      [1000],
      [14],
      [#text("depth_to_bedrock, soil_water_cap, eastness, landcover, bedrock, HLI, northness, TPI, TRI, TWI, bio04, bio06, bio12, bio14")],
      [546],
      [386],
      [0,728],

      table.hline(start: 1, end: 7, stroke: 0.25pt),

      [500],
      [13],
      [#text("depth_to_bedrock, soil_water_cap, dem_range, eastness, landcover, bedrock, HLI, northness, TWI, bio06, bio07, bio12, bio14")],
      [468],
      [333],
      [0,554],

      table.hline(start: 1, end: 7, stroke: 0.25pt),

      [200],
      [14],
      [#text("depth_to_bedrock, soil_water_cap, dem_range, eastness, landcover, bedrock, HLI, northness, TPI, TWI, bio06, bio07, bio12, bio14")],
      [546],
      [404],
      [0,542],

      table.hline(start: 1, end: 7, stroke: 0.25pt),

      [100],
      [13],
      [#text("depth_to_bedrock, aspect, soil_water_cap, dem_range, landcover, bedrock, HLI, northness, TPI, TWI, bio06, bio12, bio14")],
      [468],
      [370],
      [0,643],

      table.hline(stroke: 0.8pt),

      table.cell(
        rowspan: 4,
        align: left + horizon,
      )[_Phyteuma \ pseudorbiculare_],
      [1000],
      [14],
      [#text("depth_to_bedrock, soil_water_cap, eastness, landcover, bedrock, HLI, northness, TPI, TRI, TWI, bio04, bio06, bio12, bio14")],
      [546],
      [396],
      [0,623],

      table.hline(start: 1, end: 7, stroke: 0.25pt),

      [500],
      [13],
      [#text("depth_to_bedrock, soil_water_cap, dem_range, eastness, landcover, bedrock, HLI, northness, TWI, bio06, bio07, bio12, bio14")],
      [468],
      [345],
      [0,639],

      table.hline(start: 1, end: 7, stroke: 0.25pt),

      [200],
      [14],
      [#text("depth_to_bedrock, soil_water_cap, dem_range, eastness, landcover, bedrock, HLI, northness, TPI, TWI, bio06, bio07, bio12, bio14")],
      [546],
      [379],
      [0,688],

      table.hline(start: 1, end: 7, stroke: 0.25pt),

      [100],
      [13],
      [#text("depth_to_bedrock, aspect, soil_water_cap, dem_range, landcover, bedrock, HLI, northness, TPI, TWI, bio06, bio12, bio14")],
      [468],
      [322],
      [0,541],

      table.hline(stroke: 0.8pt),

      table.cell(
        rowspan: 4,
        align: left + horizon,
      )[_Saxifraga \ blavii_],
      [1000],
      [14],
      [#text("depth_to_bedrock, soil_water_cap, eastness, landcover, bedrock, HLI, northness, TPI, TRI, TWI, bio04, bio06, bio12, bio14")],
      [546],
      [405],
      [0,650],

      table.hline(start: 1, end: 7, stroke: 0.25pt),

      [500],
      [13],
      [#text("depth_to_bedrock, soil_water_cap, dem_range, eastness, landcover, bedrock, HLI, northness, TWI, bio06, bio07, bio12, bio14")],
      [468],
      [374],
      [0,571],

      table.hline(start: 1, end: 7, stroke: 0.25pt),

      [200],
      [14],
      [#text("depth_to_bedrock, soil_water_cap, dem_range, eastness, landcover, bedrock, HLI, northness, TPI, TWI, bio06, bio07, bio12, bio14")],
      [546],
      [378],
      [0,637],

      table.hline(start: 1, end: 7, stroke: 0.25pt),

      [100],
      [13],
      [#text("depth_to_bedrock, aspect, soil_water_cap, dem_range, landcover, bedrock, HLI, northness, TPI, TWI, bio06, bio12, bio14")],
      [468],
      [351],
      [0,404],

      table.hline(stroke: 1.2pt),
    )
  ],
  caption: [
    Souhrnná tabulka modelů určených k co nejvěrnějšímu vystižení současného rozšíření vhodných stanovišť. *$N_"pred"$* představuje absolutní počet prediktorů využitých k modelování, *$N_"biv"$* počet trénovaných bivariátních modelů (počet unikátních dvojic (PRED#sub("i") × PRED#sub("j")) × počet algoritmů), *$N_"TRUE"$* počet bivariátních modelů využitých k fitování finálního ESM, tj. modelů prošlých všemi filtry během trénování, & *Somersovo $D$* představuje souhrnný výkon modelu.
  ],
) <tab:noextrapol_all_result_table>
]