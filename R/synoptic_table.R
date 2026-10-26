## Synoptic table ----

# Reference: https://vcs.pensoft.net/article/183815/?utm_source=researchgate.net&utm_medium=article
# ###
# synoptic_table(): usage and interpretation
# ###
#
# The function constructs a synoptic table from:
#
# - veg    = vegetation matrix/data frame (releves x species) with cover values
# - groups = vector assigning each releve to a group/cluster
# - phi    = complete results object returned by indicspecies::multipatt(),
#            previously calculated with func = "r.g" and duleg = TRUE
#
# The function does NOT run multipatt(): it uses the object supplied as "phi".
# Therefore, it does not accept the nperm or seed arguments.
# The number of permutations and random seed are specified when phi is
# calculated externally.
#
# IMPORTANT:
# The phi object must have been calculated using presence/absence data
# derived from the same vegetation matrix, with species ordered as in the
# columns of veg and the same group assignment for each releve.
# The order of groups in phi must match the order used by this function.
#
# The function identifies and describes three species categories:
#
# 1) DIAGNOSTIC SPECIES
#
#    These are identified using the standardized Phi coefficient and
#    p-values stored in the supplied phi object.
#
#    A species is considered diagnostic when both conditions are met:
#
#    phi >= phi_min
#    p.value <= alpha
#
#    Main parameters:
#
#    alpha   = statistical significance threshold (default = 0.05)
#    phi_min = minimum required Phi value (default = 0.25)
#
#    Phi measures how strongly the presence of a species is associated with
#    a particular group compared with the other groups.
#
#    Higher Phi values indicate greater fidelity/diagnostic value.
#
#    With duleg = TRUE, each species is associated only with the single
#    group to which it shows the strongest association.
#
#    NOTE:
#    The phi argument must be the complete object returned by multipatt(),
#    not a vector of coefficients or only the phi$sign table.
#
#
# 2) CONSTANT SPECIES
#
#    Constancy is the percentage frequency of a species among the releves
#    belonging to a given group:
#
#    frequency (%) =
#      number of releves in the group containing the species /
#      total number of releves in the group * 100
#
#    A species is considered constant when:
#
#    frequency >= constancy_min
#
#    constancy_min = minimum percentage-frequency threshold
#                    (default = 40)
#
#    A species may be constant without being diagnostic: it may be very
#    frequent within one group but equally frequent in other groups.
#
#
# 3) DOMINANT SPECIES
#
#    Dominance is assessed using the original species cover values.
#
#    Parameters:
#
#    dominant_freq_min  = minimum percentage of releves required
#                         (default = 50)
#
#    dominant_cover_min = minimum cover regarded as high
#                         (default = 25)
#
#    When:
#
#    dominance_rule = "high_cover_frequency"
#
#    a species is dominant if its cover is >= dominant_cover_min
#    in at least dominant_freq_min % of the releves within the group.
#
#    Example:
#
#    dominant_freq_min  = 50
#    dominant_cover_min = 25
#
#    -> dominant = TRUE if the species has cover >= 25% in at least
#       50% of the releves belonging to the group.
#
#    Alternatively, with dominance_rule =
#    "presence_frequency_and_max_cover", a species is dominant if it is
#    present in >= dominant_freq_min % of releves and reaches
#    dominant_cover_min at least once in the group.
#
#
# ###
# USAGE EXAMPLE
# ###
#
# In this example, groups is a data frame and groups$group contains the
# group-membership vector for the releves.
# If groups is already a vector, pass groups directly.
#
# 1. Calculate phi externally, if it is not already available:
#
# veg_pa <- ifelse(veg > 0, 1, 0)
#
# set.seed(123)
#
# phi <- indicspecies::multipatt(
#   veg_pa,
#   groups$group,
#   func = "r.g",
#   control = permute::how(nperm = 9999),
#   duleg = TRUE
# )
#
# 2. Construct the table using the previously calculated phi object:
#
# res <- synoptic_table(
#   veg = veg,
#   groups = groups$group,
#   phi = phi,
#   alpha = 0.05,
#   phi_min = 0.25,
#   constancy_min = 40,
#   dominant_freq_min = 50,
#   dominant_cover_min = 25,
#   include = c("diagnostic", "constant", "dominant"),
#   dominance_rule = "high_cover_frequency"
# )
#
# When only the classification thresholds change, the same phi object can
# be reused without rerunning multipatt(), provided the data and groups
# remain unchanged.
#
#
# ###
# THE "include" ARGUMENT
# ###
#
# Determines which species are retained in the final table.
#
# All categories:
#
# include = c("diagnostic", "constant", "dominant")
#
# Diagnostic species only:
#
# include = "diagnostic"
#
# Diagnostic and constant species:
#
# include = c("diagnostic", "constant")
#
# A species is retained in the table if it meets at least one of the
# criteria specified in "include".
#
#
# ###
# INTERPRETING res$synoptic
# ###
#
# res$synoptic is the main output table.
#
# Each row represents a species considered relevant to a specific group
# according to at least one criterion specified in "include".
#
# Main columns:
#
# group
#   Group to which the row refers.
#
# species
#   Species name.
#
# diagnostic
#   TRUE = species is diagnostic for this group.
#   FALSE = species is included because it is constant and/or dominant.
#
# phi
#   Phi coefficient for the diagnostic species-group association.
#   Higher values indicate a stronger association.
#   NA indicates that the species was not classified as diagnostic
#   in this row.
#
# p.value
#   Significance of the species-group association test previously
#   calculated by multipatt() and stored in the supplied phi object.
#   Used together with phi_min to identify diagnostic species.
#
# frequency
#   Percentage of releves in the group in which the species occurs.
#   This corresponds to its frequency/constancy within the group.
#
# constant
#   TRUE if frequency >= constancy_min.
#
# high_cover_frequency
#   Percentage of releves in the group in which the species reaches
#   cover >= dominant_cover_min.
#
# max_cover
#   Maximum observed cover for the species within the group.
#
# dominant
#   TRUE if the species meets the specified dominance criterion.
#
# G1, G2, G3, ...
#   Percentage frequency of the same species across all groups.
#   These columns constitute the actual synoptic section of the table
#   and allow direct comparison of species distributions among groups.
#
#
# ###
# INTERPRETING SPECIES CATEGORIES
# ###
#
# diagnostic = TRUE, constant = TRUE, dominant = TRUE
#   -> highly characteristic species: distinguishes the group,
#      occurs frequently, and is also structurally dominant.
#
# diagnostic = TRUE, constant = FALSE
#   -> relatively infrequent species with a selective association
#      with the group.
#
# diagnostic = FALSE, constant = TRUE
#   -> frequent species in the group but not sufficiently distinctive
#      from species occurrences in the other groups.
#
# dominant = TRUE, diagnostic = FALSE
#   -> structurally important species that is not exclusive to the group
#      or particularly faithful to it.
#
#
# ###
# OTHER RETURNED OBJECTS
# ###
#
# res$diagnostic
#   List of diagnostic species, with group, Phi, and p-value.
#
# res$frequency
#   Species-by-group matrix of percentage frequencies.
#
# res$constant
#   Logical species-by-group matrix indicating constant species.
#
# res$dominant
#   Logical species-by-group matrix indicating dominant species.
#
# res$high_cover_frequency
#   Percentage of releves in which each species reaches at least
#   the specified cover threshold.
#
# res$max_cover
#   Maximum cover observed for each species in each group.
#
# res$phi
#   Complete multipatt() results object passed to the function.
#   Returned without recalculation.
#   For example:
#
#   summary(res$phi)
#   res$phi$sign
#   res$phi$str
#
# res$presence_absence
#   Presence/absence values derived from veg and used for frequencies.
#   These must correspond to the data used for the external phi analysis.
#
# res$settings
#   Parameters used to construct the table; useful for documenting
#   the analysis and ensuring reproducibility.
#   Does not include nperm or seed, which are specified when phi is
#   calculated externally.
#
#
# NOTE:
# Diagnostic, constant, and dominant species are NOT mutually exclusive
# categories: one species may belong to two or all three categories.
# ###

#' Build a Synoptic Table of Diagnostic, Constant and Dominant Species
#'
#' @description
#' Constructs a synoptic table for groups of vegetation releves, combining
#' species fidelity from a previously calculated
#' \code{indicspecies::multipatt()} result with species constancy and
#' dominance derived from an original species-cover matrix.
#'
#' @details
#' The input \code{veg} must have releves in rows and species in columns.
#' The \code{groups} vector assigns each releve to a vegetation group.
#' If \code{groups} is a named vector, its elements are reordered to match
#' \code{rownames(veg)}.
#'
#' \strong{Diagnostic species:} Species are flagged as diagnostic if the supplied
#' \code{multipatt()} output meets both \code{stat >= phi_min} and
#' \code{p.value <= alpha}. The \code{phi} argument must contain the complete
#' result from \code{indicspecies::multipatt()} previously computed on the
#' presence/absence transformation of \code{veg}, using
#' \code{func = "r.g"} and \code{duleg = TRUE}. The species order in
#' \code{phi$sign} must match \code{colnames(veg)}, and the group-index order
#' must match the order used by this function. The function does not calculate
#' Phi, permute data, or call \code{multipatt()} itself.
#'
#' \strong{Constant species:} The percentage frequency of each species in each
#' group is calculated from \code{veg > 0}. Species with frequency at least
#' \code{constancy_min} are classified as constant.
#'
#' \strong{Dominant species:} Dominance is assessed using the original species
#' cover values. With \code{dominance_rule = "high_cover_frequency"}, a species
#' is dominant if it reaches \code{dominant_cover_min} cover in at least
#' \code{dominant_freq_min} percent of the group's releves. With
#' \code{dominance_rule = "presence_frequency_and_max_cover"}, the species
#' must occur in at least \code{dominant_freq_min} percent of the group's
#' releves and reach \code{dominant_cover_min} in at least one releve.
#'
#' The \code{include} argument selects which categories of species are
#' retained. Selection is inclusive (logical OR): satisfying any requested
#' category is sufficient. A species may be diagnostic, constant, and dominant
#' at the same time. All output rows are sorted by group and then by diagnostic
#' status, dominance, constancy, frequency, Phi, and species name.
#'
#' The function does not accept permutation settings such as \code{nperm} or
#' \code{seed}: set these when computing \code{phi} externally. A different
#' choice of reporting thresholds can reuse the same \code{phi} object, as long
#' as the underlying species data and groups remain unchanged.
#'
#' @param veg Numeric matrix or data frame of vegetation records, with
#'   releves in rows and species in columns. Values are original cover
#'   estimates; zero indicates absence. Species names must be supplied as
#'   column names.
#' @param groups Vector of group membership, one element per releve in
#'   \code{veg}. May be numeric, character, or a factor. Named vectors are
#'   aligned to the row names of \code{veg} when possible.
#' @param phi Complete object returned by \code{indicspecies::multipatt()},
#'   calculated externally with \code{func = "r.g"}, \code{duleg = TRUE},
#'   and presence/absence vegetation data. Must contain \code{phi$sign}.
#' @param alpha Maximum p-value for diagnostic species (default \code{0.05}).
#' @param phi_min Minimum fidelity statistic for diagnostic species
#'   (default \code{0.25}).
#' @param constancy_min Minimum species frequency within a group, in percent,
#'   for classification as constant (default \code{40}).
#' @param dominant_freq_min Minimum percentage of releves meeting the selected
#'   dominance rule (default \code{50}).
#' @param dominant_cover_min Cover threshold for high cover, expressed in the
#'   same units as \code{veg} (default \code{25}).
#' @param include Character vector selecting the retained species categories:
#'   any of \code{"diagnostic"}, \code{"constant"}, and \code{"dominant"}.
#'   By default, all three categories are included.
#' @param dominance_rule Character string specifying how dominant species
#'   are defined. \code{"high_cover_frequency"} (default) requires high cover
#'   in a minimum proportion of releves; \code{"presence_frequency_and_max_cover"}
#'   requires sufficient occurrence frequency and high cover at least once.
#'
#' @return
#' A list with the following components:
#' \describe{
#'   \item{synoptic}{Main synoptic data frame, with one row per retained
#'     species-group combination. Columns are \code{group}, \code{species},
#'     \code{diagnostic}, \code{phi}, \code{p.value}, \code{frequency},
#'     \code{constant}, \code{high_cover_frequency}, \code{max_cover},
#'     \code{dominant}, and a percentage-frequency column for each group
#'     (such as \code{G1}, \code{G2}).}
#'   \item{diagnostic}{Data frame containing the diagnostic associations
#'     retained by the fidelity and significance thresholds.}
#'   \item{frequency}{Species-by-group numeric matrix of percentage
#'     occurrence frequencies.}
#'   \item{constant}{Species-by-group logical matrix of constancy.}
#'   \item{dominant}{Species-by-group logical matrix of dominance.}
#'   \item{high_cover_frequency}{Species-by-group numeric matrix of the
#'     percentage of releves at or above \code{dominant_cover_min}.}
#'   \item{max_cover}{Species-by-group numeric matrix of maximum cover.}
#'   \item{phi}{Unmodified \code{multipatt()} object supplied to the function.}
#'   \item{presence_absence}{Presence/absence data frame derived from
#'     \code{veg}.}
#'   \item{settings}{List of thresholds and options used to generate the
#'     synoptic table. Does not include the external permutation settings.}
#' }
#'
#' @references
#' Guarino, R., Caldarella, O., Gristina, A. S., Marcenò, C., &
#' Gianguzzi, L. (2026). Broom-dominated shrublands of Sicily: revisiting
#' the syntaxonomy of the Cytisetea scopario-striati at the south-eastern
#' margin of their range. \emph{Vegetation Classification and Survey}, 7,
#' 127-148. \doi{10.3897/VCS.183815}.
#'
#' @seealso
#' \code{\link[indicspecies]{multipatt}}
#'
#' @examples
#' \dontrun{
#' # Small illustrative dataset: releves in rows, species in columns
#' veg <- data.frame(
#'   Festuca = c(60, 45, 51, 50, 0, 2, 0, 3),
#'   Bromus = c(0, 0, 1, 2, 35, 43, 38, 29),
#'   Poa = c(2, 3, 0, 4, 5, 3, 0, 2)
#' )
#' rownames(veg) <- paste0("R", seq_len(nrow(veg)))
#' groups <- rep(1:2, each = 4)
#'
#' # Calculate fidelity externally, using presence/absence data
#' set.seed(123)
#' phi <- indicspecies::multipatt(
#'   (veg > 0) * 1,
#'   groups,
#'   func = "r.g",
#'   duleg = TRUE,
#'   control = permute::how(nperm = 99)
#' )
#'
#' # Build the synoptic table using original cover values
#' res <- synoptic_table(veg, groups, phi)
#' res$synoptic
#' res$diagnostic
#' res$frequency
#'
#' # Apply a more restrictive filter without recalculating phi
#' res2 <- synoptic_table(
#'   veg, groups, phi,
#'   phi_min = 0.4,
#'   constancy_min = 60,
#'   include = c("diagnostic", "constant")
#' )
#' res2$synoptic
#' }
#'
#' @export

synoptic_table <- function(
  veg,
  groups,
  phi,

  # diagnostic species
  alpha = 0.05,
  phi_min = 0.25,

  # constant species
  constancy_min = 40,

  # dominant species
  dominant_freq_min = 50,
  dominant_cover_min = 25,

  # which categories to include in the table
  include = c("diagnostic", "constant", "dominant"),

  # rule for defining dominant species
  dominance_rule = c(
    "high_cover_frequency",
    "presence_frequency_and_max_cover"
  )
) {
  # ###
  # Packages
  # ###

  requireNamespace("dplyr")
  requireNamespace("tibble")

  dominance_rule <- match.arg(dominance_rule)

  include <- match.arg(
    include,
    choices = c("diagnostic", "constant", "dominant"),
    several.ok = TRUE
  )

  # ###
  # 1. Data checks and preparation
  # ###

  veg <- as.data.frame(
    veg,
    check.names = FALSE
  )

  if (nrow(veg) != length(groups)) {
    stop(
      "Il numero di righe di 'veg' deve essere uguale alla lunghezza di 'groups'."
    )
  }

  # If groups is named and veg has row names,
  # automatically realign groups to releves
  if (
    !is.null(names(groups)) &&
      !is.null(rownames(veg))
  ) {
    if (!all(rownames(veg) %in% names(groups))) {
      stop(
        "Non tutti i rownames di 'veg' sono presenti in names(groups)."
      )
    }

    groups <- groups[rownames(veg)]
  }

  if (anyNA(groups)) {
    stop("'groups' contiene valori NA.")
  }

  if (is.null(colnames(veg))) {
    stop("'veg' deve avere i nomi delle specie nelle colonne.")
  }

  # ###
  # 2. Group handling
  # ###

  if (is.factor(groups)) {
    group_labels <- levels(droplevels(groups))
  } else if (is.numeric(groups) || is.integer(groups)) {
    group_labels <- as.character(
      sort(unique(groups))
    )
  } else {
    # For character groups, preserve their order of appearance
    group_labels <- unique(
      as.character(groups)
    )
  }

  group_id <- match(
    as.character(groups),
    group_labels
  )

  ngroups <- length(group_labels)
  species <- colnames(veg)

  # ###
  # 3. Presence / absence
  # ###

  veg_pa <- ifelse(
    veg > 0,
    1,
    0
  )

  veg_pa <- as.data.frame(
    veg_pa,
    check.names = FALSE
  )

  # ###
  # 4. Standardized Phi
  # ###

  phi_tab <- as.data.frame(
    phi$sign
  ) |>
    tibble::rownames_to_column(
      "species"
    ) |>
    dplyr::mutate(
      diagnostic = !is.na(p.value) &
        p.value <= alpha &
        stat >= phi_min,

      diagnostic_group = ifelse(
        diagnostic,
        group_labels[index],
        NA_character_
      ),

      phi = stat
    ) |>
    dplyr::select(
      species,
      diagnostic,
      diagnostic_group,
      phi,
      p.value
    )

  # ###
  # 5. Frequency / constancy (%) by group
  # ###

  freq_mat <- do.call(
    cbind,
    lapply(
      seq_len(ngroups),
      function(g) {
        colMeans(
          veg_pa[
            group_id == g,
            ,
            drop = FALSE
          ],
          na.rm = TRUE
        ) *
          100
      }
    )
  )

  rownames(freq_mat) <- species

  colnames(freq_mat) <- paste0(
    "G",
    group_labels
  )

  # constant species
  constant_mat <- freq_mat >= constancy_min

  # ###
  # 6. Dominance
  # ###

  # Percentage of releves in which the species reaches
  # at least dominant_cover_min

  high_cover_freq <- do.call(
    cbind,
    lapply(
      seq_len(ngroups),
      function(g) {
        x <- veg[
          group_id == g,
          ,
          drop = FALSE
        ]

        colMeans(
          x >= dominant_cover_min,
          na.rm = TRUE
        ) *
          100
      }
    )
  )

  rownames(high_cover_freq) <- species

  colnames(high_cover_freq) <- paste0(
    "G",
    group_labels
  )

  # Maximum species cover recorded within each group

  max_cover <- do.call(
    cbind,
    lapply(
      seq_len(ngroups),
      function(g) {
        x <- veg[
          group_id == g,
          ,
          drop = FALSE
        ]

        apply(
          x,
          2,
          max,
          na.rm = TRUE
        )
      }
    )
  )

  rownames(max_cover) <- species

  colnames(max_cover) <- paste0(
    "G",
    group_labels
  )

  # Two alternative operational definitions of dominance

  if (dominance_rule == "high_cover_frequency") {
    # Dominant if the species reaches at least the cover threshold
    # in >= dominant_freq_min % of releves

    dominant_mat <-
      high_cover_freq >= dominant_freq_min
  } else {
    # Dominant if:
    # 1. it occurs in >= dominant_freq_min % of releves
    # 2. it reaches dominant_cover_min at least once

    dominant_mat <-
      freq_mat >= dominant_freq_min &
      max_cover >= dominant_cover_min
  }

  # ###
  # 7. Long species-by-group table
  # ###

  by_group <- do.call(
    rbind,
    lapply(
      seq_len(ngroups),
      function(g) {
        diag_species <-
          phi_tab$diagnostic &
          phi_tab$diagnostic_group == group_labels[g]

        tmp <- data.frame(
          group = group_labels[g],
          species = species,

          diagnostic = diag_species,

          phi = ifelse(
            diag_species,
            phi_tab$phi,
            NA_real_
          ),

          p.value = ifelse(
            diag_species,
            phi_tab$p.value,
            NA_real_
          ),

          frequency = freq_mat[, g],

          constant = constant_mat[, g],

          high_cover_frequency = high_cover_freq[, g],

          max_cover = max_cover[, g],

          dominant = dominant_mat[, g],

          stringsAsFactors = FALSE
        )

        # Select only the requested categories

        keep <- rep(
          FALSE,
          nrow(tmp)
        )

        if ("diagnostic" %in% include) {
          keep <- keep | tmp$diagnostic
        }

        if ("constant" %in% include) {
          keep <- keep | tmp$constant
        }

        if ("dominant" %in% include) {
          keep <- keep | tmp$dominant
        }

        tmp[keep, , drop = FALSE]
      }
    )
  )

  # ###
  # 8. Add frequencies across all groups
  # ###

  freq_df <- as.data.frame(
    freq_mat
  ) |>
    tibble::rownames_to_column(
      "species"
    )

  by_group <- by_group |>
    dplyr::left_join(
      freq_df,
      by = "species"
    )

  # ###
  # 9. Sorting
  # ###

  by_group$group_order <- match(
    by_group$group,
    group_labels
  )

  by_group <- by_group |>
    dplyr::arrange(
      group_order,
      dplyr::desc(diagnostic),
      dplyr::desc(dominant),
      dplyr::desc(constant),
      dplyr::desc(frequency),
      dplyr::desc(phi),
      species
    ) |>
    dplyr::select(
      -group_order
    ) |>
    dplyr::mutate(
      phi = round(phi, 3),
      p.value = round(p.value, 4),
      frequency = round(frequency, 1),
      high_cover_frequency = round(high_cover_frequency, 1),
      max_cover = round(max_cover, 1),

      dplyr::across(
        dplyr::all_of(colnames(freq_mat)),
        ~ round(.x, 1)
      )
    )

  # ###
  # 10. Output
  # ###

  return(
    list(
      # main table sorted by group
      synoptic = by_group,

      # diagnostic results
      diagnostic = phi_tab |>
        dplyr::filter(diagnostic),

      # additional matrices
      frequency = freq_mat,
      constant = constant_mat,
      dominant = dominant_mat,
      high_cover_frequency = high_cover_freq,
      max_cover = max_cover,

      # original multipatt object
      phi = phi,

      # presence/absence
      presence_absence = veg_pa,

      # parameters used
      settings = list(
        alpha = alpha,
        phi_min = phi_min,
        constancy_min = constancy_min,
        dominant_freq_min = dominant_freq_min,
        dominant_cover_min = dominant_cover_min,
        dominance_rule = dominance_rule,
        include = include
      )
    )
  )
}
