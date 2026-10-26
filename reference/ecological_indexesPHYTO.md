# Computation of Ecological indicators (Landolt, Ellenberg) from phytosociological surveys

Computation of Ecological indicators, which can be either weighted or
not weighted with SRA. Occasional species can be taken into account.

## Usage

``` r
ecological_indexesPHYTO(database.vegetation, database.indexes)
```

## Arguments

- database.vegetation:

  database with species cover or abundance. Rows are species and columns
  are surveys. The column of species names must be imported. Database
  class must be *data.frame*

- database.indexes:

  database with Ecological indicators, without the column of species
  names. NA values must indicated as 999

## Value

a list with weighted and not weighted ecological indicators for each
survey.

## Examples

``` r
# Structure of the ecological indicator database:
# Rows represent species and columns represent ecological indicators.
# Column headings must be provided.
# The species name column must not be included.

ecological_indicators <- data.frame(
  N_Landolt = c(2, 5, 4),
  T_Landolt = c(5, 1, 999)
)

# Use 999 for species with missing ecological indicator values.

# See also the package vignettes for complete examples.
```
