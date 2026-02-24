# Biodiversity indexes

From a database with Frequency of occurrence (FO) (see
[vegetation_abundance](vegetation_abundance.md) for terminology) and
occasional species as 999 you can compute the following biodiversity
indexes:

- Species richness

- Shannon diversity index (log2)

- Effective number of species (ENS)

- Shannon max

- Equitability

## Usage

``` r
biodiversity(database, occasional.species, species.cover.coefficient)
```

## Arguments

- database:

  database with Frequency of occurrence (FO) and occasional species as
  999 (see [vegetation_abundance](vegetation_abundance.md) for
  terminology). Rows are species and columns are surveys. Database class
  must be *data.frame*

- occasional.species:

  Logical. TRUE if you want to take into account occasional species. If
  occasional species are considered, SRA correspond to "SRA_SC.fs.occ"
  (see [vegetation_abundance](vegetation_abundance.md))

- species.cover.coefficient:

  To set only when "occasional.species=TRUE":coeffient that multiplies
  FO so that the number of total touches refer to 100. SRA values for
  Shannon diversity index derive from the "SRA_SC.fo.occ" (see
  [vegetation_abundance](vegetation_abundance.md))

## Value

biodiversity indexes per each survey

## References

Magurran, A.E., 1988. Ecological diversity and its measurement.
Princeton University Press.

## Examples
