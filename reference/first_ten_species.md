# First ten species for dendrogram

For each survey, plant species names and their abundance are listed in a
decreasing order of abundance allowing an easier interpretation of the
dendrogram.

## Usage

``` r
first_ten_species(data_SRA_SC, join.dendrogram, cluster.hclust)
```

## Arguments

- data_SRA_SC:

  database with abundance data expressed as SRA or SC, calculated with
  [vegetation_abundance](vegetation_abundance.md). Database class must
  be *data.frame*. Rows are species and Columns are surveys. Species
  names must be included as row names and not in the data.

- join.dendrogram:

  LOGICAL. TRUE if species abundance need to be joined with a
  dendrogram.

- cluster.hclust:

  Only if 'join.dendrogram = TRUE'. The output from 'hclust' function of
  'stats' package has to be specified

## Value

when 'join.dendrogram' = TRUE: a dataframe in which surveys are orderd
in the same way of the dendrogram and for each of them are listed the
species orderd decreasingly by their abundance. when 'join.dendrogram' =
FALSE: a dataframe in which for each survey the species are ordered
decreasingly by their abundance

## Examples
