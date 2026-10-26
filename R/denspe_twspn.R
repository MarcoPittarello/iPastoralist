#' Label TWINSPAN Vegetation Surveys with Their Most Abundant Species
#'
#' @description
#' Generates descriptive labels for vegetation surveys classified using
#' the TWINSPAN (Two-Way Indicator Species Analysis) approach.
#' Each survey identifier is supplemented with the names of its most
#' abundant species, facilitating the floristic interpretation of
#' TWINSPAN classifications and dendrograms.
#'
#' @details
#' This function is designed as a supporting tool for vegetation
#' classification based on TWINSPAN, particularly modified TWINSPAN
#' implemented in the \code{ecan} package.
#'
#' Species are ranked according to their abundance within each survey,
#' using the results of \code{first_ten_species_twspn()}.
#' The user can specify how many species should be included in the label.
#'
#' For example, a survey originally identified as "R1" may receive
#' the label "R1 | Festuca rubra | Agrostis capillaris" when
#' \code{nspe = 2}.
#'
#' The function does not perform or repeat TWINSPAN classification.
#' Instead, it modifies the row names of the vegetation matrix for
#' descriptive and graphical purposes.
#'
#' Species-abundance information can be supplied directly through
#' \code{SpeAbund} or calculated automatically from \code{dbClust}.
#'
#' Survey identifiers are matched by name rather than row position,
#' ensuring correct correspondence between the vegetation matrix
#' and the abundance summary.
#'
#' When a fitted TWINSPAN object is provided, the vegetation matrix
#' must contain exactly the same surveys, although their order,
#' species columns and abundance units may differ.
#'
#' The resulting labels can be used with TWINSPAN plotting functions,
#' such as \code{plotClustAggregate_twspn()}, to improve the
#' ecological interpretation of vegetation groups.
#'
#' @param nspe Non-negative integer specifying the number of most
#'   abundant species to include in each survey label.
#'   Default is 5. If fewer ranked species are available,
#'   all available ranks are used. A value of 0 retains
#'   only the original survey identifiers.
#'
#' @param SpeAbund Optional data.frame produced by
#'   \code{first_ten_species_twspn()}, containing survey identifiers
#'   in the \code{Survey} column and ranked species in columns
#'   \code{X1}, \code{X2}, etc.
#'   If NULL, species rankings are calculated automatically.
#'
#' @param dbClust Numeric vegetation matrix or data.frame with
#'   surveys in rows and species in columns.
#'   If NULL, the vegetation data stored in
#'   \code{twin_ecan$data} are used.
#'
#' @param twin_ecan Optional fitted TWINSPAN object, typically
#'   produced by \code{ecan::twinspan()}.
#'   Used to retrieve the original vegetation data when
#'   \code{dbClust} is NULL and to validate survey identifiers.
#'
#' @param sep Character string separating the original survey
#'   identifier from the species names.
#'   Default is \code{" | "}.
#'
#' @return
#' A numeric vegetation matrix retaining the original values
#' and row order, but with modified row names containing
#' the survey identifier and ranked species names.
#'
#' The matrix also includes the attribute \code{survey_labels},
#' a data.frame containing:
#' \describe{
#'   \item{Survey}{Original survey identifier.}
#'   \item{label}{Generated survey label including species names.}
#' }
#'
#' @seealso
#' \code{\link{first_ten_species_twspn}},
#' \code{\link{plotClustAggregate_twspn}},
#' \code{\link[ecan]{twinspan}}
#'
#' @examples
#' # Example vegetation matrix
#' veg <- rbind(
#'   S1 = c(9, 5, 0, 0),
#'   S2 = c(8, 4, 1, 0),
#'   S3 = c(0, 1, 5, 8),
#'   S4 = c(0, 0, 4, 7)
#' )
#'
#' colnames(veg) <- c(
#'   "Species A", "Species B",
#'   "Species C", "Species D"
#' )
#'
#' # Modified TWINSPAN classification
#' tw <- ecan::twinspan(
#'   veg,
#'   modified = TRUE,
#'   n_clusters = 2,
#'   min_size = 2,
#'   polish = "hill",
#'   species = FALSE
#' )
#'
#' # Identify the most abundant species
#' top <- first_ten_species_twspn(twin_ecan = tw)
#'
#' # Label each survey with its two most abundant species
#' labelled <- denspe_twspn(
#'   nspe = 2,
#'   SpeAbund = top,
#'   twin_ecan = tw
#' )
#'
#' # Inspect the resulting labels
#' rownames(labelled)
#'
#' # Retrieve the original and modified survey identifiers
#' attr(labelled, "survey_labels")
#'
#' @export

denspe_twspn <- function(
  nspe = 5,
  SpeAbund = NULL,
  dbClust = NULL,
  twin_ecan = NULL,
  sep = " | "
) {
  .twspn_integer(nspe, "nspe", minimum = 0)
  if (!is.character(sep) || length(sep) != 1L || is.na(sep)) {
    stop("sep must be a single non-missing character string.", call. = FALSE)
  }
  if (is.null(dbClust)) {
    .twspn_info(twin_ecan)
    dbClust <- twin_ecan$data
  }
  x <- .twspn_matrix(dbClust, "dbClust")
  ids <- rownames(x)
  if (!is.null(twin_ecan)) {
    info <- .twspn_info(twin_ecan)
    .twspn_same_surveys(ids, info$classification$stand, "dbClust")
  }
  if (is.null(SpeAbund)) {
    SpeAbund <- first_ten_species_twspn(
      x,
      join.dendrogram = FALSE,
      n = max(1, min(nspe, ncol(x)))
    )
  }
  if (
    !is.data.frame(SpeAbund) ||
      !("Survey" %in% names(SpeAbund)) ||
      anyDuplicated(names(SpeAbund))
  ) {
    stop(
      "SpeAbund must be a first_ten_species_twspn() data.frame.",
      call. = FALSE
    )
  }
  summary.ids <- as.character(SpeAbund$Survey)
  .twspn_names(summary.ids, "SpeAbund$Survey")
  .twspn_same_surveys(summary.ids, ids, "SpeAbund")
  rank.names <- grep("^X[1-9][0-9]*$", names(SpeAbund), value = TRUE)
  rank.names <- rank.names[order(as.numeric(sub("^X", "", rank.names)))]
  if (nspe > 0 && !length(rank.names)) {
    stop("SpeAbund has no species-rank columns X1, X2, ... .", call. = FALSE)
  }
  chosen <- utils::head(rank.names, nspe)
  matched <- SpeAbund[match(ids, summary.ids), chosen, drop = FALSE]
  labels <- vapply(
    seq_along(ids),
    function(i) {
      text <- if (length(chosen)) {
        as.character(unlist(matched[i, ], use.names = FALSE))
      } else {
        character(0)
      }
      text <- text[!is.na(text) & nzchar(trimws(text))]
      paste(c(ids[i], text), collapse = sep)
    },
    character(1)
  )
  if (anyDuplicated(labels)) {
    stop("Generated labels are not unique; choose another sep.", call. = FALSE)
  }
  rownames(x) <- labels
  attr(x, "survey_labels") <- data.frame(
    Survey = ids,
    label = labels,
    stringsAsFactors = FALSE
  )
  x
}
