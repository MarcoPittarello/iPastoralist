# Export a Phytosociological Synoptic Table to Excel

Exports a phytosociological synoptic table to a formatted Excel
workbook, displaying diagnostic species in group-specific sections and
the remaining species in a separate section. Species frequencies, Phi
coefficients, association p-values, and dominance information are
included.

## Usage

``` r
export_synoptic(
  synoptic,
  file = "Tabella_sinottica.xlsx",
  min_frequency = 0,
  digits = 0,
  group_sizes = NULL
)
```

## Arguments

- synoptic:

  A data frame (or object coercible to a data frame), typically
  `res$synoptic` from
  [`synoptic_table()`](https://marcopittarello.github.io/iPastoralist/reference/synoptic_table.md).
  It must contain the required diagnostic, dominance, and group
  frequency columns.

- file:

  Character string indicating the output `.xlsx` filename or path.
  Default: `"Tabella_sinottica.xlsx"`.

- min_frequency:

  Numeric value between 0 and 100 specifying the minimum percentage
  frequency for retaining non-diagnostic species. Diagnostic species are
  retained regardless of this value. Default: `0`.

- digits:

  Non-negative integer indicating the number of decimal places displayed
  for species frequencies. Default: `0`.

- group_sizes:

  Optional named vector or table giving the number of vegetation relevés
  in each group, with names such as `G1`, `G2`, etc. When provided, a
  row showing group sample sizes is added to the Excel table. Default:
  `NULL`.

## Value

Invisibly returns a data frame containing the exported species with
`Species`, group frequency columns, `Diagnostic_group`, `Phi`,
`p_value`, `Dominant_in`, `max_freq`, and `section_order`. It also
writes an Excel workbook to the path specified by `file`.

## Details

The input should be the `synoptic` component returned by
[`synoptic_table()`](https://marcopittarello.github.io/iPastoralist/reference/synoptic_table.md).
The function does not calculate diagnostic species, frequency, or
dominance; it formats and exports previously calculated results.

The input must contain the columns `group`, `species`, `diagnostic`,
`phi`, `p.value`, and `dominant`, as well as frequency columns named
`GG1`, `GG2`, etc. (corresponding to group labels `G1`, `G2`, etc.).
Frequencies in these columns are percentages. Group columns are
displayed in numerical order.

Diagnostic species are assigned to the section for their group with the
highest Phi value. If a species is diagnostic for more than one group,
the corresponding frequency cells may be highlighted in each group, even
though the species appears in only one diagnostic section.
Non-diagnostic species are included when their maximum frequency across
groups is at least `min_frequency`. Diagnostic species are always
retained, regardless of this threshold.

The Excel workbook contains two worksheets:

- `Synoptic_table`: a formatted table organized by diagnostic group,
  followed by a section of other frequent species.

- `Original_data`: the complete input table, without the export filter.

The output file is overwritten if it already exists. The function
requires the `openxlsx` package.

## References

Guarino, R., Caldarella, O., Gristina, A. S., Marcenò, C., & Gianguzzi,
L. (2026). Broom-dominated shrublands of Sicily: revisiting the
syntaxonomy of the Cytisetea scopario-striati at the south-eastern
margin of their range. *Vegetation Classification and Survey*, 7,
127-148. https://doi.org/10.3897/VCS.183815

## See also

[`synoptic_table()`](https://marcopittarello.github.io/iPastoralist/reference/synoptic_table.md),
[`openxlsx::createWorkbook()`](https://rdrr.io/pkg/openxlsx/man/createWorkbook.html)

## Examples

``` r
# Example with a small, already calculated synoptic table
example_synoptic <- data.frame(
  group = c("G1", "G2", "G1"),
  species = c("Festuca rubra", "Bromus erectus", "Trifolium repens"),
  diagnostic = c(TRUE, TRUE, FALSE),
  phi = c(0.65, 0.58, NA),
  p.value = c(0.002, 0.010, NA),
  dominant = c(TRUE, FALSE, FALSE),
  GG1 = c(90, 25, 60),
  GG2 = c(15, 85, 55)
)

if (requireNamespace("openxlsx", quietly = TRUE)) {
  output_file <- tempfile(fileext = ".xlsx")
  exported <- export_synoptic(
    synoptic = example_synoptic,
    file = output_file,
    min_frequency = 30,
    group_sizes = c(G1 = 5, G2 = 6)
  )
  unlink(output_file)
}
#> Tabella sinottica esportata: /tmp/RtmproSqFb/file198847f16047.xlsx
```
