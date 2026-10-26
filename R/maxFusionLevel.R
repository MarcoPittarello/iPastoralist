#' Identify the Optimal Number of Clusters Based on Maximum Fusion Height
#'
#' @description
#' Identifies the number of clusters corresponding to the largest increase
#' in fusion height in a hierarchical clustering dendrogram.
#'
#' @details
#' The function calculates the difference between consecutive fusion
#' heights obtained from a hierarchical clustering analysis.
#'
#' The optimal number of clusters is identified as the number of groups
#' immediately before the largest increase in fusion height.
#'
#' A large increase suggests that relatively dissimilar clusters are
#' being merged, potentially indicating a meaningful partition of
#' the dataset.
#'
#' This is a heuristic criterion and does not guarantee the identification
#' of the ecologically or statistically optimal number of clusters.
#' Results may depend on the distance measure and linkage method used.
#'
#' @param cluster An object of class \code{hclust}, typically obtained
#'   using \code{stats::hclust()}.
#'
#' @return
#' A list containing:
#' \describe{
#'   \item{n.clust}{Integer vector indicating the number of clusters
#'     corresponding to the maximum increase in fusion height.
#'     Multiple values may be returned in the case of ties.}
#'   \item{results}{A data frame containing:
#'     \itemize{
#'       \item \code{h}: fusion heights.
#'       \item \code{n.clust}: number of clusters before each fusion.
#'       \item \code{diff}: differences between consecutive fusion heights.
#'     }}
#' }
#'
#' @examples
#' # Hierarchical clustering using the USArrests dataset
#' data(USArrests)
#'
#' d <- dist(scale(USArrests))
#' hc <- hclust(d, method = "ward.D2")
#'
#' # Identify the number of clusters
#' res <- maxFusionLevel(hc)
#'
#' # Suggested number of clusters
#' res$n.clust
#'
#' # Fusion heights and their differences
#' res$results
#'
#' # Plot the dendrogram with the suggested partition
#' plot(hc)
#' rect.hclust(hc, k = res$n.clust[1], border = "red")
#'
#' @seealso
#' \code{\link[stats]{hclust}},
#' \code{\link[stats]{cutree}}
#'
#' #' @references
#' Borcard, D., Gillet, F., & Legendre, P. (2018).
#' Numerical Ecology with R (2nd ed.). Springer, Cham.
#' https://doi.org/10.1007/978-3-319-71404-2
#'
#' @export
maxFusionLevel <- function(cluster) {
  clust.height.mx <- data.frame(
    h = cluster$height,
    n.clust = (length(cluster$height) + 1):2
  )

  clust.height.mx$diff <- c(
    NA_real_,
    diff(clust.height.mx$h)
  )

  return(list(
    n.clust = clust.height.mx[
      which(clust.height.mx$diff == max(clust.height.mx$diff, na.rm = TRUE)),
      "n.clust"
    ],
    results = clust.height.mx
  ))
}
