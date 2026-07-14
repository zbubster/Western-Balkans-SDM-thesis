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
  #v(1mm)
  #text(size: 14pt)[*Přírodovědecká fakulta*]
]

#v(9mm)

#align(center)[
  Studijní program:
  #v(1mm)
  Botanika ‒ Geobotanika
]

#v(10mm)

#align(center)[#image(logo_path, width: 50mm)]

#v(10mm)

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
  Vedoucí práce:
  #v(1.5mm)
  #supervisor
]

#v(1fr)

#align(center)[Praha, 2026]

//#v(0.3fr)

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

S-D ‒ Somersovo D

GLM ‒ generalized linear model, zobecněný lineární model

GBM ‒ boosted regression trees

CTA ‒ klasifikační stromy

RF ‒ random forest

MARS ‒ multivariate adaptive regression splines

GAM ‒ generalized additive models, zobecněné aditivní modely

AUC ‒ area under the receiver operating characteristic curve, plocha pod ROC křivkou

GPS ‒ 

CV ‒

SSP ‒ shared socioeconomic pathways, scénáře socioekonomického vývoje

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

_Gentiana tergestina_ Beck. #linebreak()
_Gentiana tergestina_ je vytrvalá rostlina s nízkou, obvykle nevětvenou lodyhou zakončenou jedním sytě modrým květem. Listy jsou soustředěny především v přízemní růžici, lodyžní listy jsou menší a vyrůstají v 1-3 vstřícně uspořádaných párech (viz @fig:kytky *a*). Druh se vyskytuje převážně na subalpinských a alpinských loukách na vápenci. Těžiště rozšíření leží v horských oblastech Balkánského poloostrova, avšak druh je uváděin i mimo Balkán ze střední Itálie a Pyrenejí. @tutin_3 @josifovic_5 Přesné vymezení taxonu je dlouhodobě předmětem debat a v literatuře je možné se setkat i s označením _Gentiana verna_ subsp. _tergestina_. Molekulární studie však naznačují, že jde o dobře vymezený druh. @hammerli2007 @smycka2022tempo

_Gentiana dinarica_ Beck. #linebreak()
_Gentiana dinarica_ je vytrvalý zástupce rodu hořců (_Gentiana_) s přízemní růžicí široce eliptických listů a výraznými tmavěmodrými trubkovitými květy (viz @fig:kytky *b*). Ekologicky je vázána především na suché subalpinské a alpinské louky na vápencovém podloží. Vyskytuje se v horách západního Balkánu, avšak podobně jako u _G_. _tergestina_ se nejdná o čistě balkánský endemit, jelikož je jeho výskyt uváděn také ze střední Itálie a Pyrenejí. @tutin_3 @josifovic_5

_Phyteuma orbiculare_ L. #linebreak()
_Phyteuma orbiculare_ je vytrvalá bylina, charakteristická jednoduchou lodyhou a kulovitým květenstvím tvořeným modrými až tmavě fialovými květy (viz @fig:kytky *f*). Na rozdíl od balkánského druhu P. pseudorbiculare jde o šířeji rozšířený evropský taxon. Ekologicky je spojen především s travinnými stanovišti, včetně subalpinských a alpinských trávníků. @tutin_4

_Phyteuma pseudorbiculare_ Pant. #linebreak()
_Phyteuma pseudorbiculare_ je vytrvalý balkánský endemit příbuzný široce rozšířenému druhu _P_. _orbiculare_ a sesterský druhu _P_. _sieberi_ @smycka2022tempo @schneeweiss2013. Od druhu _P_. _orbiculare_, se kterým se vyskytuje v rámci Balkánského poloostrova na podobných lokalitách, se odlišuje mimo jiné tvarem listů a velmi krátkými, případně zcela chybějícími řapíky (viz @fig:kytky *g*). Kvete sytě modrými květy a roste především na alpinských pastvinách, na bázemi bohatém podloží. @tutin_4 @josifovic_6

_Primula kitaibeliana_ Schott #linebreak()
_Primula kitaibeliana_ je vytrvalá rostlina z rodu prvosenek (_Primula_). Druh je endemický pro západní Balkán s disjunktním rozšířením v pohoří Velebit a v centrální části Bosny a Hercegoviny. Vytváří listovou růžici a krátkou lodyhu nesoucí růžové (viz @fig:kytky *c*). Roste na kamenitých pastvinách a ve skalních štěrbinách, převážně na vápencovém podloží. @zhang2004

_Saxifraga blavii_ Beck. #linebreak()
_Saxifraga blavii_ je vytrvalá rostlina s obvykle větvenou lodyhou. Charakteristická je drobná přízemní růžice a olistěná žlaznatě chlupatá lodyha nesoucí větší množství bílých květů. Listy jsou podlouhlé a bývají zakončené třemi špičkami (viz @fig:kytky *d* & *e*). Druh je vázán na disturbovaná vysokohorská stanoviště, zejména skalky a sutě. Vyskytuje se výhradně v horách západního Balkánu. @tutin_1 @josifovic_4

#figure(
  image("obj/pic/kytky.png"),
  caption: [Studované druhy rostlin. *a*: _Gentinana tergestina_ Beck., *b*: _Gentiana dinarica_ Beck., *c*: _Primula kitaibeliana_ Schott., *d* & *e*: _Saxifraga blavii_ Beck., *f*: _Phyteuma orbiculare_ L. & *g*: _Phyteuma pseudorbiculare_ Pant. #linebreak() Foto *c* převzato od Felix Puff, *e* & *f* od Jana Smyčky, *a*, *b*, *d* & *g* autor.]
) <fig:kytky>

== Vstupní data
=== Data o výskytech druhů
==== Terénní sběr dat

Terénní sběr výskytových dat probíhal na předem vybraných lokalitách, u nichž bylo na základě nadmořské výšky a charakteru prostředí předpokládáno zastoupení alpinské vegetace. Průzkum byl směřován především do horských oblastí nad 1700 metrů nad mořem. Jednotlivé trasy terénního průzkumu byly vedeny směrem k vrcholovým partiím a tak, aby co nejlépe pokrývaly variabilitu stanovištních podmínek, ideálně v severo-jižní orientaci.
Při pohybu v terénu byly využívány zejména značené cesty, které umožňovaly lepší průchodnost terénem. Terénní práce probíhaly v letech 2020 ‒ 2023.

Během průzkumu byly zaznamenávány presenční body nalezených fokálních druhů a v případě, že se studované druhy podél trasy nevyskytovaly, také body absenční. Poloha jednotlivých záznamů byla určena pomocí GPS/*v mobilním zařízení v aplikaci QField*/ v souřadnicovém systému WGS 84 (EPSG:4326). U každého záznamu byl kromě polohy zaznamenán identifikátor nálezu, název druhu, stručný popis lokality a datum sběru. V okolí přibližně 30 m od každého nálezu byla kontrolována přítomnost dalších fokálních druhů a při jejich nalezení pro ně byly zaznamenány samostatné presenční body. V úsecích, kde druh souvisle pokrýval delší část trasy, byly body zapisovány přibližně po 100 m.

==== Příprava výskytových dat

Výskytová data byla před modelováním převedena do jednotné podoby a připravena samostatně pro jednotlivé modelované druhy. V prvním kroku byly sjednoceny názvy taxonů a odstraněny nekonzistence vzniklé při zápisu terénních dat, jako na příklad překlepy a observační body s evidentně chybným prostorovým zaměřením.

Pro každý fokální druh byla následně vytvořena samostatná vrstva obsahující všechny dostupné presence a absence, přičemž za absence daného druhu byly považovány globální absence (žádný z fokálních druhů se na lokalitě navyskytuje) a presence jiných druhů (na loklitě se vyskytuje druh X → absence pro všechny ostatní druhy).

K terénním datům byly u druhů _Gentiana tergestina_ a _Primula kitaibeliana_ připojeny také externí nálezové záznamy z _Flora Croatica Database_ @flora_croatica_database, které nesly pouze informaci o přítomnosti. Tyto záznamy byly proto do dat zahrnuty až později a výhradně jako presence. Z databáze byla vybrána pouze pozorování georeferencovaná podle GPS.

Takto sestavené datové sady byly následně porovnány s referenčními rastry prediktorů ve všech využitých prostorových rozlišeních. Na výskytová data byl aplikován filtr, jehož účelem bylo, aby pro každou buňku referenčního rastru, která se překrývá s výskytovými daty, byl zachován pouze jeden výskytový záznam. V případě, že do jedné buňky spadalo více observačních dat, byly před absencemi preferovány presence. Výsledkem byly sady výskytových dat ve stejném prostorovém rozlišení jako sady prediktorů a očištěné o nadbytečné absenční body (eventuelně očištěné i o body presenční, pokud spadalo více záznamů stejného druhu do identické rastrové buňky).

V dalším kroku byly jednotlivým pozorováním přiřazeny váhy, aby byla při modelování vyrovnána odlišná četnost presencí a absencí, zohledněn původ presenčních záznamů a také nejistota ohledně spolehlivosti absenčních bodů (např. přehlédnutí jedince) @benkendorf_2023. Celková váha byla rozdělena mezi presence a absence v poměru 1 : 1, takže obě třídy měly na fitování modelů stejný souhrnný vliv.

U presenčních záznamů byl dále zohledněn jejich zdroj @fletcher_2019 @zhang_2020. Presencím pocházejícím z provedených terénních prací byla přidělena oproti záznamům databázovým dvojnásobná váha. Důvodem k tomuto rozhodnutí byl předpoklad, že terénní sběr byl, na rozdíl od databázových položek, proveden přímo za účelem této práce a lokality byly vybírány tak, aby došlo k co možná nejlepšímu pokrytí studované oblasti. Databázová data byla naopak lokalizována výhradně na území Chorvatska a sbírána podle neznámé metodiky v odlišném časovém rozmezí.

==== Prostorová autokorelace výskytových dat <chap:CV>

Pro hodnocení výkonu modelů byly připraveny prostorově oddělené křížově-validační soubory výskytových dat (také CV ‒ cross-validační ‒ foldy). Tento proces byl proveden pro každou kombinaci druhu a prostorového rozlišení samostatně. Cílem tohoto dělení bylo omezit prostorovou autokorelaci výskytových dat a zamezit tak nadhodnocení predikční úspěšnosti. @dormann_2007 @bahn_2013 @roberts_2016

Nejprve byla pomocí funkce _cv_spatial_autocor_ z balíčku _blockCV_ @blockCV odhadnuta prostorová autokorelace výskytových dat. Na základě vypočteného dosahu byla stanovena velikost prostorových bloků. Tyto bloky byly následně přiřazeny do cross-validačních foldů pomocí iterativního náhodného rozdělování tak, aby počet výskytových záznamů byl mezi foldy co nejvíce vyvážen. Druhou důležitou podmínkou bylo, aby v každém foldu byly pro daný druh jak presenční, tak absenční záznamy. Aby byly podmínky obě podmínky vyváženosti splněny, byl konečný počet cross-validačních foldů pro každý druh optimalizován zvlášť.

=== Prediktory

V rámci této práce byly k trénování modelů rozšíření vhodných stanovišť využity prediktory z pěti základních skupin:
+ *klimatické* prediktory charakterizující na hrubém měřítku variabilitu teploty a srážek
+ *topografické* prediktory jejichž účelem je postihnout jemnější variabilitu mikrostanovišťních podmínek
+ *horninový* substrát sloužící jako základní charakteristika geologických poměrů na regionální úrovni
+ *půdní* prediktory rozvíjejí informaci o půdních poměrech na úrovni lokalit a je možné považovat je za ekologicky relevantnější než samotný geologický substrát [[[zdroj]]]
+ *krajinný pokryv* klasifikuje povrch Země do základních formačních skupin a jako jediný prediktor přináší do modelů informaci, která je vzdáleně schopna charakterizovat biotické faktory [[[zdroj]]]

==== Klimatické prediktory <chap:climate_pred>

Jedním z důležitých metodických rozhodnutí při přípravě environmentálních prediktorů je volba klimatického datasetu pro současné, budoucí a historické projekce. Srovnávací studie ukazují, že teplotní proměnné klimatických datasetů jsou obvykle konzistentní, zejména díky silné vazbě teploty a nadmořské výšky. Výraznější rozdíly se však objevují u srážkových proměnných, jejichž prostorové rozložení je v horském prostředí ovlivněno lokální cirkulací vzduchu, která je pod rozlišovací schopností globálních klimatických modelů. @bobrowski_2017 @fierke_2024

[[[možná do úvodu?? ↑↑↑]]]

Pro tuto práci byl zvolen dataset CHELSA @chelsa_bioclim_model @chelsa_bioclim_data, a to především kvůli jeho vhodnosti pro modelování v topograficky členitých oblastech. @bobrowski_2017 

Dataset CHELSA-BIOCLIM je globální klimatický dataset s vysokým prostorovým rozlišením 30 úhlových sekund (cca 1 km#super([2])).
Vychází z hrubších klimatických dat, která jsou zpřesněna pomocí topografických modelů, jejichž využití umožňuje kromě výpočtu vlivu nadmořské výšky i zohlednění topografické sitace na proudění vzduchu. V táto práci jsou využity bioklimatické charakteristiky podchycující roční a sezónní variability klimatu v prostoru (bio01-bio19). @chelsa_bioclim_model
Do analýz navíc vstupoval i prediktor popisující počet dní v roce, kdy je na daném místě přítomna sněhová pokrývka (snow cover days, scd).

#import "typst/tables/pred_clim.typ": pred_clim
#pred_clim

Kromě charakterizace současného klimatu poskytuje dataset CHELSA-BIOCLIM i pro tři časové řezy (2011–2040, 2041–2070 & 2071–2100) modely extrapolující klima do budoucnosti (tzv. earth system models:
GFDL-ESM4 @GFDL-ESM,
IPSL-CM6A-LR @IPSL-CM6A-LR,
MPI-ESM 1-2-HR @MPI-ESM1-2-HR,
MRI-ESM2-0 @MRI-ESM2-0,
&
UKESM1-0-LL @UKESM1-0-LL)
na základě různých emisních scénářů SSP (shared socioeconomic pathways: SSP1-2.6, SSP3-7.0 & SSP5-8.5 @oneil__cmip6_2016).

S ohledem na zachování metodické konzistence mezi jednotlivými časovými řezy byl pro projekci modelů na historické klimatické podmínky použit dataset CHELSA-TraCE21k-bioclim @chelsa_trace_data @chelsa_trace_model, který poskytuje klimatické rekonstrukce od posledního glaciálního maxima po současnost v časových krocích 100 let a prostorovém rozlišení 30 úhlových sekund (cca 1 km#super([2])).

Klimatické prediktory byly před vstupem do modelů prostorově sjednoceny s ostatními rastrovými vrstvami. Nejprve byly reprojektovány do souřadnicového systému ETRS89-extended / LAEA Europe (EPSG:3035) a zarovnány na referenční rastr odpovídající nejhrubšímu použitému prostorovému rozlišení 1000 m, přičemž byla použita metoda nejbližšího souseda, aby nedocházelo k interpolaci. Takto připravené vrstvy byly následně převedeny do jemnějších modelovacích rozlišení tak, že každá jemnější dceřinná buňka přebírala hodnotu příslušné mateřské buňky. Tento postup zachoval původní informační obsah klimatických dat a zároveň umožnil jejich kombinaci s prediktory dostupnými v jemnějších prostorových rozlišeních.

==== Topografické prediktory

Pro analýzu topografie byl v této práci použit globální elevační dataset _Copernicus DEM 30_ s prostorovým rozlišením 30 m#super([2]). @copernicus_DEM
Tento model je odvozen z dat mise dálkového průzkumu Země TanDEM-X a poskytuje tak nejpřesnější prostorové i absolutní zaměření poměrů na daných lokalitách mezi prediktory využitými v této práci.

Data byla získána prostřednictvím prostorového požadavku ve službě Copernicus Data Space Ecosystem @CDSE zprostředkovaného _openEO_ klientem v prostředí R. @openeo_R Stažené rastrové dlaždice byly následně sloučeny do mozaiky, reprojektovány do souřadnicového systému ETRS89-extended / LAEA Europe (EPSG: 3035) a maskovány polygonem zájmového území.

Topografické prediktory využité v této práci lze rozdělit do dvou skupin podle toho, jak popisují prostorové fenomény. První skupina charakterizuje vztah cílové buňky k jejímu okolí pomocí pohyblivého okna 3*3 buňky, tedy lokální topografický kontext. Druhá skupina popisuje vnitřní elevační variabilitu dané buňky při převodu z jemnějšího na hrubší prostorové měřítko. Přehled topografických prediktorů viz @tab:pred_dem.

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
  #show figure.where(kind: table): set block(breakable: true) 
  #import "typst/tables/pred_dem.typ": pred_dem
  #pred_dem
]

#pagebreak()
#set page(flipped: false)

==== Horninový substrát

Geologické podloží je v této práci reprezentováno vrstvou GLiM (Global Lithological Map, @GLIM). Tento projekt poskytuje globální vektorovou mapu pevninských geologických jednotek.
Pro spolehlivěší pokrytí jednotlivých skupin hornin výskytovými daty byla vrstva nejprve reklasifikována do 3 tříd: _karbonátové_, _silikátové_ a _smíšené_ podloží (viz @tab:pred_geo). Reklasifikace proběhla po vzoru práce #cite(<chauvier_2021>, form: "prose").
V druhém kroku byla reklasifikovaná vrstva rasterizována podle centroidu do všech využitých rozlišení buňek s využitím souřadnicového systému ETRS89-extended / LAEA Europe (EPSG: 3035).

#import "typst/tables/pred_geo.typ": pred_geo
#pred_geo

==== Půdní prediktory

Pro doplnění prediktorové sádky o informaci o půdních poměrech byly použity tři vrstvy z databáze _SoilGrids250m_ @soilgrids_250m.
Konkrétně šlo o absolutní hloubku k podloží (_absolute depth to bedrock_), udávanou v centimetrech, dostupnou vodní kapacitu do bodu vadnutí (_derived available soil water capacity until wilting point_), vyjádřenou jako objemový podíl, a půdní reakci měřenou ve vodě (_soil pH in H#sub("2")O_), zapsanou jako pH*10.

Originální rastrová data byla prostorově sjednocena s referenčními rastry, avšak vzhledem k tomu, že jsou poskytována v hrubším měřítku, než nejjemnější měřítko využité v této práci, byla data pro rozlišení 100 a 200 m interpolována pomocí bilineární funkce. V případě agregace originálních dat do rozlišení 500 a 1000 m byl vypočítán průměr hodnot původních buňek. V rámci zmíněných operací byla data projektována do souřadnicového systému ETRS89-extended / LAEA Europe (EPSG: 3035).

Vzhledem k tomu, že půdní charakteristiky jsou v čase relativně dynamické, byly tyto prediktory využity pouze k trénování modelů, jejichž účelem nebylo extrapolovat rozšíření vhodných stanovišť do historických podmínek, případně do budoucnosti, ale pouze charakterizovat co nejvěrněji současné rozšíření.

==== Krajinný pokryv

Krajinný pokryv je v této práci reprezentován datasetem ESA WorldCover 2021. Tato data představují globální klasifikaci zemského povrchu v prostorovém rozlišení 10 m založenou na snímcích družic Sentinel-1 a Sentinel-2 @landcover_data. Dataset byl v této práci použit jako kategorický prediktor zachycující současný biotopový stav lokalit.

Data byla ručně stažena na základě prostorového dotazu z oficiálních #link("https://esa-worldcover.org/en")[stránek projektu].
Připravené dlaždice byly nejprve sloučeny do jedné mozaiky, oříznuty a maskovány polygonem studovaného území a následně reprojektovány do souřadnicového systému ETRS89-extended / LAEA Europe (EPSG: 3035). Základní vrstva byla dále informovaně agregována do rozlišení 100, 200, 500 a 1000 m podle modální hodnoty, přičemž byla zvýhodňována kategorie _bare/sparse vegetation_: v případě, že v buňce cílového rozlišení činil podíl této kategorie alespoň 5 %, byla celá buňka klasifikována jako _bare/sparse vegetation_. Tento postup měl omezit ztrátu prostorově málo rozsáhlých, avšak pro horské druhy potenciálně významných otevřených stanovišť při převodu do hrubšího rozlišení.

[[[kategorie LC]]]

Podobně jako DEM je i vrstva kategorizovaného krajinného pokryvu založená na datech dálkového průzkumu Země a jde tudíž o prostorově velmi přesný produkt s poměrně vysokou rozlišovací přesností. Určitou nevýhodou pro využití v SDM je ‒ podobně jako u půdních prediktorů ‒ nepřenositelnost v čase. Z tohoto důvodu nebyl krajinný pokryv zařazen do modelů určených pro temporální extrapolaci.

== Příprava dat
=== Datové sady pro modelování, kolinearita prediktorů

Před samotným modelováním byly pro všechny environmentální prediktory upraveny prostorové parametry tak, aby výsledné vrstvy byly prostorově jednotné. Jednotlivé vrstvy prediktorů byly zarovnány na společné referenční rastry, reprojektovány do souřadnicového systému ETRS89-extended / LAEA Europe (EPSG: 3035) a maskovány podle polygonu studovaného území. Prediktory byly podle typu dat převzorkovány nebo agregovány do prostorových rozlišení využitých v této práci, čímž vznikla sada vzájemně kompatibilních rastrových vrstev pro modelovací měřítka 100, 200, 500 a 1000 m.

Z takto připravených vrstev byly následně vytvořeny výchozí rastrové soubory (stacks) obsahující všechny kandidátní environmentální prediktory dostupné pro dané prostorové rozlišení. Pro účely temporálních projekcí byla navíc připravena užší varianta prediktorových souborů, ze které byly vyloučeny prediktory reprezentujícíc v čase proměnlivé fenomény a tudíž nevhodné pro extrapolaci mimo současnost (krajinný pokryv a pedologické vrstvy).

Na připravených souborech byla následně posouzena kolinearita prediktorů. Hodnoty prediktorů byly extrahovány pro tuto analýzu extrahovány dvojím způsobem: (i) z buňek pozorování jednotlivých druhů a (ii) v náhodně vybraném vzorku 50 tisíců buněk studovaného území. Dichotomie tohoto vzorkování měla v prvním případě předejít kolinearitě v datech, která přímo vstupují do modelu a ve druhém případě obecné kolinearitě, kterou by kvůli specifickým podmínkám vzorkovaných lokalit neodhalil přístup první.

 Pro každý druh a každé prostorové rozlišení byl na extrahovaných vzorcích proveden poloautomatizovaný výběr proměnných s využitím balíčku _collinear_ @collinear. V rámci procesu byla kolinearita posuzována pomocí párové Pearsnovy korelace a podle faktoru inflace variance (VIF, variance inflation factor). Prahová hodnota maximální povolené korelace byla stanovena na r = 0.7 a maximální VIF = 7 @dormann2013collinearity. Výsledky byly vizualizovány pomocí balíčku _corrplot_ @corrplot.

Automatizované rozhodování mezi kolineárními prediktory bylo doplněno předem stanoveným prioritním pořadím proměnných. Účelem tohoto pořadí bylo prioritizovat ekologicky relevantní prediktory a naopak upozadit prediktory s relativně komplikovanou interpretovatelností @soley_2024_TOPTENHAZARDS @dormann2013collinearity a evidentními artefakty (např. CHELSA-BIOCLIM: bio08, bio9 mají v oblasti Balkánského poloostrova velmi ostré prostorové přechody mezi hodnotami, které ‒ dle soukromé úvahy autora ‒ nemohou mít fyzikální opodstatnění).

#table(
  columns: (18%, 56%, 26%),
  inset: 4pt,
  align: left,
  [Varianta], [Preferenční pořadí prediktorů], [Vyloučené prediktory],

  [*Bez #linebreak() temporální extrapolace*],
  [
    #set par(justify: false)
    #emph[bio06], #emph[bio05], #emph[bio10], #emph[bio11], #emph[scd], #emph[landcover], #emph[northness], #emph[bio14], #emph[bio12], #emph[HLI], #emph[TWI], #emph[dem_range], #emph[dem_sd], #emph[slope], #emph[TPI], #emph[TRI], #emph[TRI_riley], #emph[TRI_rmsd], #emph[bio18], #emph[bio19], #emph[bio04], #emph[bio01], #emph[bedrock], #emph[eastness], #emph[dem_median], #emph[aspect], #emph[depth_to_bedrock], #emph[pH_in_H2O], #emph[soil_water_cap], #emph[bio02], #emph[bio03], #emph[bio15]
    ],
  [
    #set par(justify: false)
    #emph[bio08], #emph[bio09], #emph[flowdir]
    ],

  [*Temporální extrapolace*],
  [
    #set par(justify: false)
    #emph[bio10], #emph[bio11], #emph[northness], #emph[scd], #emph[bio06], #emph[bio05], #emph[dem_sd], #emph[dem_range], #emph[TPI], #emph[TRI], #emph[TRI_riley], #emph[TRI_rmsd], #emph[bio18], #emph[bio19], #emph[bio04], #emph[bio01], #emph[slope], #emph[eastness], #emph[bedrock], #emph[dem_median], #emph[aspect], #emph[bio02], #emph[bio03], #emph[bio15]
    ],
  [
    #set par(justify: false)
    #emph[bio08], #emph[bio09], #emph[landcover], #emph[pH_in_H2O], #emph[HLI], #emph[soil_water_cap], #emph[depth_to_bedrock], #emph[TWI], #emph[flowdir]
    ],
)

Výsledkem filtrace byly dvě sady prediktorů pro každý druh. První sada zahrnovala všechny prediktory vybrané analýzou kolinearity, přičemž byl brán zřetel pouze na kolineární strukturu v dané kobinaci druh-prostorové rozlišení. Druhá sada byla omezena pouze na prediktory, které byly pro daný druh vybrány konzistentně napříč všemi prostorovými rozlišeními. Tato druhá společná sada umožnila srovnávat modely mezi různými prostorovými rozlišeními buňek, tj. modely trénované na stejné prediktorové sadě, avšak s jiným rozlišením. [[[]]]

Takto vytvořené soubory prediktorů posloužily přímo jako vstupní data do navazujících analýz, tedy do samotného procesu modelování rozšíření vhodných stanovišť.

== Modelování vhodnosti stanoviště

Modely druhového rozšíření byly vytvářeny metodou ensemble of small models (_ESM_) podle metodiky #cite(<breiner_2015>, form: "prose"). Tento přístup byl zvolen kvůli relativně malému počtu pozorování modelovaných druhů a současně potřebě pracovat s větším množstvím environmentálních prediktorů. Vytvoření jednoho komplexního modelu obsahujícího všechny prediktory současně by v takové situaci mohlo vést k overfittingu. Metoda ESM tomuto riziku předchází tak, že namísto jednoho komplexního modelu vytváří všechny možné kombinace jednoduchých bivariátních modelů, které jsou testovány samostatně @lomba_2010 @breiner_2015.

Modelování probíhalo samostatně pro jednotlivé druhy a pro jednotlivá prostorová rozlišení prediktorů. Nejprve byly k bodovým výskytovým datům přiřazeny hodnoty všech prediktorů z příslušného souboru prediktorů. Každý záznam tak obsahoval informaci o presenci nebo absenci druhu, koordináty, váhu observace a hodnoty environmentálních prediktorů. Záznamy, pro které nebyla dostupná hodnota některého z použitých prediktorů, byly vyloučeny. Kategorické prediktory byly pro účely modelování převedeny na faktory.

Samotný modelovací proces začal vytvořením všech dostupných bivariátních kombinací pro každý použitý algoritmus:

$
N_"modelů" = N_"biv. kombinací prediktorů" times N_"algoritmů"
$

Pro všechny rostlinné druhy a pro všechna rozlišení prediktorů bo použito těchto 6 algoritmů: zobecněné lineární modely (_GLM_, #cite(<R>, form: "prose")), boosted regression trees (_GBM_, #cite(<gbm>, form: "prose")), zobecněné aditivní modely (_GAM_, #cite(<mgcv>, form: "prose")), klasifikační stromy (_CTA_, #cite(<rpart>, form: "prose")), multivariate adaptive regression splines (_MARS_, #cite(<earth>, form: "prose")) a random forest (_RF_, #cite(<ranger>, form: "prose")).

Jednotlivé bivariátní modely byly trénovány na předem připravených prostorových podmnožinách (CV fold, viz @chap:CV [[[kapitola??]]] @fig:ESM) observačních dat, kde část dat byla použita k fitování modelu a část k jeho testování. Výsledky této křížové validace byly pro každou jednu podmnožinu kvantifikovány pomocí Somersova D (dále také jako _S-D_, #cite(<somersD>, form: "prose") #cite(<Hmisc>, form: "prose")).

$ "Somersovo D" = 2 times ("AUC" - 0.5) $

Tato metrika vychází z běžně používaného AUC (_area under the receiver operating characteristic curve_), nabývá hodnot od _-1_ do _1_ a vyjadřuje diskriminační schopnost modelu, kde kladné hodnoty značí lepší než náhodné rozlišení presencí a absencí, zatímco nulové nebo záporné hodnoty ukazují na model s horší rozlišovací schopností než model náhodný.

V dalším kroku byly hodnoty Somersova D pro daný bivariátní model zprůměrovány a podrobeny porovnání s hraniční hodnotou 0. Bivariátní modely s průměrným S-D $<=$ 0 byly z dalších ananlýz vyloučeny.

Z bivariátních modelů, které prošly sítem, byl sestaven algoritmický soubor predikcí (_algo-ESM_, viz @fig:ESM), přičemž příspěvek jednotlivých bivariátních modelů byl vážen jejich průměrným výkonem. Modely s vyšší hodnotou S-D tak měly v algo-ESM větší vliv než modely s nižší, avšak stále kladnou úspěšností. Soubor predikcí byl sestaven pro každý algoritmus samostatně.

Predikce takto sestavených algo-ESM byla následně znovu vyhodnocena podle testovacích částí předpřipravených CV foldů a analogicky jako v kroku výše bylo vypočteno průměrné Somersovo D pro daný algo-ESM a porovnáno s hraniční hodnotou, přičemž algo-ESM s průměrným S-D $<=$ 0 byly z dalších analýz opět vyloučeny. Pokud v tomto kroku nastala situace, že S-D#sub("algo-ESM") $<=$ 0, došlo v daném běhu k efektivnímu vyloučení celé větve algoritmu z modelovacího procesu.

Po dokončení validačního procesu byly ponechané bivariátní modely znovu trénovány na celém dostupném datasetu. Tento krok zajistil, že finální ESM model využíval pro odhad vztahu mezi výskytem druhu a prostředím všechna cenná dostupná data. Relativní příspěvky jednotlivých bivariátních modelů natrénovaných na celém datasetu byly váženy přes váhy získané v prvním kroku sestavování algo-ESM a zároveň přes váhu algoritmu jako celku. Efektivní příspěvek bivariátního modelu je možné vyjádřit jako:

$
w_"efektivní" = w_"bivariátní model" times w_"mateřský algo-ESM"
$

kde $w_"efektivní"$ vyjadřuje intenzitu příspěvku bivariátního modelu do celkového ESM, $w_"bivariátní model"$ vyjadřuje váhu daného bivariátního modelu mezi všemi ostatními bivariátními modely stejného algoritmu a $w_"mateřský algo-ESM"$ vyjadřuje váhu celého algoritmu.

Finální predikční výkonnost celého ensemble modelu byla vyjádřena pomocí jediné  hodnoty Somersova D. Tato souhrnná hodnota byla vypočítána během jednotlivých cross validačních kroků z (i) projekce vážených predikcí bivariátních modelů na testovací část datového souboru v rámci jednoho algoritmu a (ii) projekce vážených predikcí jednotlivých algoritmických ESM na testovací část datového souboru. Tím vznikla dvojitě vážená predikce pro každý jeden testovací bod a po proběhnutí procesu na všech cross validačních souborech byly tyto predikce spojeny do jednoho vektoru a na něm spočítáno finální Somersovo D pro celý model.

#figure(
  image("obj/pic/ESM_schema.png", height: 90%),
  caption: [
    Schematické znázornění modelovacího procesu ESM.
  ]
) <fig:ESM>

== Projekce
=== Projekce v prostoru
=== Projekce v prostoru a čase

Vypočítané modely byly promítnuty do dvou historických a dvou budoucích časových řezů. Jako reprezentativní body v minulosti byly vybrány dva časové řezy: poslední glaciální maximum (LGM, 21k BP) a holocénní klimatické optimum (HCO, 8k BP). Jelikož se v obou případech jedná o sporné vymezení konkrétních událostí (např. #cite(<davis2003>, form: "prose") ukazují, že HCO se v jižní Evropě neprojevovalo tak silně jako v Evropě severní), je nutné vnímat zvolené časové řezy jako částečně arbitrární rozhodnutí.

Pro vyjádření budoucí potenciální vhodnosti stanovišť byly jednotlivé projekce agregovány napříč použitými klimatickými projekčními modely (earth system models, viz výše), přičemž časové řezy a scénáře SSP byly ponechány odděleně. Z možných časových řezů, připravených v rámci projektu CHELSA-BIOCLIM, byly ponechány pouze projekce do rozmezí 2041 ‒ 2070 & 2071 ‒ 2100. Agregace probíhala samostatně pro každou kombinaci druhu, prostorového rozlišení, časového řezu a scénáře SSP. Výsledná konsenzuální projekce byla vypočtena jako průměr predikované vhodnosti stanoviště z jednotlivých projekcí založených na různých earth system models. Současně byla pro stejnou sadu projekcí vypočtena směrodatná odchylka, jako vyjádření mezimodelové variability. Tento postup byl zvolen, jelikož projekce rozšíření vhodných stanovišť do budoucích klimatických podmínek jsou zatíženy nejen nejistotou spojenou se samotným modelem rozšíření, ale také s volbou klimatického modelu a emisního scénáře. Ačkoli v literatuře se obvykle přistupuje k sofistikovanějším metodám spojování predikcí i jednoduchá agregace může omezit závislost interpretace na jednom konkrétním klimatickém modelu @araujo_2007. @araujo_2005 [[[]]]

Směrodatná odchylka zde tedy nepředstavuje variabilitu v modelech samotných, ale jenom prostorové vyjádření rozdílů mezi projekcemi založenými na různých klimatických modelech v rámci stejného scénáře SSP.

== Metoda Shape jako odhad projekční extrpolace v prostoru

Metoda Shape @shape_2023 představuje nástroj určený k posouzení míry extrapolace při prostorové či časové projekci modelů vhodnosti stanoviště.
Jejím principem je porovnání podmínek prostředí v projekční oblasti s podmínkami, na jejichž základě byl model kalibrován.

Pro každou rastrovou buňku je v mnohorozměrném environmentálním prostoru vypočítána Mahalanobisova vzdálenost ke každému bodu z trénovací sady a z této množiny je pro daný bod vybrána ta nejnižší (@fig:shape *(a)*).
Takto vypočtená vzdálenost je následně škálována disperzním faktorem trénovacích dat, čímž vzniká bezrozměrná metrika vyjadřující míru environmentální novosti dané lokality (@fig:shape *(b)*).
Nízké hodnoty metriky Shape odpovídají podmínkám blízkým trénovacím datům, a tedy lokalitám, kde model interpoluje v rámci známého environmentálního prostoru.
Oproti tomu vysoké hodnoty ukazují, že projekce je prováděna do podmínek, které nejsou v trénovacích datech výrazněji zastoupeny, a predikce v daných lokalitách je proto zatížena vyšší nejistotou.
//Výhodou této metody je skutečnost, že při výpočtu nevychází pouze z centroidu trénovacích dat, ale zohledňuje jejich skutečné rozložení v environmentálním prostoru.
//Díky tomu lépe vystihuje celkový rozsah trénovacích podmínek a umožňuje rozlišit oblasti, kde model v prostoru interpoluje a kde už dochází k extrapolaci.

#figure(
  image("obj/pic/shape.jpg"),
  caption: [Grafické znázornění metody Shape v zjednodušeném dvourozměrném prostoru. *(a)* Reprezentuje výpočet Mahalanobisových vzdáleností mezi projekčním bodem a všemi trénovacími body. Nejnižší vzdálenost vyznačena oranžově. *(b)* Vyjádření metriky Shape _S#sub[pi]_ pro projekční body. _A_ značí disperzní faktor trénovacích dat. Vyšší hodnota _S#sub[pi]_ značí vyšší míru environmentální novosti a tudíž vyšší míru extrapolace modelu. Převzato z #cite(<shape_2023>, form: "prose")]
) <fig:shape>

V rámci této práce je metrika Shape hlavní metodou k posuzování míry extrapolace. Za tímto účelem byla její distribuce pro každý model i projekci vykreslena v prostoru, což umožňuje posuzovat věrohodnost predikce modelu na vybraných lokalitách, a v bivariátních grafechm které ukazují distribuci kombinací hodnot prediktorů ve dvourozměrném prostoru a unadňují posouzení dostatečnosti provzorkování gradientů.

== Prohlášení k metodám

Veškeré analýzy byly provedeny v prostředí R, verze 4.2.2 ‒ Innocent and Trusting @R s využitím těchto balíčků: _terra_, _sf_, _tidyverse_, _maptiles_, _blockCV_, _openeo_,
_collinear_, _corrplot_, _rnaturalearth_, _flexsdm_, _foreach_, _doParallel_, _parallelly_, _Hmisc_, _gbm_, _mgcv_, _rpart_, _earth_, _ranger_, _maps_ & _spatialEco_. 

[[[doplnit]]]

Vizualizace a kontrola výstupních rastrů probíhala v programu QGIS, verze 3.28.9 ‒ Firenze @QGIS_software.

#line(length: 100%)

Část výpočtů byla provedena s využitím výpočetních zdrojů MetaCentra.

#align(
  center
)[
  #block(
    width: 90%
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

== Modelové sady

Pro každý ze šesti studovaných druhů a každé ze čtyř prostorových rozlišení (1000 m, 500 m, 200 m, 100 m) byly vytvořeny tři samostatné varianty ensemble of small models (ESM), lišící se sadou vstupních prediktorů.

První varianta zahrnovala pouze prediktory extrapolovatelné v čase. Modely natrénované na současných environmentálních podmínkách byly kromě projekce pro současné podmínky taktéž projektovány na dvě období minulosti (21k BP, LGM & 8k BP, HCO) a dvě období budoucnosti (2041-2070 & 2071-2100), přičemž pro každý řez v budoucnosti byly samostatně zpracovány tři scénáře sdílených socioekonomických trajektorií (SSP1-2.6, SSP3-7.0 a SSP5-8.5). Déle _Modely na extrapolovatelných prediktorech_.

Druhá varianta vycházela ze všech vybraných prediktorů, včetně proměnných, které nebylo možné smysluplně přenášet v čase (např. krajinný pokryv, půdní prediktory). Tyto modely slouží především k co nejúplnějšímu popisu současného rozšíření vhodných stanovišť. Dále _Modely na všech prediktorech_.

Třetí varianta byla založena na sadě prediktorů společné všem prostorovým rozlišením daného druhu (tj. splňovaly podmínky kolinearity pro ve všech rozlišeních). Tato varianta tak umožňuje porovnání vlivu velikosti prostorového měřítka na výsledky modelování. Dále _Modely na společných prediktorech_.

Napříč všemi druhy a rozlišeními bylo tedy celkem vytvořeno 72 finálních ESM, ze kterých vzniklo 72 projekcí současné vhodnosti stanovišť a 192 časově extrapolovaných projekcí, tedy celkem 264 projekcí.

// # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
// výsledky
#pagebreak()
= Výsledky

#pagebreak()
#set page(flipped: true)

#import "typst/tables/res_observ.typ": observ_table
#observ_table


#pagebreak()
#set page(flipped: false)

== Modely na extrapolovatelných prediktorech

#import "typst/tables/res_extrapol.typ": extrapol_result_table
#extrapol_result_table

#import "typst/functions/extrapol_proj_grid.typ": extrapol_proj_grid

=== _Gentiana dinarica_

#extrapol_proj_grid(
  species: "GD",
  grain: 500,
  caption: "Projekce pro nejúspěšněnší ESM druhu Gentiana dinarica v rozlišení 500 m (Somersovo D: 0,721)."
)

=== _Gentiana tergestina_

#extrapol_proj_grid(
  species: "GT",
  grain: 200,
  caption: "Projekce pro nejúspěšněnší ESM druhu Gentiana tergestina v rozlišení 200 m (Somersovo D: 0,48)."
)

=== _Primula kitaibeliana_

#extrapol_proj_grid(
  species: "PK",
  grain: 200,
  caption: "Projekce pro nejúspěšněnší ESM druhu Primula kitaibeliana v rozlišení 200 m (Somersovo D: 0,839)."
)

=== _Phyteuma orbiculare_

#extrapol_proj_grid(
  species: "PO",
  grain: 1000,
  caption: "Projekce pro nejúspěšněnší ESM druhu Phyteuma orbiculare v rozlišení 1000 m (Somersovo D: 0,778)."
)

=== _Phyteuma pseudorbiculare_

#extrapol_proj_grid(
  species: "PP",
  grain: 200,
  caption: "Projekce pro nejúspěšněnší ESM druhu Phyteuma pseudorbiculare v rozlišení 200 m (Somersovo D: 0,706)."
)

=== _Saxifraga blavii_

#extrapol_proj_grid(
  species: "SB",
  grain: 1000,
  caption: "Projekce pro nejúspěšněnší ESM druhu Saxifraga blavii v rozlišení 1000 m (Somersovo D: 0,693)."
)

== Modely na všech prediktorech

#import "typst/tables/res_noextrapol_all.typ": noextrapol_all_result_table
#noextrapol_all_result_table

#import "typst/functions/esm_shape_noextrapol_proj_grid.typ": esm_shape_noextrapol

=== _Gentiana dinarica_

#figure(
  esm_shape_noextrapol(
    "GD",
    1000,
    colin: "all_selected"
  ),
  caption: [Vlevo projekce nejúspěšnějšího ESM pro druh _Gentiana dinarica_ v rozlišení 1000 m (Somersovo D: 0,733). Vpravo prostorová ditribuce metriky Shape pro data, na která byl model projektován.]
)

=== _Gentiana tergestina_

#figure(
  esm_shape_noextrapol(
    "GT",
    200,
    colin: "all_selected"
  ),
  caption: [Vlevo projekce nejúspěšnějšího ESM pro druh _Gentiana tergestina_ v rozlišení 200 m (Somersovo D: 0,519). Vpravo prostorová ditribuce metriky Shape pro data, na která byl model projektován.]
)

=== _Primula kitaibeliana_

#figure(
  esm_shape_noextrapol(
    "PK",
    200,
    colin: "all_selected"
  ),
  caption: [Vlevo projekce nejúspěšnějšího ESM pro druh _Primula kitaibeliana_ v rozlišení 200 m (Somersovo D: 0,904). Vpravo prostorová ditribuce metriky Shape pro data, na která byl model projektován.]
)

=== _Phyteuma orbiculare_

#figure(
  esm_shape_noextrapol(
    "PO",
    1000,
    colin: "all_selected"
  ),
  caption: [Vlevo projekce nejúspěšnějšího ESM pro druh _Phyteuma orbiculare_ v rozlišení 1000 m (Somersovo D: 0,728). Vpravo prostorová ditribuce metriky Shape pro data, na která byl model projektován.]
)

=== _Phyteuma pseudorbiculare_

#figure(
  esm_shape_noextrapol(
    "PP",
    200,
    colin: "all_selected"
  ),
  caption: [Vlevo projekce nejúspěšnějšího ESM pro druh _Phyteuma pseudorbiculare_ v rozlišení 200 m (Somersovo D: 0,688). Vpravo prostorová ditribuce metriky Shape pro data, na která byl model projektován.]
)

=== _Saxifraga blavii_

#figure(
  esm_shape_noextrapol(
    "SB",
    1000,
    colin: "all_selected"
  ),
  caption: [Vlevo projekce nejúspěšnějšího ESM pro druh _Saxifraga blavii_ v rozlišení 1000 m (Somersovo D: 0,65). Vpravo prostorová ditribuce metriky Shape pro data, na která byl model projektován.]
)

== Modely na společných prediktorch

#import "typst/tables/res_noextrapol_common.typ": noextrapol_common_result_table
#noextrapol_common_result_table


=== _Gentiana dinarica_

=== _Gentiana tergestina_

=== _Primula kitaibeliana_

=== _Phyteuma orbiculare_

=== _Phyteuma pseudorbiculare_

=== _Saxifraga blavii_

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
  "lit/predictors.bib",
  "lit/plants.bib"
),
  style: "copernicus",
  title: none)