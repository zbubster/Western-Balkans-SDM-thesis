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
  -
  -
  -
  -
  - This is a simple `slide` with no title.
  - #stress("Bold and coloured") text by using `#stress(text)`.
  - Sample link: #link("typst.app").
    - Link styling using `link-style`: `"color"`, `"underline"`, `"both"`
  - Font selection using `font: "Fira Sans"`, `size: 21pt`.

  #framed[This text has been written using `#framed(text)`. The background color of the box is customisable.]

  #framed(title: "Frame with title")[This text has been written using `#framed(title:"Frame with title")[text]`.]

#slide(title: "Grain question", outlined: true)[
  #cols(columns: (35%,70%))[
    - ahooj jak to jde ty stará vos ado jo dobrý
  ][
    #figure(
      image("obj/pic/WC_gif/WC_grain.gif", height: 80%),
      caption: "Various grains"
  )<grain>
  ]
  
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

// Focus slide
//#focus-slide[
//  This is an auto-resized _focus slide_.
//]

// Blank slide
#blank-slide[
  - This is a `#blank-slide`.

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