# Matrix for cluster analysis with surveys labelled with the first species ordered by decreasing abundance

After creating the dendrogram it may be appropriate to append the
species sorted by decreasing abundance to each survey in order to
facilitate the interpretation of the analysis. The function makes it
possible to generate a database with the row names coded as survey code
concatenated with a certain number of species ordered by decreasing
abundance. Therefore, this database can be used in place of the original
database (matrix survey by species) for the calculation of the
dissimilarity matrix and for the creation of the dendrogram (e.g. with
hclust).

## Usage

``` r
denspe(nspe = 5, SpeAbund, dbClust)
```

## Arguments

- nspe:

  number of species to show in the labels.

- SpeAbund:

  object generated from [first_ten_species](first_ten_species.md).

- dbClust:

  matrix used for the computation of surveys' distance matrix (e.g. with
  either Dist or
  [vegdist](https://vegandevs.github.io/vegan/reference/vegdist.html)).
  This matrix has surveys as rows and species as columns.

## Value

numeric matrix to use for the computation of surveys' distance matrix.
The dendrogram plot derived from such a numeric matrix will show the
survey ID concatenated with a certain number of species ordered by
decreasing abundance.

## Examples
