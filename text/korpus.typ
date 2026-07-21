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
#let datum = datetime.today().display("[day]. [month]. [year]")

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
/*
#let chapter(title) = {
  pagebreak()
  heading(level: 1)[#title]
}
*/

#import "typst/functions/extrapol_proj_grid.typ": extrapol_proj_grid
#import "typst/functions/esm_shape_noextrapol_proj_grid.typ": esm_shape_noextrapol
#import "typst/functions/respcurves_grid.typ": response-curves-grid
#import "typst/functions/respcurves_common_grid.typ": response-curves-common-grid

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
  [V Praze dne #datum],
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

#v(10pt)

Rozšíření druhů v geografickém prostoru je podmíněno řadou environmentálních a biotických faktorů, které nejsou napříč prostorem konstantní. Vhodnost konkrétního stanoviště pro konkrétní druh je mimo jiné dána kompatibilitou ekologické niky druhu a realizací klíčových proměnných prostředí. Vhodným nástrojem pro uchopení tohoto vztahu se zdají být modely rozšíření druhů (či také nikové modely rozšíření druhů, modely vhodnosti stanoviště, SDM), které se používají pro kvantifikaci závislosti výskytu druhů pozorovaných v geografickém prostoru na měnících se podmínkách prostředí @elith2009SDM @guisan2000predictive.

== Teoretická východiska modelování rozšíření vhodných stanovišť

#v(10pt)

Ekologickým východiskem těchto modelů je koncept ekologické niky _sensu_ Hutchinson @hutchinson1957concluding. V tomto pojetí lze niku chápat jako mnohorozměrný environmentální prostor zahrnující podmínky a zdroje vhodné pro dlouhodobé přetrvávání populace/*, avšak nikoli bez výjimky*/. Pozorované rozšíření druhu /*totiž*/ ale nemusí přesně odpovídat rozsahu environmentálních podmínek, které jsou pro daný druh limitující. Z části své _fundamentální_ niky ‒ rozsahu podmínek prostředí daný druh fyziologicky limitujících ‒ může být vyloučen biotickými interakcemi, případně v ní může absentovat v důsledku omezené disperze nebo historických událostí @pulliam @soberon2005interpretation. V opačném případě může být druh přítomen i v podmínkách, které se s jeho fundamentální nikou neshodují, například díky imigraci ze zdrojových populací (_source-sink_ dynamika @pulliam1988sources). Výstupy z tradičních SDM proto téměř nikdy nelze interpretovat jako fundamentální niku druhu v kompletní podobě, ale spíše jako empirický odhad environmentální niky získaný porovnáním zaznamenaných výskytů s podmínkami dostupnými v rámci studovaného území v daném čase @guisan2000predictive @peterson2012species. Zároveň SDM modely pracují s implicitním předpokladem, že pozorované rozšíření druhu je v rovnováze s podmínkami prostředí, tedy že druh obsazuje většinu pro něj dostupných vhodných stanovišť a naopak převážně chybí tam, kde vhodné podmínky realizovány nejsou @guisan2000equilibrium.

Z koncepčního hlediska jsou modely SDM postaveny na předpokladu Hutchinsonovy duality @hutchinson_duality, podle níž každá lokalita v geografickém prostoru odpovídá určitému bodu v mnohorozměrném environmentálním prostoru, a zároveň stejná kombinace environmentálních podmínek může být zastoupena na více geograficky oddělených lokalitách. Díky tomuto předpokladu je možné vztahy mezi prostředím a výskytem druhu, odvozené v rámci modelovacího procesu SDM, projektovat v prostoru na lokality, které nebyly součástí trénovací části modelování. Tímto projektováním odvozených vztahů mezi druhem a prostředím vznikají souvislé mapy potenciálně vhodných stanovišť @elith2009SDM. Kromě interpolování vztahů druhu a prostředí v prostoru a na současných podmínkách prostředí, je teoreticky možné projektovat odvozené závislosti i v čase. Hlavním předpokladem pro takovou projekci je niková konzervativnost (_niche conservatism_), tedy že nároky druhu na podmínky prostředí jsou v čase konstantní @niche_conservatism @pearman2008niche.

/*
[[[tím se přidává další vrstva ekologických předpokladů do SDM
vztah který odvozujeme je poměrně dost pokřivený už v současnosti, natož když ho přeneseme do minulost/budoucnosti, kde mohlo docházet k úplně jiným interakcím na všech řádech
nehledě na to, že prediktory, na kterých se ta projekce dělá, jsou samy o sobě zatíženy velikou nejistotou]]]
*/

== Princip SDM

#v(10pt)

Jak bylo již naznačeno výše, modely rozšíření druhů popisují vztah mezi pozorovaným výskytem druhu a podmínkami prostředí na známých lokalitách. Odhadnutý vztah je následně možné promítnout do geografického prostoru a vymezit oblasti s podobnými environmentálními podmínkami těm, na nichž byl druh zaznamenán. Výstupem je spojitá mapa potenciální vhodnosti stanovišť, kterou je však nutné interpretovat v kontextu použitých dat a dalších modelovacích parametrů @guisan2000predictive @elith2009SDM.

Do modelů SDM vstupují dva základní typy dat (viz @fig:schema_sdm*(a)*). Prvním jsou georeferencované záznamy o přítomnosti druhu, které bývají doplněné o absence. Vzhledem k tomu, že do modelování obvykle vstupují data, která nebyla sebrána za tímto účelem, absence bývají nahrazovány _pseudoabsencemi_ (reprezentujícími prostředí, ve kterém se druh na základě apriorní znalosti nevyskytuje), případně _pozaďovými body_ (reprezentujícími dostupné environmentální kombinace v geografické oblasti zájmu) @sillero2021common. Druhým typem vstupujících dat jsou environmentální prediktory, zpravidla reprezentované kontinuálními či kategoriálními rastrovými vrstvami klimatu, topografie a dalších faktorů. Modelovací algoritmus z těchto dat odhaduje funkce odpovědi druhu na jednotlivé environmentální faktory, které je následně možné projektovat zpět do geografického prostoru @elith2009SDM.

#figure(
  image("obj/pic/sdm_schema_CZ.png", width: 80%),
  caption: [Schematické znázornění modelovacího procesu SDM. *(a)* Do modelu vstupují výskytová data v podobě georeferencovaných bodů a rastrové prediktory představujícíc variabilitu environmentálních podmínek v prostoru. *(b)* Z kombinací prediktorů asociovaných s presencí/absencí druhu je vypočtena odpověď druhu na měnící se podmínky prostředí. *(c)* Odvozené vztahy je možné vykreslit v environmentálním prostoru a *(d)* projektovat do prostoru geografického. Schema upraveno podle #cite(<soley_2024_TOPTENHAZARDS>, form: "prose")]
) <fig:schema_sdm>

Před samotným modelováním je vždy nutné učinit několik zásadních rozhodnutí, která silně ovlivňují výstupy modelů i jejich interpretaci. Jedním z nich je volba prostorového měřítka, tedy velikosti základní prostorové jednotky analýzy, tzv. _grain_. Vhodně zvolené měřítko musí odpovídat přesnosti lokalizace výskytových záznamů, prostorovému rozlišení prediktorů a škále, na níž daný organismus na konkrétní faktory prostředí reaguje @levin1992problem. Zatímco klima obvykle vymezuje rozšíření na širších měřítkách, topografie, vegetační struktura nebo půdní faktory mohou určovat vhodnost stanoviště na podstatně jemnější úrovni. Změna měřítka modelu tak může měnit zachycenou variabilitu prostředí, tvar odhadovaných vztahů i celkovou predikční výkonnost modelu @moudry2023scale.

Dalším ze zásadních rozhodnutí je výběr prediktorů, který by měl vycházet z předem formulované ekologické hypotézy. V tomto kontextu je důležité uvědomnění, jak jednotlivé faktory prostředí působí na přežívání populací daného druhu. Nepřímé prediktory, jako jsou nadmořská výška nebo poloha ve svahu, mohou sice být v modelu velmi úspěšné, ale jejich konkrétní biologický význam může být jenom složitě interpretovatelný. Naopak přímé prediktory, reprezentující faktory prostředí s biologicky vysvětlitelným vlivem (např. dostupnost vody, _growing degree days_, limitující teploty), jsou většinou hůře dostupné v kontinuálním pokrytí prostoru, avšak poskytují lepší interpretovatelnost @guisan2000predictive. Volba prediktorů by tedy měla být podmíněna několika souběžnými kritérii: (i) účelu modelování, tedy zda jde o co nejvěrohodnější vystižení současného stavu a prostorovou predikci vhodnosti habitatů, či o přenositelnost modelu do jiných environmentálních podmínek a osvětlení rozdílů mezi současným versus minulým/budoucím rozšířením @merow2014we, pak (ii) jak působí jednotlivé prediktory na rozšíření druhu a jakým způsobem interpretovat odvozené vztahy, aby nedocházelo ke kořistění ekologie @houlahan2017priority a (iii) v neposlední řadě jaké jsou statistické vztahy mezi prediktory.

== Dosavadní využití SDM v alpinském prostředí

#v(10pt)

Navzdory zmíněným interpretačním omezením mají modely rozšíření vhodných stanovišť široké využití v základním i aplikovaném výzkumu. Mezi nejčastější využití patří snahy o popis vztahu mezi druhem a environmentálními gradienty, identifikace potenciálně vhodných stanovišť v prostoru (např. #cite(<mccune_2016_SDM_rare>, form: "prose")), podpora plánování územní ochrany včetně hodnocení hrozeb spojených s invazemi druhů @elith2009SDM. Nemalá pozornost je také věnována jejich využití při studiu historických změn areálů (např. #cite(<svenning_LGM_modelling>, form: "prose")) a při odhadu možných dopadů probíhající změny klimatu (např. #cite(<salako2019predicting>, form: "prose"), #cite(<randin2009climate>, form: "prose")). V těchto aplikacích však modely SDM nepředstavují náhradu za ekologickou znalost studovaného organismu, ale právě naopak sestavení, kontrola i interpretace modelu musí vycházet z biologicky odůvodněných předpokladů @austin2002spatial.

V kontextu vysokohorského prostředí představují modely SDM nenáročnou studijní metodu. Plné terénní zmapování areálů alpinských rostlin je obtížné, jelikož jsou vysokohorská stanoviště prostorově izolovaná a obtížně přístupná. Modely SDM tak umožňují doplnit bodové znalosti výskytu o souvislý odhad prostorového rozložení vhodných stanovišť a současně kvantifikovat vztahy mezi výskytem druhu a jednotlivými gradienty prostředí @guisan1998predicting. Ve vysokohorském prostředí bývají modely SDM užívány i k dalším výše zmíněným účelům. Predikované mapy vhodnosti umožňují vybrat lokality, na nichž je vyšší pravděpodobnost nalezení dosud neznámých populací, což může u vzácných druhů výrazně zvýšit efektivitu terénních prací. Takto nově získaná data navíc mohou zpětně sloužit ke zpřesnění výchozího modelu @guisan2006using. Mimo terénního průzkumu samotného mohou výstupy z SDM sloužit jako podklady k plánování územní ochrany. Zároveň je také možné posoudit, zda současná síť chráněných území zachová vhodná stanoviště také při očekávaném posunu areálů @chauvier2024transnational.

Další významnou oblastí využití SDM u alpinských rostlin jsou projekce potenciálně vhodných stanovišť do minulých podmínek prostředí. Tyto studie se zpravidla soustřeďují na období od posledního glaciálního maxima po současnost a jejich cílem je rekonstruovat změny rozsahu a polohy vhodných stanovišť nebo identifikovat oblasti, které mohly během klimaticky nepříznivých období fungovat jako refugia @patsiou2014topo. Na příklad, výsledky SDM modelů podpořily možnost dlouhodobého přetrvávání druhu _Saxifraga florulenta_ v lokálních refugiích v alpinu, jejichž podmínky se od regionálního klimatu lišily díky členitému reliéfu @patsiou2014topo. Podobně model pro _Edraianthus tenuifolius_ ze západního Balkánu identifikoval během posledního glaciálního maxima dvě oddělené oblasti vhodného prostředí, které odpovídaly prostorové struktuře zjištěné nezávislými morfologickými a fylogeografickými analýzami @glasnovic2018understanding.

Projekce do budoucnosti jsou naproti tomu využívány především k odhadu dopadů klimatické změny na dostupnost vhodných stanovišť. Dosavadní studie evropské horské flóry předpovídají u mnoha druhů zmenšování a fragmentaci klimaticky vhodného území a jeho přesun směrem do vyšších nadmořských výšek, přičemž rozsah očekávaných změn se liší mezi druhy, pohořími i klimatickými scénáři @engler2011. Zároveň se ukazuje, že modely s jemným prostorovým rozlišením zpravidla zachycují více lokálně stabilních stanovišť než modely hrubšího měřítka. Modely v rozlišení 10' obvykle predikují jejich úplnou ztrátu @randin2009climate. Stejně tak jemné modely častěji predikují složitější kombinace úbytku, přetrvávání a vzniku nových potenciálně vhodných lokalit @rota2022topography.

== Specifika SDM v alpinském prostředí

#v(10pt)

Modelování rozšíření vhodných stanovišť v alpinském prostředí má svá specifika, která přímo ovlivňují volbu prediktorů, prostorové rozlišení i množství dat potřebných ke kalibraci modelu. Horské oblasti se vyznačují výraznou heterogenitou reliéfu, geologického podloží, půdních poměrů a lokálního klimatu. Na krátkých prostorových vzdálenostech se zde mohou střídat svahy s odlišnou orientací a osluněním, sněhová výležiska, větrné hrany, skalní výchozy nebo místa s rozdílnou dostupností půdní vody. Tato heterogenita vytváří vysoký počet ekologicky odlišných mikrostanovišť a společně s historickými změnami klimatu a geologickým vývojem přispívá k vysoké diverzitě a endemismu horských oblastí @rahbek_2019_MGH @reihl_2019_MGH.

=== _Grain_

#v(7pt)

Klíčovým problémem při modelování v horských oblastech je volba výše zmíněného rozlišení vstupních dat, tedy hlavně prostorové velikosti jednotky, pro niž je výskyt druhu a hodnota environmentálního prediktoru reprezentována jediným údajem (_grain_). Jednotlivé faktory prostředí přitom ovlivňují rozšíření vhodných stanovišť na různých prostorových škálách: regionální klima zpravidla vymezuje širší hranice areálu, zatímco topografie rozhoduje o vhodnosti konkrétních stanovišť uvnitř pohoří. Při použití příliš hrubého rastru jsou tyto lokální rozdíly zprůměrovány, čímž mohou být potlačeny vzácné kombinace podmínek důležité zejména pro úzce specializované druhy @elith2009SDM @moudry2023scale.

/*
Stejná prostorová heterogenita, která činí horské oblasti zajímavými z hlediska endemismu a druhové bohatosti, však komplikuje zachycení vztahů mezi druhem a prostředím. Významnou vlastností vstupních dat je jejich zrnitost, kdy v rámci zjednodušení (a nedostupnosti skutečných hodnot) uchováváme pro větší plochu stejnou informaci. Neexistuje přitom jediné univerzálně optimální rozlišení, na jehož úrovni by druh na podmínky prostředí reagoval. Na příklad zatímco regionální klima omezuje rozšíření především na větších škálách, v rámci jednotlivých pohoří mohou vznikat vlivem topografie mikrostanovištní podmínky úspěšně potlačující regionální klimatické poměry @rota2022topography.
*/

Změna zrnitosti navíc neovlivňuje pouze prostorové vykreslení výsledku, ale také samotné vztahy odhadované modelem. Ve studii postavené na modelování virtuálních druhů s předem známými křivkami odpovědí dosahovaly modely nejlepších výsledků zpravidla při rozlišení odpovídajícím měřítku, na němž byl vztah definován. S rostoucí velikostí buněk se měnila relativní důležitost prediktorů, význam nadmořské výšky rostl, zatímco význam orientace svahu klesal. Modely na hrubších měřítcích než na kterých probíhal "skutečný" vztah druhu k prostředí současně výrazně nadhodnocovaly rozlohu vhodného prostředí, v krajním případě téměř čtrnáctinásobně. Tyto výsledky ukazují, že modely postavené na hrubých škálách (a tím pádem na homogenizovanějším prostředí) a s přijatelnou diskriminační schopností nemusí správně zachycovat prostorový rozsah ani strukturu a tvar ekologických vztahů @connor2018effects.

Z toho však nevyplývá, že nejjemnější dostupné rozlišení je vždy nejvhodnější. Je třeba rozlišovat mezi nominální velikostí rastrové buňky a skutečným prostorovým informačním obsahem prediktoru. Řada globálních klimatických a půdních vrstev nepředstavuje přímé měření v každé buňce, ale prostorový model vytvořený interpolací určitého počtu bodových měření za pomoci topografie a dalších kovariát (např. #cite(<chelsa_bioclim_model>, form: "prose")). Jejich přesnost je přímo ovlivněna hustotou a rozmístěním měřicích stanic, použitou interpolační metodou a schopností modelu zachytit lokální podmínky. V členitém horském terénu navíc standardní meteorologická měření často nereprezentují mikroklima skutečně působící na rostliny @guisan2000predictive. Převzorkování takové vrstvy do jemnějšího rastru ‒ na příklad jak jsem provedl v této práci ‒ nevytváří novou informaci, ale pouze prostorově zjemňuje již modelovaný odhad. Naproti tomu data dálkového průzkumu Země, letecké snímkování nebo LiDAR poskytují relativně přesné měření zemského povrchu, z něhož lze v jemném rozlišení odvodit proměnné typu digitální model reliéfu, strukturu vegetace, spektrální indexy či krajinný pokryv @leitao2019improving @schwager2021remote. V kontextu měřítka ‒ _grainu_ ‒ studie je také nutné uvažovat přesnost a prostorové rozlišení výskytových dat. Výsledky studií naznačují, že u druhů vázaných na vzácná nebo maloplošná stanoviště je vhodné upřednostnit jemnější prediktory i tehdy, jsou-li výskytová data dostupná v hrubším rozlišení, zatímco u druhů asociovaných s široce rozšířenými podmínkami mohou být dostačující i prediktory hrubší @simova2019fine. Dopady změny rozlišení je vhodné posuzovat _apriori_ pomocí prostorové autokorelace, případně podle měnícího se zastoupení úrovní faktorových prediktorů. Další cestou je zohlednění většího množství rozlišení v jednom modelu, což může zachytit působení různorodých procesů na odlišných prostorových škálách. Na druhou stranu pozorované zvýšení predikční výkonnosti víceškálových modelů bývá zpravidla pouze mírné a užitečných výsledků lze dosáhnout i pomocí modelu v jediném měřítku @moudry2023scale.

=== Výskytová data

#v(7pt)

Pro studium areálů alpinských rostlin je dalším významným omezením dostupnost kvalitních výskytových dat. Velká část alpinských endemitů má přirozeně malý areál a malý počet populací, přičemž jejich stanoviště bývají izolovaná a obtížně přístupná [[[]]]. Datové soubory jsou proto často tvořeny malým počtem přesně zaměřených terénních pozorování doplněných herbářovými nebo databázovými záznamy. Tyto zdroje mohou být nerovnoměrně rozmístěné ‒ soustředěné v blízkosti cest a známých botanických lokalit ‒ a mohou obsahovat rozdílnou polohovou nebo taxonomickou přesnost. V západobalkánských horách je tento problém zvlášť relevantní, jelikož jsou v důsledku historického vývoje obecně méně navštěvované odbornou obcí [[[gbif??]]].

Malá velikost vzorku zvyšuje nejistotu parametrů a citlivost modelu na jednotlivá pozorování. Na příklad #cite(<wisz2008effects>, form: "prose") při porovnání dvanácti modelovacích metod zjistili, že s klesajícím počtem pozorování klesala průměrná predikční výkonnost a rostla variabilita výsledků mezi druhy a algoritmy. Výsledky modelů s počtem pozorování $"< 30"$ neposkytovaly u žádného z testovaných algoritmů konzistentní výsledky, přičemž problém se zesiloval s rostoucím počtem prediktorů. Autoři tento trend vysvětlují jako nemožnost omezeného souboru pozorování dostatečně reprezentovat odpověď druhu na prostředí. Jednou z možností, jak snížit riziko spojené s modelováním na malém souboru observačních dat, je kalibrování velkého množství jednoduchých modelů s pouze několika prediktory a následné vážené spojení jejich predikcí @lomba_2010.

Spolehlivost SDM v alpinském prostředí je tedy výsledkem společného působení ekologického měřítka studovaného druhu, velikosti _grain_ a kvality environmentálních prediktorů a přesnosti i reprezentativnosti výskytových dat. Jemné rozlišení může zachytit lokální gradienty a mikrorefugia, ale pouze tehdy, pokud mu odpovídá skutečný informační obsah vstupních prediktorových vrstev. Rozsah a kvalita souboru observačních dat zase přímo ovlivňuje, do jaké míry lze pomocí modelu popsat chování druhu na gradientech prostředí a jaká ze statistických technik je pro daná data nejvhodnější.

== Balkánský poloostrov a balkánské alpinum

#v(10pt)

Balkánský poloostrov je území v jihovýchodní Evropě ležící jižně od linie řek Soča, Sáva, Dunaj a mezi Jaderským, Jónským, Egejským a Černým mořem. Horské systémy západní části poloostrova tvoří především Dinaridy, které z jihu navazují na Julské Alpy a pokračují přes Slovinsko, Chorvatsko, Bosnu a Hercegovinu a Černou Horu do severní Albánie. Nejvyšším bodem Dinarid je Maja e Jezercës dosahující výšky 2694 m n. m. Směrem k jihovýchodu na Dinaridy navazují Albanidy a Helenidy, jejichž součástí jsou mimo jiné pohoří Šar planina a Pindos. Tyto systémy společně vytvářejí téměř souvislý horský oblouk táhnoucí se podél západního okraje poloostrova k Egejskému moři @ager_geology_1980.

Současná podoba geologické skladby balkánských hor byla primárně utvářena alpinskou orogenezí. Okrajové části Dinarid jsou charakteristické mocnými vrstvami druhohorních vápenců a dolomitů, na nichž se vyvinul výrazný krasový reliéf. Vedle karbonátových hornin se však ve vnitřních i okrajových částech Dinarid uplatňují také flyšové sedimenty, metamorfované horniny a granitové či vulkanické komplexy menšího rozsahu. Albanidy a Helenidy jsou geologicky pestřejší a zahrnují střídání karbonátových příkrovů, flyšových pánví, rozsáhlých ofiolitových komplexů a krystalinických jednotek @ager_geology_1980.

Klima Balkánského poloostrova má přechodný charakter mezi mediteránními podmínkami na jihozápadě a temperátním klimatem v severních a vnitrozemských oblastech. Jižní a přímořské části se vyznačují teplými suchými léty, přičemž většina srážek připadá na chladnější zimní období. Oproti tomu směrem do vnitrozemí narůstá kontinentalita, zimní teploty klesají a větší část srážek připadá na vegetační období @kostopoulou2009evaluation. Tyto regionální klimatické gradienty úspěšně přetváří horský reliéf, který na krátkých vzdálenostech vytváří výrazné rozdíly mezi různými expozicemi svahu i mezi jednotlivými výškovými stupni @peneva2023mediterranean.

Současné rozšíření alpinského bezlesí západní části Balkánského poloostrova je rozděleno do izolovaných ostrovů přirozeně bezlesé vegetace, přičemž se nachází pouze v nejvyšších částech jednotlivých horských masivů. Jeho významnější oblasti se nacházejí zejména v Dinaridech v pohoří Vranica, Durmitor a Prokletije, dále v soustavě Šar planina–Korab–Pindos @stevanovic2009distribution. Prostorový rozsah a výšková poloha alpina se mezi těmito oblastmi liší v závislosti na regionálních klimatických podmínkách, vzdálenosti od moře i historii hospodaření @brandes2024timberlines.

Během posledního glaciálního maxima byly nejvyšší části západobalkánských pohoří pokryty karovými a údolními ledovci a současně došlo k celkovému posunu vegetačních stupňů směrem do nižších nadmořských výšek. Alpinské druhy sestupovaly na úpatí hor a do okolní otevřené periglaciální krajiny, kde se nacházely klimatické podmínky obdobné dnešnímu alpinu. Zalednění pravděpodobně nebylo souvislé a mezi ledovci mohly zůstávat nezaledněné plochy příznivých stanovišť k udržování populací vysokohorských rostlin ‒ tzv. _nunataky_ @holderegger2009discussion[[[Blytt_1882]]]. Část populací vysokohorských rostlin tak mohla přežívat ve vyšších polohách v izolovaných mikrorefugiích, zatímco jiné populace přetrvávaly v podhůří nebo na okrajích zaledněných oblastí @hughes2011glacial @spaniel2022plant. Během postglaciálního oteplování ledovce postupně ustupovaly a klimaticky vhodné podmínky pro alpinské druhy se přesouvaly zpět do vyšších nadmořských výšek. Rostliny tak z nižších refugií znovu kolonizovaly odkryté vrcholové partie a zároveň vzestup horní hranice lesa zmenšoval rozlohu otevřených stanovišť v nižších částech horských masivů. Původně rozsáhlejší a místy propojené podhorské areály se proto během holocénu postupně rozpadaly na menší, vzájemně izolované populace soustředěné v nejvyšších částech jednotlivých pohoří @birks2008alpines @spaniel2022plant.

Tento scénář ilustruje studie na balkánském horském endemitu _Campanula orbelica_, který roste v alpinských trávnících na silikátovém podloží. U tohoto druh byly rozlišeny tři geograficky odlišné genetické linie: v pohoří Pirin, v Rile a dalších východobalkánských masivech a v západněji položených pohořích Šar planina a Korab. Projekce modelu SDM do posledního glaciálního maxima ukázala rozšíření vhodných podmínek do nižších poloh a možné propojení dnešních areálů v Rile a Pirinu, nikoli však vznik souvislého areálu napříč celým Balkánem @ronikier2023high. Obdobná fylogeografická disjunkce byla zjištěna u západobalkánského endemitu _Cerastium dinaricum_, jehož současné rozšíření tvoří několik malých a navzájem izolovaných populací v Dinaridech. Tyto populace se dělí do dvou diferencovaných skupin, přičemž populace v jihovýchodní části areálu se dále dělí do několika menších genetických skupin. Současná fragmentace tohoto druhu je pravděpodobně výsledkem opakovaných výškových posunů areálu a jeho stažení do nejvyšších poloh během holocénního oteplování @kutnjak2014escaping. Oba příklady ukazují, že současné ostrůvkovité rozšíření balkánských alpinských rostlin není pouze výsledkem dnešních ekologických podmínek, ale uchovává také genetické stopy dlouhodobé pleistocenní izolace a rozdílného vývoje populací v jednotlivých horských masivech.

Z hlediska budoucí perspektivy je balkánské alpinum silně ohrožené probíhající změnou klimatu. V odborné obci panuje obecná shoda, že současný trend může vést k elevačnímu posunu klimatických zón a návaznému zmenšení rozlohy (sub)alpinských biotopů. Taková změna by vedla k ohrožení druhů se slabou migrační schopností a druhů vyskytujících se v oblastech, kde již není možné migrovat do vyšších nadmořských výšek @IPCC_2023 @theurillat1998sensitivity. V Dinaridech a dalších balkánských pohořích může být tento problém aktuálnější než ve vysokých Alpách, jelikož balkánské horské masivy dosahují nižších nadmořských výšek a fyzická hranice potenciálního elevačního posunu je umístěna níže. Na příklad již výše zmíněné modely pro druh _Cerastium dinaricum_ predikují ztrátu 73 % současné rozlohy vhodných stanovišť do roku 2080 @kutnjak2014escaping.

== Cíle práce

#v(10pt)

Tato práce se zaměřuje na západobalkánské horské rostliny _Gentiana dinarica_, _Gentiana tergestina_, _Primula kitaibeliana_, _Phyteuma orbiculare_, _Phyteuma pseudorbiculare_ a _Saxifraga blavii_. Hlavním cílem je pomocí SDM modelů popsat vztahy mezi výskytem zájmových rostlin a podmínkami prostředí reprezentovanými volně dostupnými prediktory. Na základě těchto modelů následně vytvořit projekce reprezentující současné rozšíření vhodných stanovišť, potenciální rozšíření vhodných stanovišť v limitujících obdobích (post)glaciální historie & provést projekce do hypotetických podmínek budoucích.

#block(
  inset: (left: 20pt),
)[
  + Shromáždit ekologicky relevantní prediktory pro modelování rozšíření vhodných stanovišť & vhodná výskytová data v dostatečném množství a kvalitě.
  + Sestavit druhově specifické modely potenciálně vhodných stanovišť v různých prostorových rozlišeních a posoudit jejich úspěšnost.
  + Vytvořit prostorové projekce potenciálně vhodných stanovišť v současnosti, minulosti & budoucnosti.
  + Prozkoumat míru prostorově-environmentální extrapolace odvozených vztahů.
  // tady chybí vyhodnocení, je to jen zobrazeno!!
  + Vyhodnotit vliv prostorového měřítka na konstrukci a výkonnost modelů.
  //+ Dodělat školu už konečně.
]

/*
== [[[Poznámky obecné]]]

#v(10pt)

// Vstupní data do modelování

[[[kvalita vstupních dat]]]

[[[proximita prediktorů]]]


Jedním z důležitých metodických rozhodnutí při přípravě environmentálních prediktorů je volba klimatického datasetu pro současné, budoucí a historické projekce.

Srovnávací studie ukazují, že teplotní proměnné klimatických datasetů jsou obvykle konzistentní, zejména díky silné vazbě teploty a nadmořské výšky. Výraznější rozdíly se však objevují u srážkových proměnných, jejichž prostorové rozložení je v horském prostředí ovlivněno lokální cirkulací vzduchu, která je pod rozlišovací schopností globálních klimatických modelů. @bobrowski_2017 @fierke_2024

Dalším důležitým prediktorem používaným v modelech rozšíření vhodných stanovišť je informace o geologickém podloží. Zohlednění substrátu přináší do modelu důležitou informaci, jelikož erozní procesy specifické pro daný horninový substrát přímo ovlivňují vlastnosti půdy. [[[citace? nebo obecná znalost?]]] Zejména u rostlin tak může zachycovat ekologické gradienty, které nejsou plně postižitelné klimatickými a topografickými proměnnými, přičemž zařazení geologického substrátu do modelu může zlepšit predikci rozšíření potenciálně vhodných stanovišť, obzvlášť v horských a geologicky heterogenních územích. @chauvier_2021 @dubuis_2012

Kromě samotného typu geologického podloží mohou být pro modelování rozšíření vhodných stanovišť významné také konkrétní půdní vlastnosti, které mají na růst rostlin přímější vliv. Ku příkladu hloubka půdy, půdní reakce a schopnost půdy zadržovat vodu ovlivňují přežívání rostlin významně silněji než samotný druh horniny. Zahrnutí prediktorů charakterizujících takové vlastnosti půdy může vysvětlovat část variability, kterou není možné zachytit pouze klasifikovaným geologickým substrátem, a vést k lepším projekcím vhodných stanovišť v prostoru. @dubuis_2012

Z tohoto důvodu byly v této práci vedle geologické vrstvy GLiM využity také vybrané půdní prediktory ze systému SoilGrids, který poskytuje globální predikce půdních vlastností v prostorovém rozlišení 250 m založené na půdních pozorování a následném strojovém učení. @soilgrids_250m

[[[povídání o tom, že půda se mění v čase a není možné tyto prediktory požívat při temporálních extrapolacích]]]

[[[povídání o nepřesnostech v prediktorových datasetech ‒ interpolace viz soilgrids, chelsa a počet stanic meteo na Balkáně, NAOPAK přesnost DEM, EO dat]]]

[[[studium změny klimatu je důležité proč]]]

V odborné obci panuje obecná shoda, že probíhající globální klimatická změna může vést k elevačnímu posunu klimatických zón a návaznému zmenšení rozlohy (sub)alpinských biotopů. Taková změna by vedla k ohrožení druhů se slabou migrační schopností a druhů vyskytujících se v oblastech, kde již není možné migrovat do vyšších nadmořských výšek. @IPCC_2023 @theurillat1998sensitivity

[[[]]]
Výsledky opakovaně ukazují, že rozšíření alpinských rostlin není určováno pouze regionálním klimatem, ale silnou roli hraje také topografie, geologické podloží a další faktory, které vytvářejí mozaiku mikrostanovištních podmínek @rota2022topography.

[[[]]]
Srovnávací studie ukazují, že teplotní proměnné klimatických datasetů jsou obvykle konzistentní, zejména díky silné vazbě teploty a nadmořské výšky. Výraznější rozdíly se však objevují u srážkových proměnných, jejichž prostorové rozložení je v horském prostředí ovlivněno lokální cirkulací vzduchu, která je pod rozlišovací schopností globálních klimatických modelů. @bobrowski_2017 @fierke_2024

[[[měříto]]] @randin2009climate popisují, že modely s grain 25m ukazují, že stanoviště s vhodným mikroklimatem zůstanou v Alpách i po oterplení, proti tomu velkomeritkove modely rikaji, ze klima se zmeni natolik, ze tato stanoviste vymizi

*/

// # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
// metodika
#pagebreak()
= Metodika
== Prostorové vymezení práce

#v(10pt)

#grid(
  columns: (40%, 56%),
  column-gutter: 4%,
  [
    Studovaná oblast (viz @fig:aoi) byla vymezena jediným polygonem o rozloze přibližně 296 tisíc km#super("2"). Oblast zahrnuje západní Balkán od jižního Slovinska a severního Chorvatska po Albánii a severozápadní Řecko. Území plně zahrnuje pevninskou část Chorvatska, Bosny a Hercegoviny, Černé Hory, Kosova a Albánie. Centrum oblasti tvoří Dinárské Alpy a jejich jihovýchodní pokračování přes Prokletije, Šar planinu a Korab k severnímu a centrálnímu Pindu. Mimo oblast zůstávají Julské Alpy, východosrbská karpatsko-balkánská pohoří, bulharská pohoří Rila, Pirin a Rodopy.
  ],[
    #figure(
      image("obj/pic/aoi.png"),
      caption: [Prostorové vymezení práce. Černá linie představuje hranici oblasti, ve které byly provedeny terénní práce a pro kterou byly shromažďovány prediktory. Podklad: ®OpenTopoMap.]
    ) <fig:aoi>
  ]
)

== Druhy rostlin
#v(5pt)

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
  caption: [Studované druhy rostlin. *a*: _Gentinana tergestina_ Beck., *b*: _Gentiana dinarica_ Beck., *c*: _Primula kitaibeliana_ Schott., *d* & *e*: _Saxifraga blavii_ Beck., *f*: _Phyteuma orbiculare_ L. & *g*: _Phyteuma pseudorbiculare_ Pant. #linebreak() Foto *c* převzato od Felix Puff, *e* & *f* od Jana Smyčky, *a*, *b*, *d* & *g* autor.],
) <fig:kytky>

== Vstupní data
#v(5pt)

Následující kapitola je věnována rozboru dvou základních datových vstupů do modelování rozšíření vhodných stanovišť. Jsou to data o výskytech druhů (@chap:observ_methods) sloužící jako zdroj odhadu závislosti (a zároveň i zdroj odhadu výkonnosti) a prediktory (@chap:preds_methods) na základě jejichž variability jsou závislosti odvozovány.

=== Data o výskytech druhů <chap:observ_methods>

V rámci této práce byla využita pozorování druhů získaná ze dvou hlavních zdrojů: (i) terénní práce & (ii) data z _Flora Croatica Database_ @flora_croatica_database.

==== Terénní sběr dat
#v(5pt)
Terénní sběr výskytových dat probíhal na předem vybraných lokalitách, u nichž jsem na základě nadmořské výšky a charakteru prostředí předpokládal zastoupení alpinské vegetace. Průzkum jsem směřoval především do horských oblastí nad 1700 metrů nad mořem. Jednotlivé trasy terénního průzkumu jsem vedl směrem k vrcholovým partiím a tak, aby co nejlépe pokrývaly variabilitu stanovištních podmínek, ideálně v severo-jižní orientaci.
Při pohybu v terénu jsem využíval zejména značené cesty, které umožňovaly lepší průchodnost terénem. Terénní práce probíhaly v letech 2020 ‒ 2023.

Během průzkumu jsem zaznamenával presenční body nalezených fokálních druhů a v případě, že se studované druhy podél trasy nevyskytovaly, také body absenční. Polohu jednotlivých záznamů jsem určoval pomocí GPS/*v mobilním zařízení v aplikaci QField*/ v souřadnicovém systému WGS 84 (EPSG:4326). U každého záznamu jsem kromě polohy zaznamenával identifikátor nálezu, název druhu, stručný popis lokality a datum sběru. V okolí přibližně 30 m od každého nálezu jsem kontroloval přítomnost dalších fokálních druhů a při jejich nalezení jsem pro ně zaznamenával samostatné presenční body. V úsecích, kde druh souvisle pokrýval delší část trasy, jsem body zapisoval přibližně po 100 m.

==== Příprava výskytových dat
#v(5pt)

Výskytová data jsem před modelováním převedl do jednotné podoby a připravil samostatně pro jednotlivé modelované druhy. V prvním kroku jsem sjednotil názvy taxonů a odstranil nekonzistence vzniklé při zápisu terénních dat, jako na příklad překlepy a observační body s evidentně chybným prostorovým zaměřením. Pro každý fokální druh jsem následně vytvořil samostatnou vrstvu obsahující všechny dostupné presence a absence, přičemž za absence daného druhu jsem považoval globální absence (žádný z fokálních druhů se na lokalitě navyskytuje) a presence jiných druhů (na loklitě se vyskytuje druh X → absence pro všechny ostatní druhy). Terénní data druhů _Gentiana tergestina_ a _Primula kitaibeliana_ jsem rozšířil o externí nálezové záznamy z _Flora Croatica Database_ @flora_croatica_database, které nesly pouze informaci o přítomnosti. Tyto záznamy jsem proto do dat zahrnul až později a výhradně jako presence. Z databáze jsem vybral pouze pozorování georeferencovaná podle GPS.

Takto sestavené datové sady jsem následně porovnal s referenčními rastry prediktorů ve všech využitých prostorových rozlišeních. Na výskytová data jsem aplikoval filtr, jehož účelem bylo, aby pro každou buňku referenčního rastru, která se překrývá s výskytovými daty, byl zachován pouze jeden výskytový záznam. V případě, že do jedné buňky spadalo více observačních dat, upřednostňoval jsem presence před absencemi. Výsledkem byly sady výskytových dat ve stejném prostorovém rozlišení jako sady prediktorů, očištěné o nadbytečné absenční body (eventuelně očištěné i o body presenční, pokud spadalo více záznamů stejného druhu do identické rastrové buňky).

V dalším kroku jsem jednotlivým pozorováním přiřadil váhy, abych vyrovnal četnost presencí a absencí v jednotlivých modelech, zohlednil původ presenčních záznamů a také nejistotu ohledně spolehlivosti absenčních bodů (např. přehlédnutí jedince) @benkendorf_2023. Celková váha jsem rozdělil mezi presence a absence v poměru 1 : 1, takže obě třídy měly na fitování modelů stejný souhrnný vliv. U presenčních záznamů jsem dále zohlednil jejich zdroj @fletcher_2019 @zhang_2020. Presencím pocházejícím z provedených terénních prací jsem přidělil oproti záznamům databázovým dvojnásobnou váhu. Důvodem k tomuto rozhodnutí byl předpoklad, že terénní sběr byl ‒ na rozdíl od databázových položek ‒ proveden přímo za účelem této práce a lokality byly vybírány tak, aby došlo k co možná nejlepšímu pokrytí studované oblasti. Databázová data byla naopak lokalizována výhradně na území Chorvatska a sbírána podle neznámé metodiky v odlišném časovém rozmezí.

==== Prostorová autokorelace výskytových dat <chap:CV>

#v(5pt)

Pro hodnocení výkonu modelů jsem připravil prostorově oddělené cross-validační soubory výskytových dat (také _CV foldy_). Tento proces jsem provedl pro každou kombinaci druhu a prostorového rozlišení samostatně. Cílem tohoto dělení bylo omezit prostorovou autokorelaci výskytových dat a zamezit tak nadhodnocení predikční úspěšnosti. @dormann_2007 @bahn_2013 @roberts_2016 Nejprve jsem pomocí funkce _cv_spatial_autocor_ z balíčku _blockCV_ @blockCV odhadnul prostorovou autokorelaci výskytových dat. Na základě vypočteného dosahu jsem stanovil velikost prostorových bloků. Tyto bloky jsem následně přiřadil do cross-validačních foldů pomocí iterativního náhodného rozdělování tak, aby počet výskytových záznamů byl mezi foldy co nejvíce vyvážen. Druhou důležitou podmínkou bylo, aby v každém foldu byly pro daný druh jak presenční, tak absenční záznamy. Aby byly obě podmínky vyváženosti splněny, optimalizoval jsem konečný počet cross-validačních foldů pro každý druh zvlášť.

=== Prediktory <chap:preds_methods>
#v(5pt)

V rámci této práce jsem k trénování modelů rozšíření vhodných stanovišť využil prediktory z pěti základních skupin:
+ *klimatické* prediktory charakterizující na hrubém měřítku variabilitu teploty a srážek
+ *topografické* prediktory jejichž účelem je postihnout jemnější variabilitu mikrostanovišťních podmínek
+ *horninový* substrát sloužící jako základní charakteristika geologických poměrů na regionální úrovni
+ *půdní* prediktory rozvíjejí informaci o půdních poměrech na úrovni lokalit a je možné považovat je za ekologicky relevantnější než samotný geologický substrát [[[zdroj]]]
+ *krajinný pokryv* klasifikuje povrch Země do základních formačních skupin a jako jediný prediktor přináší do modelů informaci, která je vzdáleně schopna charakterizovat biotické faktory [[[zdroj]]]

==== Klimatické prediktory <chap:climate_pred>
#v(5pt)

Pro tuto práci jsem zvolil dataset CHELSA @chelsa_bioclim_model @chelsa_bioclim_data, a to především kvůli jeho vhodnosti pro modelování v topograficky členitých oblastech. @bobrowski_2017

Dataset CHELSA-BIOCLIM je globální klimatický dataset s vysokým prostorovým rozlišením 30 úhlových sekund (cca 1 km#super([2])). Vychází z hrubších klimatických dat, která jsou zpřesněna pomocí topografických modelů, jejichž využití umožňuje kromě výpočtu vlivu nadmořské výšky i zohlednění topografické situace na proudění vzduchu. V této práci jsem využil bioklimatické charakteristiky podchycující roční a sezónní variability klimatu v prostoru (bio01-bio19). @chelsa_bioclim_model Do analýz jsem navíc zahrnul i prediktor popisující počet dní v roce, kdy je na daném místě přítomna sněhová pokrývka (snow cover days, scd).

#import "typst/tables/pred_clim.typ": pred_clim
#pred_clim

Kromě charakterizace současného klimatu poskytuje dataset CHELSA-BIOCLIM pro tři časové řezy (2011–2040, 2041–2070 & 2071–2100) modely extrapolující klima do budoucnosti (tzv. earth system models:
GFDL-ESM4 @GFDL-ESM,
IPSL-CM6A-LR @IPSL-CM6A-LR,
MPI-ESM 1-2-HR @MPI-ESM1-2-HR,
MRI-ESM2-0 @MRI-ESM2-0,
&
UKESM1-0-LL @UKESM1-0-LL)
na základě různých emisních scénářů SSP (shared socioeconomic pathways: SSP1-2.6, SSP3-7.0 & SSP5-8.5 @oneil__cmip6_2016).

S ohledem na zachování metodické konzistence mezi jednotlivými časovými řezy jsem pro projekci modelů na historické klimatické podmínky použil dataset CHELSA-TraCE21k-bioclim @chelsa_trace_data @chelsa_trace_model, který poskytuje klimatické rekonstrukce od posledního glaciálního maxima po současnost v časových krocích 100 let a prostorovém rozlišení 30 úhlových sekund (cca 1 km#super([2])).

Klimatické prediktory jsem před vstupem do modelů prostorově sjednotil s ostatními rastrovými vrstvami. Rastrové vrstvy jsem nejprve reprojektoval do souřadnicového systému ETRS89-extended / LAEA Europe (EPSG:3035) a zarovnal na referenční rastr odpovídající nejhrubšímu použitému prostorovému rozlišení 1000 m. K tomuto účelu jsem použil metodu nejbližšího souseda, aby nedocházelo k interpolaci. Takto připravené vrstvy jsem následně převedl do jemnějších modelovacích rozlišení tak, že každá jemnější dceřinná buňka dědila hodnotu příslušné mateřské buňky. Tento postup zachoval původní informační obsah klimatických dat a zároveň umožnil jejich kombinaci s prediktory dostupnými v jemnějších prostorových rozlišeních.

==== Topografické prediktory
#v(5pt)

Pro analýzu topografie jsem v této práci použil globální elevační dataset _Copernicus DEM 30_ s prostorovým rozlišením 30 m. @copernicus_DEM Tento model je odvozen z dat mise dálkového průzkumu Země TanDEM-X a poskytuje tak nejpřesnější prostorové i absolutní zaměření poměrů na daných lokalitách mezi prediktory využitými v této práci. Data jsem získal prostřednictvím prostorového požadavku ve službě Copernicus Data Space Ecosystem @CDSE zprostředkovaného _openEO_ klientem v prostředí R. @openeo_R Stažené rastrové dlaždice jsem následně sloučil do mozaiky, reprojektoval do souřadnicového systému ETRS89-extended / LAEA Europe (EPSG: 3035) a maskoval polygonem zájmového území.

Topografické prediktory využité v této práci lze rozdělit do dvou skupin podle toho, jak popisují prostorové fenomény. První skupina charakterizuje vztah cílové buňky k jejímu okolí pomocí pohyblivého okna 3×3 buňky, tedy lokální topografický kontext. Druhá skupina popisuje vnitřní elevační variabilitu dané buňky při převodu z jemnějšího na hrubší prostorové měřítko. Přehled topografických prediktorů viz @tab:pred_dem.

Pro první skupinu jsem nejprve vytvořil DEM odpovídajícícho měřítka pomocí agregace původních dat _Copernicus DEM 30_. Hodnoty jsem agregoval podle mediánu. Z takto vzniklého modelu jsem pomocí _terra::terrain_ @terra vypočítal prediktorové vrstvy _slope_, _aspect_, _TPI_, _TRI_, _TRIriley_, _TRIrmsd_, _roughness_ a _flowdir_. _TPI_ vyjadřuje rozdíl mezi výškou středové buňky a průměrem okolních buněk @TPI_weiss2001. Kladné hodnoty indexu značí lokálně vyvýšené pozice, například hřbety, a záporné hodnoty lokální sníženiny. Hodnoty okolo nuly představují plochý terén. _TRI_ představuje průměr absolutních výškových rozdílů mezi středovou buňkou a okolím a _roughness_ rozdíl mezi maximální a minimální hodnotou v rámci pohyblivého okna. Prediktory _TRI_riley_ & _TRI_rmsd_ jsou deriváty jednoduššího _TRI_ snažící se lépe zachytit elevační variabilitu v geomorfologicky členitých oblastech. Jde o odmocninu součtu čtvercových rozdílů (_TRI_riley_, @TRI) a o odmocninu průměru čtvercových rozdílů (_TRI_rmsd_, @wilson_2007_GDAL). Tuto skupinu topografických prediktorů jsem rozšířil o prediktory _eastness_ a _northness_ odvozené z orientace svahu (_aspect_) jako sinus, respektive kosinus orientace svahu převedené na radiány. Tyto proměnné vyjadřují východo-západní a severo-jižní složky orientace svahu. V navazujících modelech jsem je použil jako zástupné prediktory za _aspect_ samotný, jelikož tento prediktor vykazuje kruhový charakter (360° = 0°) a není vhodný pro běžné algoritmy @wilson_2007_GDAL. Dalším rozšířením této skupiny je _HLI_ (heat load index, @HLI), který jsem vypočítal funkcí _spatialEco::hli_ @spatialEco. Tato metrika vyjadřuje potenciální teplotní zatížení svahu a kombinuje informaci o sklonu (_slope_) a aspektu (_aspect_), přičemž hodnoty se pohybují od chladnějších po teplejší loaklity. @HLI Posledním prediktorem, který jsem vypočítal pomocí pohyblivého okna je _TWI_ (topographic wetness index, @TWI). Vypočítal jsem ho z proměnných směr odtoku (_flowdir_), akumulovaná přispívající plocha (lokální "povodí") a sklon svahu (_slope_) v radiánech jako logaritmus poměru specifické přispívající plochy a tangens sklonu.

Druhá skupina zahrnuje prediktory, které jsem vytvořil během agregace jemných základních dat _Copernicus DEM 30_ do hrubšího prostorového měřítka. Z originálních dat jsem ‒ kromě _dem_median_, který sloužil jako podklad prediktorů první skupiny ‒ během agregace vypočítal proměnné _dem_sd_ (směrodatná odchylka nadmořských výšek), _dem_min_ (minimální nadmořská výška), _dem_max_ (maximální nadmořská výška) & _dem_range_ (rozdíl mezi maximální a minimální nadmořskou výškou).
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
#v(5pt)

Geologické podloží je v této práci reprezentováno vrstvou GLiM (Global Lithological Map, @GLIM). Tento projekt poskytuje globální vektorovou mapu pevninských geologických jednotek.
Pro spolehlivěší pokrytí jednotlivých skupin hornin výskytovými daty jsem vrstva nejprve reklasifikoval do 3 tříd: _karbonátové_, _silikátové_ a _smíšené_ podloží (viz @tab:pred_geo). Metodiku reklasifikace jsem převzal z práce #cite(<chauvier_2021>, form: "prose").
V druhém kroku jsem reklasifikovanou vrstvu rasterizoval podle centroidu do všech využitých rozlišení buňek s využitím souřadnicového systému ETRS89-extended / LAEA Europe (EPSG: 3035).

#import "typst/tables/pred_geo.typ": pred_geo
#pred_geo

==== Půdní prediktory
#v(5pt)

Pro doplnění prediktorové sádky o informaci o půdních poměrech jsem použil tři vrstvy z databáze _SoilGrids250m_ @soilgrids_250m.
Konkrétně jde o absolutní hloubku k podloží (_absolute depth to bedrock_), udávanou v milimetrech, dostupnou vodní kapacitu do bodu vadnutí (_derived available soil water capacity until wilting point_), vyjádřenou jako objemový podíl, a půdní reakci měřenou ve vodě (_soil pH in H#sub("2")O_), zapsanou jako pH*10. Originální rastrová data jsem prostorově sjednotil s referenčními rastry a převedl do souřadnicového systému ETRS89-extended / LAEA Europe (EPSG: 3035). Protože byla zdrojová data poskytována v hrubším prostorovém rozlišení, než jaké jsem použil v nejjemnějších variantách modelů, hodnoty pro rozlišení 100 a 200 m jsem odvodil pomocí bilineární interpolace. Při převodu do rozlišení 500 a 1000 m jsem naopak vypočítal průměr hodnot původních buněk. Vzhledem k tomu, že se půdní charakteristiky mohou v čase měnit, využil jsem tyto prediktory pouze při trénování modelů zaměřených na co nejvěrnější charakterizaci současného rozšíření vhodných stanovišť.

==== Krajinný pokryv
#v(5pt)

Krajinný pokryv je v této práci reprezentován datasetem ESA WorldCover 2021. Tato data představují globální klasifikaci zemského povrchu v prostorovém rozlišení 10 m založenou na snímcích družic Sentinel-1 a Sentinel-2 @landcover_data. Dataset jsem v této práci použil jako kategorický prediktor zachycující současný biotopový stav lokalit. Podklady jsem stáhl na základě prostorového dotazu z oficiálních #link("https://esa-worldcover.org/en")[stránek projektu].
Připravené dlaždice jsem nejprve sloučil do jedné mozaiky, oříznul a maskoval polygonem studovaného území a následně reprojektoval do souřadnicového systému ETRS89-extended / LAEA Europe (EPSG: 3035). Základní vrstvu jsem dále informovaně agregoval do rozlišení 100, 200, 500 a 1000 m podle modální hodnoty, přičemž jsem zvýhodňoval kategorii _bare/sparse vegetation_: v případě, že v buňce cílového rozlišení činil podíl této kategorie alespoň 5 %, celou buňku jsem klasifikoval jako _bare/sparse vegetation_. Tento postup měl omezit ztrátu prostorově málo rozsáhlých, avšak pro horské druhy potenciálně významných otevřených stanovišť při převodu do hrubšího rozlišení.

[[[kategorie LC]]]

Podobně jako DEM je i vrstva kategorizovaného krajinného pokryvu založená na datech dálkového průzkumu Země a jde tudíž o prostorově velmi přesný produkt s poměrně vysokou rozlišovací přesností. Určitou nevýhodou pro využití v SDM je nepřenositelnost v čase. Z tohoto důvodu jsem krajinný pokryv _apriori_ vyloučil z modelů určených pro temporální extrapolaci.

== Příprava dat
=== Datové sady pro modelování, kolinearita prediktorů
#v(5pt)

Z individuálně připravených vrstev jsem následně vytvořil výchozí rastrové soubory (stacks) obsahující všechny kandidátní environmentální prediktory dostupné pro dané prostorové rozlišení. Pro účely temporálních projekcí jsem navíc připravil užší varianta prediktorových souborů, ze které jsem vyloučil prediktory reprezentující v čase proměnlivé fenomény a tudíž nevhodné pro extrapolaci mimo současnost (viz @tab:pred_sets).

V dalším kroku jsem na připravených souborech posuzoval kolinearitu mezi jednotlivými prediktory. Hodnoty prediktorů jsem pro tuto analýzu extrahoval dvojím způsobem: (i) z buňek pozorování jednotlivých druhů a (ii) v náhodně vybraném vzorku 50 tisíců buněk studovaného území. Dichotomie tohoto vzorkování měla v prvním případě předejít kolinearitě v datech, která přímo vstupují do modelu a ve druhém případě obecné kolinearitě, kterou by kvůli specifickým podmínkám vzorkovaných lokalit neodhalil přístup první.

Pro každý druh a každé prostorové rozlišení jsem na extrahovaných vzorcích provedl poloautomatizovaný výběr proměnných s využitím balíčku _collinear_ @collinear. V rámci procesu jsem kolinearitu posuzoval pomocí párové Pearsonovy korelace a podle faktoru inflace variance (VIF, variance inflation factor). Prahovou hodnotu maximální povolené korelace jsem stanovil na |R| = 0.7 a maximální VIF = 7 @dormann2013collinearity. Automatizované rozhodování mezi kolineárními prediktory jsem doplnil předem stanoveným prioritním pořadím proměnných. Účelem tohoto pořadí bylo prioritizovat ekologicky relevantní prediktory a naopak upozadit prediktory s relativně komplikovanou interpretovatelností @soley_2024_TOPTENHAZARDS @dormann2013collinearity a evidentními artefakty (např. CHELSA-BIOCLIM: bio08, bio9 mají v oblasti Balkánského poloostrova velmi ostré prostorové přechody mezi hodnotami, které nemohou mít fyzikální opodstatnění). Výsledky výběru prediktorů jsem pro následnou kontrolu vizualizoval pomocí balíčku _corrplot_ @corrplot.

#figure(
  caption: [Tabulka představuje dvě základní varianty prediktorových souborů, z nichž jsem na základě kolinearity vybíral prediktorové sady určené pro samotné modelování. Pořadí názvů prediktorů určuje jejich prioritu při odstraňování ze základního souboru.],
  table(
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
) <tab:pred_sets>

Výsledkem filtrace jsem pro každý druh získal dvě sady prediktorů. První zahrnovala všechny prediktory vybrané na základě analýzy kolinearity, přičemž jsem zohlednil kolineární strukturu samostatně pro každou kombinaci druhu a prostorového rozlišení. Druhou sadu jsem omezil pouze na prediktory, které byly pro daný druh vybrány konzistentně ve všech prostorových rozlišeních. Tato společná sada mi umožnila porovnávat modely vytvořené při různých velikostech buněk, avšak na základě stejného souboru prediktorů. Obě takto vytvořené sady jsem následně použil jako vstupní data pro modelování rozšíření vhodných stanovišť.

== Modelování vhodnosti stanoviště
#v(5pt)

Modely druhového rozšíření jsem vytvářel metodou ensemble of small models (_ESM_) podle metodiky #cite(<breiner_2015>, form: "prose"). Tento přístup jsem zvolil kvůli relativně malému počtu pozorování modelovaných druhů a současně potřebě pracovat s větším množstvím environmentálních prediktorů. Vytvoření jednoho komplexního modelu obsahujícího všechny prediktory současně by v takové situaci mohlo vést k overfittingu. Metodou ESM jsem tomuto riziku předcházel tak, že jsem namísto jednoho komplexního modelu vytvářel všechny možné kombinace jednoduchých bivariátních modelů, které jsem testoval samostatně @lomba_2010 @breiner_2015.

Modelování jsem prováděl samostatně pro jednotlivé druhy a jednotlivá prostorová rozlišení prediktorů. Nejprve jsem k bodovým výskytovým datům přiřadil hodnoty všech prediktorů z příslušného souboru prediktorů. Každý záznam tak obsahoval informaci o presenci nebo absenci druhu, koordináty, váhu observace a hodnoty environmentálních prediktorů. Záznamy, pro které nebyla dostupná hodnota některého z použitých prediktorů, jsem vyloučil. Kategorické prediktory jsem pro účely modelování převedl na faktory. Samotný modelovací proces jsem zahájil vytvořením všech dostupných bivariátních kombinací pro každý použitý algoritmus:

$
  N_"modelů" = N_"biv. kombinací prediktorů" times N_"algoritmů"
$

Pro všechny rostlinné druhy a pro všechna rozlišení prediktorů jsem použil těchto 6 algoritmů: zobecněné lineární modely (_GLM_, #cite(<R>, form: "prose")), boosted regression trees (_GBM_, #cite(<gbm>, form: "prose")), zobecněné aditivní modely (_GAM_, #cite(<mgcv>, form: "prose")), klasifikační stromy (_CTA_, #cite(<rpart>, form: "prose")), multivariate adaptive regression splines (_MARS_, #cite(<earth>, form: "prose")) a random forest (_RF_, #cite(<ranger>, form: "prose")).

Jednotlivé bivariátní modely jsem trénoval na předem připravených prostorových cross-validačních foldech (viz @chap:CV a @fig:ESM) observačních dat, kdy jsem část dat použil k fitování modelu a část k jeho testování. Výsledky této cross-validace jsem pro každý jeden fold kvantifikoval pomocí Somersova D (dále také jako _S-D_, #cite(<somersD>, form: "prose") #cite(<Hmisc>, form: "prose")).

$ "Somersovo D" = 2 times ("AUC" - 0.5) $

Tato metrika vychází z běžně používaného AUC (_area under the receiver operating characteristic curve_), nabývá hodnot od _-1_ do _1_ a vyjadřuje diskriminační schopnost modelu, kde kladné hodnoty značí lepší než náhodné rozlišení presencí a absencí, zatímco nulové nebo záporné hodnoty ukazují na model s horší rozlišovací schopností než model náhodný.

V dalším kroku jsem hodnoty Somersova D pro daný bivariátní model zprůměroval a porovnal s hraniční hodnotou 0. Bivariátní modely s průměrným S-D $<=$ 0 jsem z dalších analýz vyloučil. Z modelů, které prošly sítem, jsem sestavil algoritmický soubor predikcí (_algo-ESM_, viz @fig:ESM), přičemž jsem příspěvek jednotlivých bivariátních modelů vážil jejich průměrným výkonem. Modely s vyšší hodnotou S-D tak měly v algo-ESM větší vliv než modely s nižší, avšak stále kladnou úspěšností. Soubor predikcí jsem sestavil pro každý algoritmus samostatně. Predikci takto sestavených algo-ESM jsem následně znovu vyhodnotil podle testovacích částí předpřipravených CV foldů a analogicky jako v kroku výše jsem vypočítal průměrné Somersovo D pro daný algo-ESM a porovnal jej s hraniční hodnotou, přičemž algo-ESM s průměrným S-D $<=$ 0 jsem z dalších analýz opět vyloučil. Pokud v tomto kroku nastala situace, že S-D#sub("algo-ESM") $<=$ 0, vyloučil jsem v daném běhu celou větev algoritmu z modelovacího procesu.

Po dokončení validačního procesu jsem ponechané bivariátní modely znovu natrénoval na celém dostupném datasetu. Tento krok zajistil, že finální ESM model využíval pro odhad vztahu mezi výskytem druhu a prostředím všechna cenná dostupná data. Relativní příspěvky jednotlivých bivariátních modelů natrénovaných na celém datasetu jsem vážil pomocí vah získaných v prvním kroku sestavování algo-ESM a zároveň pomocí váhy algoritmu jako celku. Efektivní příspěvek bivariátního modelu je možné vyjádřit jako:

$
  w_"efektivní" = w_"bivariátní model" times w_"mateřský algo-ESM"
$

kde $w_"efektivní"$ vyjadřuje intenzitu příspěvku bivariátního modelu do celkového ESM, $w_"bivariátní model"$ vyjadřuje váhu daného bivariátního modelu mezi všemi ostatními bivariátními modely stejného algoritmu a $w_"mateřský algo-ESM"$ vyjadřuje váhu celého algoritmu.

Finální predikční výkonnost celého ensemble modelu jsem vyjádřil pomocí jediné hodnoty Somersova D. Tuto souhrnnou hodnotu jsem vypočítal během jednotlivých cross validačních kroků z (i) projekce vážených predikcí bivariátních modelů na testovací část datového souboru v rámci jednoho algoritmu a (ii) projekce vážených predikcí jednotlivých algoritmických ESM na testovací část datového souboru. Tím jsem získal dvojitě váženou predikci pro každý jeden testovací bod a po proběhnutí procesu na všech cross validačních souborech jsem tyto predikce spojil do jednoho vektoru, na němž jsem spočítal finální Somersovo D pro celý model @breiner_2015.

#figure(
  image("obj/pic/ESM_schema.png", height: 90%),
  caption: [
    Schematické znázornění modelovacího procesu ESM.
  ],
) <fig:ESM>

== Projekce

#v(10pt)

Vypočítané modely jsem promítl do dvou historických a dvou budoucích časových řezů. Jako reprezentativní body v minulosti jsem vybral dva časové řezy: poslední glaciální maximum (LGM, 21k BP) a holocénní klimatické optimum (HCO, 8k BP). Jelikož se v obou případech jedná o sporné vymezení konkrétních událostí (např. #cite(<davis2003>, form: "prose") ukazují, že HCO se v jižní Evropě neprojevovalo tak silně jako v Evropě severní), je nutné vnímat zvolené časové řezy jako částečně arbitrární rozhodnutí.

Pro vyjádření budoucí potenciální vhodnosti stanovišť jsem jednotlivé projekce agregoval napříč použitými klimatickými projekčními modely (earth system models, viz výše), přičemž jsem časové řezy a scénáře SSP ponechal odděleně. Z možných časových řezů připravených v rámci projektu CHELSA-BIOCLIM jsem ponechal pouze projekce do období 2041–2070 a 2071–2100. Agregaci jsem prováděl samostatně pro každou kombinaci druhu, prostorového rozlišení, časového řezu a scénáře SSP. Výslednou konsenzuální projekci jsem vypočítal jako průměr predikované vhodnosti stanoviště z jednotlivých projekcí založených na různých earth system models. Současně jsem pro stejnou sadu projekcí vypočítal směrodatnou odchylku jako vyjádření mezimodelové variability. Směrodatná odchylka zde tedy nepředstavuje variabilitu v modelech samotných, ale pouze prostorové vyjádření rozdílů mezi projekcemi založenými na různých klimatických modelech v rámci stejného scénáře SSP. Tento postup jsem zvolil, jelikož projekce rozšíření vhodných stanovišť do budoucích klimatických podmínek jsou zatíženy nejen nejistotou spojenou se samotným modelem rozšíření, ale také s volbou klimatického modelu a emisního scénáře. Ačkoli se v literatuře obvykle přistupuje k sofistikovanějším metodám spojování predikcí, i jednoduchá agregace může omezit závislost interpretace na jednom konkrétním klimatickém modelu @araujo_2007 @araujo_2005.

== Metoda Shape jako odhad projekční extrapolace v prostoru
#v(5pt)

Metoda Shape @shape_2023 představuje nástroj určený k posouzení míry extrapolace při prostorové či časové projekci modelů vhodnosti stanoviště.
Jejím principem je porovnání podmínek prostředí v projekční oblasti s podmínkami, na jejichž základě byl model kalibrován.

Pro každou rastrovou buňku jsem v mnohorozměrném environmentálním prostoru vypočítal Mahalanobisovu vzdálenost ke každému bodu z trénovací sady a z této množiny jsem pro danou buňku vybral nejnižší hodnotu (@fig:shape *(a)*).
Takto vypočtenou vzdálenost jsem následně škáloval disperzním faktorem trénovacích dat, čímž jsem získal bezrozměrnou metriku vyjadřující míru environmentální novosti dané lokality (@fig:shape *(b)*).
Nízké hodnoty metriky Shape odpovídají podmínkám blízkým trénovacím datům, a tedy lokalitám, kde model interpoluje v rámci známého environmentálního prostoru.
Oproti tomu vysoké hodnoty ukazují, že projekce je prováděna do podmínek, které nejsou v trénovacích datech výrazněji zastoupeny, a predikce v daných lokalitách je proto zatížena vyšší nejistotou.
//Výhodou této metody je skutečnost, že při výpočtu nevychází pouze z centroidu trénovacích dat, ale zohledňuje jejich skutečné rozložení v environmentálním prostoru.
//Díky tomu lépe vystihuje celkový rozsah trénovacích podmínek a umožňuje rozlišit oblasti, kde model v prostoru interpoluje a kde už dochází k extrapolaci.

#figure(
  image("obj/pic/shape.jpg"),
  caption: [Grafické znázornění metody Shape v zjednodušeném dvourozměrném prostoru. *(a)* Reprezentuje výpočet Mahalanobisových vzdáleností mezi projekčním bodem a všemi trénovacími body. Nejnižší vzdálenost vyznačena oranžově. *(b)* Vyjádření metriky Shape _S#sub[pi]_ pro projekční body. _A_ značí disperzní faktor trénovacích dat. Vyšší hodnota _S#sub[pi]_ značí vyšší míru environmentální novosti a tudíž vyšší míru extrapolace modelu. Převzato z #cite(<shape_2023>, form: "prose")],
) <fig:shape>

V rámci této práce jsem metriku Shape použil jako hlavní nástroj k posuzování míry extrapolace. Za tímto účelem jsem její hodnoty pro každý model a každou projekci zobrazil prostorově, což mi umožnilo hodnotit věrohodnost predikcí v jednotlivých lokalitách, a zároveň v bivariátních grafech. Ty znázorňovaly rozložení kombinací hodnot prediktorů ve dvourozměrném environmentálním prostoru a usnadňovaly posouzení, zda byly jednotlivé gradienty v trénovacích datech dostatečně provzorkovány.

== Prohlášení k metodám
#v(5pt)

Veškeré analýzy byly provedeny v prostředí R, verze 4.2.2 ‒ Innocent and Trusting @R Vizualizace a kontrola výstupních rastrů probíhala v programu QGIS, verze 3.28.9 ‒ Firenze @QGIS_software.

#line(length: 100%)

Část výpočtů byla provedena s využitím výpočetních zdrojů MetaCentra.

#align(
  center,
)[
  #block(
    width: 90%,
  )[
    Computational resources were provided by the e-INFRA CZ project (ID:90254), supported by the Ministry of Education, Youth and Sports of the Czech Republic.
  ]
]

#line(length: 100%)

Prohlašuji, že při přípravě předložené práce byly použity následující nástroje AI uvedenými způsoby:

#align(
  left,
)[
  #block(
    width: 80%,
  )[
    *ChatGPT* v období *1. 11. 2025 – #datum*, popis použití: generování kódu k analýze dat, generování kódu využitého k sazbě práce, vyhledávání publikací a zpracování výtahů z nich, návrhy textů.
  ]
]
Po použití uvedených nástrojů umělé inteligence jsem důkladně revidoval a upravil obsah podle potřeby a plně přejímám odpovědnost za výslednou podobu práce.

#line(length: 100%)

Skripty využité v rámci této diplomové práce jsou dohledatelné ve veřejném repozitáři na GitHub na adrese #link("https://github.com/zbubster/Western-Balkans-SDM-thesis")[https://github.com/zbubster/Western-Balkans-SDM-thesis].

[[[vytvořit release a odkazovat na něj]]]

== Modelové sady
#v(5pt)

Pro každý ze šesti studovaných druhů a každé ze čtyř prostorových rozlišení (1000 m, 500 m, 200 m a 100 m) jsem vytvořil tři samostatné varianty ensemble of small models (ESM), které se lišily sadou vstupních prediktorů.

+ První varianta zahrnovala pouze prediktory extrapolovatelné v čase. Modely natrénované na současných environmentálních podmínkách jsem kromě současnosti projektoval také do dvou období minulosti (21k BP, LGM a 8k BP, HCO) a dvou období budoucnosti (2041–2070 a 2071–2100). Pro každý budoucí časový řez jsem samostatně zpracoval tři scénáře sdílených socioekonomických trajektorií (SSP1-2.6, SSP3-7.0 a SSP5-8.5). Ačkoli jsem modely této sady natrénoval ve všech čtyřech prostorových rozlišeních, projekce do historických a budoucích environmentálních podmínek jsem vytvořil pouze v rozlišeních 1000, 500 a 200 m. Déle _Modely na extrapolovatelných prediktorech_.

+ Druhá varianta vycházela ze všech vybraných prediktorů, včetně proměnných, které nebylo možné smysluplně přenášet v čase, například krajinného pokryvu a půdních prediktorů. Tyto modely jsem použil především k co nejúplnějšímu popisu současného rozšíření vhodných stanovišť. Dále _Modely na všech prediktorech_.

+ Třetí varianta byla založena na sadě prediktorů společné všem prostorovým rozlišením daného druhu, tedy prediktorů splňujících podmínky kolinearity ve všech rozlišeních. Tato varianta mi umožnila porovnat vliv prostorového rozlišení na výsledky modelování. Dále _Modely na společných prediktorech_.

Napříč všemi druhy a rozlišeními jsem tedy celkem vytvořil 72 finálních ESM, ze kterých vzniklo 72 projekcí současné vhodnosti stanovišť, 36 historických projekcí a 540 budoucích projekcí (tyto jsem však zprůměroval přes klimatické modely do 108 projekcí budoucích environmentílních podmínek). Celkem tedy v rámci této práce prezentuji 216 projekcí.

// # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
// výsledky
#pagebreak()
= Výsledky

#v(5pt)

Níže prezentované výsledky jsou členěny do tří modelovacích větví. Tyto se liší sadou použitých environmentálních prediktorů, účelem vytvořených modelů a z těchto důvodů jsou odědělny do samostatných kapitol. V první části jsou prezentovány výsledky modelů založených na _extrapolovatelných prediktorech_ (@chap:res_extrapol), v druhé části modely na _všech dostupných_ prediktorech, které v daném rozlišení prošly podmínkami kolinearity (@chap:res_noextrapol_all) & ve poslední třetí části jsou prezentovány modely založené na _prediktorech společných_ všem prostorovým rozlišením u daného druhu (@chap:res_noextrapol_common).
#v(-5pt)
Všechny modelové sady byly trénovány na stejném základním souboru pozorování výskytu studovaných druhů, jehož velikost se však mezi prostorovými rozlišeními měnila v důsledku prostorové agregace a odstranění duplicitních záznamů. Počty presenčních a absenčních pozorování použitých při trénování modelů jsou shrnuty v @tab:observ.
#v(-5pt)
#line(length: 100%)
#v(-10pt)

#import "typst/tables/res_observ.typ": observ_table
#observ_table

== Modely na extrapolovatelných prediktorech <chap:res_extrapol>

#v(10pt)

V rámci této kapitoly jsou uvedeny výsledky modelů založených na extrapolovatelných prediktorech. Představené projekce tak představují odhad prostorového rozložení vhodnosti stanovišť v současnosti a jeho změn při projekci do odlišných klimatických podmínek minulosti či budoucnosti. Nejprve je uveden souhrnný přehled všech vytvořených modelů, soupis vybraných prediktorů, dále počet trénovaných a ponechaných bivariátních modelů a výsledné predikční výkonnosti vyjádřené pomocí souhrnného Somersova D (@tab:extrapol_result_table). Následně jsou výsledky jsou členěny podle jednotlivých studovaných druhů. Pro každý druh je zobrazen souhrnný mapový přehled projekcí nejúspěšnějšího ESM, tedy modelu s nejvyšší hodnotou Somersova D napříč hodnocenými prostorovými rozlišeními. Přehled zahrnuje projekci současné vhodnosti stanovišť, rekonstrukce pro poslední glaciální maximum a holocenní klimatické optimum a budoucí projekce pro období 2041–2070 & 2071–2100 podle scénářů SSP1-2.6, SSP3-7.0 a SSP5-8.5. Výstupy ostatních prostorových rozlišení, podrobné křivky odpovědí, mapy metriky Shape a další modelové výstupy pro jednotlivá období jsou uvedeny v druhově specifických přílohách.

#import "typst/tables/res_extrapol.typ": extrapol_result_table
#extrapol_result_table

=== _Gentiana dinarica_ ‒ 500 m

#extrapol_proj_grid(
  species: "GD",
  grain: 500,
  caption: "Projekce pro nejúspěšněnší ESM druhu Gentiana dinarica v rozlišení 500 m (Somersovo D: 0,721).",
)

=== _Gentiana tergestina_ ‒ 200 m

#extrapol_proj_grid(
  species: "GT",
  grain: 200,
  caption: "Projekce pro nejúspěšněnší ESM druhu Gentiana tergestina v rozlišení 200 m (Somersovo D: 0,48).",
)

=== _Primula kitaibeliana_ ‒ 200 m

#extrapol_proj_grid(
  species: "PK",
  grain: 200,
  caption: "Projekce pro nejúspěšněnší ESM druhu Primula kitaibeliana v rozlišení 200 m (Somersovo D: 0,839).",
)

=== _Phyteuma orbiculare_ ‒ 1000 m

#extrapol_proj_grid(
  species: "PO",
  grain: 1000,
  caption: "Projekce pro nejúspěšněnší ESM druhu Phyteuma orbiculare v rozlišení 1000 m (Somersovo D: 0,778).",
)

=== _Phyteuma pseudorbiculare_ ‒ 200 m

#extrapol_proj_grid(
  species: "PP",
  grain: 200,
  caption: "Projekce pro nejúspěšněnší ESM druhu Phyteuma pseudorbiculare v rozlišení 200 m (Somersovo D: 0,706).",
)

=== _Saxifraga blavii_ ‒ 1000 m

#extrapol_proj_grid(
  species: "SB",
  grain: 1000,
  caption: "Projekce pro nejúspěšněnší ESM druhu Saxifraga blavii v rozlišení 1000 m (Somersovo D: 0,693).",
)

== Modely na všech prediktorech <chap:res_noextrapol_all>

#v(10pt)

V této kapitole jsou uvedeny výsledky modelů založených na všech prediktorech, které u daného druhy a v daném prostorovém rozlišení prošly filtrem kolinearity, avšak oproti @chap:res_extrapol jsou v této modelovací sadě zahrnuty i prediktory, u kterých není možné předpokládat stabilitu v čase (půdní, krajinný pokryv). V úvodu je uvedena souhrnná tabulka popisující prediktorové sady, počty trénovaných a ponechaných bivariátních modelů a predikční výkonnost všech kombinací druhu a prostorového rozlišení (@tab:noextrapol_all_result_table). V druhových podkapitolách je zobrazena projekce současné vhodnosti stanovišť vytvořená na základě nejúspěšnějšho ESM, doplněná prostorovým rozložením metriky Shape, která vyjadřuje míru environmentální odlišnosti projekčních podmínek od podmínek zastoupených v trénovacích datech a pro každý z vybraných modelů jsou následně vyobrazeny křivky odpovědí druhů. Výstupy ostatních prostorových rozlišení, včetně křivek odpovědí druhu, mapy & bivariátní grafy metriky Shape a další výstupy jsou uvedeny v druhově specifických přílohách.

#import "typst/tables/res_noextrapol_all.typ": noextrapol_all_result_table
#noextrapol_all_result_table

=== _Gentiana dinarica_ ‒ 1000 m

#figure(
  esm_shape_noextrapol(
    "GD",
    1000,
    colin: "all_selected",
  ),
  caption: [Vlevo projekce nejúspěšnějšího ESM pro druh _Gentiana dinarica_ v rozlišení 1000 m (Somersovo D: 0,733). Vpravo prostorová ditribuce metriky Shape pro data, na která byl model projektován.],
)

#[
  #show figure.where(kind: image): set block(breakable: true)

  #figure(
    response-curves-grid(
      "GD",
      1000,
      "complex",
      colinearity: "all_selected",
      extrapolation: "noextrapol",
      columns: 4,
    ),
    caption: [Křivky odpovědí druhu _Gentiana dinarica_ v rozlišení 1000 m. Vyjadřují změnu průměrné pravděpodobnosti výskytu druhu na gradientu daného prediktoru (plná linka). Sestaveny byly z ponechaných bivariátních modelů (tenké linky) obsahujících příslušný prediktor, kdy jejich predikce byly nejprve váženě agregovány v rámci jednotlivých algoritmů a následně mezi algoritmy podle jejich vah v rámci finálního ESM.],
  )
]


=== _Gentiana tergestina_ ‒ 200 m

#figure(
  esm_shape_noextrapol(
    "GT",
    200,
    colin: "all_selected",
  ),
  caption: [Vlevo projekce nejúspěšnějšího ESM pro druh _Gentiana tergestina_ v rozlišení 200 m (Somersovo D: 0,519). Vpravo prostorová ditribuce metriky Shape pro data, na která byl model projektován.],
)

#[
  #show figure.where(kind: image): set block(breakable: true)

  #figure(
    response-curves-grid(
      "GT",
      200,
      "complex",
      colinearity: "all_selected",
      extrapolation: "noextrapol",
      columns: 4,
    ),
    caption: [Křivky odpovědí druhu _Gentiana tergestina_ v rozlišení 200 m. Vyjadřují změnu průměrné pravděpodobnosti výskytu druhu na gradientu daného prediktoru (plná linka). Sestaveny byly z ponechaných bivariátních modelů (tenké linky) obsahujících příslušný prediktor, kdy jejich predikce byly nejprve váženě agregovány v rámci jednotlivých algoritmů a následně mezi algoritmy podle jejich vah v rámci finálního ESM.],
  )
]

=== _Primula kitaibeliana_ ‒ 200 m

#figure(
  esm_shape_noextrapol(
    "PK",
    200,
    colin: "all_selected",
  ),
  caption: [Vlevo projekce nejúspěšnějšího ESM pro druh _Primula kitaibeliana_ v rozlišení 200 m (Somersovo D: 0,904). Vpravo prostorová ditribuce metriky Shape pro data, na která byl model projektován.],
)

#[
  #show figure.where(kind: image): set block(breakable: true)

  #figure(
    response-curves-grid(
      "PK",
      200,
      "complex",
      colinearity: "all_selected",
      extrapolation: "noextrapol",
      columns: 4,
    ),
    caption: [Křivky odpovědí druhu _Primul kitaibeliana_ v rozlišení 200 m. Vyjadřují změnu průměrné pravděpodobnosti výskytu druhu na gradientu daného prediktoru (plná linka). Sestaveny byly z ponechaných bivariátních modelů (tenké linky) obsahujících příslušný prediktor, kdy jejich predikce byly nejprve váženě agregovány v rámci jednotlivých algoritmů a následně mezi algoritmy podle jejich vah v rámci finálního ESM.],
  )
]

=== _Phyteuma orbiculare_ ‒ 1000 m

#figure(
  esm_shape_noextrapol(
    "PO",
    1000,
    colin: "all_selected",
  ),
  caption: [Vlevo projekce nejúspěšnějšího ESM pro druh _Phyteuma orbiculare_ v rozlišení 1000 m (Somersovo D: 0,728). Vpravo prostorová ditribuce metriky Shape pro data, na která byl model projektován.],
)

#[
  #show figure.where(kind: image): set block(breakable: true)

  #figure(
    response-curves-grid(
      "PO",
      1000,
      "complex",
      colinearity: "all_selected",
      extrapolation: "noextrapol",
      columns: 4,
    ),
    caption: [Křivky odpovědí druhu _Phyteuma orbiculare_ v rozlišení 1000 m. Vyjadřují změnu průměrné pravděpodobnosti výskytu druhu na gradientu daného prediktoru (plná linka). Sestaveny byly z ponechaných bivariátních modelů (tenké linky) obsahujících příslušný prediktor, kdy jejich predikce byly nejprve váženě agregovány v rámci jednotlivých algoritmů a následně mezi algoritmy podle jejich vah v rámci finálního ESM.],
  )
]

=== _Phyteuma pseudorbiculare_ ‒ 200 m

#figure(
  esm_shape_noextrapol(
    "PP",
    200,
    colin: "all_selected",
  ),
  caption: [Vlevo projekce nejúspěšnějšího ESM pro druh _Phyteuma pseudorbiculare_ v rozlišení 200 m (Somersovo D: 0,688). Vpravo prostorová ditribuce metriky Shape pro data, na která byl model projektován.],
)

#[
  #show figure.where(kind: image): set block(breakable: true)

  #figure(
    response-curves-grid(
      "PO",
      200,
      "complex",
      colinearity: "all_selected",
      extrapolation: "noextrapol",
      columns: 4,
    ),
    caption: [Křivky odpovědí druhu _Phyteuma pseudorbiculare_ v rozlišení 200 m. Vyjadřují změnu průměrné pravděpodobnosti výskytu druhu na gradientu daného prediktoru (plná linka). Sestaveny byly z ponechaných bivariátních modelů (tenké linky) obsahujících příslušný prediktor, kdy jejich predikce byly nejprve váženě agregovány v rámci jednotlivých algoritmů a následně mezi algoritmy podle jejich vah v rámci finálního ESM.],
  )
]

=== _Saxifraga blavii_ ‒ 1000 m

#figure(
  esm_shape_noextrapol(
    "SB",
    1000,
    colin: "all_selected",
  ),
  caption: [Vlevo projekce nejúspěšnějšího ESM pro druh _Saxifraga blavii_ v rozlišení 1000 m (Somersovo D: 0,65). Vpravo prostorová ditribuce metriky Shape pro data, na která byl model projektován.],
)

#[
  #show figure.where(kind: image): set block(breakable: true)

  #figure(
    response-curves-grid(
      "SB",
      1000,
      "complex",
      colinearity: "all_selected",
      extrapolation: "noextrapol",
      columns: 4,
    ),
    caption: [Křivky odpovědí druhu _Saxifraga blavii_ v rozlišení 1000 m. Vyjadřují změnu průměrné pravděpodobnosti výskytu druhu na gradientu daného prediktoru (plná linka). Sestaveny byly z ponechaných bivariátních modelů (tenké linky) obsahujících příslušný prediktor, kdy jejich predikce byly nejprve váženě agregovány v rámci jednotlivých algoritmů a následně mezi algoritmy podle jejich vah v rámci finálního ESM.],
  )
]

#pagebreak()
== Modely na společných prediktorch <chap:res_noextrapol_common>

#v(10pt)

V poslední kapitole výsledků jsou uvedeny výstupy modelů založených na společných prediktorech pro daný druh napříč prostorovými rozlišeními. Tyto výstupy jsou určeny především k porovnání vlivu prostorového rozlišení na výsledky modelů. V úvodu je zobrazena souhrnná tabulka (@tab:noextrapol_common_result_table) svou logikou odpovídající předchozím dvěma kapitolám. Následně u každého jednotlivého druhu je zobrazena variabilita v příspěvcích jednotlivých prediktorů napříč rozlišeními, krabicové diagramy reprezentující variabilitu v predikcích modelů a křivky odpovědí druhu napříč prosotorovými rozlišeními. Úplné prostorové projekce, mapy metriky Shape vč. bivariátních grafů, samostatné křivky odpovědí a další podrobné modelové výstupy jsou uvedeny v příslušných druhově specifických přílohách.

#line(length: 100%)

#import "typst/tables/res_noextrapol_common.typ": noextrapol_common_result_table
#noextrapol_common_result_table

=== _Gentiana dinarica_

#figure(
  image(
    "outputs/summary/figures/predictor_contributions/recent_noextrapol_weights_common/GD/heatmap.png",
    height: 40%,
  ),
  caption: [Relativní příspěvek jednotlivých prediktorů do finálního ESM. Jednotlivé příspěvky byly odvozeny z efektivních vah ponechaných bivariátních modelů ve finálním ensemble, přičemž váha každého bivariátního modelu byla rovným dílem rozdělena mezi oba prediktory.],
)

#figure(
  image("outputs/ESM/recent_noextrapol_weights_common/GD/OOF_prediction_common_grains.png", height: 30%),
  caption: [Krabicové grafy představují rozložení predikovaných hodnot mezi jednotlivými úrovněmi prostorového rozlišení. Predikce pro absence a presence jsou zobrazeny odděleně, přičemž barva reprezentuje dané prostorové rozlišení.],
)

#figure(
  response-curves-common-grid(
    "GD",
    columns: 3,
  ),
  caption: [Křivky odpovědí druhu _Gentiana dinarica_ na měnící se podmínky prostředí napříč prostorovými rozlišeními. Tato jsou vyznačena barevně. Křivky vyjadřují změnu průměrné pravděpodobnosti výskytu druhu na gradientu daného prediktoru.],
)


=== _Gentiana tergestina_

#figure(
  image(
    "outputs/summary/figures/predictor_contributions/recent_noextrapol_weights_common/GT/heatmap.png",
    height: 40%,
  ),
  caption: [Relativní příspěvek jednotlivých prediktorů do finálního ESM. Jednotlivé příspěvky byly odvozeny z efektivních vah ponechaných bivariátních modelů ve finálním ensemble, přičemž váha každého bivariátního modelu byla rovným dílem rozdělena mezi oba prediktory.],
)

#figure(
  image("outputs/ESM/recent_noextrapol_weights_common/GT/OOF_prediction_common_grains.png", height: 30%),
  caption: [Krabicové grafy představují rozložení predikovaných hodnot mezi jednotlivými úrovněmi prostorového rozlišení. Predikce pro absence a presence jsou zobrazeny odděleně, přičemž barva reprezentuje dané prostorové rozlišení.],
)

#figure(
  response-curves-common-grid(
    "GT",
    columns: 3,
  ),
  caption: [Křivky odpovědí druhu _Gentiana tergestina_ na měnící se podmínky prostředí napříč prostorovými rozlišeními. Tato jsou vyznačena barevně. Křivky vyjadřují změnu průměrné pravděpodobnosti výskytu druhu na gradientu daného prediktoru.],
)


=== _Primula kitaibeliana_

#figure(
  image(
    "outputs/summary/figures/predictor_contributions/recent_noextrapol_weights_common/PK/heatmap.png",
    height: 40%,
  ),
  caption: [Relativní příspěvek jednotlivých prediktorů do finálního ESM. Jednotlivé příspěvky byly odvozeny z efektivních vah ponechaných bivariátních modelů ve finálním ensemble, přičemž váha každého bivariátního modelu byla rovným dílem rozdělena mezi oba prediktory.],
)

#figure(
  image("outputs/ESM/recent_noextrapol_weights_common/PK/OOF_prediction_common_grains.png", height: 30%),
  caption: [Krabicové grafy představují rozložení predikovaných hodnot mezi jednotlivými úrovněmi prostorového rozlišení. Predikce pro absence a presence jsou zobrazeny odděleně, přičemž barva reprezentuje dané prostorové rozlišení.],
)

#figure(
  response-curves-common-grid(
    "PK",
    columns: 3,
  ),
  caption: [Křivky odpovědí druhu _Primula kitaibeliana_ na měnící se podmínky prostředí napříč prostorovými rozlišeními. Tato jsou vyznačena barevně. Křivky vyjadřují změnu průměrné pravděpodobnosti výskytu druhu na gradientu daného prediktoru.],
)


=== _Phyteuma orbiculare_

#figure(
  image(
    "outputs/summary/figures/predictor_contributions/recent_noextrapol_weights_common/PO/heatmap.png",
    height: 40%,
  ),
  caption: [Relativní příspěvek jednotlivých prediktorů do finálního ESM. Jednotlivé příspěvky byly odvozeny z efektivních vah ponechaných bivariátních modelů ve finálním ensemble, přičemž váha každého bivariátního modelu byla rovným dílem rozdělena mezi oba prediktory.],
)

#figure(
  image("outputs/ESM/recent_noextrapol_weights_common/PO/OOF_prediction_common_grains.png", height: 30%),
  caption: [Krabicové grafy představují rozložení predikovaných hodnot mezi jednotlivými úrovněmi prostorového rozlišení. Predikce pro absence a presence jsou zobrazeny odděleně, přičemž barva reprezentuje dané prostorové rozlišení.],
)

#figure(
  response-curves-common-grid(
    "PO",
    columns: 3,
  ),
  caption: [Křivky odpovědí druhu _Phyteuma orbiculare_ na měnící se podmínky prostředí napříč prostorovými rozlišeními. Tato jsou vyznačena barevně. Křivky vyjadřují změnu průměrné pravděpodobnosti výskytu druhu na gradientu daného prediktoru.],
)


=== _Phyteuma pseudorbiculare_

#figure(
  image(
    "outputs/summary/figures/predictor_contributions/recent_noextrapol_weights_common/PP/heatmap.png",
    height: 40%,
  ),
  caption: [Relativní příspěvek jednotlivých prediktorů do finálního ESM. Jednotlivé příspěvky byly odvozeny z efektivních vah ponechaných bivariátních modelů ve finálním ensemble, přičemž váha každého bivariátního modelu byla rovným dílem rozdělena mezi oba prediktory.],
)

#figure(
  image("outputs/ESM/recent_noextrapol_weights_common/PP/OOF_prediction_common_grains.png", height: 30%),
  caption: [Krabicové grafy představují rozložení predikovaných hodnot mezi jednotlivými úrovněmi prostorového rozlišení. Predikce pro absence a presence jsou zobrazeny odděleně, přičemž barva reprezentuje dané prostorové rozlišení.],
)

#figure(
  response-curves-common-grid(
    "PP",
    columns: 3,
  ),
  caption: [Křivky odpovědí druhu _Phyteuma pseudorbiculare_ na měnící se podmínky prostředí napříč prostorovými rozlišeními. Tato jsou vyznačena barevně. Křivky vyjadřují změnu průměrné pravděpodobnosti výskytu druhu na gradientu daného prediktoru.],
)

=== _Saxifraga blavii_

#figure(
  image(
    "outputs/summary/figures/predictor_contributions/recent_noextrapol_weights_common/SB/heatmap.png",
    height: 40%,
  ),
  caption: [Relativní příspěvek jednotlivých prediktorů do finálního ESM. Jednotlivé příspěvky byly odvozeny z efektivních vah ponechaných bivariátních modelů ve finálním ensemble, přičemž váha každého bivariátního modelu byla rovným dílem rozdělena mezi oba prediktory.],
)

#figure(
  image("outputs/ESM/recent_noextrapol_weights_common/SB/OOF_prediction_common_grains.png", height: 30%),
  caption: [Krabicové grafy představují rozložení predikovaných hodnot mezi jednotlivými úrovněmi prostorového rozlišení. Predikce pro absence a presence jsou zobrazeny odděleně, přičemž barva reprezentuje dané prostorové rozlišení.],
)

#figure(
  response-curves-common-grid(
    "SB",
    columns: 3,
  ),
  caption: [Křivky odpovědí druhu _Saxifraga blavii_ na měnící se podmínky prostředí napříč prostorovými rozlišeními. Tato jsou vyznačena barevně. Křivky vyjadřují změnu průměrné pravděpodobnosti výskytu druhu na gradientu daného prediktoru.],
)


// # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
// diskuse
#pagebreak()
= Diskuse

V této práci byla z důvodu metodické konzistence zvolena jednotná datová sada CHELSA-BIOCLIM @chelsa_bioclim_data & CHELSA-TraCE21k @chelsa_trace_data pro současné, budoucí i historické projekce. Tento přístup zajišťuje srovnatelnost mezi jednotlivými časovými řezy, avšak nezachycuje nejistotu spojenou s volbou klimatického datasetu. V oblastech s vyšší geomorfologickou členitostí je přesnost klimatickcých modelů sporná a volba konkrétního klimatického datasetu ovlivňuje výsledné křivky odpovědí druhů na konkrétní environmentální faktory i rozlohu a rozmístění modelem predikovaných vhodných stanovišť @input_matters_matter_2019
Pro vyšší důvěryhodnost projekcí je proto vhodné pracovat s více klimatickými modely a jednotlivé výsledky mezi sebou porovnávat.

Dalším problematickým aspektem globálních klimatických modelů jsou extrapolace klimatu do historických období.
#cite(<rentier_2025>, form: "prose") ukázali, že rekonstrukce ekologických fenoménů na základě klimatických projekcí se silně odlišují mezi jednotlivými datasety i mezi rekonstrukcemi založenými na proxy ukazatelích, přičemž slabší výsledky se projevovaly u klimatických datasetů s hrubším měřítkem.
Chybovost klimatických modelů navíc vykazovala obecný trend k vyšším teplotám během LGM, obzvlášť v horských oblastech. @rentier_2025
Dataset CHELSA-TraCE21k ve zmíněné studii vykazoval v horských oblastech nejhorší výsledky, a to pravděpodobně kvůli nadprůměrně složitému procesu interpolace a zjemnňování originálních dat z meteorologických stanic, který v případě odlehlých horských oblastí vytvéřel za velké množství statistického šumu s

Volba klimatického datasetu je tedy kruciální pro důvěryhodné modely současného a rekonstrukci historického rozšíření vhodných stanovišť.

V současné době je největší limitace datovými podklady, statistiku máme dostatečnou. Prediktorové sady vykazují značnou chybovost, obzvlášť v odlehlých oblastech. Geologické i půdní mapy jsou taky surově interpolované a založené na omezeném počtu pozorování. Nabízenou cestou jsou data z dálkového průzkumu Země, která se výše zmíněným nedostatkům vyhýbají: jsou měřena "přímo" na lokalitě, mají solidní časovou řadu a nadstandardní prostorové rozlišení. Na druhou stranu jsou produkty DPZ hůře ekologicky interpretovatelné a jejich zpracování vyžaduje vyšší nároky na výpočetní výkon.

Ačkoliv využití DPZ jako prediktorů v SDM je v současnosti zkoumáno a dosavadní výsledky ukazují na sporné vylepšení modelů, v jiných oblastech monitoringu přírody a krajiny nastává jejich rozvoj. Příkladem může být efektivní monitorování sucha a požárů,

vylepšení výkonu modelu pomocí EO @schwager2021remote

Modely je obecně potřeba interpretovat s opatrností.

vhodná by byla terénní validace a potvrzování/vyvracení výsledků, jiní to dělali a mělo to i úspěch @mccune_2016_SDM_rare

Mountains of W Dinaric Alps in Croatia
and W Bosnia (SNEZ, VELE, DINA,
KLEK, and CINC). These are moder-
ately high limestone mountains, but the
high number of Arctic-Alpine species
present may be caused by their proxim-
ity to the Alps. Stevanovic Div and dist arctalp balkans

// # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
// závěr
#pagebreak()
= Závěr

// # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - # - #
// literatura
#pagebreak()
= Literatura
#v(12pt)
#bibliography(
  (
    "lit/literatura.bib",
    "lit/software.bib",
    "lit/predictors.bib",
    "lit/plants.bib",
  ),
  style: "copernicus",
  title: none,
)
