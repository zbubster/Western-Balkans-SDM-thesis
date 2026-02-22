#import "@preview/typslides:1.3.2": *

// Project configuration
#show: typslides.with(
  ratio: "16-9",
  theme: "bluey",
  font: "Fira Sans",
  font-size: 20pt,
  link-style: "color",
  show-progress: true,
)

// The front slide is the first slide of your presentation
#front-slide(
  title: "Modelling the Habitat Suitability of alpine plant species in the Western Balkans",
  subtitle: [Labmeeting ‒ 24th of February 2026],
  authors: "Jakub Rataj & supervisor Jan Smyčka",
  //info: [#link("https://github.com/manjavacas/typslides")],
)

// Custom outline
#table-of-contents()

/* Title slides create new sections
#title-slide[
  This is a _Title slide_
]*/


#slide(title: "Aims", outlined: true)[
  #framed(title: "Motivation and main aims")[
  Based on limited knowledge about the distribution of the focal species,
  I would like to describe their current potential range, threats in the future & behaviour since the LGM.
  I would also like to emplhisize weaknesses of this approach.
    + Coarse SDMs with temporal extrapolation
    + Various scale (grain) SDMs with comparision of information loss
    + _Fine models based on remote sensed predictors_
  ]
  - balkan endemic (sub)alpine flora
  - fieldwork done (2020 ‒ 2023)
  ]

#slide(title: "Aims, elaborated")[
  + #framed[Compose SDMs based on *coarse climate*, *topography* & *geology* data]
    - evaluation of "simple" models and their ecological relevance (e.g. errors delivered by the climate models, samplesize, effect of the site specific microclimate)
    - spatial interpolation
    - temopral extrapolation (LGM, future scenarios)

  + #framed[Composing SDMs with same data as in *1.*, but downscaling climate models]
    - comparing finer models with models delivered from *1.*
    - estimate information lost in
  
  + #framed[Remote sensing SDMs]
    - optional
    - 20 m grain (1.2 billions cells within AOI) ‒ very high computaional demands
    - ecology complicated, almost ecologically inexplainable, predictors indirect
    - BUT, predictors "directly" measured on the site and therefore "exact"
    - combination with DEM could be powerful
  ] 

#slide(title:"SDM principles", outlined: true)[
  #let schematic = image("obj/pic/Schematic_SDM.jpg", height: 75%)
  #let proj = image("obj/pic/sdm_projection.png", height: 75%)

  #cols(columns: (40%, 60%))[
    #figure(schematic, caption: [Model fitting and evaluation])
  ][
    #figure(proj, caption: [Model projection])
  ]
]


#focus-slide("Species")

#slide(title: "Species", outlined: true)[
  #cols(columns: (70%,30%))[
  #let pic = image("obj/pic/kytky.png")
  #figure(pic)
  ][
  Focal plant species.
  #grid(
    columns: (8%, 100%),
    gutter: 0.7em,
    align: (left, left),
    [*a*:], [_Gentiana tergestina_],
    [*b*:], [_Gentiana dinarica_],
    [*c*:], [_Primula kitaibeliana_],
    [*d*,*e*:], [_Saxifraga blavii_],
    [*f*:], [_Phyteuma orbiculare_],
    [*g*:], [_Phyteuma pseudorbiculare_],
  )
  #line(length: 100%)
  #{
    set text(size: 12pt)
    [Letter *c* by Felix Puff, *e* & *f* by Honza Smyčka.]
  }
  
  ]
  /*#let pic = image("obj/pic/kytky.png", height: 100%)
  #figure(
    pic,
    caption: [Focal plant species. Letter *a* stands for _Gentiana tergestina_, *b* _Gentiana dinarica_, *c* _Primula kitaibeliana_, *d* & *e* are _Saxifraga blavii_, *f* _Phyteuma orbiculare_, *g* _Phyteuma pseudorbiculare_. ]
  )*/
]
#slide(title: "Species ‒ observation counts and modelling ambitions")[
  #{
    set align(center)
    set text(size: 15pt)
    [Table representing observation data for focal species. Shortcut _TN_ stands for _Toni Nikolić dataset_.]
  }
  #let data = csv("obj/tab/pa_summary_edit.csv")
  #let body = data.slice(1)
  #let head = data.first()
  #align(
    center,
    table(
        align: center,
        columns: head.len(),
        ..head.map(h => [*#h*]),
        ..body.flatten()
    )
  )
  #{
    set text(19pt)
    [- _Gentiana tergestina_ most abundant
  - _Phyteuma orbiculare_ is probably not differentiated from _pseudorbiculare_ in Croatian database.
    - modelling sister species with _Breiner 2015_ method?
  - For _Primula kitaibeliana_ we have only Croatian presences and our absences.
  - _Saxifraga blavii_ have shrinked distribution range, could there be something interesting in temporal extrapolation to LGM?]
  }
]

#focus-slide("Extent")

#slide(title: "Extent question")[
  - the extent of the study should be limited to the #stress("areas covered by the data")
  - interpolation between individual data "clusters"
  - sufficient sampling across environmental gradients (done spatially, but modeled in ecological space)
  #line(length: 100%)
  - How should I shrink my AOI?
    - based on the elevation ‒ as data were collected?
    - LandCover ‒ model only grassland areas?
    - keep current extent and quantify prediction error numericaly (e.g. method Shape)
]

#slide(title: "Extent ‒ elevation")[
  #let pic = image("obj/pic/elevation.png")
  #figure(
    pic, 
    caption: [Density curve of the fieldwork observations (both presences and absences included) and elevation histogram.]
  )
]

#slide(title: "Extent ‒ LandCover")[
  #cols(columns: (50%, 50%))[
  #let pic = image("obj/pic/esa_wc.png")
  #figure(
    pic, 
    caption: [Distribution of observations over LC classes within AOI.]
  )
  ][
  #let pic = image("obj/pic/WorldCover_prokletje.png")
  #figure(
    pic, 
    caption: [ESA WorldCover: Prokletje mountains and surroundig areas.]
  )
  ] 
]

#focus-slide("Grain")

#slide(title: "Grain question", outlined: true)[
  #cols(columns: (35%,70%))[
    - one of the key question when we want to *asses distribution range changes* under different climate scenarios
    - does i make sense to temp extrapolate finner grain models than 1 km?
      - only varying predictor is climate with 1 km resolution, but finer scale topography could answer something
  ][
    #figure(
      image("obj/pic/WC_gif/WC_grain.gif", height: 80%),
      caption: "Various grains"
  )<grain>
  ] 
]

#blank-slide()[
  #align(
    center,
    image("obj/pic/WC/abase.png", height: 120%)
  )
]
#blank-slide()[
  #align(
    center,
    image("obj/pic/WC/a20.png", height: 120%)
  )
]
#blank-slide()[
  #align(
    center,
    image("obj/pic/WC/a100.png", height: 120%)
  )
]
#blank-slide()[
  #align(
    center,
    image("obj/pic/WC/a200.png", height: 120%)
  )
]
#blank-slide()[
  #align(
    center,
    image("obj/pic/WC/a500.png", height: 120%)
  )
]
#blank-slide()[
  #align(
    center,
    image("obj/pic/WC/a1000.png", height: 120%)
  )
]
#blank-slide()[
  #align(
    center,
    image("obj/pic/WC/out.png", width: 100%)
  )
]

#focus-slide("Predictors")

#slide(title: "Predictors")[
  #let data = csv("obj/tab/predictors_grain.csv")
  #let body = data.slice(1)
  #let head = data.first()
  #align(
    center,
    table(
        align: left,
        columns: head.len(),
        ..head.map(h => [*#h*]),
        ..body.flatten()
    )
  )
]

// Focus slide
//#focus-slide[
//  This is an auto-resized _focus slide_.
//]

// Blank slide
#blank-slide[

  - Available #stress[themes]#footnote[Use them as *color* functions! e.g., `#reddy("your text")`]:

  #framed(back-color: white)[
    #bluey("bluey"), #reddy("reddy"), #greeny("greeny"), #yelly("yelly"), #purply("purply"), #dusky("dusky"), darky.
  ]

  // #show: typslides.with(
  //   ratio: "16-9",
  //   theme: "bluey",
  //   ...
  // )
  

  - Or just use *your own theme color*:
    - `theme: rgb("30500B")`
]

// Slide with title
#slide(title: "Outlined slide", outlined: true)[
  - Check out the *progress bar* at the bottom of the slide.

    #h(1cm) `show-progress: true`

  - Outline slides with `outlined: true`.

  #grayed([This is a `#grayed` text. Useful for equations.])
  #grayed($ P_t = alpha - 1 / (sqrt(x) + f(y)) $)

]

// Columns
#slide(title: "Columns")[

  #cols(columns: (2fr, 1fr, 2fr), gutter: 1em)[
    #grayed[Columns can be included using `#cols[...][...]`]
  ][
    #grayed[And this is
    #figure(
      image("obj/pic/elevation_freq.png")
    )<de>]
  ][
    #grayed[an example.
    @de]
  ]

  - Custom spacing: `#cols(columns: (2fr, 1fr, 2fr), gutter: 2em)[...]`

  //- Sample references: @typst, @typslides.
    - Add a #stress[bibliography slide]...

    1. `#let bib = bibliography("you_bibliography_file.bib")`
    2. `#bibliography-slide(bib)`
]

// Bibliography
//#let bib = bibliography("bibliography.bib")
//#bibliography-slide(bib)