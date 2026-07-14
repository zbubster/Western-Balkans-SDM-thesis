#let extrapol_proj_grid(
  species: "GD",
  grain: "1000",
  caption: lorem(30),
  root: "/outputs/ESM/recent_extrapol_weights_all_selected/"
) = {
  let species = str(species)
  let grain = str(grain)
  let popisek = str(caption)

  let object-with-title(title, content) = {
    grid(
      columns: 1,
      rows: (auto, 1fr),
      row-gutter: 3pt,

      text(
        size: 8pt,
        weight: "semibold",
        title,
      ),

      content,
    )
  }

  let recent = image(
    root + "/"
      + species + "/"
      + grain
      + "/ESM_projection.png"
  )

  let lgm = image(
    root + "/"
      + species + "/"
      + grain
      + "/projections/190_all_selected/"
      + "ESM_projection_190_all_selected.png"
  )

  let hco = image(
    root + "/"
      + species + "/"
      + grain
      + "/projections/060_all_selected/"
      + "ESM_projection_060_all_selected.png"
  )

  let F41_1 = image(
    root + "/"
      + "_future_aggregated/"
      + species + "/"
      + grain
      + "/2041-2070_ssp126/"
      + "mean_predicted_suitability_"
      + species + "_"
      + grain
      + "_2041-2070_ssp126.png"
  )

  let F41_3 = image(
    root + "/"
      + "_future_aggregated/"
      + species + "/"
      + grain
      + "/2041-2070_ssp370/"
      + "mean_predicted_suitability_"
      + species + "_"
      + grain
      + "_2041-2070_ssp370.png"
  )

  let F41_5 = image(
    root + "/"
      + "_future_aggregated/"
      + species + "/"
      + grain
      + "/2041-2070_ssp585/"
      + "mean_predicted_suitability_"
      + species + "_"
      + grain
      + "_2041-2070_ssp585.png"
  )

  let F71_1 = image(
    root + "/"
      + "_future_aggregated/"
      + species + "/"
      + grain
      + "/2071-2100_ssp126/"
      + "mean_predicted_suitability_"
      + species + "_"
      + grain
      + "_2071-2100_ssp126.png"
  )

  let F71_3 = image(
    root + "/"
      + "_future_aggregated/"
      + species + "/"
      + grain
      + "/2071-2100_ssp370/"
      + "mean_predicted_suitability_"
      + species + "_"
      + grain
      + "_2071-2100_ssp370.png"
  )

  let F71_5 = image(
    root + "/"
      + "_future_aggregated/"
      + species + "/"
      + grain
      + "/2071-2100_ssp585/"
      + "mean_predicted_suitability_"
      + species + "_"
      + grain
      + "_2071-2100_ssp585.png"
  )

  figure(
    grid(
      columns: 1,
      row-gutter: 6pt,

      // Horní část
      grid(
        columns: (60%, 40%),
        column-gutter: 0pt,

        align(
          horizon,
          [#recent],
        ),

        grid(
          columns: 1,
          rows: (25%, 25%),
          row-gutter: 0pt,
          align: right,

          object-with-title(
            [21k BP, LGM],
            [#lgm],
          ),

          object-with-title(
            [8k BP, HCO],
            [#hco],
          ),
        ),
      ),

      // Dolní část
      grid(
        columns: (1fr, 1fr, 1fr),
        rows: (20%, 20%),
        column-gutter: 0pt,
        row-gutter: 0pt,

        object-with-title(
          [2041–2070, SSP1-2.6],
          [#F41_1],
        ),

        object-with-title(
          [2041–2070, SSP3-7.0],
          [#F41_3],
        ),

        object-with-title(
          [2041–2070, SSP5-8.5],
          [#F41_5],
        ),

        object-with-title(
          [2071–2100, SSP1-2.6],
          [#F71_1],
        ),

        object-with-title(
          [2071–2100, SSP3-7.0],
          [#F71_3],
        ),

        object-with-title(
          [2071–2100, SSP5-8.5],
          [#F71_5],
        ),
      ),
    ),
    caption: [#popisek],
  )
}