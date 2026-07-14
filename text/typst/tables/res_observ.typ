#let observ_table = [
  #figure(
    table(
      //columns:(1.9fr, 0.7fr, 0.9fr, 0.9fr, 0.9fr, 1.1fr, 0.9fr, 0.9fr, 0.9fr),
      columns:(20%, 10%, 10%, 10%, 10%, 10%, 10%, 10%, 10%),
      inset: 3.2pt,
      align: (left, center, center, center, center, center, center, center, center),
      stroke: none,

      table.hline(stroke: 1.2pt),

      table.header(
        [#box(height: 1.5em)[#align(horizon)[*Druh*]]],
        [#box(height: 1.5em)[#align(horizon)[*Rozlišení*]]],
        [#box(height: 1.5em)[#align(horizon)[*$N$*]]],
        [#box(height: 1.5em)[#align(horizon)[*$N_A$*]]],
        [#box(height: 1.5em)[#align(horizon)[*$N_"P-FW"$*]]],
        [#box(height: 1.5em)[#align(horizon)[*$N_"P-DB"$*]]],
        [#box(height: 1.5em)[#align(horizon)[*$w_A$*]]],
        [#box(height: 1.5em)[#align(horizon)[*$w_"P-FW"$*]]],
        [#box(height: 1.5em)[#align(horizon)[*$w_"P-DB"$*]]],
      ),

      table.hline(stroke: 0.5pt),

      [_Gentiana dinarica_], [100], [601], [552], [49], [0], [0,544], [6,133], [–],
      [_Gentiana dinarica_], [200], [533], [485], [48], [0], [0,549], [5,552], [–],
      [_Gentiana dinarica_], [500], [399], [355], [44], [0], [0,562], [4,534], [–],
      [_Gentiana dinarica_], [1000], [272], [240], [32], [0], [0,567], [4,250], [–],

      table.hline(stroke: 0.2pt),

      [_Gentiana tergestina_], [100], [660], [418], [183], [59], [0,789], [1,553], [0,776],
      [_Gentiana tergestina_], [200], [591], [357], [176], [58], [0,828], [1,441], [0,721],
      [_Gentiana tergestina_], [500], [453], [265], [134], [54], [0,855], [1,407], [0,703],
      [_Gentiana tergestina_], [1000], [315], [179], [93], [43], [0,880], [1,376], [0,688],

      table.hline(stroke: 0.2pt),

      [_Phyteuma orbiculare_], [100], [601], [570], [31], [0], [0,527], [9,694], [–],
      [_Phyteuma orbiculare_], [200], [533], [503], [30], [0], [0,530], [8,883], [–],
      [_Phyteuma orbiculare_], [500], [399], [375], [24], [0], [0,532], [8,313], [–],
      [_Phyteuma orbiculare_], [1000], [272], [251], [21], [0], [0,542], [6,476], [–],

      table.hline(stroke: 0.2pt),

      [_Phyteuma pseudorbiculare_], [100], [601], [579], [22], [0], [0,519], [13,659], [–],
      [_Phyteuma pseudorbiculare_], [200], [533], [511], [22], [0], [0,522], [12,114], [–],
      [_Phyteuma pseudorbiculare_], [500], [399], [377], [22], [0], [0,529], [9,068], [–],
      [_Phyteuma pseudorbiculare_], [1000], [272], [252], [20], [0], [0,540], [6,800], [–],

      table.hline(stroke: 0.2pt),

      [_Primula kitaibeliana_], [100], [671], [601], [0], [70], [0,558], [–], [4,793],
      [_Primula kitaibeliana_], [200], [598], [533], [0], [65], [0,561], [–], [4,600],
      [_Primula kitaibeliana_], [500], [452], [399], [0], [53], [0,566], [–], [4,264],
      [_Primula kitaibeliana_], [1000], [315], [272], [0], [43], [0,579], [–], [3,663],

      table.hline(stroke: 0.2pt),

      [_Saxifraga blavii_], [100], [601], [513], [88], [0], [0,586], [3,415], [–],
      [_Saxifraga blavii_], [200], [533], [448], [85], [0], [0,595], [3,135], [–],
      [_Saxifraga blavii_], [500], [399], [327], [72], [0], [0,610], [2,771], [–],
      [_Saxifraga blavii_], [1000], [272], [219], [53], [0], [0,621], [2,566], [–],

      table.hline(stroke: 1.2pt),
    ),
    caption: [Přehled počtu pozorování a vah použitých při modelování jednotlivých druhů v různých prostorových rozlišeních. *$N$* reprezentuje celkový počet pozorování, *$N_A$* počet absencí druhu, *$N_"P-FW"$* počet terénních presencí z vlastního sběru dat, *$N_"P-DB"$* počet presencí převzatých z _Flora Croatica Database_ @flora_croatica_database, *$w_A$* váha jednoho absenčního bodu, *$w_"P-FW"$* váha terénního presenčního bodu & *$w_"P-DB"$* váha jednoho databázového bodu. 
    /*Váhy observačních bodů byly rozděleny v poměru 1 : 1 mezi *$N_A$* a *$N_P$* (= *$N_"P-FW"$* + *$N_"P-DB"$*) a následně váhy *$N_P$* v poměru 2 : 1 mezi *$N_"P-FW"$* a *$N_"P-DB"$*.*/
    Váhy observačních bodů byly rozděleny v poměru 1 : 1 mezi absence a všechny presence, přičemž presenční váhy byly následně rozděleny v poměru 2 : 1 mezi terénní a databázová data. [[[]]]
    ]
  ) <tab:observ>
]