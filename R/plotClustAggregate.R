#' Plot dendrograms and (optionally) aggregated cluster summaries
#'
#' @description
#' Create a dendrogram from a surveys-by-species matrix where survey row names
#' can be labelled with the top species by decreasing abundance. Optionally
#' aggregate surveys by cluster and return a summary of the top species for
#' each cluster. The function writes PNG files (one for the non-aggregated
#' dendrogram and, when aggregation is used, one prefixed with "aggregate_")
#' to the current working directory.
#'
#' @param nspePlot Integer; number of species to include in the survey labels (default 5).
#' @param firt10 Object created by \link[iPastoralist]{first_ten_species}; used to generate labels of top species.
#' @param dbClust Numeric matrix (surveys x species) used to compute dissimilarities.
#' @param distance Character; distance method passed to \link[vegan]{vegdist} (default "chord").
#' @param clust.method Character; agglomeration method passed to \link[stats]{hclust} (default "average").
#' @param clust.mar Numeric vector of length 4; plot margins passed to \link[graphics]{par} (default c(1, 2, 2, 18)).
#' @param file.name Character; filename for the saved dendrogram PNG (default "dendrogram.png").
#' @param file.height Integer; height (pixels) for the PNG device (default 2500).
#' @param file.width Integer; width (pixels) for the PNG device (default 1200).
#' @param file.res Integer; resolution (ppi) for the PNG device (default 200).
#' @param aggregate Logical; if TRUE, aggregate surveys by cluster and produce an aggregated dendrogram and summary (default TRUE).
#' @param aggr.Nspe Integer; number of species to report per cluster in the returned summary (default 5).
#' @param n.clust Integer; number of clusters used for grouping and for drawing rectangles on the aggregated dendrogram (default 20).
#'
#' @details
#' The function uses iPastoralist::denspe to create labelled survey rows, computes
#' a distance matrix with \link[vegan]{vegdist}, and generates a hierarchical
#' clustering with \link[stats]{hclust}. When \code{aggregate = TRUE} the
#' function calls iPastoralist::clustOrder and iPastoralist::clustGroupAggregate2
#' to compute cluster-level average compositions, relabels rows with a cluster
#' prefix, reclusters aggregated profiles and draws cluster rectangles on the
#' aggregated dendrogram.
#'
#' Side effects: PNG files are written to the working directory. Use \link[base]{getwd}
#' to inspect or change the location before running.
#' @import tidyverse vegan dendextend
#' @return
#' If \code{aggregate = TRUE}, a tibble/data.frame with one row per cluster
#' and a \code{name} column containing the top species (with rounded percentage)
#' concatenated for that cluster. If \code{aggregate = FALSE}, the function
#' invisibly returns NULL (plots and saves the plain dendrogram).
#'
#' @examples
#' \dontrun{
#' # prepare inputs (replace with real objects)
#' firt10_obj <- iPastoralist::first_ten_species(my_survey_matrix)
#' db_matrix <- my_survey_matrix
#'
#' # aggregated run: returns cluster top-species summary and writes PNGs
#' plotClustAggregate(
#'   nspePlot = 5,
#'   firt10 = firt10_obj,
#'   dbClust = db_matrix,
#'   aggregate = TRUE,
#'   n.clust = 10
#' )
#'
#' # non-aggregated run: just produces and saves a dendrogram
#' plotClustAggregate(
#'   nspePlot = 5,
#'   firt10 = firt10_obj,
#'   dbClust = db_matrix,
#'   aggregate = FALSE
#' )
#' }
#'
#' @seealso \link[vegan]{vegdist}, \link[stats]{hclust}, \link[iPastoralist]{denspe},
#' \link[iPastoralist]{clustOrder}, \link[iPastoralist]{clustGroupAggregate2}
#' @export

plotClustAggregate = function(
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
  labels.cex = 0.5,
  aggregate = TRUE,
  aggr.Nspe = 5,
  n.clust = NULL
) {
  if (is.null(firt10) | is.null(dbClust)) {
    stop(
      "Please provide the database of the first ten species and the database used for cluster analysis."
    )
  }

  db.lab <- iPastoralist::denspe(
    nspe = nspePlot,
    SpeAbund = firt10,
    dbClust = dbClust
  )
  d <- vegdist(
    db.lab, #database name
    method = distance
  )
  clst <- hclust(
    d, #distance matrix
    method = clust.method
  )

  if (aggregate == FALSE) {
    clst.dxt <- as.dendrogram(clst) #coversion of cluster to class 'dendrogram' of 'dendexted' package (which allows a better customisation of the plot)

    par(mfrow = c(1, 1), mar = clust.mar) #graphical settings
    plot(
      clst.dxt %>%
        set("labels_cex", labels.cex),
      horiz = T
    )

    getwd()
    png(
      file = file.name,
      height = file.height,
      width = file.width,
      res = file.res
    ) #png export
    par(mfrow = c(1, 1), mar = clust.mar) #graphical settings
    plot(
      clst.dxt %>%
        set("labels_cex", labels.cex),
      horiz = T
    )
    dev.off()
  } else if (aggregate == TRUE) {
    if (is.null(n.clust)) {
      stop(
        "Please provide the number of clusters for aggregation."
      )
    }

    groups <- iPastoralist::clustOrder(
      cluster.hclust = clst,
      cluster.group = T,
      cluster.number = n.clust
    )
    dt.g <- merge(
      groups,
      db.lab,
      by.x = "Survey",
      by.y = "row.names"
    )

    db.aggr <- as.data.frame(dt.g[, -c(1, 3)])
    aggr <- iPastoralist::clustGroupAggregate2(db.aggr) #aggregate for each group:average composition for group
    group.names <- aggr$df.long %>%
      group_by(group) %>%
      arrange(-abundance) %>%
      slice(1:aggr.Nspe) %>%
      mutate(
        ab_pct = round(abundance, 0),
        label = paste0(species, " (", ab_pct, "%)")
      ) %>%
      summarize(name = paste(label, collapse = ", "), .groups = "drop")

    dbClust.aggr <- dt.g %>%
      mutate(
        cluster = sprintf("%04d", as.integer(as.character(cluster))),
        Survey = paste0(cluster, "_", Survey)
      ) %>%
      select(-c(cluster, Survey.order)) %>%
      column_to_rownames("Survey")
    d.aggr <- vegdist(
      dbClust.aggr, #database name
      method = distance
    )
    clst.aggr <- hclust(
      d.aggr, #distance matrix
      method = clust.method
    )
    clst.dxt.aggr <- as.dendrogram(clst.aggr)

    par(mfrow = c(1, 1), mar = clust.mar)
    plot(
      clst.dxt.aggr %>%
        set("labels_cex", labels.cex),
      horiz = T
    )
    rect.dendrogram(
      clst.dxt.aggr,
      k = n.clust,
      horiz = TRUE,
      border = 5,
      lty = 1,
      lwd = 1
    )

    getwd()
    png(
      file = paste0("aggregate_", file.name),
      height = file.height,
      width = file.width,
      res = file.res
    ) #png export
    par(mfrow = c(1, 1), mar = clust.mar)
    plot(
      clst.dxt.aggr %>%
        set("labels_cex", labels.cex),
      horiz = T
    )
    rect.dendrogram(
      clst.dxt.aggr,
      k = n.clust,
      horiz = TRUE,
      border = 5,
      lty = 1,
      lwd = 1
    )
    dev.off()

    return(group.names)
  }
}
