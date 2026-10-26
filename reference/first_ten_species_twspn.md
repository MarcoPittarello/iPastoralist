# Most abundant species per survey with TWINSPAN classification

Rank the original abundance values within each survey and format the
first species as text. Input orientation defaults to the
surveys-by-species matrix accepted by
[`ecan::twinspan()`](https://matutosi.github.io/ecan/reference/twinspan.html).

## Usage

``` r
first_ten_species_twspn(
  data_SRA_SC = NULL,
  join.dendrogram = TRUE,
  twin_ecan = NULL,
  n = 10,
  digits = 1,
  surveys.rows = TRUE,
  include.zero = FALSE
)
```

## Arguments

- data_SRA_SC:

  Numeric matrix or data.frame of abundances. By default, rows are
  surveys and columns are species. If `NULL`, use `twin_ecan$data`.
  Names on both dimensions must be unique and non-empty.

- join.dendrogram:

  Logical; order surveys as in `twin_ecan` and include their positions
  and terminal groups?

- twin_ecan:

  An object returned by
  [`ecan::twinspan()`](https://matutosi.github.io/ecan/reference/twinspan.html).
  Both classical and modified TWINSPAN are supported, including
  `species = FALSE`.

- n:

  Positive integer; maximum number of species returned per survey.

- digits:

  Non-negative integer; decimal places used in displayed values.

- surveys.rows:

  Logical; if `FALSE`, `data_SRA_SC` has species in rows and surveys in
  columns, as in the original iPastoralist function. This argument
  applies only to explicitly supplied data, not `twin_ecan$data`.

- include.zero:

  Logical; include absent species (zero abundance) after the present
  species?

## Value

A data.frame with `Survey`, optionally `cluster` and `Survey.order`, and
text columns `X1`, ..., `Xn` (for example, `"Festuca rubra 12.5"`).

## Details

Species are ordered by unrounded abundance, with ties resolved by input
species order. Rounding is applied only to the displayed text. No
conversion to percentages is performed. If fewer than `n` eligible
species occur in a survey, its remaining entries are `NA_character_`.

Unlike the original function, the result always has one row per survey;
no survey is dropped. With `join.dendrogram = FALSE`, rows follow the
input order. When joining, all fitted survey IDs must be present exactly
once. An explicit abundance table may use different units or species
columns from the fitting matrix; only survey IDs are matched to the
classification.

## See also

[`denspe_twspn()`](https://marcopittarello.github.io/iPastoralist/reference/denspe_twspn.md),
[`clustOrder_twspn()`](https://marcopittarello.github.io/iPastoralist/reference/clustOrder_twspn.md)

## Examples

``` r
veg <- rbind(S1 = c(9, 5, 0, 0), S2 = c(8, 4, 1, 0),
             S3 = c(0, 1, 5, 8), S4 = c(0, 0, 4, 7))
colnames(veg) <- c("Species A", "Species B", "Species C", "Species D")
tw <- ecan::twinspan(veg, modified = TRUE, n_clusters = 2,
                     min_size = 2, polish = "hill", species = FALSE)
first_ten_species_twspn(twin_ecan = tw, n = 3)
#>   Survey cluster Survey.order          X1          X2          X3
#> 1     S3       1            1 Species D 8 Species C 5 Species B 1
#> 2     S4       1            2 Species D 7 Species C 4        <NA>
#> 3     S1       2            3 Species A 9 Species B 5        <NA>
#> 4     S2       2            4 Species A 8 Species B 4 Species C 1
first_ten_species_twspn(veg, join.dendrogram = FALSE, n = 3)
#>   Survey          X1          X2          X3
#> 1     S1 Species A 9 Species B 5        <NA>
#> 2     S2 Species A 8 Species B 4 Species C 1
#> 3     S3 Species D 8 Species C 5 Species B 1
#> 4     S4 Species D 7 Species C 4        <NA>
first_ten_species_twspn(t(veg), twin_ecan = tw, surveys.rows = FALSE)
#>   Survey cluster Survey.order          X1          X2          X3   X4   X5
#> 1     S3       1            1 Species D 8 Species C 5 Species B 1 <NA> <NA>
#> 2     S4       1            2 Species D 7 Species C 4        <NA> <NA> <NA>
#> 3     S1       2            3 Species A 9 Species B 5        <NA> <NA> <NA>
#> 4     S2       2            4 Species A 8 Species B 4 Species C 1 <NA> <NA>
#>     X6   X7   X8   X9  X10
#> 1 <NA> <NA> <NA> <NA> <NA>
#> 2 <NA> <NA> <NA> <NA> <NA>
#> 3 <NA> <NA> <NA> <NA> <NA>
#> 4 <NA> <NA> <NA> <NA> <NA>
```
