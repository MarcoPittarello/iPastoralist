# Select Vegetation Clusters Using Modified TWINSPAN and OptimClass

Generates vegetation partitions using Modified TWINSPAN and selects the
number of clusters according to OptimClass 1 or OptimClass 2, based on
statistically significant species-to-cluster fidelity.

## Usage

``` r
twinspan_optimclass_ecan(
  veg,
  cut_levels = c(0, 2, 5, 10, 20),
  min_size = 5,
  k_values = 2:20,
  p_threshold = 0.05,
  min_faithful = 3,
  version = c("fast", "original"),
  select_by = c("optimclass1", "optimclass2"),
  show_plots = TRUE
)
```

## Arguments

- veg:

  A numeric vegetation matrix or data frame, with relevés (sampling
  plots) in rows and species in columns. Row names and column names must
  be present, non-empty, and unique. Values must be finite,
  non-negative, and free of missing values; zero indicates species
  absence.

- cut_levels:

  Numeric vector of cover cut levels for TWINSPAN pseudospecies. Default
  is `c(0, 2, 5, 10, 20)`.

- min_size:

  Positive integer specifying the minimum cluster size passed to
  [`ecan::twinspan()`](https://matutosi.github.io/ecan/reference/twinspan.html).
  Default is `5` relevés.

- k_values:

  Integer vector of cluster numbers to evaluate. Default is `2:20`.
  Values not yielding valid partitions are excluded.

- p_threshold:

  Fisher's exact test significance threshold used to identify faithful
  species. Must be strictly between 0 and 1. Default is `0.05`.

- min_faithful:

  Positive integer specifying the minimum number of faithful species
  required for a cluster to contribute to OptimClass 2. Default is `3`.

- version:

  Fidelity computation method. `"fast"` uses the upper tail of the
  hypergeometric distribution with
  [`stats::phyper()`](https://rdrr.io/r/stats/Hypergeometric.html);
  `"original"` uses
  [`stats::fisher.test()`](https://rdrr.io/r/stats/fisher.test.html).
  Both implement an equivalent one-sided Fisher exact test
  (`alternative = "greater"`). Default is `"fast"`. Code from
  Monteiro-Henrique. (2025)

- select_by:

  Selection criterion for the final partition: `"optimclass1"` (default)
  or `"optimclass2"`.

- show_plots:

  Logical; whether to print both OptimClass plots. Default is `TRUE`.

## Value

A named list containing:

- `results`: Data frame summarizing each valid `k`: OptimClass 1
  (`optimclass1`), OptimClass 2 (`optimclass2`), proportion of
  qualifying clusters (`prop_good_clusters`), minimum group size
  (`min_group_size`), and optimum indicators (`best_optim1`,
  `best_optim2`).

- `best_k`: List of all optimal k values under `optimclass1` and
  `optimclass2`, including ties.

- `selected_k`: Number of clusters selected for the final partition.

- `selected_by`: Criterion used for final selection.

- `classification`: Data frame with `stand` and `group` columns for the
  selected partition.

- `classification_all`: Data frame with `k`, `stand`, and `group` for
  every valid partition.

- `partitions`: List of named cluster membership vectors for each k.

- `faithful_species`: Table of significant species-cluster associations
  in the selected partition (`k`, `group`, `species`, `p_value`).

- `faithful_species_all`: Table of significant species-cluster
  associations across all valid partitions.

- `faithful_by_group`: Named list of faithful species for each selected
  cluster.

- `fidelity`: Per-partition matrices `p_values` and `faithful` (species
  by cluster), plus `faithful_per_group` counts.

- `plots`: List with `optimclass1` and `optimclass2` ggplot objects.

- `failed_k`: Candidate values of k without a valid partition.

- `settings`: List of parameters used for the analysis.

## Details

The function performs Modified TWINSPAN with
[`ecan::twinspan()`](https://matutosi.github.io/ecan/reference/twinspan.html)
for every candidate number of clusters in `k_values`. Species cover
values are used by TWINSPAN, while species fidelity is evaluated on a
presence/absence matrix derived from `veg`.

For each species and each cluster, fidelity is assessed using a
one-sided Fisher exact test against all other clusters. Species with a
p-value less than or equal to `p_threshold` are counted as faithful.
This function uses p-values rather than the standardized Phi
coefficient. It does not apply multiple-testing correction.

**OptimClass 1** is the number of unique species that are significantly
faithful to at least one cluster. **OptimClass 2** is the number of
clusters containing at least `min_faithful` significantly faithful
species. Each criterion is maximized separately.

All tied optimal values of `k` are retained in `best_k`. For the final
classification, the smallest optimal `k` is chosen under `select_by`.
The number of clusters is optimal only with respect to the candidate
partitions and the chosen fidelity threshold; ecological and
syntaxonomic validation remains necessary.

The function relies on `ecan` for Modified TWINSPAN and `ggplot2` for
plotting. Their namespaces must be available.

## References

Roleček, J., Tichý, L., Zelený, D., & Chytrý, M. (2009). Modified
TWINSPAN classification in which the hierarchy respects cluster
heterogeneity. *Journal of Vegetation Science*, 20, 596–602.
[doi:10.1111/j.1654-1103.2009.01062.x](https://doi.org/10.1111/j.1654-1103.2009.01062.x)

Tichý, L., Chytrý, M., Hájek, M., Talbot, S. S., & Botta-Dukát, Z.
(2010). OptimClass: Using species-to-cluster fidelity to determine the
optimal partition in classification of ecological communities. *Journal
of Vegetation Science*, 21, 287–299.
[doi:10.1111/j.1654-1103.2009.01143.x](https://doi.org/10.1111/j.1654-1103.2009.01143.x)

Monteiro-Henriques, T. (2025). TDV-optimization: A novel numerical
method for phytosociological tabulation. *Vegetation Classification and
Survey*, 6, 99–127.
[doi:10.3897/VCS.140466](https://doi.org/10.3897/VCS.140466)

## See also

[`ecan::twinspan()`](https://matutosi.github.io/ecan/reference/twinspan.html),
[`stats::fisher.test()`](https://rdrr.io/r/stats/fisher.test.html),
[`stats::phyper()`](https://rdrr.io/r/stats/Hypergeometric.html)

## Examples

``` r
if (FALSE) { # \dontrun{
# Vegetation matrix: relevés in rows, species in columns
data("dune", package = "vegan")

res <- twinspan_optimclass_ecan(
  dune,
  k_values = 2:10,
  min_size = 2,
  select_by = "optimclass1",
  show_plots = FALSE
)

res$best_k
res$selected_k
head(res$classification)
head(res$faithful_species)
res$plots$optimclass1
res$plots$optimclass2

# Partition chosen using OptimClass 2
k2 <- min(res$best_k$optimclass2)
subset(res$classification_all, k == k2)
} # }
```
