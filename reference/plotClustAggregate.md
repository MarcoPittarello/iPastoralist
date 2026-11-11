# Plot dendrograms and (optionally) aggregated cluster summaries

Create a dendrogram from a surveys-by-species matrix where survey row
names can be labelled with the top species by decreasing abundance.
Optionally aggregate surveys by cluster and return a summary of the top
species for each cluster. When `save.file = TRUE`, the function writes a
PDF (default) or PNG file (one for the non-aggregated dendrogram and,
when aggregation is used, one prefixed with `"aggregate_"`) to the
current working directory.

## Usage

``` r
plotClustAggregate(
  nspePlot = 5,
  firt10 = NULL,
  dbClust = NULL,
  distance = "chord",
  clust.method = "average",
  clust.mar = c(1, 2, 2, 18),
  file.name = "dendrogram.pdf",
  file.height = 30,
  file.width = 15,
  file.res = 200,
  labels.cex = 0.5,
  aggregate = TRUE,
  aggr.Nspe = 5,
  n.clust = NULL,
  save.file = TRUE,
  format = "pdf",
  show.rectangles = TRUE
)
```

## Arguments

- nspePlot:

  Integer; number of species to include in the survey labels (default
  5).

- firt10:

  Optional object created by
  [first_ten_species](https://marcopittarello.github.io/iPastoralist/reference/first_ten_species.md);
  used to generate labels of top species. If `NULL` (default), compute
  it internally from `dbClust`.

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

  Character; filename for the output file (default `"dendrogram.pdf"`).

- file.height:

  Numeric; height of the output file. For PDF (default) this is in
  inches (default 30); for PNG it is used together with `file.res` to
  compute pixel dimensions.

- file.width:

  Numeric; width of the output file. For PDF (default) this is in inches
  (default 15); for PNG it is used together with `file.res` to compute
  pixel dimensions.

- file.res:

  Integer; resolution in ppi, used only when `format = "png"` (default
  200).

- labels.cex:

  Numeric. Character expansion factor for dendrogram labels (default
  0.5).

- aggregate:

  Logical; if TRUE, aggregate surveys by cluster and produce an
  aggregated dendrogram and summary (default TRUE).

- aggr.Nspe:

  Integer; number of species to report per cluster in the returned
  summary (default 5).

- n.clust:

  Integer; number of clusters used for grouping and for drawing
  rectangles on the aggregated dendrogram. With `n.clust = 0`, use a
  single cluster. Rectangle visibility is controlled by
  `show.rectangles`.

- save.file:

  Logical; if TRUE (default), the dendrogram(s) are exported to disk.
  Set to FALSE to skip file output.

- format:

  Character; output format, either `"pdf"` (default) or `"png"`.

- show.rectangles:

  Logical; draw the blue group rectangles on the aggregated dendrogram
  (default TRUE). Set to FALSE to hide them, independently of `n.clust`.
  This changes only rectangle visibility, not the clustering,
  dendrogram, labels or cluster summaries.

## Value

If `aggregate = TRUE`, a tibble/data.frame with one row per cluster and
a `name` column containing the top species (with rounded percentage)
concatenated for that cluster. If `aggregate = FALSE`, the function
invisibly returns NULL (and optionally saves the plain dendrogram).

## Details

The function uses iPastoralist::denspe to create labelled survey rows,
computes a distance matrix with
[vegdist](https://vegandevs.github.io/vegan/reference/vegdist.html), and
generates a hierarchical clustering with
[hclust](https://rdrr.io/r/stats/hclust.html). When `aggregate = TRUE`
the function calls iPastoralist::clustOrder and
iPastoralist::clustGroupAggregate2 to compute cluster-level average
compositions, relabels rows with a cluster prefix, reclusters aggregated
profiles and optionally draws cluster rectangles on the aggregated
dendrogram. With `n.clust = 0`, all surveys belong to a single cluster.
Rectangles are drawn only when `show.rectangles = TRUE`, including when
there is a single cluster. Set it to FALSE to omit them.

Side effects: when `save.file = TRUE`, a PDF or PNG file is written to
the working directory depending on `format`. Use
[getwd](https://rdrr.io/r/base/getwd.html) to inspect or change the
location before running.

## See also

[vegdist](https://vegandevs.github.io/vegan/reference/vegdist.html),
[hclust](https://rdrr.io/r/stats/hclust.html),
[denspe](https://marcopittarello.github.io/iPastoralist/reference/denspe.md),
[clustOrder](https://marcopittarello.github.io/iPastoralist/reference/clustOrder.md),
[clustGroupAggregate2](https://marcopittarello.github.io/iPastoralist/reference/clustGroupAggregate2.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# prepare inputs (replace with real objects)
db_matrix <- my_survey_matrix

# aggregated run: save as PDF (default)
plotClustAggregate(
  nspePlot    = 5,
  dbClust     = db_matrix,
  aggregate   = TRUE,
  n.clust     = 10,
  save.file   = TRUE,
  format      = "pdf"
)

# aggregated run: save as PNG
plotClustAggregate(
  nspePlot    = 5,
  dbClust     = db_matrix,
  file.name   = "dendrogram.png",
  file.height = 30,
  file.width  = 15,
  file.res    = 200,
  aggregate   = TRUE,
  n.clust     = 10,
  save.file   = TRUE,
  format      = "png",
  show.rectangles = FALSE
)

# non-aggregated run: display only, no file saved
plotClustAggregate(
  nspePlot  = 5,
  dbClust   = db_matrix,
  aggregate = FALSE,
  save.file = FALSE
)
} # }
```
