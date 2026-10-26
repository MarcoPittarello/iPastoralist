#' Survey order and terminal groups of an ecan TWINSPAN classification
#'
#' Extract survey identifiers, their positions in the TWINSPAN dendrogram,
#' and, optionally, the terminal groups already fitted by [ecan::twinspan()].
#'
#' @param twin_ecan An object returned by [ecan::twinspan()]. Both classical
#'   and modified TWINSPAN are supported, including `species = FALSE`.
#' @param cluster.group Logical; include the terminal group, path and depth?
#' @param cluster.number Optional positive integer. If supplied, it must equal
#'   the number of terminal groups actually present in `twin_ecan`.
#'
#' @details
#' This is the TWINSPAN counterpart of `iPastoralist::clustOrder`, the function
#' defined in the original file `cluster_survey_order.R`.
#'
#' The groups are taken from `twin_ecan$classification$group`, matched by
#' survey identifier. They are never obtained by cutting a new clustering.
#' To request a different classification, refit [ecan::twinspan()] with the
#' desired `n_clusters`. That argument is a stopping target: the fitted number
#' can be smaller when no group can be divided further.
#'
#' Survey positions follow [stats::as.hclust()] for the supplied object. Within
#' a terminal group, TWINSPAN has not resolved the order of individual surveys;
#' ecan retains their input order and inserts zero-height graphical merges.
#'
#' @return A data.frame sorted by `Survey.order`. With `cluster.group = FALSE`,
#'   columns are `Survey` and `Survey.order`. Otherwise columns are `Survey`,
#'   `cluster` (ecan group ID), `Survey.order`, `path` (binary division path),
#'   and `depth` (terminal division depth).
#' @seealso [first_ten_species_twspn()], [plotClustAggregate_twspn()]
#' @examples
#' veg <- rbind(S1 = c(9, 5, 0, 0), S2 = c(8, 4, 1, 0),
#'              S3 = c(0, 1, 5, 8), S4 = c(0, 0, 4, 7))
#' colnames(veg) <- c("Species A", "Species B", "Species C", "Species D")
#' tw <- ecan::twinspan(veg, modified = TRUE, n_clusters = 2,
#'                      min_size = 2, polish = "hill", species = FALSE)
#' clustOrder_twspn(tw)
#' clustOrder_twspn(tw, cluster.group = FALSE)
#' @export
clustOrder_twspn <- function(
  twin_ecan,
  cluster.group = TRUE,
  cluster.number = NULL
) {
  .twspn_flag(cluster.group, "cluster.group")
  info <- .twspn_info(twin_ecan)
  cls <- info$classification
  if (!is.null(cluster.number)) {
    .twspn_integer(cluster.number, "cluster.number", minimum = 1)
    actual <- length(unique(cls$group))
    if (cluster.number != actual) {
      stop(
        "cluster.number = ",
        cluster.number,
        "; the fitted object contains ",
        actual,
        " terminal group(s). Refit ecan::twinspan() to change groups.",
        call. = FALSE
      )
    }
  }
  ids <- info$hclust$labels[info$hclust$order]
  i <- match(ids, cls$stand)
  out <- data.frame(
    Survey = ids,
    Survey.order = seq_along(ids),
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
  if (cluster.group) {
    out$cluster <- cls$group[i]
    out$path <- cls$path[i]
    out$depth <- cls$depth[i]
    out <- out[c("Survey", "cluster", "Survey.order", "path", "depth")]
  }
  out
}

# Shared, unexported validation helpers. Source all four scripts when using
# these functions outside a package; no installed iPastoralist is required.
.twspn_flag <- function(x, argument) {
  if (!is.logical(x) || length(x) != 1L || is.na(x)) {
    stop(argument, " must be TRUE or FALSE.", call. = FALSE)
  }
  invisible(x)
}

.twspn_integer <- function(x, argument, minimum = 0) {
  if (
    !is.numeric(x) ||
      length(x) != 1L ||
      !is.finite(x) ||
      x != floor(x) ||
      x < minimum ||
      x > .Machine$integer.max
  ) {
    stop(argument, " must be a single integer >= ", minimum, ".", call. = FALSE)
  }
  invisible(x)
}

.twspn_names <- function(x, argument) {
  if (is.null(x) || anyNA(x) || any(!nzchar(x)) || anyDuplicated(x)) {
    stop(argument, " must be present, non-empty and unique.", call. = FALSE)
  }
  invisible(x)
}

.twspn_matrix <- function(x, argument) {
  if (!(is.matrix(x) || is.data.frame(x))) {
    stop(argument, " must be a numeric matrix or data.frame.", call. = FALSE)
  }
  x <- as.matrix(x)
  if (
    !is.numeric(x) ||
      nrow(x) < 1L ||
      ncol(x) < 1L ||
      any(!is.finite(x)) ||
      any(x < 0)
  ) {
    stop(
      argument,
      " must have at least one row and column, with finite, ",
      "non-negative numeric abundances (no NA/NaN/Inf).",
      call. = FALSE
    )
  }
  .twspn_names(rownames(x), paste0(argument, " row names"))
  .twspn_names(colnames(x), paste0(argument, " column names"))
  x
}

.twspn_same_surveys <- function(ids, expected, argument) {
  if (length(ids) != length(expected) || !setequal(ids, expected)) {
    stop(
      argument,
      " must contain exactly the fitted survey IDs. Missing: ",
      paste(setdiff(expected, ids), collapse = ", "),
      "; extra: ",
      paste(setdiff(ids, expected), collapse = ", "),
      ".",
      call. = FALSE
    )
  }
  invisible(ids)
}

.twspn_info <- function(twin_ecan) {
  if (
    !inherits(twin_ecan, "twinspan") ||
      !is.list(twin_ecan) ||
      !is.data.frame(twin_ecan$classification) ||
      !all(
        c("stand", "group", "path", "depth") %in%
          names(twin_ecan$classification)
      ) ||
      is.null(twin_ecan$nodes) ||
      is.null(twin_ecan$data)
  ) {
    stop(
      "twin_ecan must be an unmodified object returned by ecan::twinspan() ",
      "(not an object from twinspan or twinspanR).",
      call. = FALSE
    )
  }
  if (!requireNamespace("ecan", quietly = TRUE)) {
    stop("Package 'ecan' (>= 0.3.0) is required.", call. = FALSE)
  }
  cls <- as.data.frame(twin_ecan$classification, stringsAsFactors = FALSE)
  cls$stand <- as.character(cls$stand)
  .twspn_names(cls$stand, "classification$stand")
  if (nrow(cls) < 2L || anyNA(cls[c("group", "path", "depth")])) {
    stop(
      "The fitted classification is empty, incomplete or contains NA.",
      call. = FALSE
    )
  }
  ecan.as.hclust <- utils::getS3method(
    "as.hclust",
    "twinspan",
    envir = asNamespace("ecan")
  )
  hc <- ecan.as.hclust(twin_ecan)
  .twspn_names(hc$labels, "TWINSPAN survey labels")
  .twspn_same_surveys(hc$labels, cls$stand, "TWINSPAN dendrogram")
  .twspn_same_surveys(rownames(twin_ecan$data), cls$stand, "twin_ecan$data")
  if (!identical(hc$labels[hc$order], cls$stand)) {
    stop(
      "The dendrogram order differs from ecan's classification. ",
      "Check for a conflicting as.hclust.twinspan method or an edited object.",
      call. = FALSE
    )
  }
  list(classification = cls, hclust = hc)
}
