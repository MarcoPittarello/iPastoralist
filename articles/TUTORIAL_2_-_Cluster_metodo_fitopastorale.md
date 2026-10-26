# Vegetation classification: a pastoral approach

Suppose we want to identify vegetation groups that can be interpreted
from the dominant species and their relative abundances. A useful first
step is to display a dendrogram together with the most abundant species
in each survey. This makes it easier to see which surveys share a
similar composition and to decide where to cut the dendrogram.

In this example, we calculate Species Relative Abundance (SRA), run an
agglomerative cluster analysis, and match the first ten species of each
survey to the dendrogram. After choosing a cut, we calculate mean group
composition and explore the groups using transformation-based PCA
(tb-PCA), with species labels selected by `ordiselect`.

## 1. Packages and example data

The example uses
[`iPastoralist::data`](https://rdrr.io/r/utils/data.html). Survey values
are frequencies of occurrence (FO), `999` identifies occasional species,
and empty cells indicate absences. We use species codes to keep
dendrogram labels compact.

``` r

library(iPastoralist)
library(vegan)
library(dendextend)
library(tidyverse)

# If tb_pca_plot() is stored in a separate script, load it here with source().
if (!exists("tb_pca_plot", mode = "function")) {
  stop("Load tb_pca_plot() before rendering this vignette.")
}
stopifnot(
  requireNamespace("cluster", quietly = TRUE),
  requireNamespace("goeveg", quietly = TRUE)
)
```

Select species codes and survey columns, excluding ecological indicator
values and other ancillary information. The first column contains the
species codes, as required by
[`vegetation_abundance()`](../reference/vegetation_abundance.md).

``` r

data_example <- as.data.frame(iPastoralist::data)
survey_columns <- grep("^R[0-9]+$", names(data_example), value = TRUE)

vegetation <- data_example[,
  c("species.name.code", survey_columns),
  drop = FALSE
]

knitr::kable(head(vegetation[, seq_len(min(7L, ncol(vegetation)))]))
```

| species.name.code |  R1 |  R2 |  R3 |  R4 |  R5 |  R6 |
|:------------------|----:|----:|----:|----:|----:|----:|
| Achmacr           |  NA |  NA |  NA |  NA |  NA |  NA |
| Achmill           |  NA |  NA |  NA |  NA |  NA |  NA |
| Achmosc           |  NA |  NA |  NA |  NA |  NA |  NA |
| Acialpi           |  NA |  NA |  NA |  NA |  NA |  NA |
| Acolama           | 999 |  NA |  NA |  NA |  NA |  NA |
| Adealli           |  NA | 999 |  NA |  NA |  NA |  NA |

## 2. Species Relative Abundance

First, calculate SRA from FO. With `method = "SRA_fo"`, occasional
species are excluded and species abundances sum to 100 within each
survey.

``` r

sra <- vegetation_abundance(
  database = vegetation,
  method = "SRA_fo"
)

# For subsequent analyses: rows = surveys; columns = species.
veg <- t(as.matrix(sra))

# Remove only species that are completely absent after calculating SRA.
veg <- veg[, colSums(veg) > 0, drop = FALSE]
sra <- as.data.frame(t(veg), check.names = FALSE)

rowSums(veg)
#>  R1  R2  R3  R4  R5  R6  R7  R8  R9 R10 R11 R12 R13 R14 R15 R16 R17 R18 R19 R20 
#> 100 100 100 100 100 100 100 100 100 100 100 100 100 100 100 100 100 100 100 100 
#> R21 R22 R23 R24 
#> 100 100 100 100
dim(veg)
#> [1] 24 91
```

|         |  R1 |  R2 |  R3 |  R4 |  R5 |   R6 |
|:--------|----:|----:|----:|----:|----:|-----:|
| Achmacr | 0.0 |   0 | 0.0 | 0.0 |   0 |  0.0 |
| Achmill | 0.0 |   0 | 0.0 | 0.0 |   0 |  0.0 |
| Acialpi | 0.0 |   0 | 0.0 | 0.0 |   0 |  0.0 |
| Acolama | 0.0 |   0 | 0.0 | 0.0 |   0 |  0.0 |
| Adealli | 0.0 |   0 | 0.0 | 0.0 |   0 |  0.0 |
| Agrcapi | 6.7 |   0 | 1.7 | 1.5 |   0 | 14.1 |

If occasional species should be included, replace the abundance call
above with `method = "SRA_SC.fo.occ"` and
`species.cover.coefficient = 4`, then rerun the subsequent steps. The
coefficient of 4 corresponds to the 25 measurement points in this
dataset.

## 3. Cluster analysis

Now we can calculate chord distances and apply UPGMA (`average`). Chord
distances are obtained as Euclidean distances between survey rows
normalised to unit length.

``` r

veg_chord <- vegan::decostand(veg, method = "normalize", MARGIN = 1)
d <- stats::dist(veg_chord, method = "euclidean")
clst <- stats::hclust(d, method = "average")

par(mfrow = c(1, 1), mar = c(4, 4, 3, 1))
plot(clst, cex = 0.6, hang = -1, main = "Chord distance - UPGMA")
```

![](TUTORIAL_2_-_Cluster_metodo_fitopastorale_files/figure-html/clustering-1.png)

## 4. Matching the first ten species to the dendrogram

To interpret the branches, extract the species of each survey ordered by
decreasing SRA, using
[`first_ten_species()`](../reference/first_ten_species.md). Setting
`join.dendrogram = TRUE` associates each survey with its position in the
dendrogram.

``` r

first10 <- first_ten_species(
  data_SRA_SC = sra,
  join.dendrogram = TRUE,
  cluster.hclust = clst
)

# Retain the ten highest ranks and order surveys as in the dendrogram.
first10 <- first10[order(first10$Survey.order), , drop = FALSE]
rank_columns <- setdiff(names(first10), c("Survey", "Survey.order"))
rank_columns <- head(rank_columns, 10L)
first10_table <- first10[,
  c("Survey", "Survey.order", rank_columns),
  drop = FALSE
]
rownames(first10_table) <- NULL

knitr::kable(first10_table)
```

| Survey | Survey.order | V1 | V2 | V3 | V4 | V5 | V6 | V7 | V8 | V9 | V10 |
|:---|---:|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| R23 | 1 | Rhoferr 63.9 | Junnana 30.6 | Oxaacet 2.8 | Vacmyrt 2.8 | Achmacr 0 | Achmill 0 | Acialpi 0 | Acolama 0 | Adealli 0 | Agrcapi 0 |
| R24 | 2 | Rhoferr 63.6 | Fesscab 18.2 | Aveflex 9.1 | Agrcapi 3 | Arnmont 3 | Vacmyrt 3 | Achmacr 0 | Achmill 0 | Acialpi 0 | Acolama 0 |
| R13 | 3 | Calvill 39.6 | Alnviri 18.9 | Rubidae 18.9 | Rhoferr 17 | Gymdryo 3.8 | Galtetr 1.9 | Achmacr 0 | Achmill 0 | Acialpi 0 | Acolama 0 |
| R16 | 4 | Vacmyrt 28.8 | Calvill 27.3 | Rhoferr 22.7 | Aveflex 7.6 | Gymdryo 3 | Rubidae 3 | Vacviti 3 | Antalpi 1.5 | Arnmont 1.5 | Junnana 1.5 |
| R14 | 5 | Adealli 21.6 | Rubidae 16.2 | Urtdioi 16.2 | Rumalpe 13.5 | Alnviri 8.1 | Galtetr 8.1 | Viobifl 5.4 | Achmacr 2.7 | Acolama 2.7 | Fesnigr 2.7 |
| R17 | 6 | Alnviri 48.9 | Agrcapi 14.9 | Viobifl 10.6 | Adealli 6.4 | Alcvulg 4.3 | Peuostr 4.3 | Verlobe 4.3 | Luzalpi 2.1 | Rubidae 2.1 | Vacmyrt 2.1 |
| R19 | 7 | Alnviri 45.2 | Calvill 11.9 | Rhoferr 9.5 | Agrcapi 7.1 | Vacmyrt 7.1 | Antalpi 2.4 | Genpurp 2.4 | Gersylv 2.4 | Geumont 2.4 | Luzalpi 2.4 |
| R2 | 8 | Descesp 51.1 | Carclav 22.2 | Poaalpi 8.9 | Fesnigr 4.4 | Carechi 2.2 | Luzcamp 2.2 | Narstri 2.2 | Peuostr 2.2 | Phlrhae 2.2 | Viobifl 2.2 |
| R4 | 9 | Descesp 34.3 | Phlrhae 16.4 | Fesnigr 11.9 | Alcvulg 9 | Verlobe 7.5 | Peuostr 6 | Rumalpe 4.5 | Caramar 3 | Carcarv 3 | Poaalpi 3 |
| R3 | 10 | Rumalpe 27.1 | Triflav 22 | Peuostr 20.3 | Phlrhae 13.6 | Alcvulg 6.8 | Poaalpi 3.4 | Agrcapi 1.7 | Ranmont 1.7 | Silvulg 1.7 | Triprat 1.7 |
| R8 | 11 | Rumalpi 36.7 | Triflav 11.7 | Chahirs 10 | Alcvulg 8.3 | Phlrhae 8.3 | Poaalpi 6.7 | Rumalpe 6.7 | Myoalpe 5 | Agrcapi 1.7 | Fesnigr 1.7 |
| R18 | 12 | Fesscab 28.3 | Narstri 18.9 | Fesnigr 15.1 | Leohelv 7.5 | Antalpi 5.7 | Phlrhae 5.7 | Agrcapi 3.8 | Poaalpi 3.8 | Potgran 3.8 | Vacmyrt 3.8 |
| R6 | 13 | Agrcapi 14.1 | Fesnigr 10.6 | Rumalpe 10.6 | Rhoferr 8.2 | Silvulg 8.2 | Chahirs 7.1 | Triflav 5.9 | Alcvulg 4.7 | Phlrhae 4.7 | Rubidae 4.7 |
| R15 | 14 | Vacmyrt 20.9 | Rhoferr 13.4 | Fesnigr 10.4 | Agrcapi 9 | Chahirs 7.5 | Antalpi 6 | Phlrhae 6 | Poachai 4.5 | Rubidae 4.5 | Gersylv 3 |
| R10 | 15 | Fesnigr 14.3 | Ranmont 12.9 | Agrcapi 8.6 | Phlrhae 8.6 | Chahirs 7.1 | Fesscab 5.7 | Lashall 5.7 | Bislaev 4.3 | Thyserp 4.3 | Triprat 4.3 |
| R21 | 16 | Fesnigr 25 | Ranmont 12.5 | Triniva 10.9 | Thyserp 9.4 | Antalpi 6.2 | Poaalpi 6.2 | Pulapii 6.2 | Leohelv 4.7 | Galpusi 3.1 | Geumont 3.1 |
| R1 | 17 | Fesnigr 21.3 | Phlrhae 14.7 | Vacmyrt 14.7 | Antalpi 8 | Agrcapi 6.7 | Rhoferr 6.7 | Geumont 5.3 | Leohelv 5.3 | Chahirs 4 | Narstri 2.7 |
| R22 | 18 | Fesnigr 27.8 | Phlrhae 12.7 | Agrcapi 10.1 | Antalpi 10.1 | Geumont 7.6 | Silvulg 5.1 | Vacmyrt 5.1 | Chahirs 3.8 | Rumalpe 3.8 | Leohelv 2.5 |
| R5 | 19 | Fesnigr 19.7 | Chahirs 9.2 | Phlrhae 9.2 | Triflav 9.2 | Pulapii 7.9 | Triprat 7.9 | Antalpi 6.6 | Alcvulg 5.3 | Geumont 3.9 | Poaalpi 3.9 |
| R7 | 20 | Fesnigr 25 | Triflav 11.2 | Alcvulg 7.5 | Antalpi 7.5 | Phlrhae 7.5 | Poaalpi 7.5 | Ranmont 6.2 | Geumont 5 | Camsche 2.5 | Leohelv 2.5 |
| R9 | 21 | Alcvulg 22.5 | Phlrhae 12.5 | Poaalpi 12.5 | Triflav 11.2 | Fesnigr 10 | Achmill 6.2 | Agrcapi 6.2 | Triprat 3.8 | Chahirs 2.5 | Antalpi 1.2 |
| R12 | 22 | Fesnigr 13.8 | Phlrhae 12.6 | Achmill 11.5 | Fesmela 11.5 | Agrcapi 6.9 | Chahirs 5.7 | Triprat 5.7 | Alcvulg 3.4 | Triflav 3.4 | Acialpi 2.3 |
| R11 | 23 | Fesmela 20.3 | Thaminu 12.7 | Rubidae 8.9 | Chahirs 6.3 | Rhoferr 6.3 | Vacmyrt 6.3 | Agrcapi 5.1 | Fesovin 3.8 | Acialpi 2.5 | Antalpi 2.5 |
| R20 | 24 | Rubidae 20.5 | Agrcapi 18.1 | Poanemo 15.7 | Myoalpe 12 | Silvulg 6 | Rhoferr 3.6 | Rumalpe 3.6 | Triflav 3.6 | Alcvulg 2.4 | Gersylv 2.4 |

Each species entry reports its code followed by its SRA. The table
already helps identify changes in the dominant species along the
dendrogram.

We can also display these species directly beside the survey labels. The
[`denspe()`](../reference/denspe.md) function creates labels containing
the survey identifier and the selected number of ranked species. Here we
show all ten; set `n_species_labels` to 4 or 5 for a more compact
figure.

``` r

n_species_labels <- 10L

db_labels <- denspe(
  nspe = n_species_labels,
  SpeAbund = first10,
  dbClust = veg
)

# Keep the original clustering and change only the displayed labels.
stopifnot(identical(unname(as.matrix(db_labels)), unname(veg)))
clst_labels <- clst
clst_labels$labels <- rownames(db_labels)[
  match(clst$labels, rownames(veg))
]

dend_labels <- as.dendrogram(clst_labels)
label_cex <- 0.5
dend_labels <- dendextend::set(dend_labels, "labels_cex", label_cex)
```

``` r

# Reserve enough space on the right for the species labels.
right_margin <- max(strwidth(
  clst_labels$labels,
  units = "inches",
  cex = label_cex
)) /
  par("csi") +
  2

par(mfrow = c(1, 1), mar = c(4, 2, 3, right_margin))
plot(
  dend_labels,
  horiz = TRUE,
  main = "Dendrogram with the ten most abundant species",
  xlab = "Chord distance"
)
```

![](TUTORIAL_2_-_Cluster_metodo_fitopastorale_files/figure-html/dendrogram-with-species-1.png)

From this view, it is easier to recognise groups sharing the same
dominant species and to see whether subdivisions correspond to changes
in their relative abundances. Inspect both species identities and SRA:
surveys may share the same species but differ considerably in dominance.
Ranks with an SRA of zero do not represent species present in that
survey.

The original cluster object `clst` is retained for every subsequent
analysis. Adding species labels does not change distances, branch
structure, or group membership.

## 5. Choosing where to cut the dendrogram

The cut should produce groups that can be interpreted in terms of
vegetation composition and the purpose of the pastoral classification.
The labelled dendrogram provides the main basis for this interpretation.
Fusion levels and silhouettes can support the choice by suggesting
alternative numbers of groups to inspect.

For example, compare mean silhouette widths for 2 to 10 groups, using
the same distance matrix as the cluster analysis. Here, automatic
silhouette selection excludes partitions with fewer than two surveys in
any group.

``` r

k_values <- seq.int(2L, min(10L, nrow(veg) - 1L))
min_group_size <- 2L

silhouette_results <- do.call(
  rbind,
  lapply(k_values, function(k) {
    membership <- stats::cutree(clst, k = k)
    sil <- cluster::silhouette(membership, d)
    sizes <- table(membership)

    data.frame(
      k = k,
      mean_silhouette = mean(sil[, "sil_width"]),
      smallest_group = min(sizes),
      admissible = all(sizes >= min_group_size)
    )
  })
)

admissible_results <- subset(silhouette_results, admissible)
if (nrow(admissible_results) == 0L) {
  stop("No partition meets min_group_size: review k_values or the constraint.")
}

# In the event of a tie, select the smallest k among those examined.
best_k <- admissible_results$k[
  which.max(admissible_results$mean_silhouette)
]

knitr::kable(silhouette_results, digits = 3)
```

|   k | mean_silhouette | smallest_group | admissible |
|----:|----------------:|---------------:|:-----------|
|   2 |           0.160 |              7 | TRUE       |
|   3 |           0.171 |              2 | TRUE       |
|   4 |           0.191 |              2 | TRUE       |
|   5 |           0.196 |              2 | TRUE       |
|   6 |           0.207 |              2 | TRUE       |
|   7 |           0.224 |              1 | FALSE      |
|   8 |           0.215 |              1 | FALSE      |
|   9 |           0.196 |              1 | FALSE      |
|  10 |           0.179 |              1 | FALSE      |

``` r

best_k
#> [1] 6

plot(
  mean_silhouette ~ k,
  data = silhouette_results,
  type = "b",
  xlab = "Number of groups",
  ylab = "Mean silhouette width"
)
points(
  mean_silhouette ~ k,
  data = subset(silhouette_results, !admissible),
  pch = 4,
  col = "red",
  cex = 1.4
)
abline(v = best_k, lty = 2, col = "blue")
```

![](TUTORIAL_2_-_Cluster_metodo_fitopastorale_files/figure-html/silhouette-1.png)

If [`maxFusionLevel()`](../reference/maxFusionLevel.md) is available, we
can also inspect its suggested number of groups. This optional chunk is
not evaluated during rendering.

``` r

fusion <- maxFusionLevel(clst)
fusion
fusion$n.clust
```

Suppose we decide to examine four groups after reading the labelled
dendrogram. We can set a custom cut, use `best_k`, or select the number
suggested by [`maxFusionLevel()`](../reference/maxFusionLevel.md). A
custom cut is an illustrative choice, not a claim that four groups are
optimal for this dataset.

``` r

selection_method <- "custom" # "custom", "silhouette", or "fusion"
k_custom <- 4L

n.cluster <- switch(
  selection_method,
  custom = k_custom,
  silhouette = best_k,
  fusion = {
    if (!exists("maxFusionLevel", mode = "function")) {
      stop("Load maxFusionLevel() to use the fusion criterion.")
    }
    maxFusionLevel(clst)$n.clust
  },
  stop("Unrecognised selection_method.")
)

stopifnot(
  length(n.cluster) == 1L,
  is.numeric(n.cluster),
  is.finite(n.cluster),
  n.cluster == as.integer(n.cluster),
  n.cluster >= 2L,
  n.cluster < nrow(veg)
)
n.cluster <- as.integer(n.cluster)
```

Highlight the selected groups on the same dendrogram with species
labels. We can now inspect which dominant species characterise each
group and whether the cut separates meaningful vegetation units.

``` r

# Match branch colours to the group numbers returned by cutree().
membership <- stats::cutree(clst, k = n.cluster)
palette <- scales::hue_pal()(n.cluster)
groups_in_dendrogram_order <- unique(membership[clst$order])
branch_colours <- palette[groups_in_dendrogram_order]

dend_selected <- dendextend::color_branches(
  dend_labels,
  k = n.cluster,
  col = branch_colours
)

par(mfrow = c(1, 1), mar = c(4, 2, 3, right_margin))
plot(
  dend_selected,
  horiz = TRUE,
  main = paste("Pastoral classification -", n.cluster, "groups"),
  xlab = "Chord distance"
)
dendextend::rect.dendrogram(
  dend_selected,
  k = n.cluster,
  horiz = TRUE,
  border = branch_colours,
  lty = 1,
  lwd = 1.2
)
```

![](TUTORIAL_2_-_Cluster_metodo_fitopastorale_files/figure-html/display-cut-1.png)

## 6. Extracting groups and calculating mean composition

Once the cut has been chosen, extract the group of each survey using
`cutree()`. Align group membership with the rows of `veg` before
calculating summaries or running the ordination.

``` r

groups.hclust <- stats::cutree(clst, k = n.cluster)
groups <- data.frame(
  stand = names(groups.hclust),
  group = paste0("G", groups.hclust),
  stringsAsFactors = FALSE
)

stopifnot(
  !anyDuplicated(groups$stand),
  setequal(rownames(veg), as.character(groups$stand))
)

groups <- groups[
  match(rownames(veg), as.character(groups$stand)),
  c("stand", "group"),
  drop = FALSE
]
rownames(groups) <- NULL
groups$group <- factor(groups$group, levels = paste0("G", seq_len(n.cluster)))

stopifnot(
  identical(rownames(veg), as.character(groups$stand)),
  !anyNA(groups$group),
  nlevels(droplevels(groups$group)) == n.cluster
)

knitr::kable(groups)
```

| stand | group |
|:------|:------|
| R1    | G1    |
| R2    | G2    |
| R3    | G1    |
| R4    | G2    |
| R5    | G1    |
| R6    | G1    |
| R7    | G1    |
| R8    | G1    |
| R9    | G1    |
| R10   | G1    |
| R11   | G1    |
| R12   | G1    |
| R13   | G3    |
| R14   | G4    |
| R15   | G1    |
| R16   | G3    |
| R17   | G4    |
| R18   | G1    |
| R19   | G4    |
| R20   | G1    |
| R21   | G1    |
| R22   | G1    |
| R23   | G3    |
| R24   | G3    |

``` r

table(groups$group)
#> 
#> G1 G2 G3 G4 
#> 15  2  4  3
```

Always inspect group sizes, especially after a custom cut. The
`min_group_size` constraint above applies only to automatic selection by
silhouette.

To describe the groups, calculate the mean SRA of each species using
[`clustGroupAggregate2()`](../reference/clustGroupAggregate2.md). The
group identifier must be the first column. Zeros are included when
averaging surveys where a species is absent.

The simplified table lists species in decreasing order of mean SRA
within each group, providing a concise description of the vegetation
units identified from the dendrogram.

``` r

db_aggregate <- data.frame(
  group = groups$group,
  as.data.frame(veg, check.names = FALSE),
  check.names = FALSE
)

aggregate_groups <- clustGroupAggregate2(db_aggregate)
knitr::kable(head(aggregate_groups$table, 10), digits = 1)
```

| G1_species | G1_abundance | G2_species | G2_abundance | G3_species | G3_abundance | G4_species | G4_abundance |
|:---|---:|:---|---:|:---|---:|:---|---:|
| Fesnigr | 13.1 | Descesp | 42.7 | Rhoferr | 41.8 | Alnviri | 34.1 |
| Phlrhae | 8.1 | Carclav | 11.1 | Calvill | 16.7 | Adealli | 9.3 |
| Agrcapi | 6.3 | Phlrhae | 9.3 | Vacmyrt | 8.6 | Agrcapi | 7.3 |
| Triflav | 5.5 | Fesnigr | 8.2 | Junnana | 8.0 | Rubidae | 6.1 |
| Chahirs | 4.4 | Poaalpi | 5.9 | Rubidae | 5.5 | Urtdioi | 5.4 |
| Antalpi | 4.1 | Alcvulg | 4.5 | Alnviri | 4.7 | Viobifl | 5.3 |
| Alcvulg | 4.1 | Peuostr | 4.1 | Fesscab | 4.5 | Rumalpe | 5.3 |
| Rumalpe | 3.7 | Verlobe | 3.7 | Aveflex | 4.2 | Calvill | 4.0 |
| Vacmyrt | 3.4 | Rumalpe | 2.2 | Gymdryo | 1.7 | Rhoferr | 3.2 |
| Poaalpi | 3.2 | Caramar | 1.5 | Arnmont | 1.1 | Vacmyrt | 3.1 |

``` r


head(aggregate_groups$df.long)
#> # A tibble: 6 × 3
#>   group species abundance
#>   <chr> <chr>       <dbl>
#> 1 G1    Fesnigr     13.1 
#> 2 G1    Phlrhae      8.09
#> 3 G1    Agrcapi      6.31
#> 4 G1    Triflav      5.49
#> 5 G1    Chahirs      4.38
#> 6 G1    Antalpi      4.07
aggregate_groups$df.wide
#> # A tibble: 4 × 92
#>   group Achmacr Achmill Acialpi Acolama Adealli Agrcapi Alcpent Alcvulg Alnviri
#>   <chr>   <dbl>   <dbl>   <dbl>   <dbl>   <dbl>   <dbl>   <dbl>   <dbl>   <dbl>
#> 1 G1      0        1.18   0.322   0        0      6.31   0.0833    4.06    0   
#> 2 G2      0        0      0       0        0      0.746  0         4.48    0   
#> 3 G3      0        0      0       0        0      0.758  0         0       4.72
#> 4 G4      0.901    0      0       0.901    9.33   7.35   0         1.42   34.1 
#> # ℹ 82 more variables: Antalpi <dbl>, Arnmont <dbl>, Aveflex <dbl>,
#> #   Bislaev <dbl>, Calvill <dbl>, Camsche <dbl>, Caramar <dbl>, Cardefl <dbl>,
#> #   Carclav <dbl>, Carechi <dbl>, Carsemp <dbl>, Carcarv <dbl>, Cerarve <dbl>,
#> #   Cervulg <dbl>, Chahirs <dbl>, Cusepit <dbl>, Dapmeze <dbl>, Descesp <dbl>,
#> #   Eupcypa <dbl>, Fesovin <dbl>, Fesmela <dbl>, Fesnigr <dbl>, Fesscab <dbl>,
#> #   Galtetr <dbl>, Galpusi <dbl>, Genpurp <dbl>, Gersylv <dbl>, Geumont <dbl>,
#> #   Geuriva <dbl>, Gymdryo <dbl>, Hiemuro <dbl>, Junnana <dbl>, …
```

## 7. Exploring the groups with tb-PCA and ordiselect

We can now explore the selected groups using a PCA of
Hellinger-transformed SRA values. Groups are overlaid on the ordination;
they do not determine the PCA axes.

To keep the species plot readable, use `species = "ordiselect"` in
[`tb_pca_plot()`](../reference/tb_pca_plot.md). This calls
[`goeveg::ordiselect()`](https://rdrr.io/pkg/goeveg/man/ordiselect.html)
to select species according to abundance and fit to the displayed axes:

- `ablim = 0.3` retains the most abundant 30% of species;
- `fitlim = 0.8` retains the 80% of species with the best fit to the
  axes;
- `freq = FALSE` uses abundance rather than occurrence frequency.

Species must meet both selection criteria. In
[`tb_pca_plot()`](../reference/tb_pca_plot.md), `ordiselect()` receives
the transformed matrix used for the PCA. The abundance threshold is a
proportion of species, not a cumulative percentage of total SRA.

``` r

set.seed(123)
pca <- tb_pca_plot(
  veg = veg,
  groups = groups,
  transformation = "hellinger", # alternative: "chord"
  axes = c(1, 2),
  area = "hull", # "hull", "ellipse", or "none"
  species = "ordiselect",
  ablim = 0.3,
  fitlim = 0.8,
  freq = FALSE,
  label_groups = TRUE,
  segment.alpha_labelSpe = 0.3,
  segment.size_labelSpe = 0.3
)
#> [1] "28 species selected (30.8% of total number of species)."
#> [1] "All species selected which belong to the 30% most abundant species and to the 80% of species with the highest absolute axis scores."

pca$plot_sites
```

![](TUTORIAL_2_-_Cluster_metodo_fitopastorale_files/figure-html/tb-pca-1.png)

``` r

pca$plot_species
```

![](TUTORIAL_2_-_Cluster_metodo_fitopastorale_files/figure-html/tb-pca-2.png)

The survey plot shows how groups are distributed in the ordination
plane. The species plot helps interpret the main compositional
gradients. For `ordiselect`, the species colour identifies the group
with the highest mean SRA; this is a descriptive assignment, not a test
of indicator value.

Convex hulls describe the distribution of surveys and are not confidence
intervals. Interpret overlap or separation alongside the variance
explained by the axes and the group composition tables.

``` r

pca$variance
#>       PC1       PC2       PC3       PC4       PC5       PC6       PC7       PC8 
#> 22.476597 13.005802  9.591037  8.420782  6.142118  5.022319  4.796562  4.327911 
#>       PC9      PC10      PC11      PC12      PC13      PC14      PC15      PC16 
#>  3.722181  3.389445  2.842252  2.515764  2.322194  2.037121  1.909219  1.699734 
#>      PC17      PC18      PC19      PC20      PC21      PC22      PC23 
#>  1.409381  1.108072  0.914318  0.755615  0.665978  0.522745  0.402852
head(pca$sites)
#>    stand          x           y group
#> R1    R1 -0.1462875 -0.59947043    G1
#> R2    R2 -0.1208754  0.49795477    G2
#> R3    R3 -0.2649394  0.57840480    G1
#> R4    R4 -0.3074023  0.51494749    G2
#> R5    R5 -0.5170555 -0.08394836    G1
#> R6    R6 -0.1240123 -0.09499077    G1
head(pca$species)
#>         species           x           y group
#> Agrcapi Agrcapi -0.05662518 -0.04166251    G4
#> Alcvulg Alcvulg -0.17951134  0.15199803    G2
#> Alnviri Alnviri  0.25968378  0.24511778    G4
#> Antalpi Antalpi -0.12669237 -0.18129291    G1
#> Aveflex Aveflex  0.07605068 -0.09634260    G3
#> Calvill Calvill  0.25930058  0.01318816    G3
pca$selected_species
#>  [1] "Agrcapi" "Alcvulg" "Alnviri" "Antalpi" "Aveflex" "Calvill" "Chahirs"
#>  [8] "Descesp" "Fesmela" "Fesnigr" "Fesscab" "Geumont" "Leohelv" "Myoalpe"
#> [15] "Narstri" "Peuostr" "Phlrhae" "Poaalpi" "Pulapii" "Ranmont" "Rhoferr"
#> [22] "Rubidae" "Rumalpe" "Silvulg" "Triprat" "Triflav" "Vacmyrt" "Viobifl"
```

## 8. Optional extension: Indicator Species Analysis

IndVal can also be applied to the selected groups to identify species
associated with individual vegetation units. This complements the
description based on dominant species and the exploratory species
selection provided by `ordiselect`.

The following optional chunk applies `IndVal.g` to SRA values,
accounting for unequal group sizes. Setting `duleg = TRUE` limits the
analysis to individual groups. Adapt the permutation design if surveys
are repeated or arranged in blocks.

``` r

set.seed(123)
indval <- indicspecies::multipatt(
  x = veg,
  cluster = groups$group,
  func = "IndVal.g",
  duleg = TRUE,
  control = permute::how(nperm = 9999)
)

summary(indval, alpha = 0.05, indvalcomp = TRUE)
```

The statistic returned by `multipatt()` is the square root of IndVal.
Its summary uses unadjusted p-values. Since groups were derived from the
same species matrix, this analysis characterises the classification and
does not provide an independent validation.

If desired, display species selected by IndVal in a separate tb-PCA
figure, keeping the same surveys, groups, transformation, and axes.

``` r

pca_indval <- tb_pca_plot(
  veg = veg,
  groups = groups,
  transformation = "hellinger",
  axes = c(1, 2),
  area = "hull",
  species = "indval",
  indval = indval,
  alpha = 0.05,
  label_groups = TRUE
)

pca_indval$plot_sites
pca_indval$plot_species
```

## 9. Optional export

Run the following chunk interactively to save the species table,
classification, group composition, and ordination results.

``` r

output_dir <- "risultati_pastoralista"
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

write.csv2(
  first10_table,
  file.path(output_dir, "first_ten_species.csv"),
  row.names = FALSE
)
write.csv2(groups, file.path(output_dir, "gruppi.csv"), row.names = FALSE)
write.csv2(
  silhouette_results,
  file.path(output_dir, "silhouette.csv"),
  row.names = FALSE
)
write.csv2(
  aggregate_groups$table,
  file.path(output_dir, "composizione_media.csv"),
  row.names = FALSE
)

saveRDS(
  list(
    veg = veg,
    distance = d,
    clustering = clst,
    first10 = first10_table,
    selection_method = selection_method,
    n.cluster = n.cluster,
    silhouette = silhouette_results,
    groups = groups,
    aggregate = aggregate_groups,
    pca = pca,
    session = sessionInfo()
  ),
  file.path(output_dir, "analisi_pastoralista.rds")
)
```

## Function references

- [iPastoralist documentation and source
  code](https://github.com/MarcoPittarello/iPastoralist).
- [goeveg documentation](https://fvlampe.r-universe.dev/goeveg).
- [silhouette
  documentation](https://stat.ethz.ch/R-manual/R-devel/library/cluster/html/silhouette.html).
- [multipatt
  documentation](https://search.r-project.org/CRAN/refmans/indicspecies/html/multipatt.html).
