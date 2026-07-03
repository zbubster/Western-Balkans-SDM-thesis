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
#set par(
  justify: true,
  leading: 0.65em,
  first-line-indent: (
    amount: 1.25em,
    all: true,
  ),
)

// words splitting on the end of the line turned off
#set text(hyphenate: false)

// chapter numbering
#set heading(numbering: "1.")

// tables: caption TOP
#show figure.where(kind: table): set figure.caption(position: top)
// figures: caption BOTTOM
#show figure.where(kind: image): set figure.caption(position: bottom)

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

[[[seřadit podle abecedy]]]
[[[převést na tabulku]]]

LGM ‒ last glacial maximum, poslední glaciální maximum

HCO ‒ holocene climatic optimum, holocénní klimatické optimum

DEM ‒ digital elevation model, digitální model reliéfu

TPI

TRI

HLI

TWI

ESM ‒ ensemble of small models

GLiM

SDM ‒ species distribution modelling, modelování rozšíření druhů,
#linebreak() #h(50pt) 
modelování rozšíření potenciálně vhodných stanovišť

EO, DPZ ‒ Earth observing, dálkový průzkum Země

S-D ‒ Somerovo D

GLM ‒ generalized linear model, zobecněný lineární model

GBM ‒ boosted regression trees

CTA ‒ klasifikační stromy

RF ‒ random forest

MARS ‒ multivariate adaptive regression splines

GAM ‒ generalized additive models, zobecněné aditivní modely

AUC ‒ area under the receiver operating characteristic curve, plocha pod ROC křivkou

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

[[[proximita prediktorů]]]

Dalším důležitým prediktorem používaným v modelech rozšíření vhodných stanovišť je informace o geologickém podloží. Zohlednění substrátu přináší do modelu důležitou informaci, jelikož erozní procesy specifické pro daný horninový substrát přímo ovlivňují vlastnosti půdy. [[[citace? nebo obecná znalost?]]] Zejména u rostlin tak může zachycovat ekologické gradienty, které nejsou plně postižitelné klimatickými a topografickými proměnnými, přičemž zařazení geologického substrátu do modelu může zlepšit predikci rozšíření potenciálně vhodných stanovišť, obzvlášť v horských a geologicky heterogenních územích. @chauvier_2021 @dubuis_2012

Kromě samotného typu geologického podloží mohou být pro modelování rozšíření vhodných stanovišť významné také konkrétní půdní vlastnosti, které mají na růst rostlin přímější vliv. Ku příkladu hloubka půdy, půdní reakce a schopnost půdy zadržovat vodu ovlivňují přežívání rostlin významně silněji než samotný druh horniny. Zahrnutí prediktorů charakterizujících takové vlastnosti půdy může vysvětlovat část variability, kterou není možné zachytit pouze klasifikovaným geologickým substrátem, a vést k lepším projekcím vhodných stanovišť v prostoru. @dubuis_2012

Z tohoto důvodu byly v této práci vedle geologické vrstvy GLiM využity také vybrané půdní prediktory ze systému SoilGrids, který poskytuje globální predikce půdních vlastností v prostorovém rozlišení 250 m založené na půdních pozorování a následném strojovém učení. @soilgrids_250m

[[[povídání o tom, že půda se mění v čase a není možné tyto prediktory požívat při temporálních extrapolacích]]]

[[[povídání o nepřesnostech v prediktorových datasetech ‒ interpolace viz soilgrids, chelsa a počet stanic meteo na Balkáně, NAOPAK přesnost DEM, EO dat]]]

[[[studium změny klimatu je důležité proč]]]

V odborné obci panuje obecná shoda, že probíhající globální klimatická změna může vést k elevačnímu posunu klimatických zón a návaznému zmenšení rozlohy (sub)alpinských biotopů. Taková změna by vedla k ohrožení druhů se slabou migrační schopností a druhů vyskytujících se v oblastech, kde již není možné migrovat do vyšších nadmořských výšek. @IPCC_2023

== Cíle práce

// # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
// metodika
#pagebreak()
= Metodika
== Prostorové vymezení práce
== Druhy Rostlin
== Vstupní data
=== Data o výskytech druhů

vlastní sběr, TN, váhy udělené outsource datům

=== Modelovací prediktory

V rámci této práce byly k trénování modelů rozšíření vhodných stanovišť využity prediktory z pěti základních skupin:
+ *klimatické* prediktory charakterizující na hrubém měřítku variabilitu teploty a srážek
+ *topografické* prediktory jejichž účelem je postihnout jemnější variabilitu mikrostanovišťních podmínek
+ *horninový* substrát sloužící jako základní charakteristika geologických poměrů na regionální úrovni
+ *půdní* prediktory rozvíjejí informaci o půdních poměrech na úrovni lokalit a je možné považovat je za ekologicky relevantnější než samotný geologický substrát [[[zdroj]]]
+ *krajinný pokryv* klasifikuje povrch Země do základních kategorií [[[louka-les]]] a jako jediný prediktor přináší do modelů informaci, která je vzdáleně schopna charakterizovat ovlivnění rozšíření vhodných stanovišť biotickými faktory [[[zdroj]]]

==== Klimatické prediktory

Jedním z důležitých metodických rozhodnutí při přípravě environmentálních prediktorů je volba klimatického datasetu pro současné, budoucí a historické projekce. Srovnávací studie ukazují, že teplotní proměnné klimatických datasetů jsou obvykle konzistentní, zejména díky silné vazbě teploty a nadmořské výšky. Výraznější rozdíly se však objevují u srážkových proměnných, jejichž prostorové rozložení je v horském prostředí ovlivněno lokální cirkulací vzduchu, která je pod rozlišovací schopností globálních klimatických modelů. @bobrowski_2017 @fierke_2024

[[[možná do úvodu?? ↑↑↑]]]

V této práci byl zvolen dataset CHELSA @chelsa_bioclim_model @chelsa_bioclim_data, a to především kvůli jeho vhodnosti pro modelování v topograficky členitých oblastech. @bobrowski_2017 

Dataset CHELSA-BIOCLIM je globální klimatický dataset s vysokým prostorovým rozlišením 30 úhlových sekund (cca 1 km#super([2])).
Vychází z hrubších klimatických dat, která jsou zpřesněna pomocí topografických modelů, jejichž využití umožňuje kromě výpočtu vlivu nadmořské výšky i zohlednění topografické sitace na proudění vzduchu. V táto práci jsou využity bioklimatické charakteristiky podchycující roční a sezónní variability klimatu v prostoru (bio01-bio19). @chelsa_bioclim_model
Do analýz navíc vstupoval i prediktor popisující počet dní v roce, kdy je na daném místě přítomna sněhová pokrývka (snow cover days, scd).

#figure(
  table(
    //columns: (0.8fr, 1.2fr, 4.5fr),
    columns: (10%, 20%, 70%),
    inset: 4pt,
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
    [bio03], [°C], [Isotermalita: 100 × bio02 / bio07; porovnává denní teplotní variabilitu s ročním teplotním rozsahem.],
    table.hline(start: 2, end: 3, stroke: 0.25pt),
    [bio04], [°C/100], [Teplotní sezonalita vyjádřená směrodatnou odchylkou průměrných měsíčních teplot.],
    table.hline(start: 2, end: 3, stroke: 0.25pt),
    [bio05], [°C], [Nejvyšší měsíční průměr denních maximálních teplot (_tasmax_) v průběhu roku; vyjadřuje extrémní teplotní podmínky v nejteplejším období.],
    table.hline(start: 2, end: 3, stroke: 0.25pt),
    [bio06], [°C], [Nejnižší měsíční průměr denních minimálních teplot (_tasmin_) v průběhu roku; charakterizuje intenzitu zimního chladu.],
    table.hline(start: 2, end: 3, stroke: 0.25pt),
    [bio07], [°C], [Roční teplotní rozsah vypočítaný jako bio05 − bio06; vyjadřuje rozdíl mezi nejteplejším a nejchladnějším měsícem.],
    table.hline(start: 2, end: 3, stroke: 0.25pt),
    [bio08], [°C], [Průměrná měsíční teplota během nejvlhčího tříměsíčního období roku.],
    table.hline(start: 2, end: 3, stroke: 0.25pt),
    [bio09], [°C], [Průměrná měsíční teplota během nejsuššího tříměsíčního období roku.],
    table.hline(start: 2, end: 3, stroke: 0.25pt),
    [bio10], [°C], [Průměrná měsíční teplota během nejteplejšího tříměsíčního období roku.],
    table.hline(start: 2, end: 3, stroke: 0.25pt),
    [bio11], [°C], [Průměrná měsíční teplota během nejchladnějšího tříměsíčního období roku.],

    table.hline(stroke: 0.75pt),

    [bio12], [$"kg" m^(-2) "rok"^(-1)$], [Součet měsíčních úhrnů srážek za celý rok.],
    table.hline(start: 2, end: 3, stroke: 0.25pt),
    [bio13], [$"kg" m^(-2) "měsíc"^(-1)$], [Nejvyšší měsíční úhrn srážek.],
    table.hline(start: 2, end: 3, stroke: 0.25pt),
    [bio14], [$"kg" m^(-2) "měsíc"^(-1)$], [Nejnižší měsíční úhrn srážek.],
    table.hline(start: 2, end: 3, stroke: 0.25pt),
    [bio15], [$"kg" m^(-2)$], [Koeficient variability měsíčních úhrnů srážek vypočítaný jako 100 × směrodatná odchylka / průměr.],
    table.hline(start: 2, end: 3, stroke: 0.25pt),
    [bio16], [$"kg" m^(-2) "měsíc"^(-1)$], [Průměrný měsíční úhrn srážek během nejvlhčího tříměsíčního období roku.],
    table.hline(start: 2, end: 3, stroke: 0.25pt),
    [bio17], [$"kg" m^(-2) "měsíc"^(-1)$], [Průměrný měsíční úhrn srážek během nejsuššího tříměsíčního období roku.],
    table.hline(start: 2, end: 3, stroke: 0.25pt),
    [bio18], [$"kg" m^(-2) "měsíc"^(-1)$], [Průměrný měsíční úhrn srážek během nejteplejšího tříměsíčního období roku.],
    table.hline(start: 2, end: 3, stroke: 0.25pt),
    [bio19], [$"kg" m^(-2) "měsíc"^(-1)$], [Průměrný měsíční úhrn srážek během nejchladnějšího tříměsíčního období roku.],

    table.hline(stroke: 0.75pt),

    [scd], [dny], [Počet dní v roce, kdy je na zemském povrchu přítomna sněhová pokrývka.],

    table.hline(stroke: 1.2pt),
  ),
  caption: [Přehled použitých bioklimatických prediktorů datasetů CHELSA-BIOCLIM a CHELSA-TraCE21k-bioclim.]
) <tab:chelsa>

Kromě charakterizace současného klimatu poskytuje dataset CHELSA-BIOCLIM i pro tři časové řezy (2011–2040, 2041–2070 & 2071–2100) modely extrapolující klima do budoucnosti (tzv. earth system models: GFDL-ESM4,
IPSL-CM6A-LR, MPI-ESM 1-2-HR, MRI-ESM2-0,
& UKESM1-0-LL) na základě různých emisních scénářů (shared socioeconomic pathways: ssp126, ssp370 & ssp585 @oneil__cmip6_2016).

[[[citovat earth system modely nebo vynechat podle toho, který nakonec půjde ven]]]

S ohledem na zachování metodické konzistence mezi jednotlivými časovými řezy byl pro projekci modelů na historické klimatické podmínky použit dataset CHELSA-TraCE21k-bioclim @chelsa_trace_data @chelsa_trace_model, který poskytuje klimatické rekonstrukce od posledního glaciálního maxima po současnost v časových krocích 100 let a prostorovém rozlišení 30 úhlových sekund (cca 1 km#super([2])).

[[[process využití v diplomce]]]

==== Topografické prediktory

Pro analýzu topografie byl v této práci použit globální elevační dataset _Copernicus DEM 30_ s prostorovým rozlišením 30 m#super([2]). @copernicus_DEM
Tento model je odvozen z dat mise dálkového průzkumu Země TanDEM-X a poskytuje tak nejpřesnější prostorové i absolutní zaměření poměrů na daných lokalitách mezi prediktory využitými v této práci.

Data byla získána prostřednictvím prostorového požadavku ve službě Copernicus Data Space Ecosystem @CDSE zprostředkovaného _openEO_ klientem v prostředí R. @openeo_R Stažené rastrové dlaždice byly následně sloučeny do mozaiky, oříznuty a maskovány polygonem zájmového území.

Topografické prediktory využité v této práci lze rozdělit do dvou skupin podle toho, jak popisují prostorové fenomény. První skupina charakterizuje vztah cílové buňky k jejímu okolí pomocí pohyblivého okna 3*3 buňky, tedy lokální topografický kontext. Druhá skupina popisuje vnitřní elevační variabilitu dané buňky při převodu z jemnějšího na hrubší prostorové měřítko. Přehled topografických prediktorů viz @tab:dem.

Pro první skupinu byl nejprve vytvořen DEM odpovídajícícho měřítka pomocí agregace původních dat _Copernicus DEM 30_. Hodnoty byly agregovány podle mediánu. Z takto vzniklého modelu byly pomocí _terra::terrain()_ @terra vypočteny vrstvy _slope_, _aspect_, _TPI_, _TRI_, _TRIriley_, _TRIrmsd_, _roughness_ a _flowdir_.
_TPI_ vyjadřuje rozdíl mezi výškou středové buňky a průměrem okolních buněk @TPI_weiss2001. Kladné hodnoty indexu značí lokálně vyvýšené pozice, například hřbety, a záporné hodnoty lokální sníženiny. Hodnoty okolo nuly představují plochý terén. 
_TRI_ průměr absolutních výškových rozdílů mezi středovou buňkou a okolím a _roughness_ rozdíl mezi maximální a minimální hodnotou v rámci pohyblivého okna. Prediktory _TRI_riley_ & _TRI_rmsd_ jsou deriváty jednoduššího _TRI_ snažící se lépe zachytit elevační variabilitu v geomorfologicky členitých oblastech. Jde o odmocninu součtu čtvercových rozdílů (_TRI_riley_, @TRI) a o odmocninu průměru čtvercových rozdílů (_TRI_rmsd_, @wilson_2007_GDAL).

Tato skupina topografických prediktorů byla následně rozšířena o prediktory _eastness_ a _northness_ odvozené z orientace svahu (_aspect_) jako sinus, respektive kosinus orientace svahu převedené na radiány. Tyto proměnné vyjadřují východo-západní a severo-jižní složky orientace svahu. V navazujících modelech byly použity jako zástupné prediktory za _aspect_ samotný, jelikož tento prediktor vykazuje kruhový charakter (360° = 0°) a není vhodný pro běžné algoritmy @wilson_2007_GDAL.
Dalším rozšířením je _HLI_ (heat load index, @HLI), který byl vypočten funkcí _spatialEco::hli()_ @spatialEco. Tato metrika vyjadřuje potenciální teplotní zatížení svahu a kombinuje informaci o sklonu (_slope_) a aspektu (_aspect_), přičemž hodnoty se pohybují od chladnějších po teplejší loaklity. @HLI
Posledním prediktorem počítaným pomocí pohyblivého okna byl _TWI_ (topographic wetness index, @TWI), který byl vypočítán na základě směru odtoku (_flowdir_), akumulované přispívající ploše (lokální "povodí") a sklonu (_slope_) v radiánech. Výsledný index byl vypočten jako logaritmus poměru specifické přispívající plochy a tangens sklonu.

Druhá skupina zahrnuje prediktory vzniklé během agregace jemných základních dat _Copernicus DEM 30_ do hrubšího prostorového měřítka. Z originálních dat byly ‒ kromě _dem_median_, který sloužil jako podklad prediktorů první skupiny ‒ během agregace vypočteny proměnné _dem_sd_ (směrodatná odchylka nadmořských výšek), _dem_min_ (minimální nadmořská výška), _dem_max_ (maximální nadmořská výška) & _dem_range_ (rozdíl mezi maximální a minimální nadmořskou výškou).
Tyto prediktory tak nezachycují topografický kontext lokality, ale heterogenitu reliéfu uvnitř jedné modelovací buňky.

#pagebreak()
#set page(flipped: true)

#[
  //zalamovani figure pres stranky
  #show figure.where(kind: table): set block(breakable: true) 

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
  ) <tab:dem>
]

#pagebreak()
#set page(flipped: false)

==== Horninový substrát

Geologické podloží je v této práci reprezentováno vrstvou GLiM (Global Lithological Map, @GLIM). Tento projekt poskytuje globální vektorovou mapu pevninských geologických jednotek.
Pro spolehlivěší pokrytí jednotlivých skupin hornin výskytovými daty byla vrstva nejprve reklasifikována do 3 tříd: _karbonátové_, _silikátové_ a _smíšené_ podloží (viz @tab:glim). Reklasifikace proběhla po vzoru práce #cite(<chauvier_2021>, form: "prose").
V druhém kroku byla reklasifikovaná vrstva rasterizována podle centroidu do všech využitých rozlišení buňek.

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
    Přehled reklasifikace geologického podloží.
    /*Přehled reklasifikace původních kategorií do tří základních typů geologického podloží podle práce #cite(<chauvier_2021>, form: "prose").*/]
) <tab:glim>

==== Půdní prediktory

Pro doplnění prediktorové sádky o informaci o půdních poměrech byly použity tři vrstvy z databáze _SoilGrids250m_ @soilgrids_250m.
Konkrétně šlo o absolutní hloubku k podloží (_absolute depth to bedrock_), udávanou v centimetrech, dostupnou vodní kapacitu do bodu vadnutí (_derived available soil water capacity until wilting point_), vyjádřenou jako objemový podíl, a půdní reakci měřenou ve vodě (_soil pH in H#sub("2")O_), zapsanou jako pH*10.

Vzhledem k tomu, že originální data jsou poskytována v hrubším měřítku, než nejjemnější měřítko využité v této práci, byla data pro rozlišení 100 a 200 m interpolována pomocí bilineární funkce. V případě agregace originálních dat do rozlišení 500 a 1000 m byl vypočítán průměr hodnot původních buňek.

Vzhledem k tomu, že půdní charakteristiky jsou v čase relativně dynamické, byly tyto prediktory využity pouze k trénování modelů, jejichž účelem nebylo extrapolovat rozšíření vhodných stanovišť do historických podmínek, případně do budoucnosti, ale pouze charakterizovat co nejvěrněji současné rozšíření.

==== Krajinný pokryv

Krajinný pokryv je v této práci reprezentován datasetem ESA WorldCover 2021. Tato data představují globální klasifikaci zemského povrchu v prostorovém rozlišení 10 m založenou na snímcích družic Sentinel-1 a Sentinel-2 @landcover_data. Dataset byl v této práci použit jako kategorický prediktor zachycující současný biotopový stav lokalit.

Data byla ručně stažena na základě prostorového dotazu z oficiálních #link("https://esa-worldcover.org/en")[stránek projektu].
Připravené dlaždice byly nejprve sloučeny do jedné mozaiky, oříznuty a maskovány polygonem studovaného území a následně reprojektovány do souřadnicového systému ETRS89-extended / LAEA Europe (EPSG: 3035). Základní vrstva byla dále informovaně agregována do rozlišení 100, 200, 500 a 1000 m podle modální hodnoty, přičemž byla zvýhodňována kategorie _bare/sparse vegetation_: v případě, že v buňce cílového rozlišení činil podíl této kategorie alespoň 5 %, byla celá buňka klasifikována jako _bare/sparse vegetation_. Tento postup měl omezit ztrátu prostorově málo rozsáhlých, avšak pro horské druhy potenciálně významných otevřených stanovišť při převodu do hrubšího rozlišení.

[[[kategorie LC]]]

Podobně jako DEM je i vrstva kategorizovaného krajinného pokryvu založená na datech dálkového průzkumu Země a jde tudíž o prostorově velmi přesný produkt s poměrně vysokou rozlišovací přesností. Určitou nevýhodou pro využití v SDM je ‒ podobně jako u půdních prediktorů ‒ nepřenositelnost v čase. Z tohoto důvodu nebyl krajinný pokryv zařazen do modelů určených pro temporální extrapolaci.

== Příprava dat
=== Modelovací měřítko GRAIN
=== Prostorová autokorelace výskytových dat CV folds

Data byla rozdělena do předem připravených prostorových foldů, přičemž v každém validačním kole byla část dat použita k fitování modelu a prostorově oddělená část k jeho testování. Tento postup měl omezit nadhodnocení predikční úspěšnosti, které může vznikat při náhodném dělení prostorově autokorelovaných dat, protože blízké lokality si bývají environmentálně i biologicky podobnější než lokality vzdálené [[[bahn_2012, valavi_2019]]].

=== Kolinearita prediktorů
=== Datové sady pro modelování

druh, grain, colinearity set, purpose

== Modelování vhodnosti stanoviště

Modely druhového rozšíření byly vytvářeny metodou ensemble of small models (_ESM_) podle metodiky #cite(<breiner_2015>, form: "prose"). Tento přístup byl zvolen kvůli relativně malému počtu pozorování modelovaných druhů a současně potřebě pracovat s větším množstvím environmentálních prediktorů. Vytvoření jednoho komplexního modelu obsahujícího všechny prediktory současně by v takové situaci mohlo vést k overfittingu. Metoda ESM tomuto riziku předchází tak, že namísto jednoho komplexního modelu vytváří všechny možné kombinace jednoduchých bivariátních modelů, které jsou testovány samostatně @lomba_2010 @breiner_2015.

Modelování probíhalo samostatně pro jednotlivé druhy a pro jednotlivá prostorová rozlišení prediktorů. Nejprve byly k bodovým výskytovým datům přiřazeny hodnoty všech prediktorů z příslušného souboru prediktorů. Každý záznam tak obsahoval informaci o presenci nebo absenci druhu, koordináty, váhu observace a hodnoty environmentálních prediktorů. Záznamy, pro které nebyla dostupná hodnota některého z použitých prediktorů, byly vyloučeny. Kategorické prediktory byly pro účely modelování převedeny na faktory.

Samotný modelovací proces začal vytvořením všech dostupných bivariátních kombinací pro každý použitý algoritmus:

$
N_"modelů" = N_"biv. kombinací prediktorů" times N_"algoritmů"
$

Pro všechny rostlinné druhy a pro všechna rozlišení prediktorů bo použito těchto 6 algoritmů: zobecněné lineární modely (_GLM_, #cite(<R>, form: "prose")), boosted regression trees (_GBM_, #cite(<gbm>, form: "prose")), zobecněné aditivní modely (_GAM_, #cite(<mgcv>, form: "prose")), klasifikační stromy (_CTA_, #cite(<rpart>, form: "prose")), multivariate adaptive regression splines (_MARS_, #cite(<earth>, form: "prose")) a random forest (_RF_, #cite(<ranger>, form: "prose")).

Jednotlivé bivariátní modely byly trénovány na předem připravených prostorových podmnožinách (CV fold, viz [[[kapitola??]]] @fig:ESM) observačních dat, kde část dat byla použita k fitování modelu a část k jeho testování. Výsledky této křížové validace byly pro každou jednu podmnožinu kvantifikovány pomocí Somersova D (dále také jako _S-D_, #cite(<somersD>, form: "prose") #cite(<Hmisc>, form: "prose")).

$ "Somersovo D" = 2 times ("AUC" - 0.5) $

Tato metrika vychází z běžně používaného AUC (_area under the receiver operating characteristic curve_), nabývá hodnot od _-1_ do _1_ a vyjadřuje diskriminační schopnost modelu, kde kladné hodnoty značí lepší než náhodné rozlišení presencí a absencí, zatímco nulové nebo záporné hodnoty ukazují na model s horší rozlišovací schopností než model náhodný.

V dalším kroku byly hodnoty Somersova D pro daný bivariátní model zprůměrovány a podrobeny porovnání s hraniční hodnotou 0. Bivariátní modely s průměrným S-D $<=$ 0 byly z dalších ananlýz vyloučeny.

Z bivariátních modelů, které prošly sítem, byl sestaven algoritmický soubor predikcí (_algo-ESM_, viz @fig:ESM), přičemž příspěvek jednotlivých bivariátních modelů byl vážen jejich průměrným výkonem. Modely s vyšší hodnotou S-D tak měly v algo-ESM větší vliv než modely s nižší, avšak stále kladnou úspěšností. Soubor predikcí byl sestaven pro každý algoritmus samostatně.

Predikce takto sestavených algo-ESM byla následně znovu vyhodnocena podle testovacích částí předpřipravených CV foldů a analogicky jako v kroku výše bylo vypočteno průměrné Somerovo D pro daný algo-ESM a porovnáno s hraniční hodnotou, přičemž algo-ESM s průměrným S-D $<=$ 0 byly z dalších analýz opět vyloučeny. Pokud v tomto kroku nastala situace, že S-D#sub("algo-ESM") $<=$ 0, došlo v daném běhu k efektivnímu vyloučení celé větve algoritmu z modelovacího procesu.

Po dokončení validačního procesu byly ponechané bivariátní modely znovu trénovány na celém dostupném datasetu. Tento krok zajistil, že finální ESM model využíval pro odhad vztahu mezi výskytem druhu a prostředím všechna cenná dostupná data. Relativní příspěvky jednotlivých bivariátních modelů natrénovaných na celém datasetu byly váženy přes váhy získané v prvním kroku sestavování algo-ESM a zároveň přes váhu algoritmu jako celku. Efektivní příspěvek bivariátního modelu je možné vyjádřit jako:

$
w_"efektivní" = w_"bivariátní model" times w_"mateřský algo-ESM"
$

kde $w_"efektivní"$ vyjadřuje intenzitu příspěvku bivariátního modelu do celkového ESM, $w_"bivariátní model"$ vyjadřuje váhu daného bivariátního modelu mezi všemi ostatními bivariátními modely stejného algoritmu a $w_"mateřský algo-ESM"$ vyjadřuje váhu celého algoritmu.

#figure(
  image("obj/pic/ESM_schema.png", height: 75%),
  caption: [
    Schematické znázornění modelovacího procesu ESM.
  ]
) <fig:ESM>

== Projekce
=== Projekce v prostoru
=== Projekce v prostoru a čase

[[[co ta budoucí projekce]]]

Vypočítané modely byly promítnuty do dvou historických a jednoho budoucího časového řezu. [[[]]]
Jako reprezentativní body v minulosti byly vybrány dva časové řezy: poslední glaciální maximum (LGM, 21k BP) a holocénní klimatické optimum (HCO, 8k BP). Jelikož se v obou případech jedná o sporné vymezení konkrétních událostí (např. #cite(<davis2003>, form: "prose") ukazují, že HCO se v jižní Evropě neprojevovalo tak silně jako v Evropě severní), je nutné vnímat zvolené časové řezy jako částečně arbitrární rozhodnutí.

== Metoda Shape jako odhad projekční extrpolace v prostoru

Metoda Shape @shape_2023 představuje nástroj určený k posouzení míry extrapolace při prostorové či časové projekci modelů vhodnosti stanoviště.
Jejím principem je porovnání podmínek prostředí v projekční oblasti s podmínkami, na jejichž základě byl model kalibrován.

Pro každou rastrovou buňku, je v mnohorozměrném environmentálním prostoru vypočítána Mahalanobisova vzdálenost ke každému bodu z trénovací sady a z této množiny je pro daný bod vybrána ta nejnižší (@fig:shape *(a)*).
Takto vypočtená vzdálenost je následně škálována disperzním faktorem trénovacích dat, čímž vzniká bezrozměrná metrika vyjadřující míru environmentální novosti dané lokality  (@fig:shape *(b)*).
Nízké hodnoty metriky Shape odpovídají podmínkám blízkým trénovacím datům, a tedy lokalitám, kde model interpoluje v rámci známého environmentálního prostoru.
Oproti tomu vysoké hodnoty ukazují, že projekce je prováděna do podmínek, které nejsou v trénovacích datech výrazněji zastoupeny, a predikce v daných lokalitách je proto zatížena vyšší nejistotou.
//Výhodou této metody je skutečnost, že při výpočtu nevychází pouze z centroidu trénovacích dat, ale zohledňuje jejich skutečné rozložení v environmentálním prostoru.
//Díky tomu lépe vystihuje celkový rozsah trénovacích podmínek a umožňuje rozlišit oblasti, kde model v prostoru interpoluje a kde už dochází k extrapolaci.

#figure(
  image("obj/pic/shape.jpg"),
  caption: [Grafické znázornění metody Shape v zjednodušeném dvourozměrném prostoru. *(a)* Reprezentuje výpočet Mahalanobisových vzdáleností mezi projekčním bodem a všemi trénovacími body. Nejnižší vzdálenost vyznačena oranžově. *(b)* Vyjádření metriky Shape _S#sub[pi]_ pro projekční body. _A_ značí disperzní faktor trénovacích dat. Vyšší hodnota _S#sub[pi]_ značí vyšší míru environmentální novosti a tudíž vyšší míru extrapolace modelu. Převzato z #cite(<shape_2023>, form: "prose")]
) <fig:shape>

[[[realizace Shape v diplomce]]]

== Prohlášení k metodám

Veškeré analýzy byly provedeny v prostředí R, verze 4.2.2 ‒ Innocent and Trusting @R s využitím těchto balíčků: _terra_, _sf_, _tidyverse_, _maptiles_, _blockCV_, _openeo_,
_collinear_, _corrplot_, _rnaturalearth_, _flexsdm_, _foreach_, _doParallel_, _parallelly_, _Hmisc_, _gbm_, _mgcv_, _rpart_, _earth_, _ranger_, _maps_ & _spatialEco_.

Vizualizace a kontrola výstupních rastrů probíhala v programu QGIS, verze 3.28.9 ‒ Firenze @QGIS_software.

#line(length: 100%)

Část výpočtů byla provedena s využitím výpočetních zdrojů MetaCentra.

#align(
  left
)[
  #block(
    width: 80%
  )[
    Computational resources were provided by the e-INFRA CZ project (ID:90254), supported by the Ministry of Education, Youth and Sports of the Czech Republic.
  ]
]

#line(length: 100%)

Prohlašuji, že při přípravě předložené práce byly použity následující nástroje AI uvedenými způsoby:

#align(
  left
)[
  #block(
    width: 80%
  )[
    *ChatGPT* v období *1. 11. 2025 – 7. 8. 2026*, popis použití: generování kódu k analýze dat, generování kódu využitého k sazbě práce, vyhledávání publikací a zpracování výtahů z nich, návrhy textů.
  ]
]
Po použití uvedených nástrojů umělé inteligence jsem důkladně revidoval a upravil obsah podle potřeby a plně přejímám odpovědnost za výslednou podobu práce.

#line(length: 100%)

Skripty využité v rámci této diplomové práce jsou dohledatelné ve veřejném repozitáři na GitHub na adrese #link("https://github.com/zbubster/Western-Balkans-SDM-thesis")[https://github.com/zbubster/Western-Balkans-SDM-thesis].

[[[vytvořit release a odkazovat na něj]]]

// # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
// výsledky
#pagebreak()
= Výsledky

// # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
// diskuse
#pagebreak()
= Diskuse

V této práci byla z důvodu metodické konzistence zvolena jednotná datová sada CHELSA-BIOCLIM @chelsa_bioclim_data & CHELSA-TraCE21k @chelsa_trace_data pro současné, budoucí i historické projekce. Tento přístup zajišťuje srovnatelnost mezi jednotlivými časovými řezy, avšak nezachycuje nejistotu spojenou s volbou klimatického datasetu. V oblastech s vyšší geomorfologickou členitostí je přesnost klimatickcých modelů sporná a volba konkrétního klimatického datasetu ovlivňuje výsledné křivky odpovědí druhů na konkrétní environmentální faktory i rozlohu a rozmístění modelem predikovaných vhodných stanovišť @input_matters_matter_2019
Pro vyšší důvěryhodnost projekcí je proto vhodné pracovat s více klimatickými modely a jednotlivé výsledky mezi sebou porovnávat. 

Dalším problematickým aspektem globálních klimatických modelů jsou extrapolace klimatu do hisotrických období.
#cite(<rentier_2025>, form: "prose") ukázali, že rekonstrukce ekologických fenoménů na základě klimatických projekcí se silně odlišují mezi jednotlivými datasety i mezi rekonstrukcemi založenými na proxy ukazatelích, přičemž slabší výsledky se projevovaly u klimatických datasetů s hrubším měřítkem. 
Chybovost klimatických modelů navíc vykazovala obecný trend k vyšším teplotám během LGM, obzvlášť v horských oblastech. @rentier_2025
Dataset CHELSA-TraCE21k ve zmíněné studii vykazoval v horských oblastech nejhorší výsledky, a to pravděpodobně kvůli nadprůměrně složitému procesu interpolace a zjemnňování originálních dat z meteorologických stanic, který v případě odlehlých horských oblastí vytvéřel za velké množství statistického šumu s 

Volba klimatického datasetu je tedy kruciální pro důvěryhodné modely současného a rekonstrukci historického rozšíření vhodných stanovišť.

V současné době je největší limitace datovými podklady, statistiku máme dostatečnou. Prediktorové sady vykazují značnou chybovost, obzvlášť v odlehlých oblastech. Geologické i půdní mapy jsou taky surově interpolované a založené na omezeném počtu pozorování. Nabízenou cestou jsou data z dálkového průzkumu Země, která se výše zmíněným nedostatkům vyhýbají: jsou měřena "přímo" na lokalitě, mají solidní časovou řadu a nadstandardní prostorové rozlišení. Na druhou stranu jsou produkty DPZ hůře ekologicky interpretovatelné a jejich zpracování vyžaduje vyšší nároky na výpočetní výkon.

Ačkoliv využití DPZ jako prediktorů v SDM je v současnosti zkoumáno a dosavadní výsledky ukazují na sporné vylepšení modelů, v jiných oblastech monitoringu přírody a krajiny nastává jejich rozvoj. Příkladem může být efektivní monitorování sucha a požárů, 

Modely je obecně potřeba interpretovat s opatrností.

// # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
// závěr
#pagebreak()
= Závěr

// # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
// literatura
#pagebreak()
= Literatura
#v(12pt)
#bibliography((
  "lit/literatura.bib",
  "lit/software.bib",
  "lit/predictors.bib"
),
  style: "copernicus",
  title: none)