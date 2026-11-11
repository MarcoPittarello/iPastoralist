# Fit TWINSPAN and plot its dendrogram using the iPastoralist layout

Run
[`ecan::twinspan()`](https://matutosi.github.io/ecan/reference/twinspan.html)
from scratch on `dbClust` at every call, using the supplied native
fitting parameters. Label surveys with their most abundant species. With
`aggregate = TRUE`, retain every survey, prefix each label with its
terminal TWINSPAN group, optionally draw rectangles around groups, and
return their dominant species based on mean abundance. This follows the
layout of
[`iPastoralist::plotClustAggregate`](https://marcopittarello.github.io/iPastoralist/reference/plotClustAggregate.md).

## Usage

``` r
plotClustAggregate_twspn(
  nspePlot = 5,
  dbClust,
  clust.mar = c(1, 2, 2, 18),
  file.name = "dendrogram.pdf",
  file.height = 30,
  file.width = 15,
  file.res = 200,
  labels.cex = 0.5,
  aggregate = TRUE,
  aggr.Nspe = 5,
  save.file = TRUE,
  format = "pdf",
  modified = TRUE,
  n_clusters = NULL,
  cut_levels = c(0, 2, 5, 10, 20),
  min_size = 5,
  max_depth = 6,
  polish = "hill",
  species = FALSE,
  max_indicators = 7,
  diff_threshold = 1/3,
  refine_iter = 5,
  use_indicator = FALSE,
  downweight = TRUE,
  display = !save.file,
  show.rectangles = TRUE
)
```

## Arguments

- nspePlot:

  Non-negative integer; number of species per survey label.

- dbClust:

  Required numeric surveys-by-species matrix or data.frame. Rows are
  surveys and columns are species, with unique non-empty names. This
  exact abundance matrix is used for fitting and group summaries.

- clust.mar:

  Four non-negative plot margins passed to
  [`graphics::par()`](https://rdrr.io/r/graphics/par.html).

- file.name:

  Output filename, default `"dendrogram.pdf"`. With `aggregate = TRUE`,
  save only `aggregate_` plus the basename in the same directory, as in
  the original function. The directory must exist.

- file.height, file.width:

  Positive numeric output dimensions in inches.

- file.res:

  Positive numeric resolution in pixels per inch for PNG.

- labels.cex:

  Positive numeric survey-label size multiplier.

- aggregate:

  Logical; prefix survey labels with their groups and return the
  group-species summary? Group rectangles are controlled by
  `show.rectangles`.

- aggr.Nspe:

  Positive integer; number of species in each group summary.

- save.file:

  Logical; export the selected dendrogram to disk?

- format:

  Output format, `"pdf"` (default) or `"png"`.

- modified:

  Logical; use modified TWINSPAN? Default `TRUE`.

- n_clusters:

  Optional non-negative integer; requested number of terminal groups.
  Positive values are passed to
  [`ecan::twinspan()`](https://matutosi.github.io/ecan/reference/twinspan.html).
  `NULL` leaves the stopping decision to the other native parameters.
  With `0`, return a single group; internally use `n_clusters = 1` and
  `max_depth = 0`.

- cut_levels:

  Numeric finite non-negative pseudospecies cut levels.

- min_size:

  Positive integer; minimum group size eligible for division.

- max_depth:

  Non-negative integer; maximum division depth.

- polish:

  Native polishing method, `"hill"` (default) or `"ecan"`.

- species:

  Logical; also classify species? Default `FALSE`.

- max_indicators:

  Non-negative integer; maximum indicator pseudospecies.

- diff_threshold:

  Numeric in `(0, 1]`; native differential-species threshold, used by
  `polish = "ecan"`.

- refine_iter:

  Non-negative integer; native number of refinement steps, used by
  `polish = "ecan"`.

- use_indicator:

  Logical; native indicator-ordination option, used by
  `polish = "ecan"`.

- downweight:

  Logical; downweight rare pseudospecies in the ordination?

- display:

  Logical; also draw the selected dendrogram on the current device?
  Defaults to `!save.file`. Set both to `FALSE` for computation only.

- show.rectangles:

  Logical; draw the blue group rectangles when `aggregate = TRUE`?
  Default `TRUE`. Set to `FALSE` to hide them, regardless of the
  requested or actual number of groups. This changes only rectangle
  visibility, not the fitted tree, group membership, labels or
  summaries.

## Value

With `aggregate = TRUE`, a data.frame with `group` and `name`, as in the
original function. Attributes provide `mean.abundance` (matrix),
`n.surveys` (named counts), `survey.order` (survey membership and
order), `dendrogram` (species-labelled tree), `aggregate.dendrogram`
(the same survey tree with group prefixes), and `files` (saved path).
Attributes `twinspan`, `twinspan.parameters` and `n.clusters` contain
the newly fitted ecan object, effective native argument values and
actual group count. They are also attached to the non-aggregated result.
With `aggregate = FALSE`, invisibly return the species-labelled survey
dendrogram, with attributes `survey.order` and `files`.

## Details

Native TWINSPAN parameters, `display` and `show.rectangles` follow
`format`. Species used in survey labels are computed internally from
`dbClust`. No precomputed fitted object is accepted. A single new fit is
used for the plain or grouped survey tree, membership, rectangles and
mean abundance summaries.

Groups come from the newly fitted object's `classification$group`. The
tree is converted using ecan's own `as.hclust.twinspan` method,
retrieved from its namespace, so the separate package named `twinspan`
cannot intercept the conversion. Branches, order and heights of this new
hierarchy are retained. When `n_clusters` cannot be reached because of
`min_size`, `max_depth` or a lack of further divisions, the actual
fitted groups are used throughout. Heights are reverse division order,
not dissimilarities or eigenvalues; zero-height joins within terminal
groups are graphical placeholders.

In the aggregated dendrogram, each survey remains a separate leaf.
Labels are of the form `0001_Survey | Species abundance | ...`. When
`show.rectangles = TRUE`, rectangles use
[`dendextend::rect.dendrogram()`](https://talgalili.github.io/dendextend/reference/rect.dendrogram.html)
with `k` equal to the actual group count, `horiz = TRUE`, `border = 5`,
`lty = 1` and `lwd = 1`, matching the original function. A single group
is outlined using
[`graphics::rect()`](https://rdrr.io/r/graphics/rect.html) with the same
border settings. With `show.rectangles = FALSE`, no group rectangles are
drawn. There is no collapse of surveys into group leaves.

The returned group names follow the original convention: arithmetic mean
abundances across all group surveys (including zeros), ranked before
rounding, rounded to zero decimal places and formatted as
`Species (12%)`. Species with zero means can appear when fewer than
`aggr.Nspe` species have positive means. Ties follow input species
order. No percentage conversion is performed: use percentage abundances
in `dbClust` for the `%` suffix to describe their units correctly.

## See also

[`first_ten_species_twspn()`](https://marcopittarello.github.io/iPastoralist/reference/first_ten_species_twspn.md),
[`denspe_twspn()`](https://marcopittarello.github.io/iPastoralist/reference/denspe_twspn.md),
[`clustOrder_twspn()`](https://marcopittarello.github.io/iPastoralist/reference/clustOrder_twspn.md)

## Examples

``` r
veg <- rbind(S1 = c(9, 5, 0, 0), S2 = c(8, 4, 1, 0),
             S3 = c(0, 1, 5, 8), S4 = c(0, 0, 4, 7))
colnames(veg) <- c("Species A", "Species B", "Species C", "Species D")
result <- plotClustAggregate_twspn(
  nspePlot = 2, dbClust = veg, modified = TRUE, n_clusters = 2,
  cut_levels = c(0, 2, 5, 10, 20), min_size = 2, max_depth = 6,
  polish = "hill", species = FALSE, save.file = FALSE, display = FALSE,
  show.rectangles = FALSE
)
result
#>   group                                                           name
#> 1     1 Species D (8%), Species C (4%), Species B (0%), Species A (0%)
#> 2     2 Species A (8%), Species B (4%), Species C (0%), Species D (0%)
attr(result, "mean.abundance")
#>   Species A Species B Species C Species D
#> 1       0.0       0.5       4.5       7.5
#> 2       8.5       4.5       0.5       0.0
fitted <- attr(result, "twinspan")
clustOrder_twspn(fitted)
#>   Survey cluster Survey.order path depth
#> 1     S3       1            1    0     1
#> 2     S4       1            2    0     1
#> 3     S1       2            3    1     1
#> 4     S2       2            4    1     1
```
