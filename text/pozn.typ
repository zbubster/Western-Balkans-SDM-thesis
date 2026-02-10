= Poznámky k DP
#line(length: 100%)
+ Kam práce směřuje
    - jak se vyhnout dělání modelu pro model, existuje ekologická otázka, na kterou jsem schopný svou prací odpovědět?
        - hindcast/forecast
            - asi nejjednodušší způsob jak si zajistit klasickou "otázku a hypotézy"
            - velikost vhodného areálu v LGM, v současnosti, ev. predikce změny areálu v budoucnosti
        - conservation
            - kde jsou v současnosti vhodné lokality a kam zaměřit ochranářské snahy, možná by to chtělo aplikačního partnera? (místní ochrana přírody)
        - vztah druhu s podmínkami prostředí
            - ekologické nároky na srážky, teplotu atd. zajímavé, ale jsme schopni z dat získat informaci s relevantní přesností? (klimatické modely interpolované, mikroklimatické podmínky)
            - obávám se, že to přes lidi zvyklé trápit kytičky v laboratoři neprojde :)
        - nested hierarchical SDM, čerstvý nápad, nutno dostudovat. modelování na různých úrovních velikostí grain. snaha odpovědět na otázku, jak hrubé sdm nadhodnocuje plochu vhodných habitatů (recentní i budoucí časové rámce)
    - RS data
        - moje fascinace poslední doby
        - obrovská výhoda je, že jsme tím schopni pokrýt prostorově variabilní podmínky prostředí velmi přesně. rozlišení 20*20 m, ale hlavně jsou to data, která jsou změřená přímo v dané lokalitě (narozdíl od klimatických modelů nejsou interpolovány, ale reálně změřeny senzorem)
        - v současnosti mám data pro celý západní balkán nastahovaná na HDD
            + pro sezonu roku 2022 (1. květen 2022 až 31. srpen 2022) jsem stáhl všechny dostupné snímky
            + odmaskoval jsem podle SCL vrstvy mraky, sníh a chyby
            + z validních pixlů jsem utvořil medoidové kompozity
            + TODO: vypočítat indexy (NDVI/EVI/SAVI, NDMI, BSI, CIre, atd)
        - problém je výpočetní náročnost velikých rastrů, což řeším výpočty na metacentru
    #grid(
        columns: (1fr, 1fr),
        align(
            (left),
            [#figure(
                image("obj/pic/satellite_gen_ter.png", height: 90%),
                caption:[Presence (zelené) a absence (červené) pro druh _Gentiana tergestina_ na vrchovině Sinjajevina. Podklad: Sentinel2, 20*20 m, RGB pásma]
                )
            ]
        ),
        align(
            (right),
            [#figure(
                image("obj/pic/satellite_sax_bla.png", height: 90%),
                caption:[Presence (zelené) a absence (červené) pro druh _Saxifraga blavii_ na vrchovině Sinjajevina. Podklad: Sentinel2, 20*20 m, RGB pásma]
                )
            ]
        )
    )
    #line(length: 100%)
+ Jaké metody
    + _biomod2_ balíček
        - ani nezvažuji nic jiného, dokumentace je super, navíc jednoduché konstrukce ensamble modelů
        #line(length: 50%, stroke: (paint: black, dash: "dashed"))
    + extent a grain
        - zatím shromažduji data v co nejjemnějším dostupném měřítku si tím, že se s tím dá ještě později operovat
        - extent jsem stanovil "od oka" tak, aby logicky odpovídal místním topografickým poměrům a zároveň aby příliš nepřesahoval prosamplovanou oblast. je to zatím jen nástroj, podle kterého si zmenšuji prediktorová data, ale rozhodně se nebráním ještě jeho zmenšení (u nějakých rostlinných druhů by to klidně mohlo dávat smysl)
        - extent viz obrázky níže (např. @Genter_occur)
        #line(length: 50%, stroke: (paint: black, dash: "dashed"))
    + prediktory
        - DEM
            - copernicus DEM
            - grain 30*30 m (bohužel znepřístupnili evropský model s grainem 10*10 m, ale tento hrubší model je více než dostatečný)
            - slope/aspect/altitude?/různé topografické indexy
            - SDM evergreen. Je možné DEM používat i k temporální extrapolaci?
        - GEO
            - v procesu
            - mám nastahovaná European Soil Database data, z nichž některá se omezují na prostor EU, ale některá popisují i rozšířený prostor, včetně bývalé Jugoslavie
            - v blízké době z nich chci vybrat relevantní prediktory
            - grain 1*1 km
            - #link("https://esdac.jrc.ec.europa.eu/content/description-raster-layers")[odkaz na ESDAC raster layer description]
        - CLIM
            - chelsa v2.1
            - grain cca 1*1 km, v našem terénu hodně hrubý prediktor, ale asi by bylo možné rozdělit na "jemnější", jako jsem to udělal v případě seminárky. Samozřejmě by pak bylo zásadní argumentovat, že data reálně nejsou jemnější, ale že větší množství sousedících buněk nese stenou hodnotu buňky mateřské
            - bioclim variables (present, future)
            - #link("https://www.chelsa-climate.org/datasets/chelsa-trace21k-centennial-bioclim")[TraCE21k bioclim variables] nutno dostudovat a dostahovat
        #line(length: 50%, stroke: (paint: black, dash: "dashed"))
    + data výskytová
        - nasbírali jsme 875 datových bodů (skutečný počet použitelných buňek predikčních rastrů bude trochu nižší, jelikož na některých místech je bodů víc ‒ jsou tam presence pro různé druhy rostoucí vedle sebe)
        - dále jsem v seminárce pracoval s daty od Toniho Nikoliče lokalizovanými výhradně na území Chorvatska, tato data jsou pouze prezenční
        - v létě 2025 jsem ještě vyrazil do jižního Slovinska a kopců severně od Velebitu, abych tam něco dosbíral (hlavně jsem si říkal, že bude fajn mít odtamtud absence), ale bohužel se mi pak po návratu rozbil telefon a bylo to dřív než jsem udělal export z qfieldu... takže data ztracená
    tabulka ukazuje množství nasbíraných dat pro jednotlivé druhy
        - _pres/abs_ = počet presencí/absencí
        - _N_ = celkový počet záznamů
        - _N_TN_ = počet záznamů z datasetu Toniho Nikoliče (*pouze presence*)
        - data _N_TN_ jsou pouze z území Chorvatska. pokud se hodnota _pres_  blíží hodnotě _N_TN_, jsou data akumulována v severní části AOI ‒ to samozřejmě nemusí být špatně (jako např u druhu _Primula kitaibeliana_), ale může :)

#let data = csv("obj/tab/counts_arranged.csv")
#let head = data.first()
#let body = data.slice(1)

#align(center,
    table(
        align: center,
        columns: head.len(),
        ..head.map(h => [*#h*]),
        ..body.flatten()
    )
)

Níže pár poznámek k vybraným druhům
#pagebreak()
- *_Gentiana tergestina_*
    -  TN 105 z 291
    - pro tento druh máme úplně nejvíc dat, navíc prostorově dobře rozdělených
    #figure(
        image("obj/pic/occurence_EDA/gentiana_tergestina.jpeg"),
        caption:[Gentiana tergestina]
    ) <Genter_occur>
#pagebreak()
- *_Saxifraga blavii_*
    -  TN 0 z 88
    - poměrně málo presencí na velikost celkového extentu
    - jádrová oblast ale dobře prosamplovaná
    #figure(
        image("obj/pic/occurence_EDA/saxifraga_blavii.jpeg"),
        caption:[Saxifraga blavii]
    )
#pagebreak()
- *_Primula kiataibeliana_*
    - TN 109 z 109
    - všechna data od TN, ale na jihu už růst nemá
    - absence points = 0 je výpočetní chyba, která vznikla při spojování našich terénních dat s daty Toniho Nikoliče (nemáme z terénu žádný prezenční bod pro primkit, takže nevznikla vrstva absenčních bodů, ke které bych pak připojil TN data). kdybychom se rozhodli primkit modelovat, tuhle chybu lehce napravím
    #figure(
        image("obj/pic/occurence_EDA/primula_kitaibeliana.jpeg"),
        caption:[Primula kitaibeliana]
    )
#pagebreak()
- *_Phyteuma orbiculare_*
    - TN 210 z 241 !!
    - množství dat z Chorvatska je trochu nepoměrně vysoké vzhledem k tomu, že jsme ji nalézali i na jihu
    #figure(
        image("obj/pic/occurence_EDA/phyteuma_orbiculare.jpeg"),
        caption:[Phyteuma orbiculare]
    )
#pagebreak()
- *_Gentiana dinarica_*
    - TN 0 z 49
    - 49 presencí je dle literatury poměrně dost málo na robustní model takového extentu, každopádně by stálo za to zkusit něco vymyslet
    #figure(
        image("obj/pic/occurence_EDA/gentiana_dinarica.jpeg"),
        caption:[Phyteuma orbiculare]
    )

