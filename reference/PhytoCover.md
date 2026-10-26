# Transform visually estimated species cover to cover-abundance values

Convert visually estimated percentage cover using the simplified cover
classes in the table below.

## Usage

``` r
PhytoCover(database, method)
```

## Arguments

- database:

  A data frame with species in rows and surveys in columns. The first
  column contains non-missing, non-empty, unique species names; spaces
  in species names are allowed. Remaining columns contain percentages
  from 0 to 100, numeric strings, or `"+"` for trace cover. Factors are
  accepted through their labels. `NA` and blank strings are interpreted
  as absence (0).

- method:

  One of `"BrBl"`, `"Maarel"`, or `"TassTapp"`.

## Value

A data frame with species names as row names and the original survey
names as column names. The species-name column is omitted. `"BrBl"`
returns character columns; the other methods return numeric columns.

## Details

**Conversion table**

|                              |      |        |          |
|------------------------------|------|--------|----------|
| Visually estimated cover (%) | BrBl | Maarel | TassTapp |
| 0                            | 0    | 0      | 0        |
| 0 \< cover \< 1, or `+`      | \+   | 2      | 0.3      |
| 1 \<= cover \<= 5            | 1    | 3      | 2.8      |
| 5 \< cover \<= 15            | 2a   | 5      | 10       |
| 15 \< cover \<= 25           | 2b   | 5      | 20.5     |
| 25 \< cover \<= 50           | 3    | 7      | 38       |
| 50 \< cover \<= 75           | 4    | 8      | 63       |
| 75 \< cover \<= 100          | 5    | 9      | 88       |

These are the package's simplified, cover-based conversions, rather than
a reconstruction of abundance from percentage cover. The full extended
Braun-Blanquet scale includes abundance categories not inferred here. In
particular, `"Maarel"` preserves the package convention of assigning 5
to both 2a and 2b; the full ordinal transformation distinguishes these
as 5 and 6. The `"TassTapp"` values are fixed representatives of cover
classes, not percentages normalized to sum to 100 within a survey.

Missing values are treated as absence for compatibility. Use this
convention only when missing cells actually represent species absence,
not unknown cover.

## References

Braun-Blanquet, J. (1964). Pflanzensoziologie. Springer, Vienna.

van der Maarel, E. (1979). Transformation of cover-abundance values in
phytosociology and its effects on community similarity. Vegetatio, 39,
97-114.

Tasser, E. and Tappeiner, U. (2005). New model to predict rooting in
diverse plant community compositions. Ecological Modelling, 185,
195-211.

## Examples

``` r
# Rows are species; columns after the first are surveys.
cover <- data.frame(
  Species = c("Festuca rubra", "Poa pratensis", "Trifolium repens"),
  survey1 = c("12.3", "+", NA),
  survey2 = c("5", "0", "27")
)
PhytoCover(cover, "BrBl")
#>                  survey1 survey2
#> Festuca rubra         2a       1
#> Poa pratensis          +       0
#> Trifolium repens       0       3
PhytoCover(cover, "Maarel")
#>                  survey1 survey2
#> Festuca rubra          5       3
#> Poa pratensis          2       0
#> Trifolium repens       0       7
PhytoCover(cover, "TassTapp")
#>                  survey1 survey2
#> Festuca rubra       10.0     2.8
#> Poa pratensis        0.3     0.0
#> Trifolium repens     0.0    38.0
```
