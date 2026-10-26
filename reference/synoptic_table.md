# Build a Synoptic Table of Diagnostic, Constant and Dominant Species

Constructs a synoptic table for groups of vegetation releves, combining
species fidelity from a previously calculated
[`indicspecies::multipatt()`](https://emf-creaf.github.io/indicspecies/reference/multipatt.html)
result with species constancy and dominance derived from an original
species-cover matrix.

## Usage

``` r
synoptic_table(
  veg,
  groups,
  phi,
  alpha = 0.05,
  phi_min = 0.25,
  constancy_min = 40,
  dominant_freq_min = 50,
  dominant_cover_min = 25,
  include = c("diagnostic", "constant", "dominant"),
  dominance_rule = c("high_cover_frequency", "presence_frequency_and_max_cover")
)
```

## Arguments

- veg:

  Numeric matrix or data frame of vegetation records, with releves in
  rows and species in columns. Values are original cover estimates; zero
  indicates absence. Species names must be supplied as column names.

- groups:

  Vector of group membership, one element per releve in `veg`. May be
  numeric, character, or a factor. Named vectors are aligned to the row
  names of `veg` when possible.

- phi:

  Complete object returned by
  [`indicspecies::multipatt()`](https://emf-creaf.github.io/indicspecies/reference/multipatt.html),
  calculated externally with `func = "r.g"`, `duleg = TRUE`, and
  presence/absence vegetation data. Must contain `phi$sign`.

- alpha:

  Maximum p-value for diagnostic species (default `0.05`).

- phi_min:

  Minimum fidelity statistic for diagnostic species (default `0.25`).

- constancy_min:

  Minimum species frequency within a group, in percent, for
  classification as constant (default `40`).

- dominant_freq_min:

  Minimum percentage of releves meeting the selected dominance rule
  (default `50`).

- dominant_cover_min:

  Cover threshold for high cover, expressed in the same units as `veg`
  (default `25`).

- include:

  Character vector selecting the retained species categories: any of
  `"diagnostic"`, `"constant"`, and `"dominant"`. By default, all three
  categories are included.

- dominance_rule:

  Character string specifying how dominant species are defined.
  `"high_cover_frequency"` (default) requires high cover in a minimum
  proportion of releves; `"presence_frequency_and_max_cover"` requires
  sufficient occurrence frequency and high cover at least once.

## Value

A list with the following components:

- synoptic:

  Main synoptic data frame, with one row per retained species-group
  combination. Columns are `group`, `species`, `diagnostic`, `phi`,
  `p.value`, `frequency`, `constant`, `high_cover_frequency`,
  `max_cover`, `dominant`, and a percentage-frequency column for each
  group (such as `G1`, `G2`).

- diagnostic:

  Data frame containing the diagnostic associations retained by the
  fidelity and significance thresholds.

- frequency:

  Species-by-group numeric matrix of percentage occurrence frequencies.

- constant:

  Species-by-group logical matrix of constancy.

- dominant:

  Species-by-group logical matrix of dominance.

- high_cover_frequency:

  Species-by-group numeric matrix of the percentage of releves at or
  above `dominant_cover_min`.

- max_cover:

  Species-by-group numeric matrix of maximum cover.

- phi:

  Unmodified `multipatt()` object supplied to the function.

- presence_absence:

  Presence/absence data frame derived from `veg`.

- settings:

  List of thresholds and options used to generate the synoptic table.
  Does not include the external permutation settings.

## Details

The input `veg` must have releves in rows and species in columns. The
`groups` vector assigns each releve to a vegetation group. If `groups`
is a named vector, its elements are reordered to match `rownames(veg)`.

**Diagnostic species:** Species are flagged as diagnostic if the
supplied `multipatt()` output meets both `stat >= phi_min` and
`p.value <= alpha`. The `phi` argument must contain the complete result
from
[`indicspecies::multipatt()`](https://emf-creaf.github.io/indicspecies/reference/multipatt.html)
previously computed on the presence/absence transformation of `veg`,
using `func = "r.g"` and `duleg = TRUE`. The species order in `phi$sign`
must match `colnames(veg)`, and the group-index order must match the
order used by this function. The function does not calculate Phi,
permute data, or call `multipatt()` itself.

**Constant species:** The percentage frequency of each species in each
group is calculated from `veg > 0`. Species with frequency at least
`constancy_min` are classified as constant.

**Dominant species:** Dominance is assessed using the original species
cover values. With `dominance_rule = "high_cover_frequency"`, a species
is dominant if it reaches `dominant_cover_min` cover in at least
`dominant_freq_min` percent of the group's releves. With
`dominance_rule = "presence_frequency_and_max_cover"`, the species must
occur in at least `dominant_freq_min` percent of the group's releves and
reach `dominant_cover_min` in at least one releve.

The `include` argument selects which categories of species are retained.
Selection is inclusive (logical OR): satisfying any requested category
is sufficient. A species may be diagnostic, constant, and dominant at
the same time. All output rows are sorted by group and then by
diagnostic status, dominance, constancy, frequency, Phi, and species
name.

The function does not accept permutation settings such as `nperm` or
`seed`: set these when computing `phi` externally. A different choice of
reporting thresholds can reuse the same `phi` object, as long as the
underlying species data and groups remain unchanged.

## References

Guarino, R., Caldarella, O., Gristina, A. S., Marcenò, C., & Gianguzzi,
L. (2026). Broom-dominated shrublands of Sicily: revisiting the
syntaxonomy of the Cytisetea scopario-striati at the south-eastern
margin of their range. *Vegetation Classification and Survey*, 7,
127-148. [doi:10.3897/VCS.183815](https://doi.org/10.3897/VCS.183815) .

## See also

[`multipatt`](https://emf-creaf.github.io/indicspecies/reference/multipatt.html)

## Examples

``` r
if (FALSE) { # \dontrun{
# Small illustrative dataset: releves in rows, species in columns
veg <- data.frame(
  Festuca = c(60, 45, 51, 50, 0, 2, 0, 3),
  Bromus = c(0, 0, 1, 2, 35, 43, 38, 29),
  Poa = c(2, 3, 0, 4, 5, 3, 0, 2)
)
rownames(veg) <- paste0("R", seq_len(nrow(veg)))
groups <- rep(1:2, each = 4)

# Calculate fidelity externally, using presence/absence data
set.seed(123)
phi <- indicspecies::multipatt(
  (veg > 0) * 1,
  groups,
  func = "r.g",
  duleg = TRUE,
  control = permute::how(nperm = 99)
)

# Build the synoptic table using original cover values
res <- synoptic_table(veg, groups, phi)
res$synoptic
res$diagnostic
res$frequency

# Apply a more restrictive filter without recalculating phi
res2 <- synoptic_table(
  veg, groups, phi,
  phi_min = 0.4,
  constancy_min = 60,
  include = c("diagnostic", "constant")
)
res2$synoptic
} # }
```
