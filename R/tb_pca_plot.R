## Exploratory tb-PCA ----

# ===
# FUNCTION: tb_pca_plot()
# ===
#
# DESCRIPTION
# Performs a transformation-based principal component analysis (tb-PCA)
# on a vegetation matrix using Hellinger or chord transformation,
# implemented with vegan::decostand() and vegan::rda().
#
# Produces two ggplot2 plots:
# 1. Site ordination, with sites coloured by cluster membership and
#    optional convex hulls or ellipses.
# 2. Species ordination, displaying selected species scores and labels,
#    chosen using ordiselect, IndVal, or Phi.
#
# The same group colours are used in both plots.
#
# USAGE
#
# tb_pca_plot(
#   veg,
#   groups,
#   transformation = "hellinger",
#   axes = c(1, 2),
#   area = "hull",
#   species = "ordiselect",
#   indval = NULL,
#   phi = NULL,
#   alpha = 0.05,
#   ablim = 0.4,
#   fitlim = 0.5,
#   freq = FALSE,
#   label_groups = FALSE,
#   segment.alpha_labelSpe = 0.3,
#   segment.size_labelSpe = 0.3
# )
#
# ARGUMENTS
#
# veg       : Vegetation matrix with sites in rows and species in columns.
#             Site IDs must be supplied as row names. Non-negative
#             numeric cover or abundance values are accepted.
#
# groups    : Data frame with two columns:
#             - stand: site identifier;
#             - group: cluster membership (e.g. G1, G2, G3).
#             Site order is automatically matched to veg.
#
# transformation : "hellinger" (default) or "chord". The chord option
#                  uses vegan::decostand(method = "normalize").
#
# axes      : Two principal components to display (default c(1, 2)),
#             for example c(1, 3) or c(2, 3).
#
# area      : Group display in the site plot:
#             "hull"    = convex hull (default);
#             "ellipse" = 95% normal-data ellipses;
#             "none"    = points only.
#             Groups with too few observations are not outlined.
#
# species   : Method for selecting species to display:
#             "ordiselect" = abundance/frequency and ordination scores;
#             "indval"     = significant indicator species (IndVal);
#             "phi"        = significant diagnostic species (Phi).
#
# indval    : Full result of indicspecies::multipatt() for IndVal;
#             required when species = "indval".
#
# phi       : Full result of indicspecies::multipatt(), calculated with
#             func = "r.g" for Phi; required when species = "phi".
#
# alpha     : Significance threshold for IndVal/Phi (default 0.05),
#             using the p-values from the supplied multipatt object.
#
# ablim     : Proportion of the most abundant species considered by
#             ordiselect (default 0.4, i.e. 40%).
#
# fitlim    : Proportion of species with the largest absolute scores
#             on the selected axes (default 0.5, i.e. 50%).
#
# freq      : If TRUE, ordiselect uses species frequency instead of
#             abundance (default FALSE).
#
# label_groups : If TRUE, labels group centroids on the site plot and
#                appends the group to each species label (default FALSE).
#
# segment.alpha_labelSpe : Transparency of label connector segments
#                          in the species plot (default 0.3).
#
# segment.size_labelSpe  : Width of label connector segments in the
#                          species plot (default 0.3).
#
# SPECIES COLOURS
#
# - IndVal/Phi: colour of the group to which the species is significantly
#   associated.
# - ordiselect: colour of the group with the highest mean species cover;
#   this is a descriptive rather than a statistical criterion.
#
# RETURN VALUE
#
# The function returns a list containing:
#
# $pca              : PCA object produced by vegan::rda().
# $plot_sites       : ggplot2 object showing site ordination.
# $plot_species     : ggplot2 object showing species ordination.
# $sites            : PCA site coordinates and group membership.
# $species          : PCA coordinates of the selected species.
# $selected_species : Character vector of selected species.
# $variance         : Explained variance (%) for each PCA axis.
#
# EXAMPLES
#
# 1. PCA with convex hulls and ordiselect species selection:
# res <- tb_pca_plot(
#   veg = veg,
#   groups = groups,
#   axes = c(1, 2),
#   area = "hull",
#   species = "ordiselect"
# )
#
# 2. PCA with ellipses and IndVal indicator species:
# res <- tb_pca_plot(
#   veg = veg,
#   groups = groups,
#   axes = c(1, 2),
#   area = "ellipse",
#   species = "indval",
#   indval = indval
# )
#
# 3. PCA with convex hulls and Phi diagnostic species:
# res <- tb_pca_plot(
#   veg = veg,
#   groups = groups,
#   axes = c(1, 3),
#   area = "hull",
#   species = "phi",
#   phi = phi
# )
#
# ACCESSING RESULTS
# res$plot_sites
# res$plot_species
# res$selected_species
# res$variance
#
# METHODOLOGICAL NOTES
#
# - PCA is applied to Hellinger- or chord-transformed vegetation data.
# - Ordination scores are extracted with scaling = 2.
# - Groups originate from a previously performed classification
#   (e.g. TWINSPAN or hierarchical clustering).
# - IndVal and Phi must be calculated separately with multipatt().
# - IndVal/Phi selection retains only significant single-group
#   associations (as with duleg = TRUE).
# - No correction for multiple testing is applied by this function.
# - Ellipses describe site dispersion, not confidence intervals
#   for group centroids.
# - Species arrows are not drawn because the geom_segment()
#   block in the supplied function is commented out.
#
# REQUIRED PACKAGES
# vegan, ggplot2, ggrepel, goeveg, scales;
# indicspecies for generating the optional multipatt inputs.
#
#' Exploratory transformation-based PCA of vegetation communities
#'
#' @md
#' @description
#' Performs an unconstrained principal component analysis (PCA) on a
#' Hellinger- or chord-transformed vegetation matrix. Produces coordinated
#' ordination plots of sites and selected species, coloured according to
#' previously defined vegetation groups.
#'
#' @details
#' The vegetation matrix must contain sites (releves) in rows and species
#' in columns, with non-negative numeric values and unique site row names.
#' The `groups` data frame must have columns `stand` and `group`, and its
#' site identifiers must match those in `veg`. Group order is matched to
#' the vegetation matrix automatically. At least two groups and no empty
#' sites are required; species absent from every site are removed.
#'
#' For `transformation = "hellinger"`, the data are transformed using
#' `vegan::decostand(method = "hellinger")`. With `"chord"`, the function
#' uses `vegan::decostand(method = "normalize", MARGIN = 1)`. Unconstrained
#' PCA is then performed using `vegan::rda()`; site and species scores
#' are extracted with `scaling = 2`.
#'
#' Site groups can be displayed as convex hulls (`area = "hull"`),
#' 95-percent normal-data ellipses (`"ellipse"`), or points alone
#' (`"none"`). Hulls require at least three non-collinear observations
#' per group, whereas ellipses require at least four non-collinear
#' observations. Ellipses describe the spread of sites and are not
#' confidence intervals for group centroids.
#'
#' Three species-selection methods are available:
#' \itemize{
#'   \item `"ordiselect"`: selects species using `goeveg::ordiselect()`
#'     with `ablim`, `fitlim`, and `freq`. Species are coloured by the
#'     group with the highest mean cover, a descriptive criterion.
#'   \item `"indval"`: uses significant single-group associations from
#'     a previously computed `indicspecies::multipatt()` result.
#'   \item `"phi"`: uses significant single-group associations from
#'     a previously computed `multipatt()` result (typically with
#'     `func = "r.g"`).
#' }
#' For `"indval"` and `"phi"`, the supplied `multipatt` object must
#' contain the same ordered site-group assignments as the PCA input.
#' Species are selected by `p.value <= alpha` and membership of exactly
#' one group; the function does not apply a separate minimum Phi cutoff
#' or adjust p-values for multiple testing.
#'
#' When `label_groups = TRUE`, group labels are added at site centroids
#' and appended to species labels. Species are displayed as text labels
#' with optional label connector segments; the species-arrow drawing
#' code is commented out in this implementation.
#'
#' @param veg Numeric matrix or data frame with sites in rows and species
#'   in columns. Must have site row names, non-negative values, and no NA.
#' @param groups Data frame containing `stand` (site identifier) and
#'   `group` (group membership). Every site in `veg` must appear exactly
#'   once in `groups`.
#' @param transformation Character string; `"hellinger"` (default) or
#'   `"chord"`.
#' @param axes Integer vector of length two specifying distinct PCA axes
#'   to plot; defaults to `c(1, 2)`.
#' @param area Character string indicating group envelopes for the site
#'   plot: `"hull"` (default), `"ellipse"`, or `"none"`.
#' @param species Character string specifying species selection:
#'   `"ordiselect"` (default), `"indval"`, or `"phi"`.
#' @param indval Complete `indicspecies::multipatt()` result for IndVal
#'   selection; required when `species = "indval"`.
#' @param phi Complete `indicspecies::multipatt()` result for Phi-type
#'   selection (typically `func = "r.g"`); required when
#'   `species = "phi"`.
#' @param alpha Numeric significance threshold for selecting species
#'   from `indval` or `phi`; default `0.05`.
#' @param ablim Proportion of most abundant species considered by
#'   `goeveg::ordiselect()`; default `0.4`.
#' @param fitlim Proportion of species retained based on their ordination
#'   scores by `goeveg::ordiselect()`; default `0.5`.
#' @param freq Logical; if `TRUE`, `ordiselect` uses species frequencies
#'   rather than abundances; default `FALSE`.
#' @param label_groups Logical; if `TRUE`, displays group-centroid labels
#'   on the site plot and adds group IDs to species labels; default `FALSE`.
#' @param segment.alpha_labelSpe Numeric transparency of the label
#'   connector segments in the species plot; default `0.3`.
#' @param segment.size_labelSpe Numeric line width of the label connector
#'   segments in the species plot; default `0.3`.
#'
#' @return
#' A list with the following elements:
#' \describe{
#'   \item{pca}{PCA object returned by `vegan::rda()`.}
#'   \item{plot_sites}{`ggplot2` plot of the site ordination.}
#'   \item{plot_species}{`ggplot2` plot of selected species scores.}
#'   \item{sites}{Data frame with site IDs, plot coordinates, and groups.}
#'   \item{species}{Data frame with selected species, plot coordinates,
#'     and assigned groups.}
#'   \item{selected_species}{Character vector of selected species names.}
#'   \item{variance}{Numeric vector of variance explained by each PCA
#'     axis, expressed as a percentage.}
#' }
#'
#' @references
#' Legendre, P. & Gallagher, E. D. (2001). Ecologically meaningful
#' transformations for ordination of species data. Oecologia, 129,
#' 271-280. https://doi.org/10.1007/s004420100716
#'
#' @seealso
#' [vegan::decostand()], [vegan::rda()], [vegan::scores()],
#' [goeveg::ordiselect()], [indicspecies::multipatt()]
#'
#' @examples
#' \dontrun{
#' data("dune", package = "vegan")
#' data("dune.env", package = "vegan")
#'
#' # Create a group-membership table, matching the vegetation matrix
#' site_groups <- data.frame(
#'   stand = rownames(dune),
#'   group = as.character(dune.env$Management)
#' )
#'
#' # Hellinger PCA with convex hulls and ordiselect
#' res <- tb_pca_plot(
#'   veg = dune,
#'   groups = site_groups,
#'   transformation = "hellinger",
#'   area = "hull",
#'   species = "ordiselect"
#' )
#' print(res$plot_sites)
#' print(res$plot_species)
#' res$selected_species
#'
#' # Alternative chord transformation with group labels
#' res_chord <- tb_pca_plot(
#'   veg = dune,
#'   groups = site_groups,
#'   transformation = "chord",
#'   area = "none",
#'   label_groups = TRUE
#' )
#'
#' # Previously computed IndVal indicators
#' set.seed(123)
#' mp_indval <- indicspecies::multipatt(
#'   (dune > 0) * 1,
#'   site_groups$group,
#'   duleg = TRUE,
#'   control = permute::how(nperm = 999)
#' )
#' res_indval <- tb_pca_plot(
#'   veg = dune,
#'   groups = site_groups,
#'   species = "indval",
#'   indval = mp_indval
#' )
#' }
#'
#' @export

tb_pca_plot <- function(
  veg,
  groups,
  transformation = c("hellinger", "chord"),
  axes = c(1, 2),
  area = c("hull", "ellipse", "none"),
  species = c("ordiselect", "indval", "phi"),
  indval = NULL,
  phi = NULL,
  alpha = 0.05,
  ablim = 0.4,
  fitlim = 0.5,
  freq = FALSE,
  label_groups = FALSE,
  segment.alpha_labelSpe = 0.3, # Segment transparency (0-1)
  segment.size_labelSpe = 0.3 # Segment line width
) {
  transformation <- match.arg(transformation)
  area <- match.arg(area)
  species <- match.arg(species)

  # 1. Data preparation

  veg <- as.matrix(veg)

  if (
    is.null(rownames(veg)) ||
      !all(c("stand", "group") %in% names(groups)) ||
      anyDuplicated(groups$stand) ||
      !setequal(rownames(veg), as.character(groups$stand))
  ) {
    stop("Controllare la corrispondenza tra rilievi e groups.")
  }

  if (!is.numeric(veg) || anyNA(veg) || any(veg < 0)) {
    stop("veg deve contenere valori numerici >= 0, senza NA.")
  }

  # Align groups with the vegetation matrix
  gr <- factor(as.character(
    groups$group[match(rownames(veg), groups$stand)]
  ))

  if (anyNA(gr) || nlevels(gr) < 2) {
    stop("Servono almeno due gruppi, senza valori NA.")
  }

  if (any(rowSums(veg) == 0)) {
    stop("Sono presenti rilievi senza specie.")
  }

  # Remove species absent from all sites
  veg <- veg[, colSums(veg) > 0, drop = FALSE]

  # 2. Transformed PCA

  method <- switch(
    transformation,
    hellinger = "hellinger",
    chord = "normalize"
  )

  veg_hel <- vegan::decostand(
    veg,
    method = method,
    MARGIN = 1
  )
  pca <- vegan::rda(veg_hel)

  eig <- vegan::eigenvals(pca)
  variance <- 100 * eig / sum(eig)

  if (
    length(axes) != 2 ||
      anyNA(axes) ||
      any(axes < 1) ||
      any(axes != as.integer(axes)) ||
      any(axes > length(eig)) ||
      axes[1] == axes[2]
  ) {
    stop("Specificare due assi PCA validi e diversi.")
  }

  # Use consistent colours in both plots
  cols <- setNames(
    scales::hue_pal()(nlevels(gr)),
    levels(gr)
  )

  xlab <- paste0("PC", axes[1], " (", round(variance[axes[1]], 1), "%)")
  ylab <- paste0("PC", axes[2], " (", round(variance[axes[2]], 1), "%)")

  # 3. Site scores

  sc_sites <- vegan::scores(
    pca,
    display = "sites",
    choices = axes,
    scaling = 2
  )

  sites <- data.frame(
    stand = rownames(sc_sites),
    x = sc_sites[, 1],
    y = sc_sites[, 2],
    group = gr
  )

  p1 <- ggplot2::ggplot(
    sites,
    ggplot2::aes(x, y)
  ) +
    ggplot2::geom_hline(
      yintercept = 0,
      colour = "grey85"
    ) +
    ggplot2::geom_vline(
      xintercept = 0,
      colour = "grey85"
    )

  # Convex hull
  if (area == "hull") {
    hulls <- do.call(
      rbind,
      lapply(
        split(sites, sites$group),
        function(d) {
          if (
            nrow(d) < 3 ||
              qr(cbind(d$x, d$y))$rank < 2
          ) {
            return(NULL)
          }
          d[chull(d$x, d$y), , drop = FALSE]
        }
      )
    )

    if (!is.null(hulls)) {
      p1 <- p1 +
        ggplot2::geom_polygon(
          data = hulls,
          ggplot2::aes(fill = group, colour = group, group = group),
          alpha = 0.15,
          linewidth = 0.6
        )
    }
  }

  # 95% ellipses
  if (area == "ellipse") {
    valid <- names(Filter(
      function(d) {
        nrow(d) >= 4 &&
          qr(cbind(d$x, d$y))$rank == 2
      },
      split(sites, sites$group)
    ))

    if (length(valid) > 0) {
      p1 <- p1 +
        ggplot2::stat_ellipse(
          data = sites[sites$group %in% valid, ],
          ggplot2::aes(colour = group),
          type = "norm",
          level = 0.95,
          linewidth = 0.7
        )
    }
  }

  p1 <- p1 +
    ggplot2::geom_point(
      ggplot2::aes(colour = group),
      size = 3,
      alpha = 0.9
    ) +
    ggplot2::scale_colour_manual(values = cols) +
    ggplot2::scale_fill_manual(values = cols, guide = "none") +
    ggplot2::coord_equal() +
    ggplot2::labs(
      x = xlab,
      y = ylab,
      colour = "Group",
      title = paste(transformation, " tb PCA - Sites")
    ) +
    ggplot2::theme_classic(base_size = 13)

  # Group labels at site centroids
  if (label_groups) {
    centroids <- aggregate(
      cbind(x, y) ~ group,
      data = sites,
      FUN = mean
    )

    p1 <- p1 +
      ggrepel::geom_label_repel(
        data = centroids,
        ggplot2::aes(
          x = x,
          y = y,
          label = group,
          colour = group
        ),
        inherit.aes = FALSE,
        fontface = "bold",
        size = 4,
        fill = "white",
        show.legend = FALSE,
        max.overlaps = Inf
      )
  }

  # 4. Species selection

  if (species == "ordiselect") {
    selected <- goeveg::ordiselect(
      veg_hel,
      pca,
      choices = axes,
      ablim = ablim,
      fitlim = fitlim,
      freq = freq
    )

    # Group with the highest mean cover
    means <- sapply(levels(gr), function(g) {
      colMeans(veg[gr == g, , drop = FALSE])
    })

    sp_groups <- setNames(
      levels(gr)[max.col(means, ties.method = "first")],
      rownames(means)
    )
  } else {
    mp <- if (species == "indval") indval else phi

    if (is.null(mp) || is.null(mp$sign)) {
      stop("Fornire l'oggetto multipatt richiesto.")
    }

    if (
      length(mp$cluster) != nrow(veg) ||
        !identical(as.character(mp$cluster), as.character(gr))
    ) {
      stop("I gruppi di multipatt non corrispondono a groups.")
    }

    tab <- mp$sign

    # Group columns in the multipatt object
    group_cols <- paste0("s.", levels(gr))

    if (!all(group_cols %in% colnames(tab))) {
      stop("I gruppi non coincidono con quelli di multipatt.")
    }

    # Select significant species
    tab <- tab[
      !is.na(tab$p.value) & tab$p.value <= alpha,
      ,
      drop = FALSE
    ]

    # Retain single-group associations only
    tab <- tab[
      rowSums(tab[, group_cols, drop = FALSE]) == 1,
      ,
      drop = FALSE
    ]

    selected <- rownames(tab)

    sp_groups <- setNames(
      levels(gr)[max.col(
        as.matrix(tab[, group_cols, drop = FALSE]),
        ties.method = "first"
      )],
      selected
    )
  }

  # 5. Species scores

  sc_sp <- vegan::scores(
    pca,
    display = "species",
    choices = axes,
    scaling = 2
  )

  selected <- intersect(selected, rownames(sc_sp))

  sp <- data.frame(
    species = selected,
    x = sc_sp[selected, 1],
    y = sc_sp[selected, 2],
    group = factor(
      sp_groups[selected],
      levels = levels(gr)
    )
  )

  # Species labels with optional group IDs
  sp_labels <- if (label_groups) {
    paste0(sp$species, " [", sp$group, "]")
  } else {
    sp$species
  }

  # 6. Species plot

  p2 <- ggplot2::ggplot(sp, ggplot2::aes(x, y)) +
    ggplot2::geom_hline(
      yintercept = 0,
      colour = "grey85"
    ) +
    ggplot2::geom_vline(
      xintercept = 0,
      colour = "grey85"
    ) +
    ggplot2::scale_colour_manual(values = cols) +
    ggplot2::coord_equal() +
    ggplot2::labs(
      x = xlab,
      y = ylab,
      colour = "Group",
      title = paste(transformation, " tb PCA - Species:", species)
    ) +
    ggplot2::theme_classic(base_size = 13)

  if (nrow(sp) > 0) {
    p2 <- p2 +
      # ggplot2::geom_segment(
      #   ggplot2::aes(
      #     x = 0, y = 0,
      #     xend = x, yend = y,
      #     colour = group
      #   ),
      #   arrow = grid::arrow(
      #     length = grid::unit(0.15, "cm")
      #   ),
      #   linewidth = 0.5
      # ) +
      ggrepel::geom_text_repel(
        ggplot2::aes(
          label = sp_labels,
          colour = group
        ),
        size = 3.5,
        segment.alpha = segment.alpha_labelSpe, # Segment transparency (0-1)
        segment.size = segment.size_labelSpe, # Segment line width
        max.overlaps = Inf
      )
  } else {
    warning("Nessuna specie soddisfa i criteri selezionati.")
  }

  # 7. Output

  list(
    pca = pca,
    plot_sites = p1,
    plot_species = p2,
    sites = sites,
    species = sp,
    selected_species = selected,
    variance = variance
  )
}
