#' Plot dendrograms and (optionally) aggregated cluster summaries
#'
#' @description
#' Create a dendrogram from a surveys-by-species matrix where survey row names
#' can be labelled with the top species by decreasing abundance. Optionally
#' aggregate surveys by cluster and return a summary of the top species for
#' each cluster. When \code{save.file = TRUE}, the function writes a PDF (default)
#' or PNG file (one for the non-aggregated dendrogram and, when aggregation is
#' used, one prefixed with \code{"aggregate_"}) to the current working directory.
#'
#' @param nspePlot Integer; number of species to include in the survey labels (default 5).
#' @param firt10 Object created by \link[iPastoralist]{first_ten_species}; used to generate labels of top species.
#' @param dbClust Numeric matrix (surveys x species) used to compute dissimilarities.
#' @param distance Character; distance method passed to \link[vegan]{vegdist} (default "chord").
#' @param clust.method Character; agglomeration method passed to \link[stats]{hclust} (default "average").
#' @param clust.mar Numeric vector of length 4; plot margins passed to \link[graphics]{par} (default c(1, 2, 2, 18)).
#' @param file.name Character; filename for the output file (default \code{"dendrogram.pdf"}).
#' @param file.height Numeric; height of the output file. For PDF (default) this is in inches (default 30);
#'   for PNG it is used together with \code{file.res} to compute pixel dimensions.
#' @param file.width Numeric; width of the output file. For PDF (default) this is in inches (default 15);
#'   for PNG it is used together with \code{file.res} to compute pixel dimensions.
#' @param file.res Integer; resolution in ppi, used only when \code{format = "png"} (default 200).
#' @param aggregate Logical; if TRUE, aggregate surveys by cluster and produce an aggregated dendrogram and summary (default TRUE).
#' @param aggr.Nspe Integer; number of species to report per cluster in the returned summary (default 5).
#' @param n.clust Integer; number of clusters used for grouping and for drawing rectangles on the aggregated dendrogram.
#' @param save.file Logical; if TRUE (default), the dendrogram(s) are exported to disk. Set to FALSE to skip file output.
#' @param format Character; output format, either \code{"pdf"} (default) or \code{"png"}.
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
#' Side effects: when \code{save.file = TRUE}, a PDF or PNG file is written to the
#' working directory depending on \code{format}. Use \link[base]{getwd} to inspect
#' or change the location before running.
#' @import tidyverse vegan dendextend
#' @return
#' If \code{aggregate = TRUE}, a tibble/data.frame with one row per cluster
#' and a \code{name} column containing the top species (with rounded percentage)
#' concatenated for that cluster. If \code{aggregate = FALSE}, the function
#' invisibly returns NULL (and optionally saves the plain dendrogram).
#'
#' @examples
#' \dontrun{
#' # prepare inputs (replace with real objects)
#' firt10_obj <- iPastoralist::first_ten_species(my_survey_matrix)
#' db_matrix <- my_survey_matrix
#'
#' # aggregated run: save as PDF (default)
#' plotClustAggregate(
#'   nspePlot    = 5,
#'   firt10      = firt10_obj,
#'   dbClust     = db_matrix,
#'   aggregate   = TRUE,
#'   n.clust     = 10,
#'   save.file   = TRUE,
#'   format      = "pdf"
#' )
#'
#' # aggregated run: save as PNG
#' plotClustAggregate(
#'   nspePlot    = 5,
#'   firt10      = firt10_obj,
#'   dbClust     = db_matrix,
#'   file.name   = "dendrogram.png",
#'   file.height = 30,
#'   file.width  = 15,
#'   file.res    = 200,
#'   aggregate   = TRUE,
#'   n.clust     = 10,
#'   save.file   = TRUE,
#'   format      = "png"
#' )
#'
#' # non-aggregated run: display only, no file saved
#' plotClustAggregate(
#'   nspePlot  = 5,
#'   firt10    = firt10_obj,
#'   dbClust   = db_matrix,
#'   aggregate = FALSE,
#'   save.file = FALSE
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
  file.name = "dendrogram.pdf",
  file.height = 30,
  file.width = 15,
  file.res = 200,
  labels.cex = 0.5,
  aggregate = TRUE,
  aggr.Nspe = 5,
  n.clust = NULL,
  save.file = TRUE,
  format = "pdf"
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
  d <- vegdist(db.lab, method = distance)
  clst <- hclust(d, method = clust.method)

  # helper: open the appropriate graphics device
  open_device <- function(fname, format, file.height, file.width, file.res) {
    if (format == "pdf") {
      pdf(file = fname, height = file.height, width = file.width)
    } else if (format == "png") {
      png(
        file = fname,
        height = file.height * file.res,
        width = file.width * file.res,
        res = file.res
      )
    } else {
      stop("format must be 'pdf' or 'png'")
    }
  }

  if (aggregate == FALSE) {
    clst.dxt <- as.dendrogram(clst)

    if (save.file) {
      open_device(file.name, format, file.height, file.width, file.res)
      par(mfrow = c(1, 1), mar = clust.mar)
      plot(clst.dxt %>% set("labels_cex", labels.cex), horiz = TRUE)
      dev.off()
    }
  } else if (aggregate == TRUE) {
    if (is.null(n.clust)) {
      stop("Please provide the number of clusters for aggregation.")
    }

    groups <- iPastoralist::clustOrder(
      cluster.hclust = clst,
      cluster.group = TRUE,
      cluster.number = n.clust
    )
    dt.g <- merge(groups, db.lab, by.x = "Survey", by.y = "row.names")

    db.aggr <- as.data.frame(dt.g[, -c(1, 3)])
    aggr <- iPastoralist::clustGroupAggregate2(db.aggr)

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

    d.aggr <- vegdist(dbClust.aggr, method = distance)
    clst.aggr <- hclust(d.aggr, method = clust.method)
    clst.dxt.aggr <- as.dendrogram(clst.aggr)

    if (save.file) {
      fname <- paste0("aggregate_", file.name)
      open_device(fname, format, file.height, file.width, file.res)
      par(mfrow = c(1, 1), mar = clust.mar)
      plot(clst.dxt.aggr %>% set("labels_cex", labels.cex), horiz = TRUE)
      rect.dendrogram(
        clst.dxt.aggr,
        k = n.clust,
        horiz = TRUE,
        border = 5,
        lty = 1,
        lwd = 1
      )
      dev.off()
    }

    return(group.names)
  }
}
