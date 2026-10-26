#' Computation of Ecological indicators (Landolt, Ellenberg) from phytosociological surveys
#'
#' @description Computation of Ecological indicators, which can be either weighted or not weighted with SRA. Occasional species can be taken into account.
#' @param database.vegetation database with species cover or abundance. Rows are species and columns are surveys. The column of species names must be imported. Database class must be *data.frame*
#' @param database.indexes database with Ecological indicators, without the column of species names. NA values must indicated as 999
#' @return a list with weighted and not weighted ecological indicators for each survey.
#' @import tidyverse
#' @examples
#' # Structure of the ecological indicator database:
#' # Rows represent species and columns represent ecological indicators.
#' # Column headings must be provided.
#' # The species name column must not be included.
#'
#' ecological_indicators <- data.frame(
#'   N_Landolt = c(2, 5, 4),
#'   T_Landolt = c(5, 1, 999)
#' )
#'
#' # Use 999 for species with missing ecological indicator values.
#'
#' # See also the package vignettes for complete examples.
#' @export

ecological_indexesPHYTO <- function(database.vegetation, database.indexes) {
  db <- cbind(database.vegetation, database.indexes)
  row.names(db) <- database.vegetation[, 1]

  db2 <- pivot_longer(
    db,
    cols = ncol(database.vegetation) + 1:ncol(database.indexes),
    names_to = "index",
    values_to = "value"
  )

  weighted <- list()
  not.weighted <- list()

  for (i in unique(db2$index)) {
    temp <- filter(db2, index == i & value > 0)

    temp <- temp[temp$value != 999, ]

    v <- temp[, 1:(ncol(db2) - 2), ]
    v <- data.frame(v)
    row.names(v) <- v[, 1]
    v <- v[, -1]
    v[(v == 0)] <- NA

    li <- temp[, (ncol(db2) - 1):ncol(db2)]
    li <- data.frame(li)

    prodotto <- apply(v, MARGIN = 2, function(x) sum(x * li[, 2], na.rm = T))
    pesi <- apply(v, MARGIN = 2, function(x) sum(x, na.rm = T))
    w <- prodotto / pesi

    weighted[[i]] <- w

    v.pa <- ifelse(v > 0, 1, 0)
    uw <- apply(v.pa, MARGIN = 2, function(x) mean(x * (li[, 2]), na.rm = T))
    not.weighted[[i]] <- uw
  }

  weigthed.indicators <- do.call(cbind, weighted)
  not.weigthed.indicators <- do.call(cbind, not.weighted)

  colnames(weigthed.indicators) <- paste(
    colnames(weigthed.indicators),
    "WEIGHTED",
    sep = "_"
  )
  colnames(not.weigthed.indicators) <- paste(
    colnames(not.weigthed.indicators),
    "NOT_WEIGHTED",
    sep = "_"
  )

  indicators <- list(
    weigthed.indicators = weigthed.indicators,
    not.weighted.indicators = not.weigthed.indicators
  )

  return(indicators)
}
