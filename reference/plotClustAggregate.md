# Plot dendrograms and (optionally) aggregated cluster summaries

Create a dendrogram from a surveys-by-species matrix where survey row
names can be labelled with the top species by decreasing abundance.
Optionally aggregate surveys by cluster and return a summary of the top
species for each cluster. The function writes PNG files (one for the
non-aggregated dendrogram and, when aggregation is used, one prefixed
with "aggregate\_") to the current working directory.

## Usage

``` r
plotClustAggregate(
  nspePlot = 5,
  firt10 = NULL,
  dbClust = NULL,
  distance = "chord",
  clust.method = "average",
  clust.mar = c(1, 2, 2, 18),
  file.name = "dendrogram.png",
  file.height = 2500,
  file.width = 1200,
  file.res = 200,
  aggregate = TRUE,
  aggr.Nspe = 5,
  n.clust = NULL
)
```

## Arguments

- nspePlot:

  Integer; number of species to include in the survey labels (default
  5).

- firt10:

  Object created by [first_ten_species](first_ten_species.md); used to
  generate labels of top species.

- dbClust:

  Numeric matrix (surveys x species) used to compute dissimilarities.

- distance:

  Character; distance method passed to
  [vegdist](https://vegandevs.github.io/vegan/reference/vegdist.html)
  (default "chord").

- clust.method:

  Character; agglomeration method passed to
  [hclust](https://rdrr.io/r/stats/hclust.html) (default "average").

- clust.mar:

  Numeric vector of length 4; plot margins passed to
  [par](https://rdrr.io/r/graphics/par.html) (default c(1, 2, 2, 18)).

- file.name:

  Character; filename for the saved dendrogram PNG (default
  "dendrogram.png").

- file.height:

  Integer; height (pixels) for the PNG device (default 2500).

- file.width:

  Integer; width (pixels) for the PNG device (default 1200).

- file.res:

  Integer; resolution (ppi) for the PNG device (default 200).

- aggregate:

  Logical; if TRUE, aggregate surveys by cluster and produce an
  aggregated dendrogram and summary (default TRUE).

- aggr.Nspe:

  Integer; number of species to report per cluster in the returned
  summary (default 5).

- n.clust:

  Integer; number of clusters used for grouping and for drawing
  rectangles on the aggregated dendrogram (default 20).

## Value

If `aggregate = TRUE`, a tibble/data.frame with one row per cluster and
a `name` column containing the top species (with rounded percentage)
concatenated for that cluster. If `aggregate = FALSE`, the function
invisibly returns NULL (plots and saves the plain dendrogram).

## Details

The function uses iPastoralist::denspe to create labelled survey rows,
computes a distance matrix with
[vegdist](https://vegandevs.github.io/vegan/reference/vegdist.html), and
generates a hierarchical clustering with
[hclust](https://rdrr.io/r/stats/hclust.html). When `aggregate = TRUE`
the function calls iPastoralist::clustOrder and
iPastoralist::clustGroupAggregate2 to compute cluster-level average
compositions, relabels rows with a cluster prefix, reclusters aggregated
profiles and draws cluster rectangles on the aggregated dendrogram.

Side effects: PNG files are written to the working directory. Use
[getwd](https://rdrr.io/r/base/getwd.html) to inspect or change the
location before running.

## See also

[vegdist](https://vegandevs.github.io/vegan/reference/vegdist.html),
[hclust](https://rdrr.io/r/stats/hclust.html), [denspe](denspe.md),
[clustOrder](clustOrder.md),
[clustGroupAggregate2](clustGroupAggregate2.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# prepare inputs (replace with real objects)
firt10_obj <- iPastoralist::first_ten_species(my_survey_matrix)
db_matrix <- my_survey_matrix

# aggregated run: returns cluster top-species summary and writes PNGs
plotClustAggregate(
  nspePlot = 5,
  firt10 = firt10_obj,
  dbClust = db_matrix,
  aggregate = TRUE,
  n.clust = 10
)

# non-aggregated run: just produces and saves a dendrogram
plotClustAggregate(
  nspePlot = 5,
  firt10 = firt10_obj,
  dbClust = db_matrix,
  aggregate = FALSE
)
} # }
```
