#' Fit TWINSPAN and plot its dendrogram using the iPastoralist layout
#'
#' Run [ecan::twinspan()] from scratch on `dbClust` at every call, using the
#' supplied native fitting parameters. Label surveys with their most abundant
#' species. With `aggregate = TRUE`,
#' retain every survey, prefix each label with its terminal TWINSPAN group,
#' draw rectangles around groups, and return their dominant species based on
#' mean abundance. This follows the layout of `iPastoralist::plotClustAggregate`.
#'
#' @param nspePlot Non-negative integer; number of species per survey label.
#' @param firt10 Optional data.frame returned by [first_ten_species_twspn()].
#'   If `NULL`, compute the ranked species from `dbClust`. Existing group and
#'   order columns are ignored: the new fit determines membership and order.
#'   The spelling retains the original argument name.
#' @param dbClust Required numeric surveys-by-species matrix or data.frame.
#'   Rows are surveys and columns are species, with unique non-empty names.
#'   This exact abundance matrix is used for fitting and group summaries.
#' @param distance,clust.method Retained in their original positions for call
#'   compatibility. They are not used by TWINSPAN; use the native fitting
#'   arguments below instead.
#' @param clust.mar Four non-negative plot margins passed to [graphics::par()].
#' @param file.name Output filename, default `"dendrogram.pdf"`. With
#'   `aggregate = TRUE`, save only `aggregate_` plus the basename in the same
#'   directory, as in the original function. The directory must exist.
#' @param file.height,file.width Positive numeric output dimensions in inches.
#' @param file.res Positive numeric resolution in pixels per inch for PNG.
#' @param labels.cex Positive numeric survey-label size multiplier.
#' @param aggregate Logical; prefix survey labels with their groups, draw
#'   group rectangles and return the group-species summary?
#' @param aggr.Nspe Positive integer; number of species in each group summary.
#' @param n.clust Optional compatibility alias for `n_clusters`. If both are
#'   supplied they must be equal. The actual fitted groups determine the
#'   rectangles and summaries, even if stopping rules yield fewer groups.
#' @param save.file Logical; export the selected dendrogram to disk?
#' @param format Output format, `"pdf"` (default) or `"png"`.
#' @param modified Logical; use modified TWINSPAN? Default `TRUE`.
#' @param n_clusters Optional positive integer; requested number of terminal
#'   groups, passed to [ecan::twinspan()]. `NULL` leaves the stopping decision
#'   to the other native parameters (or uses `n.clust`, when supplied).
#' @param cut_levels Numeric finite non-negative pseudospecies cut levels.
#' @param min_size Positive integer; minimum group size eligible for division.
#' @param max_depth Non-negative integer; maximum division depth.
#' @param polish Native polishing method, `"hill"` (default) or `"ecan"`.
#' @param species Logical; also classify species? Default `FALSE`.
#' @param max_indicators Non-negative integer; maximum indicator pseudospecies.
#' @param diff_threshold Numeric in `(0, 1]`; native differential-species
#'   threshold, used by `polish = "ecan"`.
#' @param refine_iter Non-negative integer; native number of refinement steps,
#'   used by `polish = "ecan"`.
#' @param use_indicator Logical; native indicator-ordination option, used by
#'   `polish = "ecan"`.
#' @param downweight Logical; downweight rare pseudospecies in the ordination?
#' @param display Logical; also draw the selected dendrogram on the current
#'   device? Defaults to `!save.file`. Set both to `FALSE` for computation only.
#'
#' @details
#' The original plotting arguments are retained. Native TWINSPAN parameters
#' and `display` are appended after `format`. No precomputed fitted object
#' is accepted. A single new fit is used for the plain or grouped survey tree,
#' membership, rectangles and mean abundance summaries.
#'
#' Groups come from the newly fitted object's `classification$group`. The tree is converted
#' using ecan's own `as.hclust.twinspan` method, retrieved from its namespace,
#' so the separate package named `twinspan` cannot intercept the conversion.
#' Branches, order and heights of this new hierarchy are retained. When
#' `n_clusters` cannot be reached because of `min_size`, `max_depth` or a lack
#' of further divisions, the actual fitted groups are used throughout.
#' Heights are reverse division order, not dissimilarities or eigenvalues;
#' zero-height joins within terminal groups are graphical placeholders.
#'
#' In the aggregated dendrogram, each survey remains a separate leaf. Labels
#' are of the form `0001_Survey | Species abundance | ...`. Rectangles use
#' [dendextend::rect.dendrogram()] with `k` equal to the actual group count, `horiz = TRUE`,
#' `border = 5`, `lty = 1` and `lwd = 1`, matching the original function.
#' There is no collapse of surveys into group leaves.
#'
#' The returned group names follow the original convention: arithmetic mean
#' abundances across all group surveys (including zeros), ranked before
#' rounding, rounded to zero decimal places and formatted as `Species (12%)`.
#' Species with zero means can appear when fewer than `aggr.Nspe` species have
#' positive means. Ties follow input species order. No percentage conversion
#' is performed: use percentage abundances in `dbClust` for the `%` suffix to
#' describe their units correctly.
#'
#' @return With `aggregate = TRUE`, a data.frame with `group` and `name`, as
#'   in the original function. Attributes provide `mean.abundance` (matrix),
#'   `n.surveys` (named counts), `survey.order` (survey membership and order),
#'   `dendrogram` (species-labelled tree), `aggregate.dendrogram` (the same
#'   survey tree with group prefixes), and `files` (saved path).
#'   Attributes `twinspan`, `twinspan.parameters` and `n.clusters` contain the
#'   newly fitted ecan object, effective native argument values and actual
#'   group count. They are also attached to the non-aggregated result.
#'   With `aggregate = FALSE`, invisibly return the species-labelled survey
#'   dendrogram, with attributes `survey.order` and `files`.
#' @seealso [first_ten_species_twspn()], [denspe_twspn()], [clustOrder_twspn()]
#' @examples
#' veg <- rbind(S1 = c(9, 5, 0, 0), S2 = c(8, 4, 1, 0),
#'              S3 = c(0, 1, 5, 8), S4 = c(0, 0, 4, 7))
#' colnames(veg) <- c("Species A", "Species B", "Species C", "Species D")
#' result <- plotClustAggregate_twspn(
#'   nspePlot = 2, dbClust = veg, modified = TRUE, n_clusters = 2,
#'   cut_levels = c(0, 2, 5, 10, 20), min_size = 2, max_depth = 6,
#'   polish = "hill", species = FALSE, save.file = FALSE, display = FALSE
#' )
#' result
#' attr(result, "mean.abundance")
#' fitted <- attr(result, "twinspan")
#' clustOrder_twspn(fitted)
#' @export
plotClustAggregate_twspn <- function(
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
  modified = TRUE,
  n_clusters = NULL,
  cut_levels = c(0, 2, 5, 10, 20),
  min_size = 5,
  max_depth = 6,
  polish = "hill",
  species = FALSE,
  max_indicators = 7,
  diff_threshold = 1 / 3,
  refine_iter = 5,
  use_indicator = FALSE,
  downweight = TRUE,
  display = !save.file
) {
  if (is.null(dbClust)) {
    stop(
      "Please provide dbClust, the surveys-by-species abundance matrix.",
      call. = FALSE
    )
  }
  .twspn_flag(aggregate, "aggregate")
  .twspn_flag(save.file, "save.file")
  .twspn_flag(display, "display")
  .twspn_integer(nspePlot, "nspePlot", minimum = 0)
  .twspn_integer(aggr.Nspe, "aggr.Nspe", minimum = 1)
  for (argument in c("modified", "species", "use_indicator", "downweight")) {
    .twspn_flag(get(argument), argument)
  }
  for (argument in c("n.clust", "n_clusters")) {
    if (!is.null(get(argument))) {
      .twspn_integer(get(argument), argument, minimum = 1)
    }
  }
  if (!is.null(n.clust) && !is.null(n_clusters) && n.clust != n_clusters) {
    stop(
      "n.clust and n_clusters must specify the same target; supply only ",
      "n_clusters or give equal values.",
      call. = FALSE
    )
  }
  if (is.null(n_clusters)) {
    n_clusters <- n.clust
  }
  .twspn_integer(min_size, "min_size", minimum = 1)
  .twspn_integer(max_depth, "max_depth", minimum = 0)
  .twspn_integer(max_indicators, "max_indicators", minimum = 0)
  .twspn_integer(refine_iter, "refine_iter", minimum = 0)
  if (
    !is.numeric(cut_levels) ||
      !length(cut_levels) ||
      any(!is.finite(cut_levels)) ||
      any(cut_levels < 0)
  ) {
    stop(
      "cut_levels must be a finite non-negative numeric vector.",
      call. = FALSE
    )
  }
  if (
    !is.numeric(diff_threshold) ||
      length(diff_threshold) != 1L ||
      !is.finite(diff_threshold) ||
      diff_threshold <= 0 ||
      diff_threshold > 1
  ) {
    stop("diff_threshold must be a single number in (0, 1].", call. = FALSE)
  }
  polish <- match.arg(polish, c("hill", "ecan"))
  format <- match.arg(format, c("pdf", "png"))
  for (argument in c("file.height", "file.width", "file.res", "labels.cex")) {
    value <- get(argument)
    if (
      !is.numeric(value) ||
        length(value) != 1L ||
        !is.finite(value) ||
        value <= 0
    ) {
      stop(argument, " must be a single finite positive number.", call. = FALSE)
    }
  }
  if (
    !is.numeric(clust.mar) ||
      length(clust.mar) != 4L ||
      any(!is.finite(clust.mar)) ||
      any(clust.mar < 0)
  ) {
    stop(
      "clust.mar must contain four finite non-negative numbers.",
      call. = FALSE
    )
  }
  if (
    !is.character(file.name) ||
      length(file.name) != 1L ||
      is.na(file.name) ||
      !nzchar(file.name)
  ) {
    stop("file.name must be a single non-empty path.", call. = FALSE)
  }
  if (save.file && !dir.exists(dirname(file.name))) {
    stop(
      "The output directory does not exist: ",
      dirname(file.name),
      call. = FALSE
    )
  }
  if (save.file && tolower(tools::file_ext(file.name)) != format) {
    stop(
      "The file.name extension must match format = '",
      format,
      "'.",
      call. = FALSE
    )
  }

  x <- .twspn_matrix(dbClust, "dbClust")
  fit <- ecan::twinspan(
    x,
    modified = modified,
    n_clusters = n_clusters,
    cut_levels = cut_levels,
    min_size = min_size,
    max_depth = max_depth,
    polish = polish,
    species = species,
    max_indicators = max_indicators,
    diff_threshold = diff_threshold,
    refine_iter = refine_iter,
    use_indicator = use_indicator,
    downweight = downweight
  )
  parameters <- list(
    modified = modified,
    n_clusters = n_clusters,
    cut_levels = cut_levels,
    min_size = min_size,
    max_depth = max_depth,
    polish = polish,
    species = species,
    max_indicators = max_indicators,
    diff_threshold = diff_threshold,
    refine_iter = refine_iter,
    use_indicator = use_indicator,
    downweight = downweight
  )
  info <- .twspn_info(fit)
  groups <- clustOrder_twspn(fit)
  actual.groups <- length(unique(groups$cluster))
  if (is.null(firt10)) {
    firt10 <- first_ten_species_twspn(
      x,
      join.dendrogram = FALSE,
      n = max(10, nspePlot)
    )
  }
  labelled <- denspe_twspn(
    nspe = nspePlot,
    SpeAbund = firt10,
    dbClust = x,
    twin_ecan = fit
  )
  mapping <- attr(labelled, "survey_labels")
  hc <- info$hclust
  hc$labels <- mapping$label[match(hc$labels, mapping$Survey)]
  dend <- stats::as.dendrogram(hc)

  group.names <- NULL
  dend.aggr <- NULL
  if (aggregate) {
    group.ids <- unique(groups$cluster)
    means <- matrix(
      0,
      nrow = length(group.ids),
      ncol = ncol(x),
      dimnames = list(as.character(group.ids), colnames(x))
    )
    sizes <- stats::setNames(
      integer(length(group.ids)),
      as.character(group.ids)
    )
    description <- character(length(group.ids))
    for (i in seq_along(group.ids)) {
      ids <- groups$Survey[groups$cluster == group.ids[i]]
      sizes[i] <- length(ids)
      means[i, ] <- colMeans(x[match(ids, rownames(x)), , drop = FALSE])
      chosen <- utils::head(order(-means[i, ], seq_len(ncol(x))), aggr.Nspe)
      description[i] <- paste0(
        colnames(x)[chosen],
        " (",
        round(means[i, chosen], 0),
        "%)",
        collapse = ", "
      )
    }
    group.names <- data.frame(
      group = group.ids,
      name = description,
      stringsAsFactors = FALSE
    )
    member <- match(info$hclust$labels, groups$Survey)
    hc$labels <- paste0(
      sprintf("%04d", as.integer(as.character(groups$cluster[member]))),
      "_",
      hc$labels
    )
    dend.aggr <- stats::as.dendrogram(hc)
    attr(group.names, "mean.abundance") <- means
    attr(group.names, "n.surveys") <- sizes
    attr(group.names, "survey.order") <- groups
    attr(group.names, "dendrogram") <- dend
    attr(group.names, "aggregate.dendrogram") <- dend.aggr
  }

  draw <- function(tree, rectangles) {
    old <- graphics::par(mfrow = c(1, 1), mar = clust.mar)
    on.exit(graphics::par(old), add = TRUE)
    tree <- stats::dendrapply(tree, function(node) {
      if (stats::is.leaf(node)) {
        attr(node, "nodePar") <- list(lab.cex = labels.cex, pch = NA)
      }
      node
    })
    graphics::plot(tree, horiz = TRUE, cex = labels.cex)
    if (rectangles && actual.groups > 1L) {
      dendextend::rect.dendrogram(
        tree,
        k = actual.groups,
        horiz = TRUE,
        border = 5,
        lty = 1,
        lwd = 1
      )
    } else if (rectangles) {
      # dendextend::rect.dendrogram() requires at least two clusters.
      extent <- max(abs(graphics::strwidth(labels(tree), cex = labels.cex)))
      graphics::rect(
        xleft = attr(tree, "height"),
        ybottom = 0.66,
        xright = -extent * 1.05,
        ytop = length(labels(tree)) + 0.33,
        border = 5,
        lty = 1,
        lwd = 1,
        xpd = TRUE
      )
    }
    invisible(NULL)
  }
  open.device <- function(path) {
    if (format == "pdf") {
      grDevices::pdf(file = path, height = file.height, width = file.width)
    } else {
      grDevices::png(
        filename = path,
        height = file.height,
        width = file.width,
        units = "in",
        res = file.res
      )
    }
  }
  selected <- if (aggregate) dend.aggr else dend
  files <- character(0)
  if (save.file) {
    path <- if (aggregate) {
      file.path(dirname(file.name), paste0("aggregate_", basename(file.name)))
    } else {
      file.name
    }
    open.device(path)
    device <- grDevices::dev.cur()
    tryCatch(
      draw(selected, aggregate),
      finally = grDevices::dev.off(which = device)
    )
    files <- stats::setNames(
      normalizePath(path, winslash = "/", mustWork = TRUE),
      if (aggregate) "aggregate" else "surveys"
    )
  }
  if (display) {
    draw(selected, aggregate)
  }
  if (aggregate) {
    attr(group.names, "files") <- files
    attr(group.names, "twinspan") <- fit
    attr(group.names, "twinspan.parameters") <- parameters
    attr(group.names, "n.clusters") <- actual.groups
    return(group.names)
  }
  attr(dend, "survey.order") <- groups
  attr(dend, "files") <- files
  attr(dend, "twinspan") <- fit
  attr(dend, "twinspan.parameters") <- parameters
  attr(dend, "n.clusters") <- actual.groups
  invisible(dend)
}
