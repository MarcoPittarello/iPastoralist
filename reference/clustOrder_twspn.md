# Survey order and terminal groups of an ecan TWINSPAN classification

Extract survey identifiers, their positions in the TWINSPAN dendrogram,
and, optionally, the terminal groups already fitted by
[`ecan::twinspan()`](https://matutosi.github.io/ecan/reference/twinspan.html).

## Usage

``` r
clustOrder_twspn(twin_ecan, cluster.group = TRUE, cluster.number = NULL)
```

## Arguments

- twin_ecan:

  An object returned by
  [`ecan::twinspan()`](https://matutosi.github.io/ecan/reference/twinspan.html).
  Both classical and modified TWINSPAN are supported, including
  `species = FALSE`.

- cluster.group:

  Logical; include the terminal group, path and depth?

- cluster.number:

  Optional positive integer. If supplied, it must equal the number of
  terminal groups actually present in `twin_ecan`.

## Value

A data.frame sorted by `Survey.order`. With `cluster.group = FALSE`,
columns are `Survey` and `Survey.order`. Otherwise columns are `Survey`,
`cluster` (ecan group ID), `Survey.order`, `path` (binary division
path), and `depth` (terminal division depth).

## Details

This is the TWINSPAN counterpart of
[`iPastoralist::clustOrder`](clustOrder.md), the function defined in the
original file `cluster_survey_order.R`.

The groups are taken from `twin_ecan$classification$group`, matched by
survey identifier. They are never obtained by cutting a new clustering.
To request a different classification, refit
[`ecan::twinspan()`](https://matutosi.github.io/ecan/reference/twinspan.html)
with the desired `n_clusters`. That argument is a stopping target: the
fitted number can be smaller when no group can be divided further.

Survey positions follow
[`stats::as.hclust()`](https://rdrr.io/r/stats/as.hclust.html) for the
supplied object. Within a terminal group, TWINSPAN has not resolved the
order of individual surveys; ecan retains their input order and inserts
zero-height graphical merges.

## See also

[`first_ten_species_twspn()`](first_ten_species_twspn.md),
[`plotClustAggregate_twspn()`](plotClustAggregate_twspn.md)

## Examples

``` r
veg <- rbind(S1 = c(9, 5, 0, 0), S2 = c(8, 4, 1, 0),
             S3 = c(0, 1, 5, 8), S4 = c(0, 0, 4, 7))
colnames(veg) <- c("Species A", "Species B", "Species C", "Species D")
tw <- ecan::twinspan(veg, modified = TRUE, n_clusters = 2,
                     min_size = 2, polish = "hill", species = FALSE)
clustOrder_twspn(tw)
#>   Survey cluster Survey.order path depth
#> 1     S3       1            1    0     1
#> 2     S4       1            2    0     1
#> 3     S1       2            3    1     1
#> 4     S2       2            4    1     1
clustOrder_twspn(tw, cluster.group = FALSE)
#>   Survey Survey.order
#> 1     S3            1
#> 2     S4            2
#> 3     S1            3
#> 4     S2            4
```
