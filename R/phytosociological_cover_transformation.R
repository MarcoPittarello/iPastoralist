#' Transform visually estimated species cover to cover-abundance values
#'
#' @description Convert visually estimated percentage cover using the simplified
#' cover classes in the table below.
#'
#' @param database A data frame with species in rows and surveys in columns.
#'   The first column contains non-missing, non-empty, unique species names;
#'   spaces in species names are allowed. Remaining columns contain percentages
#'   from 0 to 100, numeric strings, or `"+"` for trace cover. Factors are accepted
#'   through their labels. `NA` and blank strings are interpreted as absence (0).
#' @param method One of `"BrBl"`, `"Maarel"`, or `"TassTapp"`.
#'
#' @details
#' **Conversion table**
#'
#' | Visually estimated cover (%) | BrBl | Maarel | TassTapp |
#' | :--- | :--- | :--- | :--- |
#' | 0 | 0 | 0 | 0 |
#' | 0 < cover < 1, or `+` | + | 2 | 0.3 |
#' | 1 <= cover <= 5 | 1 | 3 | 2.8 |
#' | 5 < cover <= 15 | 2a | 5 | 10 |
#' | 15 < cover <= 25 | 2b | 5 | 20.5 |
#' | 25 < cover <= 50 | 3 | 7 | 38 |
#' | 50 < cover <= 75 | 4 | 8 | 63 |
#' | 75 < cover <= 100 | 5 | 9 | 88 |
#'
#' These are the package's simplified, cover-based conversions, rather than
#' a reconstruction of abundance from percentage cover. The full extended
#' Braun-Blanquet scale includes abundance categories not inferred here.
#' In particular, `"Maarel"` preserves the package convention of assigning 5
#' to both 2a and 2b; the full ordinal transformation distinguishes these as
#' 5 and 6. The `"TassTapp"` values are fixed representatives of cover classes,
#' not percentages normalized to sum to 100 within a survey.
#'
#' Missing values are treated as absence for compatibility. Use this convention
#' only when missing cells actually represent species absence, not unknown cover.
#'
#' @return A data frame with species names as row names and the original survey
#'   names as column names. The species-name column is omitted. `"BrBl"` returns
#'   character columns; the other methods return numeric columns.
#'
#' @references
#' Braun-Blanquet, J. (1964). Pflanzensoziologie. Springer, Vienna.
#'
#' van der Maarel, E. (1979). Transformation of cover-abundance values in
#' phytosociology and its effects on community similarity. Vegetatio, 39, 97-114.
#'
#' Tasser, E. and Tappeiner, U. (2005). New model to predict rooting in diverse
#' plant community compositions. Ecological Modelling, 185, 195-211.
#'
#' @examples
#' # Rows are species; columns after the first are surveys.
#' cover <- data.frame(
#'   Species = c("Festuca rubra", "Poa pratensis", "Trifolium repens"),
#'   survey1 = c("12.3", "+", NA),
#'   survey2 = c("5", "0", "27")
#' )
#' PhytoCover(cover, "BrBl")
#' PhytoCover(cover, "Maarel")
#' PhytoCover(cover, "TassTapp")
#'
#' @md
#' @export
PhytoCover <- function(database, method) {
       if (!is.data.frame(database) || ncol(database) < 2L) {
              stop(
                     "'database' must be a data frame with species names and at least one survey.",
                     call. = FALSE
              )
       }
       methods <- c("BrBl", "Maarel", "TassTapp")
       if (
              missing(method) ||
                     !is.character(method) ||
                     length(method) != 1L ||
                     is.na(method) ||
                     !method %in% methods
       ) {
              stop(
                     "'method' must be one of 'BrBl', 'Maarel', or 'TassTapp'.",
                     call. = FALSE
              )
       }
       species <- as.character(database[[1L]])
       if (
              anyNA(species) ||
                     any(!nzchar(trimws(species))) ||
                     anyDuplicated(species)
       ) {
              stop(
                     "Species names must be non-missing, non-empty, and unique.",
                     call. = FALSE
              )
       }

       values <- switch(
              method,
              BrBl = c("0", "+", "1", "2a", "2b", "3", "4", "5"),
              Maarel = c(0, 2, 3, 5, 5, 7, 8, 9),
              TassTapp = c(0, 0.3, 2.8, 10, 20.5, 38, 63, 88)
       )
       result <- database[, -1L, drop = FALSE]
       for (j in seq_along(result)) {
              column <- result[[j]]
              if (
                     !(is.numeric(column) ||
                            is.character(column) ||
                            is.factor(column) ||
                            (is.logical(column) && all(is.na(column)))) ||
                            !is.null(dim(column)) ||
                            is.complex(column)
              ) {
                     stop(
                            sprintf(
                                   "Survey column %d must contain percentages, '+', or missing values.",
                                   j + 1L
                            ),
                            call. = FALSE
                     )
              }
              text <- trimws(as.character(column))
              text[is.na(column) | text == ""] <- "0"
              trace <- text == "+"
              text[trace] <- "0.5"
              x <- suppressWarnings(as.numeric(text))
              invalid <- !is.finite(x) | x < 0 | x > 100
              if (any(invalid)) {
                     stop(
                            sprintf(
                                   "Invalid cover at species row %d, survey column %d: use 0-100 or '+'.",
                                   which(invalid)[1L],
                                   j + 1L
                            ),
                            call. = FALSE
                     )
              }
              # Thresholds distinguish exact 0 and 1, and include each upper class limit.
              index <- 1L +
                     (x > 0) +
                     (x >= 1) +
                     (x > 5) +
                     (x > 15) +
                     (x > 25) +
                     (x > 50) +
                     (x > 75)
              result[[j]] <- values[index]
       }
       rownames(result) <- species
       result
}
