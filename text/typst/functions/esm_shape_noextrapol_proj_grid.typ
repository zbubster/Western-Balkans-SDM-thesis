#let esm_shape_noextrapol(
  species,
  grain,
  root: "/outputs",
  gap: 0pt,
  width: 100%,
  colin: none
) = {
  let grain = str(grain)

  let paths = (
      esm: root + "/ESM/recent_noextrapol_weights_" + colin + "/"
        + species + "/" + grain
        + "/ESM_projection.png",

      shape: root + "/Shape/recent_noextrapol_weights_" + colin + "/"
        + species + "/" + grain
        + "/Shape_projection.png",
    )

  grid(
    columns: (1fr, 1fr),
    column-gutter: gap,
    align: center,

    image(paths.esm, width: width),
    image(paths.shape, width: width),
  )
}