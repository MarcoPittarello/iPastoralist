# Computation of means for cluster groups (aggregate)

Once the groups of a cluster have been identified, the average value for
each species (or target variable) are computed for each group. Moreover,
within each group, species (or target variables) are sorted decreasingly
by their cover (or value).

## Usage

``` r
clustGroupAggregate(database)
```

## Arguments

- database:

  a dataframe in which Rows are surveys and Columns are Species. The
  first column is the identifier of dendrogram groups. The group
  identifier must be numeric. see @example for a graphical detail

## Value

dataframe with the average value of abundance for each species (or
target variable) within each group sorted decreasingly by the abundance

## Details

This function is deprecated. Use
[`clustGroupAggregate2`](https://marcopittarello.github.io/iPastoralist/reference/clustGroupAggregate2.md)
instead.

## Examples

``` r
# Structure of the database to use as input:
# Rows: Vegetation surveys
# Columns: species
# Group  Spe1  Spe2
# 1      12.3   0.0
# 1       0.0   5.0
# See the package vignettes for complete examples.
```
