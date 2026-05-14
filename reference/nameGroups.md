# Name vegetation groups based on dominant species

Assigns a descriptive name to each vegetation group identified by
[`clustGroupAggregate2`](clustGroupAggregate2.md). The name is built by
selecting, within each group, the most-abundant species whose
*cumulated* relative abundance does not exceed a user-defined threshold.
Species names are retrieved by joining the long-format output with a
lookup table that maps abbreviated CEP codes to full scientific names.
Each species is followed by its rounded relative abundance in
parentheses (e.g. *Trifolium repens* (30\\

## Usage

``` r
nameGroups(df.long, cep, threshold = 50)
```

## Arguments

- df.long:

  A dataframe in long format as returned by the `$df.long` element of
  [`clustGroupAggregate2`](clustGroupAggregate2.md). It must contain at
  least three columns:

  `group`

  :   Group identifier (character or factor).

  `species`

  :   Species code in CEP format (character).

  `abundance`

  :   Mean abundance value for the species within the group (numeric).

- cep:

  A dataframe with exactly two columns used as a lookup table:

  Column 1

  :   Full scientific name of the species (character). This column is
      used as the display name in the output.

  Column 2

  :   CEP code of the species (character). This column is matched
      against the `species` column of `df.long`.

  Column names are not required to follow a specific convention; the
  function renames them internally.

- threshold:

  A single numeric value (0–100) representing the maximum cumulated
  relative abundance (in percent) that the selected species may reach.
  Species are added in decreasing order of abundance until including the
  next one would cause the cumulated percentage to equal or exceed this
  value. Defaults to `50`.

## Value

A dataframe with two columns:

- `group`:

  Group identifier, matching those in `df.long`.

- `name`:

  A character string with the group name, composed of the dominant
  species and their relative abundances, separated by commas. Example:
  `"Trifolium repens (30%), Lolium perenne (10%)"`.

## Details

The function works in three steps:

1.  The long-format dataframe produced by `clustGroupAggregate2`
    (columns `group`, `species`, `abundance`) is joined with the CEP
    lookup table so that every CEP code is replaced by the corresponding
    full scientific name.

2.  For each group, species are sorted in decreasing order of mean
    abundance and their relative percentages are computed. Cumulative
    percentages are then calculated.

3.  Starting from the most-abundant species, species are retained as
    long as *adding* the next species would keep the cumulated abundance
    below `threshold`. At least one species is always retained, even
    when a single species already exceeds the threshold.

## Examples

``` r
## Minimal reproducible example -------------------------------------------

## Simulate a long-format aggregate dataframe
df.long <- data.frame(
  group     = c(rep("1", 3), rep("2", 3)),
  species   = c("trif rep", "loli per", "fest rub",
                "brom ere", "poa alp",  "agro cap"),
  abundance = c(30, 10, 5, 40, 20, 8)
)

## CEP lookup table (full name | cep code)
cep <- data.frame(
  full_name = c("Trifolium repens", "Lolium perenne", "Festuca rubra",
                "Bromus erectus", "Poa alpina", "Agrostis capillaris"),
  cep_code  = c("trif rep", "loli per", "fest rub",
                "brom ere", "poa alp",  "agro cap"),
  stringsAsFactors = FALSE
)

## Name the groups using the default 50 % threshold
nameGroups(df.long, cep, threshold = 50)
#> Warning: There was 1 warning in `summarise()`.
#> ℹ In argument: `name = { ... }`.
#> ℹ In group 1: `group = "1"`.
#> Caused by warning:
#> ! `cur_data()` was deprecated in dplyr 1.1.0.
#> ℹ Please use `pick()` instead.
#> ℹ The deprecated feature was likely used in the iPastoralist package.
#>   Please report the issue to the authors.
#>   group                   name
#> 1     1 Trifolium repens (67%)
#> 2     2   Bromus erectus (59%)

## Use a more restrictive threshold to retain only the single top species
nameGroups(df.long, cep, threshold = 30)
#>   group                   name
#> 1     1 Trifolium repens (67%)
#> 2     2   Bromus erectus (59%)
```
