# Computation of Ecological indicators (Landolt, Ellenberg) from vertical point-quadrat method surveys

Computation of Ecological indicators, which can be either weighted or
not weighted with SRA. Occasional species can be taken into account. If
occasional species are considered, SRA correspond to "SRA_SC.fo.occ"
(see [vegetation_abundance](vegetation_abundance.md))

## Usage

``` r
ecological_indexes(
  database.vegetation,
  database.indexes,
  occasional.species,
  species.cover.coefficient,
  weight
)
```

## Arguments

- database.vegetation:

  database with Frequency of occurrence (FO) and occasional species as
  999 (see [vegetation_abundance](vegetation_abundance.md)). Rows are
  species and columns are surveys. The column of species names must be
  imported. Database class must be *data.frame*

- database.indexes:

  database with Ecological indicators, without the column of species
  names. NA values must indicated as 999

- occasional.species:

  Logical. TRUE if you want to take into account occasional species. If
  occasional species are considered, SRA correspond to "SRA_SC.fo.occ"
  (see [vegetation_abundance](vegetation_abundance.md))

- species.cover.coefficient:

  only if "occasional.species=TRUE". Coeffient that multiplies FS so
  that the number of total touches refer to 100

- weight:

  Logical. TRUE if you want to weight Ecological indicators with SRA.

## Value

database with Ecological indicators for each survey.

## Examples
