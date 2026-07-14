#let pred_dem = [

  #figure(
    table(
      columns: (10%, 15%, 7%, 15%, 40%, 13%),
      //columns: (0.9fr, 1.7fr, 0.8fr, 1.8fr, 3.6fr, 1.5fr),
      align: (left, left, center, center, left, right),
      inset: 4.5583pt,
      stroke: none,
      //stroke: red,

      table.hline(stroke: 1.2pt),

      table.header(
        [*Zkratka*],
        [*Název*],
        [*Jednotky*],
        [*Způsob výpočtu*],
        [*Popis výpočtu*],
        [*Citace*],
      ),

      table.hline(stroke: 0.5pt),

      table.cell(colspan: 6)[
        *Relativní topografické prediktory* \
        Prediktory počítané z DEM v cílovém rozlišení: popisují vztah středové buňky k okolním buňkám v rámci pohyblivého okna.
      ],

      table.hline(stroke: 0.5pt),

      [`aspect`],
      [_Aspect_],
      [stupně],
      [_terra::terrain_],
      [Orientace svahu odvozená z relativní elevace okolních buňek.],
      [#cite(<terra>, form: "prose"), #cite(<slope_aspect_neigh8>, form: "prose")],

      [`slope`],
      [_Slope_],
      [stupně],
      [_terra::terrain_],
      [Sklon povrchu odvozený z relativní elevace okolních buňek.],
      [#cite(<terra>, form: "prose"), #cite(<slope_aspect_neigh8>, form: "prose")],

      [`eastness`],
      [_Eastness_],
      [‒],
      [sin(aspect)],
      [Sinus aspektu v radiánech; vyjadřuje východo-západní složku orientace svahu.],
      [‒],

      [`northness`],
      [_Northness_],
      [‒],
      [cos(aspect)],
      [Kosinus aspektu v radiánech; vyjadřuje severo-jižní složku orientace svahu.],
      [‒],

      [`HLI`],
      [_Heat Load Index_],
      [‒],
      [_spatialEco::hli_],
      [Index potenciálního teplotního zatížení svahu odvozený ze sklonu, orientace a zeměpisné šířky.],
      [#cite(<spatialEco>, form: "prose"), #cite(<HLI>, form: "prose")],

      [`flowdir`],
      [_Flow direction_],
      [‒],
      [_terra::terrain_],
      [Směr odtoku určený podle sousední buňky s nejmenší elevací.],
      [#cite(<terra>, form: "prose")],

      [`TWI`],
      [_Topographic Wetness Index_],
      [‒],
      [$ln(a / tan(beta))$],
      [Logaritmický poměr specifické přispívající plochy $a$ a sklonu svahu $beta$; vyšší hodnoty indikují potenciálně vlhčí místa.],
      [#cite(<TWI>, form: "prose")],

      [`TPI`],
      [_Topographic Position Index_],
      [metry],
      [$z_0 - 1/8 sum_(i=1)^8 z_i$],
      [Rozdíl mezi výškou středové buňky a průměrnou výškou okolních buněk.],
      [#cite(<terra>, form: "prose"), #cite(<TPI_weiss2001>, form: "prose"), #cite(<wilson_2007_GDAL>, form: "prose")],

      [`roughness`],
      [_Roughness_],
      [metry],
      [$max(z_0, z_i) - min(z_0, z_i)$],
      [Rozdíl mezi nejvyšší a nejnižší hodnotou výšky v rámci pohyblivého okna.],
      [#cite(<terra>, form: "prose"), #cite(<wilson_2007_GDAL>, form: "prose")],

      [`TRI`],
      [_Terrain Ruggedness Index_],
      [metry],
      [$(1 / n) sum_i abs(z_0 - z_i)$ #v(0.1pt) _terra::terrain_],
      [Průměr absolutních výškových rozdílů mezi středovou buňkou a okolím.],
      [#cite(<terra>, form: "prose"), #cite(<wilson_2007_GDAL>, form: "prose")],

      [`TRI_riley`],
      [_Terrain Ruggedness Index -- Riley_],
      [metry],
      [$sqrt(sum_i (z_0 - z_i)^2)$ #v(0.1pt) _terra::terrain_],
      [Odmocnina ze součtu čtvercových výškových rozdílů mezi středovou buňkou a okolními buňkami.],
      [#cite(<terra>, form: "prose"), #cite(<TRI>, form: "prose")],

      [`TRI_rmsd`],
      [_Terrain Ruggedness Index -- RMSD_],
      [metry],
      [$sqrt((1 / n) sum_i (z_0 - z_i)^2)$ #v(0.1pt) _terra::terrain_],
      [Odmocnina z průměru čtvercových výškových rozdílů mezi středovou buňkou a okolními buňkami.],
      [#cite(<terra>, form: "prose"), #cite(<wilson_2007_GDAL>, form: "prose")],

      table.hline(stroke: 0.5pt),

      table.cell(colspan: 6)[
        *Agregační topografické prediktory* \
        Prediktory vzniklé během agregace originálních dat do cílového rozlišení: popisují elevační variabilitu uvnitř jedné modelovací buňky.
      ],

      table.hline(stroke: 0.5pt),

      [`dem_median`],
      [_Median elevation_],
      [metry],
      [median(z#sub("j"))],
      [Medián elevací 30m buněk agregovaných do jedné buňky cílového rozlišení.],
      [‒],

      [`dem_sd`],
      [_Elevation standard deviation_],
      [metry],
      [sd(z#sub("j"))],
      [Směrodatná odchylka elevací 30m buněk agregovaných do jedné buňky cílového rozlišení.],
      [‒],

      [`dem_max`],
      [_Maximum elevation_],
      [metry],
      [$max(z_j)$],
      [Maximální elevace 30m buněk agregovaných do jedné buňky cílového rozlišení.],
      [‒],

      [`dem_min`],
      [_Minimum elevation_],
      [metry],
      [$min(z_j)$],
      [Minimální elevace 30m buněk agregovaných do jedné buňky cílového rozlišení.],
      [‒],

      [`dem_range`],
      [_Elevation range_],
      [metry],
      [$max(z_j) - min(z_j)$],
      [Rozdíl mezi maximální a minimální elevací 30m buněk agregovaných do jedné buňky cílového rozlišení.],
      [‒],

      table.hline(stroke: 1.2pt),
    ),
    caption: [
      Přehled topografických prediktorů odvozených z digitálního modelu reliéfu DEM. Ve vzorcích $z_0$ reprezentuje elevaci buňky, pro kterou je daný parametr počítán, $z_i$ ukazuje na sousední buňky v rámci pohyblivého okna a $z_j$ se vztahuje k buňkám, které byly agregovány do menšího rozlišení.
    ]
  ) <tab:pred_dem>
]