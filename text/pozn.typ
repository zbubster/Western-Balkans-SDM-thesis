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
        - problém je výpočetní náročnost velikých rastrů, což řeším výpočty na metacentru
    #line(length: 100%)
+ Jaké metody
    + _biomod2_ balíček
        - ani nezvažuji nic jiného, dokumentace je super, navíc jednoduché konstrukce ensamble modelů
        #line(length: 50%, stroke: (paint: black, dash: "dashed"))
    + prediktory
        - DEM
            - copernicus DEM
            - grain 30*30 m (bohužel znepřístupnili evropský model s grainem 10*10 m, ale tento hrubší model je více než dostatečný)
            - slope/aspect/altitude?/různé topografické indexy
            - SDM evergreen. Dobré je, že s přihmouřeným okem  je možné DEM používat i k temporální extrapolaci
        - GEO
            - v procesu
            - mám nastahovaná European Soil Database data, z nichž některá se omezují na prostor EU, ale některá popisují i rozšířený prostor, včetně bývalé Jugoslavie
            - v blízké době z nich chci vybrat relevantní prediktory
            - grain 1*1 km
            - #link("https://esdac.jrc.ec.europa.eu/content/description-raster-layers")[odkaz na ESDAC raster layer description]
        - CLIM
            - chelsa v2.1
            - grain cca 1*1 km, v našem terénu hodně hrubý prediktor, ale asi by bylo možné rozdělit na "jemnější", jako jsem to udělal v případě seminárky. Samozřejmě by pak bylo zásadní argumentovat, že data reálně nejsou jemnější, ale že větší množství sousedících buněk nese stenou hodnotu buňky mateřské
            - 
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

        - pro modelování vychází jako poměrně vhodné druhy:
            - *_Gentiana tergestina_* ‒ TN 105 z 291
            #figure(
                image("obj/pic/occurence_EDA/gentiana_tergestina.jpeg"),
                caption:[Gentiana tergestina]
                )
            - *_Phyteuma orbiculare_* ‒ TN 210 z 241 !!
                - množství dat z Chorvatska je trochu nepoměrně vysoké vzhledem k tomu, že jsme ji nalézali i na jihu
            #figure(
                image("obj/pic/occurence_EDA/phyteuma_orbiculare.jpeg"),
                caption:[Phyteuma orbiculare]
            )
            - *_Saxifraga blavii_* ‒ TN 0 z 88
                - poměrně málo presencí na velikost celkového extentu
            #figure(
                image("obj/pic/occurence_EDA/saxifraga_blavii.jpeg"),
                caption:[Saxifraga blavii]
            )
            - *_Primula kiataibeliana_* ‒ TN 109 z 109
                - všechna data od TN, ale na jihu už růst nemá
                - absence points = 0 je výpočetní chyba, která vznikla při spojování našich terénních dat s daty Toniho Nikoliče (nemáme z terénu žádný prezenční bod pro primkit, takže nevznikla vrstva absenčních bodů, ke které bych pak připojil TN data). kdybychom se rozhodli primkit modelovat, tuhle chybu lehce napravím
            #figure(
                image("obj/pic/occurence_EDA/primula_kitaibeliana.jpeg"),
                caption:[Primula kitaibeliana]
            )

