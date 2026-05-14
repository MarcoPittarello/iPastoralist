#' Name vegetation groups based on dominant species
#'
#' @description
#' Assigns a descriptive name to each vegetation group identified by
#' \code{\link{clustGroupAggregate2}}. The name is built by selecting, within
#' each group, the most-abundant species whose \emph{cumulated} relative
#' abundance does not exceed a user-defined threshold. Species names are
#' retrieved by joining the long-format output with a lookup table that maps
#' abbreviated CEP codes to full scientific names. Each species is followed by
#' its rounded relative abundance in parentheses (e.g.
#' \emph{Trifolium repens} (30\%), \emph{Lolium perenne} (10\%)).
#'
#' @details
#' The function works in three steps:
#' \enumerate{
#'   \item The long-format dataframe produced by \code{clustGroupAggregate2}
#'         (columns \code{group}, \code{species}, \code{abundance}) is joined
#'         with the CEP lookup table so that every CEP code is replaced by the
#'         corresponding full scientific name.
#'   \item For each group, species are sorted in decreasing order of mean
#'         abundance and their relative percentages are computed. Cumulative
#'         percentages are then calculated.
#'   \item Starting from the most-abundant species, species are retained as
#'         long as \emph{adding} the next species would keep the cumulated
#'         abundance below \code{threshold}. At least one species is always
#'         retained, even when a single species already exceeds the threshold.
#' }
#'
#' @param df.long A dataframe in long format as returned by the
#'   \code{$df.long} element of \code{\link{clustGroupAggregate2}}. It must
#'   contain at least three columns:
#'   \describe{
#'     \item{\code{group}}{Group identifier (character or factor).}
#'     \item{\code{species}}{Species code in CEP format (character).}
#'     \item{\code{abundance}}{Mean abundance value for the species within the
#'       group (numeric).}
#'   }
#' @param cep A dataframe with exactly two columns used as a lookup table:
#'   \describe{
#'     \item{Column 1}{Full scientific name of the species (character). This
#'       column is used as the display name in the output.}
#'     \item{Column 2}{CEP code of the species (character). This column is
#'       matched against the \code{species} column of \code{df.long}.}
#'   }
#'   Column names are not required to follow a specific convention; the
#'   function renames them internally.
#' @param threshold A single numeric value (0–100) representing the maximum
#'   cumulated relative abundance (in percent) that the selected species may
#'   reach. Species are added in decreasing order of abundance until including
#'   the next one would cause the cumulated percentage to equal or exceed this
#'   value. Defaults to \code{50}.
#'
#' @return A dataframe with two columns:
#'   \describe{
#'     \item{\code{group}}{Group identifier, matching those in \code{df.long}.}
#'     \item{\code{name}}{A character string with the group name, composed of
#'       the dominant species and their relative abundances, separated by
#'       commas. Example: \code{"Trifolium repens (30\%), Lolium perenne (10\%)"}.}
#'   }
#'
#' @examples
#' ## Minimal reproducible example -------------------------------------------
#'
#' ## Simulate a long-format aggregate dataframe
#' df.long <- data.frame(
#'   group     = c(rep("1", 3), rep("2", 3)),
#'   species   = c("trif rep", "loli per", "fest rub",
#'                 "brom ere", "poa alp",  "agro cap"),
#'   abundance = c(30, 10, 5, 40, 20, 8)
#' )
#'
#' ## CEP lookup table (full name | cep code)
#' cep <- data.frame(
#'   full_name = c("Trifolium repens", "Lolium perenne", "Festuca rubra",
#'                 "Bromus erectus", "Poa alpina", "Agrostis capillaris"),
#'   cep_code  = c("trif rep", "loli per", "fest rub",
#'                 "brom ere", "poa alp",  "agro cap"),
#'   stringsAsFactors = FALSE
#' )
#'
#' ## Name the groups using the default 50 % threshold
#' nameGroups(df.long, cep, threshold = 50)
#'
#' ## Use a more restrictive threshold to retain only the single top species
#' nameGroups(df.long, cep, threshold = 30)
#'
#' @importFrom dplyr left_join summarise cur_data arrange desc mutate lag
#' @importFrom dplyr join_by
#' @export

nameGroups <- function(df.long, cep, threshold = 50) {
  # Standardise column names of the lookup table
  names(cep) <- c("full_name", "cep")

  df.long |>
    left_join(cep, join_by(species == cep)) |>
    summarise(
      .by = group,
      name = {
        # Sort species by decreasing abundance within the group
        d <- cur_data() |> arrange(desc(abundance))
        # Compute relative (%) and cumulative relative abundance
        d <- d |>
          mutate(
            rel = abundance / sum(abundance) * 100,
            cum = cumsum(rel)
          )
        # Keep species whose *preceding* cumulative sum is below the threshold.
        # Using lag() ensures the first species is always retained.
        keep <- which(lag(d$cum, default = 0) < threshold)
        d <- d[keep, ]
        # Build the label: "Full name (XX%)"
        paste(
          paste0(d$full_name, " (", round(d$rel, 0), "%)"),
          collapse = ", "
        )
      }
    )
}
