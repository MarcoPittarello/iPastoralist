# Computation of means for cluster groups (aggregate)

Once the groups of a cluster have been identified, the average value for
each species (or target variable) are computed for each group. Moreover,
within each group, species (or target variables) are sorted decreasingly
by their cover (or value).

## Usage

``` r
clustGroupAggregate2(database)
```

## Arguments

- database:

  a dataframe in which Rows are surveys and Columns are Species. The
  first column is the identifier of dendrogram groups see @example for a
  graphical detail

## Value

a list of three elements: 1) aggregate in matrix format (rows: group,
columns: species); 2) aggregate in long format
(group,species,abundance); 3) aggregate in simplified table format
(group species, abundance)

## Examples
