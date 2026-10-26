## Modified TWINSPAN + OptimClass 1 and 2 ----

# ===
# twinspan_optimclass_ecan()
# ===
#
# DESCRIPTION
#   Determines the optimal number of vegetation clusters using
#   Modified TWINSPAN (ecan package) and OptimClass 1 and 2.
#
#   The function generates several TWINSPAN partitions (k clusters),
#   evaluates species fidelity using a one-sided Fisher's exact test
#   (alternative = "greater"), and identifies the partitions that
#   maximize OptimClass 1 and OptimClass 2.
#
# USAGE
#   res <- twinspan_optimclass_ecan(
#     veg,
#     cut_levels = c(0, 2, 5, 10, 20),
#     min_size = 5,
#     k_values = 2:20,
#     p_threshold = 0.05,
#     min_faithful = 3,
#     version = "fast",
#     select_by = "optimclass1",
#     show_plots = TRUE
#   )
#
# ARGUMENTS
#   veg           Vegetation matrix with relevés in rows (rownames)
#                 and species in columns (colnames).
#                 Values represent species cover; 0 indicates absence.
#
#   cut_levels    Cover thresholds used for TWINSPAN pseudospecies.
#                 Default: c(0, 2, 5, 10, 20).
#
#   min_size      Minimum TWINSPAN group size.
#                 Default: 5 relevés.
#
#   k_values      Numbers of clusters to compare.
#                 Default: 2:20.
#                 Unavailable partitions are excluded.
#
#   p_threshold   Fisher's exact test significance threshold for
#                 identifying faithful species.
#                 Default: 0.05.
#
#   min_faithful  Minimum number of faithful species required for a
#                 cluster to count under OptimClass 2.
#                 Default: 3.
#
#   version       Method for calculating species fidelity:
#                 "fast"     = hypergeometric distribution (phyper).
#                 "original" = fisher.test, following Monteiro-Henriques (2025).
#                 Both perform a one-sided exact test.
#
#   select_by     Criterion used to select the final partition:
#                 "optimclass1" or "optimclass2".
#                 Default: "optimclass1".
#
#   show_plots    TRUE = display OptimClass 1 and 2 plots.
#                 FALSE = do not display the plots.
#
# OPTIMIZATION CRITERIA
#   OptimClass 1:
#     Total number of species significantly faithful to at least
#     one cluster. Each species is counted once, even if it is
#     significant for multiple clusters.
#     The selected k maximizes this count.
#
#   OptimClass 2:
#     Number of clusters with at least min_faithful significantly
#     faithful species.
#     The selected k maximizes this count.
#
#   In the event of ties, all optimal k values are retained in
#   res$best_k; the smallest k according to select_by is used
#   for the final classification.
#
# OUTPUT
#   res$results
#     Table containing k, OptimClass 1, OptimClass 2, proportion of
#     qualifying clusters, minimum cluster size, and indicators
#     of optimal partitions.
#
#   res$best_k
#     Optimal numbers of clusters for both criteria:
#       res$best_k$optimclass1
#       res$best_k$optimclass2
#
#   res$selected_k
#     Number of clusters in the selected final partition.
#
#   res$selected_by
#     Criterion used to select the final partition.
#
#   res$classification
#     Data frame with relevé identifiers and TWINSPAN clusters for
#     the k selected using select_by.
#
#   res$classification_all
#     Relevé classifications for all valid k values.
#
#   res$partitions
#     List of cluster membership vectors for each k.
#
#   res$faithful_species
#     Faithful species in the selected partition, with associated
#     cluster and Fisher's exact test p-value.
#
#   res$faithful_species_all
#     Faithful species from all evaluated partitions.
#
#   res$faithful_by_group
#     List of faithful species for each selected cluster.
#
#   res$fidelity
#     Species-by-cluster matrices of p-values, significant fidelity
#     (TRUE/FALSE), and numbers of faithful species per cluster.
#
#   res$plots$optimclass1
#   res$plots$optimclass2
#     Plots of OptimClass scores against the number of clusters.
#
#   res$failed_k
#     Values of k for which TWINSPAN could not produce a valid partition.
#
#   res$settings
#     Parameter values used in the analysis.
#
# EXAMPLES
#
#   # Complete analysis
#   res <- twinspan_optimclass_ecan(veg, version = "fast")
#
#   # Compare both methods
#   res$results
#   res$best_k
#
#   # Selected number of clusters
#   res$selected_k
#
#   # Cluster membership for each relevé
#   res$classification
#
#   # Faithful species in the selected classification
#   res$faithful_species
#   res$faithful_by_group
#
#   # Optimal classification according to OptimClass 2
#   k2 <- min(res$best_k$optimclass2)
#   subset(res$classification_all, k == k2)
#
#   # Faithful species in a specific partition (e.g., k = 7)
#   subset(res$faithful_species_all, k == 7)
#
#   # Display the plots again
#   print(res$plots$optimclass1)
#   print(res$plots$optimclass2)
#
# METHODOLOGICAL NOTES
#   - TWINSPAN uses cover values through pseudospecies.
#   - OptimClass uses the species presence/absence matrix.
#   - Faithful species are identified using statistical significance
#     (Fisher's exact test), not the Phi coefficient.
#   - OptimClass 1 and 2 may select different numbers of clusters.
#   - The optimal number is conditional on the k values evaluated.
#   - Final selection should also consider the ecological and
#     syntaxonomic interpretability of the resulting communities.
#
# REFERENCES
#   Tichy et al. (2010).
#   OptimClass: Using species-to-cluster fidelity to determine the
#   optimal partition in classification of ecological communities.
#   Journal of Vegetation Science.
#
#   Monteiro-Henriques (2025).
#   TDV-optimization: A novel numerical method for
#   phytosociological tabulation.
#   Vegetation Classification and Survey.
#   Supplementary Material 1:
#   https://doi.org/10.3897/VCS.140466.suppl1
#
#' Select Vegetation Clusters Using Modified TWINSPAN and OptimClass
#'
#' @md
#' @description
#' Generates vegetation partitions using Modified TWINSPAN and selects
#' the number of clusters according to OptimClass 1 or OptimClass 2,
#' based on statistically significant species-to-cluster fidelity.
#'
#' @param veg A numeric vegetation matrix or data frame, with relevés
#'   (sampling plots) in rows and species in columns. Row names and column
#'   names must be present, non-empty, and unique. Values must be finite,
#'   non-negative, and free of missing values; zero indicates species absence.
#' @param cut_levels Numeric vector of cover cut levels for TWINSPAN
#'   pseudospecies. Default is `c(0, 2, 5, 10, 20)`.
#' @param min_size Positive integer specifying the minimum cluster size
#'   passed to `ecan::twinspan()`. Default is `5` relevés.
#' @param k_values Integer vector of cluster numbers to evaluate.
#'   Default is `2:20`. Values not yielding valid partitions are excluded.
#' @param p_threshold Fisher's exact test significance threshold used to
#'   identify faithful species. Must be strictly between 0 and 1.
#'   Default is `0.05`.
#' @param min_faithful Positive integer specifying the minimum number of
#'   faithful species required for a cluster to contribute to OptimClass 2.
#'   Default is `3`.
#' @param version Fidelity computation method. `"fast"` uses the upper
#'   tail of the hypergeometric distribution with [stats::phyper()];
#'   `"original"` uses [stats::fisher.test()]. Both implement an equivalent
#'   one-sided Fisher exact test (`alternative = "greater"`).
#'   Default is `"fast"`. Code from Monteiro-Henrique. (2025)
#' @param select_by Selection criterion for the final partition:
#'   `"optimclass1"` (default) or `"optimclass2"`.
#' @param show_plots Logical; whether to print both OptimClass plots.
#'   Default is `TRUE`.
#'
#' @details
#' The function performs Modified TWINSPAN with [ecan::twinspan()]
#' for every candidate number of clusters in `k_values`. Species cover
#' values are used by TWINSPAN, while species fidelity is evaluated on
#' a presence/absence matrix derived from `veg`.
#'
#' For each species and each cluster, fidelity is assessed using a
#' one-sided Fisher exact test against all other clusters. Species with
#' a p-value less than or equal to `p_threshold` are counted as faithful.
#' This function uses p-values rather than the standardized Phi coefficient.
#' It does not apply multiple-testing correction.
#'
#' **OptimClass 1** is the number of unique species that are significantly
#' faithful to at least one cluster. **OptimClass 2** is the number of
#' clusters containing at least `min_faithful` significantly faithful
#' species. Each criterion is maximized separately.
#'
#' All tied optimal values of `k` are retained in `best_k`. For the
#' final classification, the smallest optimal `k` is chosen under
#' `select_by`. The number of clusters is optimal only with respect
#' to the candidate partitions and the chosen fidelity threshold;
#' ecological and syntaxonomic validation remains necessary.
#'
#' The function relies on `ecan` for Modified TWINSPAN and `ggplot2`
#' for plotting. Their namespaces must be available.
#'
#' @return A named list containing:
#' * `results`: Data frame summarizing each valid `k`: OptimClass 1
#'     (`optimclass1`), OptimClass 2 (`optimclass2`), proportion of
#'     qualifying clusters (`prop_good_clusters`), minimum group size
#'     (`min_group_size`), and optimum indicators (`best_optim1`,
#'     `best_optim2`).
#' * `best_k`: List of all optimal k values under `optimclass1`
#'     and `optimclass2`, including ties.
#' * `selected_k`: Number of clusters selected for the final partition.
#' * `selected_by`: Criterion used for final selection.
#' * `classification`: Data frame with `stand` and `group` columns
#'     for the selected partition.
#' * `classification_all`: Data frame with `k`, `stand`, and `group`
#'     for every valid partition.
#' * `partitions`: List of named cluster membership vectors for each k.
#' * `faithful_species`: Table of significant species-cluster
#'     associations in the selected partition (`k`, `group`, `species`,
#'     `p_value`).
#' * `faithful_species_all`: Table of significant species-cluster
#'     associations across all valid partitions.
#' * `faithful_by_group`: Named list of faithful species for each
#'     selected cluster.
#' * `fidelity`: Per-partition matrices `p_values` and `faithful`
#'     (species by cluster), plus `faithful_per_group` counts.
#' * `plots`: List with `optimclass1` and `optimclass2` ggplot objects.
#' * `failed_k`: Candidate values of k without a valid partition.
#' * `settings`: List of parameters used for the analysis.
#'
#'
#' @references
#' Roleček, J., Tichý, L., Zelený, D., & Chytrý, M. (2009).
#' Modified TWINSPAN classification in which the hierarchy respects cluster
#' heterogeneity. *Journal of Vegetation Science*, 20, 596–602.
#' \doi{10.1111/j.1654-1103.2009.01062.x}
#'
#' Tichý, L., Chytrý, M., Hájek, M., Talbot, S. S., & Botta-Dukát, Z. (2010).
#' OptimClass: Using species-to-cluster fidelity to determine the optimal
#' partition in classification of ecological communities.
#' *Journal of Vegetation Science*, 21, 287–299.
#' \doi{10.1111/j.1654-1103.2009.01143.x}
#'
#' Monteiro-Henriques, T. (2025). TDV-optimization: A novel numerical method
#' for phytosociological tabulation. *Vegetation Classification and Survey*,
#' 6, 99–127. \doi{10.3897/VCS.140466}
#'
#' @seealso [ecan::twinspan()], [stats::fisher.test()], [stats::phyper()]
#'
#' @examples
#' \dontrun{
#' # Vegetation matrix: relevés in rows, species in columns
#' data("dune", package = "vegan")
#'
#' res <- twinspan_optimclass_ecan(
#'   dune,
#'   k_values = 2:10,
#'   min_size = 2,
#'   select_by = "optimclass1",
#'   show_plots = FALSE
#' )
#'
#' res$best_k
#' res$selected_k
#' head(res$classification)
#' head(res$faithful_species)
#' res$plots$optimclass1
#' res$plots$optimclass2
#'
#' # Partition chosen using OptimClass 2
#' k2 <- min(res$best_k$optimclass2)
#' subset(res$classification_all, k == k2)
#' }
#'
#' @export

twinspan_optimclass_ecan <- function(
  veg,
  cut_levels = c(0, 2, 5, 10, 20),
  min_size = 5,
  k_values = 2:20,
  p_threshold = 0.05,
  min_faithful = 3,
  version = c("fast", "original"),
  select_by = c("optimclass1", "optimclass2"),
  show_plots = TRUE
) {
  version <- match.arg(version)
  select_by <- match.arg(select_by)

  # ===
  # 1. INPUT VALIDATION
  # ===

  if (!requireNamespace("ecan", quietly = TRUE)) {
    stop("Install the 'ecan' package.")
  }

  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Install the 'ggplot2' package.")
  }

  veg <- as.matrix(veg)

  if (!is.numeric(veg) || anyNA(veg) || any(!is.finite(veg)) || any(veg < 0)) {
    stop("veg must be a numeric matrix with no NA values and all values >= 0.")
  }

  if (
    is.null(rownames(veg)) ||
      is.null(colnames(veg)) ||
      anyNA(rownames(veg)) ||
      anyNA(colnames(veg)) ||
      any(!nzchar(rownames(veg))) ||
      any(!nzchar(colnames(veg))) ||
      anyDuplicated(rownames(veg)) ||
      anyDuplicated(colnames(veg))
  ) {
    stop("Unique names are required for relevés (rows) and species (columns).")
  }

  if (nrow(veg) < 2 || ncol(veg) < 1) {
    stop("The matrix must contain at least 2 relevés and 1 species.")
  }

  if (any(rowSums(veg > 0) == 0)) {
    stop("Some relevés contain no species.")
  }

  if (
    length(min_size) != 1 ||
      !is.finite(min_size) ||
      min_size < 1 ||
      min_size != as.integer(min_size)
  ) {
    stop("min_size must be a positive integer.")
  }

  if (
    length(min_faithful) != 1 ||
      !is.finite(min_faithful) ||
      min_faithful < 1 ||
      min_faithful != as.integer(min_faithful)
  ) {
    stop("min_faithful must be a positive integer.")
  }

  if (
    length(p_threshold) != 1 ||
      !is.finite(p_threshold) ||
      p_threshold <= 0 ||
      p_threshold >= 1
  ) {
    stop("p_threshold must be between 0 and 1.")
  }

  if (
    !is.numeric(k_values) ||
      !length(k_values) ||
      anyNA(k_values) ||
      any(!is.finite(k_values)) ||
      any(k_values < 2) ||
      any(k_values != floor(k_values))
  ) {
    stop("k_values must contain integers >= 2.")
  }

  if (
    !is.numeric(cut_levels) ||
      !length(cut_levels) ||
      anyNA(cut_levels) ||
      any(!is.finite(cut_levels)) ||
      any(cut_levels < 0)
  ) {
    stop("cut_levels must contain non-negative numeric values.")
  }

  k_values <- sort(unique(as.integer(k_values)))
  cut_levels <- sort(unique(cut_levels))

  # Presence/absence matrix:
  # species in rows, relevés in columns
  mat <- t((veg > 0) * 1L)

  n_sites <- ncol(mat)
  occ <- rowSums(mat)

  # ===
  # 2. SPECIES FIDELITY TEST FUNCTION
  # ===

  # version = "original":
  # same procedure as fish_fidel() by
  # Monteiro-Henriques (2025), Supplementary Material 1.
  #
  # version = "fast":
  # equivalent exact test, calculated with phyper().
  #
  # Both methods return a matrix of p-values:
  # species x clusters.

  calc_fidelity <- function(par) {
    k <- max(par)

    p_mat <- matrix(
      NA_real_,
      nrow = nrow(mat),
      ncol = k,
      dimnames = list(
        rownames(mat),
        paste0("G", seq_len(k))
      )
    )

    if (version == "original") {
      # Exact Fisher test: original procedure
      for (i in seq_len(nrow(mat))) {
        for (j in seq_len(k)) {
          p_mat[i, j] <- stats::fisher.test(
            factor(
              mat[i, ] > 0,
              levels = c(FALSE, TRUE)
            ),
            factor(
              par == j,
              levels = c(FALSE, TRUE)
            ),
            alternative = "greater"
          )$p.value
        }
      }
    } else {
      # Exact Fisher test via the hypergeometric distribution
      for (j in seq_len(k)) {
        idx <- par == j

        a <- rowSums(
          mat[, idx, drop = FALSE]
        )

        p_mat[, j] <- stats::phyper(
          q = a - 1,
          m = occ,
          n = n_sites - occ,
          k = sum(idx),
          lower.tail = FALSE
        )
      }
    }

    p_mat
  }

  # ===
  # 3. MODIFIED TWINSPAN FOR EACH k
  # ===

  partitions <- list()
  fidelity_results <- list()
  summary_list <- list()
  failed_k <- integer(0)

  for (k in k_values) {
    tw <- tryCatch(
      ecan::twinspan(
        veg,
        modified = TRUE,
        n_clusters = k,
        cut_levels = cut_levels,
        min_size = min_size,
        polish = "hill",
        species = FALSE
      ),
      error = function(e) NULL
    )

    if (is.null(tw)) {
      failed_k <- c(failed_k, k)
      next
    }

    # Aligning classification with relevés
    cl <- tw$classification

    idx <- match(
      rownames(veg),
      cl$stand
    )

    if (anyNA(idx)) {
      failed_k <- c(failed_k, k)
      next
    }

    # Renumber clusters from 1 to k
    par <- as.integer(
      factor(cl$group[idx])
    )

    k_actual <- length(unique(par))

    if (k_actual != k) {
      failed_k <- c(failed_k, k)
      next
    }

    names(par) <- rownames(veg)

    partitions[[as.character(k)]] <- par

    # ===
    # 4. OPTIMCLASS 1 AND 2
    # ===

    p_mat <- calc_fidelity(par)

    # Species-by-cluster significance
    faithful <- p_mat <= p_threshold

    # OptimClass 1:
    # number of unique faithful species
    # (each species counted only once)
    oc1 <- sum(rowSums(faithful) > 0)

    # Number of faithful species in each cluster
    faithful_per_group <- colSums(faithful)

    # OptimClass 2:
    # clusters with at least min_faithful faithful species
    oc2 <- sum(
      faithful_per_group >= min_faithful
    )

    fidelity_results[[as.character(k)]] <- list(
      p_values = p_mat,
      faithful = faithful,
      faithful_per_group = faithful_per_group
    )

    summary_list[[as.character(k)]] <- data.frame(
      k = k,
      optimclass1 = oc1,
      optimclass2 = oc2,
      prop_good_clusters = oc2 / k,
      min_group_size = min(tabulate(par, nbins = k))
    )
  }

  # ===
  # 5. RESULTS AND SELECTION OF THE NUMBER OF CLUSTERS
  # ===

  if (length(summary_list) == 0) {
    stop("No valid TWINSPAN partitions found.")
  }

  results <- do.call(
    rbind,
    summary_list
  )

  rownames(results) <- NULL

  # All maxima, including possible ties
  best_k <- list(
    optimclass1 = results$k[
      results$optimclass1 == max(results$optimclass1)
    ],
    optimclass2 = results$k[
      results$optimclass2 == max(results$optimclass2)
    ]
  )

  results$best_optim1 <-
    results$k %in% best_k$optimclass1

  results$best_optim2 <-
    results$k %in% best_k$optimclass2

  # In case of ties, select the smallest k
  selected_k <- min(best_k[[select_by]])

  selected_key <- as.character(selected_k)

  groups_selected <- partitions[[selected_key]]

  classification <- data.frame(
    stand = rownames(veg),
    group = factor(
      paste0("G", groups_selected),
      levels = paste0("G", seq_len(selected_k))
    ),
    row.names = NULL
  )

  # Classifications for ALL partitions
  classification_all <- do.call(
    rbind,
    lapply(names(partitions), function(key) {
      data.frame(
        k = as.integer(key),
        stand = rownames(veg),
        group = paste0("G", partitions[[key]]),
        row.names = NULL
      )
    })
  )

  rownames(classification_all) <- NULL

  # ===
  # 6. FAITHFUL SPECIES
  # ===

  # Table of all significant associations
  extract_faithful <- function(fidelity, k) {
    faithful <- fidelity$faithful
    p_mat <- fidelity$p_values

    pos <- which(
      faithful,
      arr.ind = TRUE
    )

    data.frame(
      k = rep(k, nrow(pos)),
      group = colnames(faithful)[pos[, 2]],
      species = rownames(faithful)[pos[, 1]],
      p_value = p_mat[pos],
      row.names = NULL
    )
  }

  faithful_species_all <- do.call(
    rbind,
    lapply(names(fidelity_results), function(key) {
      extract_faithful(
        fidelity_results[[key]],
        as.integer(key)
      )
    })
  )

  rownames(faithful_species_all) <- NULL

  # Faithful species in the selected partition
  faithful_species <- subset(
    faithful_species_all,
    k == selected_k
  )

  # List of faithful species by cluster
  faithful_by_group <- lapply(
    seq_len(selected_k),
    function(j) {
      f <- fidelity_results[[selected_key]]$faithful

      rownames(f)[f[, j]]
    }
  )

  names(faithful_by_group) <-
    paste0("G", seq_len(selected_k))

  # ===
  # 7. PLOTS
  # ===

  make_plot <- function(yvar, title, ylabel, best_flag) {
    ggplot2::ggplot(
      results,
      ggplot2::aes(
        x = k,
        y = .data[[yvar]]
      )
    ) +
      ggplot2::geom_line() +
      ggplot2::geom_point(size = 2.5) +
      ggplot2::geom_point(
        data = results[results[[best_flag]], , drop = FALSE],
        shape = 21,
        size = 5,
        stroke = 1.2
      ) +
      ggplot2::scale_x_continuous(
        breaks = results$k
      ) +
      ggplot2::labs(
        title = title,
        subtitle = paste0(
          "Fisher exact test, p <= ",
          p_threshold
        ),
        x = "Number of groups (k)",
        y = ylabel
      ) +
      ggplot2::theme_classic()
  }

  # Dynamic mapping is implemented through the .data pronoun in aes()
  # to reference yvar without calling dplyr functions
  make_plot <- function(yvar, title, ylabel, best_flag) {
    ggplot2::ggplot(
      results,
      ggplot2::aes(x = k, y = .data[[yvar]])
    ) +
      ggplot2::geom_line() +
      ggplot2::geom_point(size = 2.5) +
      ggplot2::geom_point(
        data = results[results[[best_flag]], , drop = FALSE],
        shape = 21,
        size = 5,
        stroke = 1.2
      ) +
      ggplot2::scale_x_continuous(
        breaks = results$k
      ) +
      ggplot2::labs(
        title = title,
        subtitle = paste0("Fisher: p <= ", p_threshold),
        x = "Number of groups (k)",
        y = ylabel
      ) +
      ggplot2::theme_classic()
  }

  plots <- list(
    optimclass1 = make_plot(
      "optimclass1",
      "OptimClass 1",
      "Number of unique faithful species",
      "best_optim1"
    ),
    optimclass2 = make_plot(
      "optimclass2",
      "OptimClass 2",
      paste0(
        "Groups with at least ",
        min_faithful,
        " faithful species"
      ),
      "best_optim2"
    )
  )

  if (show_plots) {
    print(plots$optimclass1)
    print(plots$optimclass2)
  }

  # ===
  # 8. OUTPUT
  # ===

  output <- list(
    results = results,
    best_k = best_k,
    selected_k = selected_k,
    selected_by = select_by,
    classification = classification,
    classification_all = classification_all,
    partitions = partitions,
    faithful_species = faithful_species,
    faithful_species_all = faithful_species_all,
    faithful_by_group = faithful_by_group,
    fidelity = fidelity_results,
    plots = plots,
    failed_k = failed_k,
    settings = list(
      cut_levels = cut_levels,
      min_size = min_size,
      k_values = k_values,
      p_threshold = p_threshold,
      min_faithful = min_faithful,
      version = version,
      select_by = select_by
    )
  )

  cat("\n--- TWINSPAN + OPTIMCLASS ---\n")
  cat("Version:", version, "\n")
  cat(
    "OptimClass 1, optimal k values:",
    paste(best_k$optimclass1, collapse = ", "),
    "\n"
  )
  cat(
    "OptimClass 2, optimal k values:",
    paste(best_k$optimclass2, collapse = ", "),
    "\n"
  )
  cat(
    "Selected partition:",
    selected_k,
    "groups (",
    select_by,
    ")\n",
    sep = ""
  )
  cat(
    "Unique faithful species:",
    results$optimclass1[results$k == selected_k],
    "\n"
  )

  if (length(failed_k) > 0) {
    cat("Unavailable partitions:", paste(failed_k, collapse = ", "), "\n")
  }

  return(output)
}

# Alternative implementation using Jari Oksanen's twinspan package.
# Inputs, fidelity test, OptimClass, selection, and output structure
# are retained. The TWINSPAN engine and extraction of partitions change.
# Modified procedure: twinspan::twinspan() + twinspan::cuth(ngroups = k).
# Maximum depth: 6 levels, as in the original default ecan call.
# groupmin limits the size of the group to be divided, not its child groups.
# API source: https://jarioksa.r-universe.dev/twinspan/doc/manual.html
