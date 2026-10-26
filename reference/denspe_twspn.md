# Label TWINSPAN Vegetation Surveys with Their Most Abundant Species

Generates descriptive labels for vegetation surveys classified using the
TWINSPAN (Two-Way Indicator Species Analysis) approach. Each survey
identifier is supplemented with the names of its most abundant species,
facilitating the floristic interpretation of TWINSPAN classifications
and dendrograms.

## Usage

``` r
denspe_twspn(
  nspe = 5,
  SpeAbund = NULL,
  dbClust = NULL,
  twin_ecan = NULL,
  sep = " | "
)
```

## Arguments

- nspe:

  Non-negative integer specifying the number of most abundant species to
  include in each survey label. Default is 5. If fewer ranked species
  are available, all available ranks are used. A value of 0 retains only
  the original survey identifiers.

- SpeAbund:

  Optional data.frame produced by
  [`first_ten_species_twspn()`](https://marcopittarello.github.io/iPastoralist/reference/first_ten_species_twspn.md),
  containing survey identifiers in the `Survey` column and ranked
  species in columns `X1`, `X2`, etc. If NULL, species rankings are
  calculated automatically.

- dbClust:

  Numeric vegetation matrix or data.frame with surveys in rows and
  species in columns. If NULL, the vegetation data stored in
  `twin_ecan$data` are used.

- twin_ecan:

  Optional fitted TWINSPAN object, typically produced by
  [`ecan::twinspan()`](https://matutosi.github.io/ecan/reference/twinspan.html).
  Used to retrieve the original vegetation data when `dbClust` is NULL
  and to validate survey identifiers.

- sep:

  Character string separating the original survey identifier from the
  species names. Default is `" | "`.

## Value

A numeric vegetation matrix retaining the original values and row order,
but with modified row names containing the survey identifier and ranked
species names.

The matrix also includes the attribute `survey_labels`, a data.frame
containing:

- Survey:

  Original survey identifier.

- label:

  Generated survey label including species names.

## Details

This function is designed as a supporting tool for vegetation
classification based on TWINSPAN, particularly modified TWINSPAN
implemented in the `ecan` package.

Species are ranked according to their abundance within each survey,
using the results of
[`first_ten_species_twspn()`](https://marcopittarello.github.io/iPastoralist/reference/first_ten_species_twspn.md).
The user can specify how many species should be included in the label.

For example, a survey originally identified as "R1" may receive the
label "R1 \| Festuca rubra \| Agrostis capillaris" when `nspe = 2`.

The function does not perform or repeat TWINSPAN classification.
Instead, it modifies the row names of the vegetation matrix for
descriptive and graphical purposes.

Species-abundance information can be supplied directly through
`SpeAbund` or calculated automatically from `dbClust`.

Survey identifiers are matched by name rather than row position,
ensuring correct correspondence between the vegetation matrix and the
abundance summary.

When a fitted TWINSPAN object is provided, the vegetation matrix must
contain exactly the same surveys, although their order, species columns
and abundance units may differ.

The resulting labels can be used with TWINSPAN plotting functions, such
as
[`plotClustAggregate_twspn()`](https://marcopittarello.github.io/iPastoralist/reference/plotClustAggregate_twspn.md),
to improve the ecological interpretation of vegetation groups.

## See also

[`first_ten_species_twspn`](https://marcopittarello.github.io/iPastoralist/reference/first_ten_species_twspn.md),
[`plotClustAggregate_twspn`](https://marcopittarello.github.io/iPastoralist/reference/plotClustAggregate_twspn.md),
[`twinspan`](https://matutosi.github.io/ecan/reference/twinspan.html)

## Examples

``` r
# Example vegetation matrix
veg <- rbind(
  S1 = c(9, 5, 0, 0),
  S2 = c(8, 4, 1, 0),
  S3 = c(0, 1, 5, 8),
  S4 = c(0, 0, 4, 7)
)

colnames(veg) <- c(
  "Species A", "Species B",
  "Species C", "Species D"
)

# Modified TWINSPAN classification
tw <- ecan::twinspan(
  veg,
  modified = TRUE,
  n_clusters = 2,
  min_size = 2,
  polish = "hill",
  species = FALSE
)

# Identify the most abundant species
top <- first_ten_species_twspn(twin_ecan = tw)

# Label each survey with its two most abundant species
labelled <- denspe_twspn(
  nspe = 2,
  SpeAbund = top,
  twin_ecan = tw
)

# Inspect the resulting labels
rownames(labelled)
#> [1] "S1 | Species A 9 | Species B 5" "S2 | Species A 8 | Species B 4"
#> [3] "S3 | Species D 8 | Species C 5" "S4 | Species D 7 | Species C 4"

# Retrieve the original and modified survey identifiers
attr(labelled, "survey_labels")
#>   Survey                          label
#> 1     S1 S1 | Species A 9 | Species B 5
#> 2     S2 S2 | Species A 8 | Species B 4
#> 3     S3 S3 | Species D 8 | Species C 5
#> 4     S4 S4 | Species D 7 | Species C 4
```
