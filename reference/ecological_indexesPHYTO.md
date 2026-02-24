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
