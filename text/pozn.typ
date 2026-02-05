= Poznámky k DP
+ Kam práce směřuje
    - jak se vyhnout dělání modelu pro model, existuje ekologická otázka, na kterou jsem schopný svou prací odpovědět?
        - hindcast/forecast
            - asi nejjednodušší způsob jak si zajistit klasickou "otázku a hypotézy"
            - velikost vhodného areálu v LGM, v současnosti, ev. predikce změny areálu v budoucnosti
        - conservation
            - kde jsou v současnosti vhodné lokality a kam zaměřit ochranářské snahy, možná by to chtělo *aplikačního partnera?* (místní ochrana přírody)
        - vztah druhu s podmínkami prostředí
            - ekologické nároky na srážky, teplotu atd. zajímavé, ale jsme schopni z dat získat informaci s relevantní přesností? (klimatické modely interpolované, mikroklimatické podmínky)
            - obávám se, že to přes lidi zvyklé trápit kytičky v laboratoři neprojde :)
    - RS data
        - moje fascinace poslední doby
        - obrovská výhoda je, že jsme tím schopni pokrýt prostorově variabilní podmínky prostředí velmi přesně. rozlišení 20*20 m, ale hlavně jsou to data, která jsou změřená přímo v dané lokalitě (narozdíl od klimatických modelů je v tomto případě interpolace rovna nule)
        - problém je výpočetní náročnost
+ Jaké metody
    + _biomod2_ balíček
        - ani nezvažuji nic jiného, dokumentace je super, navíc jednoduché konstrukce ensamble modelů
    + prediktory
        - DEM
            - slope/aspect/altitude?/různé topografické indexy 
        - GEO
            - 
        - CLIM
            - chelsa v2.1
            - 
    + data výskytová
        - tabulka ukazuje množství nasbíraných dat pro jednotlivé druhy
        - _pres/abs_ = počet presencí/absencí
        - _N_ = celkový počet záznamů
        - _N_TN_ = počet záznamů z datasetu Toniho Nikoliče (*pouze presence*)
        - data _N_TN_ jsou pouze z území Chorvatska. pokud se hodnota _pres_  blíží hodnotě _N_TN_, jsou data akumulována v severní části AOI ‒ to samozřejmě nemusí být špatně, ale může :)

#let data = csv("obj/tab/counts.csv")
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
            - *_Phyteuma orbiculare_* ‒ TN 210 z 241 !!
                - množství dat z Chorvatska je trochu nepoměrně vysoké vzhledem k tomu, že jsme ji nalézali i na jihu
            - *_Saxifraga blavii_* ‒ TN 0 z 88
                - poměrně málo
            - *_Primula kiataibeliana_* ‒ TN 109 z 109
                - všechna data od TN, ale na jihu už růst nemá
