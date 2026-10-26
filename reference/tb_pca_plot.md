# Exploratory transformation-based PCA of vegetation communities

Performs an unconstrained principal component analysis (PCA) on a
Hellinger- or chord-transformed vegetation matrix. Produces coordinated
ordination plots of sites and selected species, coloured according to
previously defined vegetation groups.

## Usage

``` r
tb_pca_plot(
  veg,
  groups,
  transformation = c("hellinger", "chord"),
  axes = c(1, 2),
  area = c("hull", "ellipse", "none"),
  species = c("ordiselect", "indval", "phi"),
  indval = NULL,
  phi = NULL,
  alpha = 0.05,
  ablim = 0.4,
  fitlim = 0.5,
  freq = FALSE,
  label_groups = FALSE,
  segment.alpha_labelSpe = 0.3,
  segment.size_labelSpe = 0.3
)
```

## Arguments

- veg:

  Numeric matrix or data frame with sites in rows and species in
  columns. Must have site row names, non-negative values, and no NA.

- groups:

  Data frame containing `stand` (site identifier) and `group` (group
  membership). Every site in `veg` must appear exactly once in `groups`.

- transformation:

  Character string; `"hellinger"` (default) or `"chord"`.

- axes:

  Integer vector of length two specifying distinct PCA axes to plot;
  defaults to `c(1, 2)`.

- area:

  Character string indicating group envelopes for the site plot:
  `"hull"` (default), `"ellipse"`, or `"none"`.

- species:

  Character string specifying species selection: `"ordiselect"`
  (default), `"indval"`, or `"phi"`.

- indval:

  Complete
  [`indicspecies::multipatt()`](https://emf-creaf.github.io/indicspecies/reference/multipatt.html)
  result for IndVal selection; required when `species = "indval"`.

- phi:

  Complete
  [`indicspecies::multipatt()`](https://emf-creaf.github.io/indicspecies/reference/multipatt.html)
  result for Phi-type selection (typically `func = "r.g"`); required
  when `species = "phi"`.

- alpha:

  Numeric significance threshold for selecting species from `indval` or
  `phi`; default `0.05`.

- ablim:

  Proportion of most abundant species considered by
  [`goeveg::ordiselect()`](https://rdrr.io/pkg/goeveg/man/ordiselect.html);
  default `0.4`.

- fitlim:

  Proportion of species retained based on their ordination scores by
  [`goeveg::ordiselect()`](https://rdrr.io/pkg/goeveg/man/ordiselect.html);
  default `0.5`.

- freq:

  Logical; if `TRUE`, `ordiselect` uses species frequencies rather than
  abundances; default `FALSE`.

- label_groups:

  Logical; if `TRUE`, displays group-centroid labels on the site plot
  and adds group IDs to species labels; default `FALSE`.

- segment.alpha_labelSpe:

  Numeric transparency of the label connector segments in the species
  plot; default `0.3`.

- segment.size_labelSpe:

  Numeric line width of the label connector segments in the species
  plot; default `0.3`.

## Value

A list with the following elements:

- pca:

  PCA object returned by
  [`vegan::rda()`](https://vegandevs.github.io/vegan/reference/cca.html).

- plot_sites:

  `ggplot2` plot of the site ordination.

- plot_species:

  `ggplot2` plot of selected species scores.

- sites:

  Data frame with site IDs, plot coordinates, and groups.

- species:

  Data frame with selected species, plot coordinates, and assigned
  groups.

- selected_species:

  Character vector of selected species names.

- variance:

  Numeric vector of variance explained by each PCA axis, expressed as a
  percentage.

## Details

The vegetation matrix must contain sites (releves) in rows and species
in columns, with non-negative numeric values and unique site row names.
The `groups` data frame must have columns `stand` and `group`, and its
site identifiers must match those in `veg`. Group order is matched to
the vegetation matrix automatically. At least two groups and no empty
sites are required; species absent from every site are removed.

For `transformation = "hellinger"`, the data are transformed using
`vegan::decostand(method = "hellinger")`. With `"chord"`, the function
uses `vegan::decostand(method = "normalize", MARGIN = 1)`. Unconstrained
PCA is then performed using
[`vegan::rda()`](https://vegandevs.github.io/vegan/reference/cca.html);
site and species scores are extracted with `scaling = 2`.

Site groups can be displayed as convex hulls (`area = "hull"`),
95-percent normal-data ellipses (`"ellipse"`), or points alone
(`"none"`). Hulls require at least three non-collinear observations per
group, whereas ellipses require at least four non-collinear
observations. Ellipses describe the spread of sites and are not
confidence intervals for group centroids.

Three species-selection methods are available:

- `"ordiselect"`: selects species using
  [`goeveg::ordiselect()`](https://rdrr.io/pkg/goeveg/man/ordiselect.html)
  with `ablim`, `fitlim`, and `freq`. Species are coloured by the group
  with the highest mean cover, a descriptive criterion.

- `"indval"`: uses significant single-group associations from a
  previously computed
  [`indicspecies::multipatt()`](https://emf-creaf.github.io/indicspecies/reference/multipatt.html)
  result.

- `"phi"`: uses significant single-group associations from a previously
  computed `multipatt()` result (typically with `func = "r.g"`).

For `"indval"` and `"phi"`, the supplied `multipatt` object must contain
the same ordered site-group assignments as the PCA input. Species are
selected by `p.value <= alpha` and membership of exactly one group; the
function does not apply a separate minimum Phi cutoff or adjust p-values
for multiple testing.

When `label_groups = TRUE`, group labels are added at site centroids and
appended to species labels. Species are displayed as text labels with
optional label connector segments; the species-arrow drawing code is
commented out in this implementation.

## References

Legendre, P. & Gallagher, E. D. (2001). Ecologically meaningful
transformations for ordination of species data. Oecologia, 129, 271-280.
https://doi.org/10.1007/s004420100716

## See also

[`vegan::decostand()`](https://vegandevs.github.io/vegan/reference/decostand.html),
[`vegan::rda()`](https://vegandevs.github.io/vegan/reference/cca.html),
[`vegan::scores()`](https://vegandevs.github.io/vegan/reference/scores.html),
[`goeveg::ordiselect()`](https://rdrr.io/pkg/goeveg/man/ordiselect.html),
[`indicspecies::multipatt()`](https://emf-creaf.github.io/indicspecies/reference/multipatt.html)

## Examples

``` r
if (FALSE) { # \dontrun{
data("dune", package = "vegan")
data("dune.env", package = "vegan")

# Create a group-membership table, matching the vegetation matrix
site_groups <- data.frame(
  stand = rownames(dune),
  group = as.character(dune.env$Management)
)

# Hellinger PCA with convex hulls and ordiselect
res <- tb_pca_plot(
  veg = dune,
  groups = site_groups,
  transformation = "hellinger",
  area = "hull",
  species = "ordiselect"
)
print(res$plot_sites)
print(res$plot_species)
res$selected_species

# Alternative chord transformation with group labels
res_chord <- tb_pca_plot(
  veg = dune,
  groups = site_groups,
  transformation = "chord",
  area = "none",
  label_groups = TRUE
)

# Previously computed IndVal indicators
set.seed(123)
mp_indval <- indicspecies::multipatt(
  (dune > 0) * 1,
  site_groups$group,
  duleg = TRUE,
  control = permute::how(nperm = 999)
)
res_indval <- tb_pca_plot(
  veg = dune,
  groups = site_groups,
  species = "indval",
  indval = mp_indval
)
} # }
```
