#' Most abundant species per survey with TWINSPAN classification
#'
#' Rank the original abundance values within each survey and format the first
#' species as text. Input orientation defaults to the surveys-by-species matrix
#' accepted by [ecan::twinspan()].
#'
#' @param data_SRA_SC Numeric matrix or data.frame of abundances. By default,
#'   rows are surveys and columns are species. If `NULL`, use `twin_ecan$data`.
#'   Names on both dimensions must be unique and non-empty.
#' @param join.dendrogram Logical; order surveys as in `twin_ecan` and include
#'   their positions and terminal groups?
#' @inheritParams clustOrder_twspn
#' @param n Positive integer; maximum number of species returned per survey.
#' @param digits Non-negative integer; decimal places used in displayed values.
#' @param surveys.rows Logical; if `FALSE`, `data_SRA_SC` has species in rows
#'   and surveys in columns, as in the original iPastoralist function. This
#'   argument applies only to explicitly supplied data, not `twin_ecan$data`.
#' @param include.zero Logical; include absent species (zero abundance) after
#'   the present species?
#'
#' @details
#' Species are ordered by unrounded abundance, with ties resolved by input
#' species order. Rounding is applied only to the displayed text. No conversion
#' to percentages is performed. If fewer than `n` eligible species occur in a
#' survey, its remaining entries are `NA_character_`.
#'
#' Unlike the original function, the result always has one row per survey;
#' no survey is dropped. With `join.dendrogram = FALSE`, rows follow the input
#' order. When joining, all fitted survey IDs must be present exactly once.
#' An explicit abundance table may use different units or species columns from
#' the fitting matrix; only survey IDs are matched to the classification.
#'
#' @return A data.frame with `Survey`, optionally `cluster` and `Survey.order`,
#'   and text columns `X1`, ..., `Xn` (for example, `"Festuca rubra 12.5"`).
#' @seealso [denspe_twspn()], [clustOrder_twspn()]
#' @examples
#' veg <- rbind(S1 = c(9, 5, 0, 0), S2 = c(8, 4, 1, 0),
#'              S3 = c(0, 1, 5, 8), S4 = c(0, 0, 4, 7))
#' colnames(veg) <- c("Species A", "Species B", "Species C", "Species D")
#' tw <- ecan::twinspan(veg, modified = TRUE, n_clusters = 2,
#'                      min_size = 2, polish = "hill", species = FALSE)
#' first_ten_species_twspn(twin_ecan = tw, n = 3)
#' first_ten_species_twspn(veg, join.dendrogram = FALSE, n = 3)
#' first_ten_species_twspn(t(veg), twin_ecan = tw, surveys.rows = FALSE)
#' @export
first_ten_species_twspn <- function(
  data_SRA_SC = NULL,
  join.dendrogram = TRUE,
  twin_ecan = NULL,
  n = 10,
  digits = 1,
  surveys.rows = TRUE,
  include.zero = FALSE
) {
  .twspn_flag(join.dendrogram, "join.dendrogram")
  .twspn_flag(surveys.rows, "surveys.rows")
  .twspn_flag(include.zero, "include.zero")
  .twspn_integer(n, "n", minimum = 1)
  .twspn_integer(digits, "digits", minimum = 0)
  if (digits > 15L) {
    stop("digits must be <= 15.", call. = FALSE)
  }
  if (is.null(data_SRA_SC)) {
    .twspn_info(twin_ecan)
    x <- .twspn_matrix(twin_ecan$data, "twin_ecan$data")
  } else {
    x <- .twspn_matrix(data_SRA_SC, "data_SRA_SC")
    if (!surveys.rows) x <- t(x)
  }
  ids <- rownames(x)
  ranked <- matrix(
    NA_character_,
    nrow = nrow(x),
    ncol = n,
    dimnames = list(NULL, paste0("X", seq_len(n)))
  )
  for (i in seq_len(nrow(x))) {
    eligible <- if (include.zero) seq_len(ncol(x)) else which(x[i, ] > 0)
    ord <- eligible[order(-x[i, eligible], eligible)]
    chosen <- utils::head(ord, n)
    if (length(chosen)) {
      values <- format(
        round(x[i, chosen], digits),
        trim = TRUE,
        scientific = FALSE
      )
      ranked[i, seq_along(chosen)] <- paste(colnames(x)[chosen], values)
    }
  }
  out <- data.frame(
    Survey = ids,
    ranked,
    stringsAsFactors = FALSE,
    check.names = FALSE,
    row.names = NULL
  )
  if (join.dendrogram) {
    groups <- clustOrder_twspn(twin_ecan)
    .twspn_same_surveys(ids, groups$Survey, "data_SRA_SC")
    out <- out[match(groups$Survey, out$Survey), , drop = FALSE]
    out <- cbind(
      groups[c("Survey", "cluster", "Survey.order")],
      out[setdiff(names(out), "Survey")]
    )
    rownames(out) <- NULL
  }
  out
}
