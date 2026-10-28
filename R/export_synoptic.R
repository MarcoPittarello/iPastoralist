## Export synoptic table to Excel ----

# FUNCTION: export_synoptic()
#
# Purpose:
# Exports a phytosociological synoptic table to Excel,
# organizing diagnostic species by group and placing other
# species in a separate section.
#
# Arguments:
# synoptic       = table produced by ipastoralist::synoptic_table()
# file           = name and path of the Excel file to create
# min_frequency  = minimum frequency (%) for including
#                  non-diagnostic species; diagnostic species are
#                  always retained (default = 0)
# digits         = number of decimal places for frequencies (default = 0)
# group_sizes    = optional number of vegetation relevés per group,
#                  e.g. table(groups$group)
#
# Output:
# Excel file containing:
# 1. Synoptic_table: formatted synoptic table
# 2. Original_data: full original data
#
# Required package: openxlsx
#
# Example:
# export_synoptic(ipastoralist::synoptic_table(...),
#                 file = "Tabella_sinottica.xlsx",
#                 min_frequency = 30,
#                 group_sizes = table(groups$group))

#' Export a Phytosociological Synoptic Table to Excel
#'
#' @md
#' @description
#' Exports a phytosociological synoptic table to a formatted Excel workbook,
#' displaying diagnostic species in group-specific sections and the remaining
#' species in a separate section. Species frequencies, Phi coefficients,
#' association p-values, and dominance information are included.
#'
#' @details
#' The input should be the `synoptic` component returned by
#' [synoptic_table()]. The function does not calculate diagnostic species,
#' frequency, or dominance; it formats and exports previously calculated
#' results.
#'
#' The input must contain the columns `group`, `species`, `diagnostic`,
#' `phi`, `p.value`, and `dominant`, as well as frequency columns named
#' `GG1`, `GG2`, etc. (corresponding to group labels `G1`, `G2`, etc.).
#' Frequencies in these columns are percentages. Group columns are
#' displayed in numerical order.
#'
#' Diagnostic species are assigned to the section for their group with
#' the highest Phi value. If a species is diagnostic for more than one
#' group, the corresponding frequency cells may be highlighted in each
#' group, even though the species appears in only one diagnostic section.
#' Non-diagnostic species are included when their maximum frequency across
#' groups is at least `min_frequency`. Diagnostic species are always
#' retained, regardless of this threshold.
#'
#' The Excel workbook contains two worksheets:
#' * `Synoptic_table`: a formatted table organized by diagnostic group,
#'   followed by a section of other frequent species.
#' * `Original_data`: the complete input table, without the export filter.
#'
#' The output file is overwritten if it already exists. The function
#' requires the `openxlsx` package.
#'
#' @param synoptic A data frame (or object coercible to a data frame),
#'   typically `res$synoptic` from [synoptic_table()]. It must contain the
#'   required diagnostic, dominance, and group frequency columns.
#' @param file Character string indicating the output `.xlsx` filename or
#'   path. Default: `"Tabella_sinottica.xlsx"`.
#' @param min_frequency Numeric value between 0 and 100 specifying the
#'   minimum percentage frequency for retaining non-diagnostic species.
#'   Diagnostic species are retained regardless of this value.
#'   Default: `0`.
#' @param digits Non-negative integer indicating the number of decimal places
#'   displayed for species frequencies. Default: `0`.
#' @param group_sizes Optional named vector or table giving the number of
#'   vegetation relevés in each group, with names such as `G1`, `G2`, etc.
#'   When provided, a row showing group sample sizes is added to the Excel
#'   table. Default: `NULL`.
#'
#' @return
#' Invisibly returns a data frame containing the exported species with
#' `Species`, group frequency columns, `Diagnostic_group`, `Phi`, `p_value`,
#' `Dominant_in`, `max_freq`, and `section_order`. It also writes an Excel
#' workbook to the path specified by `file`.
#'
#' @examples
#' # Example with a small, already calculated synoptic table
#' example_synoptic <- data.frame(
#'   group = c("G1", "G2", "G1"),
#'   species = c("Festuca rubra", "Bromus erectus", "Trifolium repens"),
#'   diagnostic = c(TRUE, TRUE, FALSE),
#'   phi = c(0.65, 0.58, NA),
#'   p.value = c(0.002, 0.010, NA),
#'   dominant = c(TRUE, FALSE, FALSE),
#'   GG1 = c(90, 25, 60),
#'   GG2 = c(15, 85, 55)
#' )
#'
#' if (requireNamespace("openxlsx", quietly = TRUE)) {
#'   output_file <- tempfile(fileext = ".xlsx")
#'   exported <- export_synoptic(
#'     synoptic = example_synoptic,
#'     file = output_file,
#'     min_frequency = 30,
#'     group_sizes = c(G1 = 5, G2 = 6)
#'   )
#'   unlink(output_file)
#' }
#'
#' @seealso [synoptic_table()], [openxlsx::createWorkbook()]
#'
#' @references
#' Guarino, R., Caldarella, O., Gristina, A. S., Marcenò, C., & Gianguzzi,
#' L. (2026). Broom-dominated shrublands of Sicily: revisiting the syntaxonomy
#' of the Cytisetea scopario-striati at the south-eastern margin of their range.
#' *Vegetation Classification and Survey*, 7, 127-148.
#' https://doi.org/10.3897/VCS.183815
#'
#' @export

export_synoptic <- function(
  synoptic,
  file = "Tabella_sinottica.xlsx",
  min_frequency = 0,
  digits = 0,
  group_sizes = NULL
) {
  if (!requireNamespace("openxlsx", quietly = TRUE)) {
    stop("Installare il pacchetto openxlsx.")
  }

  if (
    !is.numeric(min_frequency) ||
      length(min_frequency) != 1 ||
      is.na(min_frequency) ||
      min_frequency < 0 ||
      min_frequency > 100
  ) {
    stop("min_frequency deve essere compreso tra 0 e 100.")
  }

  if (
    !is.numeric(digits) ||
      length(digits) != 1 ||
      is.na(digits) ||
      digits < 0 ||
      digits != as.integer(digits)
  ) {
    stop("digits deve essere un intero non negativo.")
  }

  x <- as.data.frame(synoptic)

  # Check required columns
  required <- c(
    "group",
    "species",
    "diagnostic",
    "phi",
    "p.value",
    "dominant"
  )

  if (!all(required %in% names(x))) {
    stop("Mancano alcune colonne richieste in synoptic.")
  }

  if (nrow(x) == 0) {
    stop("La tabella synoptic e' vuota.")
  }

  x$group <- as.character(x$group)
  x$species <- as.character(x$species)

  # Colonne prodotte da synoptic_table(): "G" + etichetta originale
  freq_cols <- names(x)[startsWith(names(x), "G")]

  if (length(freq_cols) == 0) {
    stop("Nessuna colonna di frequenza trovata (G<nome gruppo>).")
  }

  # Rimuove solo la G aggiunta da synoptic_table()
  groups <- substring(freq_cols, 2L)

  # Ordine numerico per 1, 2, 10 oppure G1, G2, G10;
  # per altri nomi mantiene l'ordine delle colonne
  idx <- seq_along(groups)

  if (all(grepl("^[0-9]+$", groups))) {
    idx <- order(as.numeric(groups))
  } else if (all(grepl("^G[0-9]+$", groups))) {
    idx <- order(as.numeric(substring(groups, 2L)))
  }

  groups <- groups[idx]
  freq_cols <- freq_cols[idx]

  if (!all(unique(x$group) %in% groups)) {
    stop("I gruppi in 'group' non corrispondono alle colonne di frequenza.")
  }

  # Keep one row per species
  freq <- x[
    !duplicated(x$species),
    c("species", freq_cols),
    drop = FALSE
  ]

  names(freq) <- c("Species", groups)

  # Check consistency of repeated species frequencies
  freq_check <- unique(
    x[, c("species", freq_cols), drop = FALSE]
  )

  if (any(duplicated(freq_check$species))) {
    stop("Frequenze discordanti per una o piu' specie.")
  }

  # Identify diagnostic species
  diag <- x[
    !is.na(x$diagnostic) & x$diagnostic,
    c("species", "group", "phi", "p.value"),
    drop = FALSE
  ]

  # Sort by decreasing Phi
  diag <- diag[
    order(-diag$phi, na.last = TRUE),
    ,
    drop = FALSE
  ]

  # Primary group: the one with the highest Phi
  diag_main <- diag[
    !duplicated(diag$species),
    ,
    drop = FALSE
  ]

  # Also retain diagnostic associations with multiple groups, if present
  diag_groups <- split(
    diag$group,
    diag$species
  )

  # Diagnostic information
  m <- match(freq$Species, diag_main$species)

  freq$Diagnostic_group <- diag_main$group[m]
  freq$Phi <- diag_main$phi[m]
  freq$p_value <- diag_main$p.value[m]

  # Groups in which each species is dominant
  dominant_groups <- vapply(
    freq$Species,
    function(sp) {
      g <- unique(x$group[
        x$species == sp &
          !is.na(x$dominant) &
          x$dominant
      ])
      if (length(g) == 0) {
        NA_character_
      } else {
        paste(g, collapse = ", ")
      }
    },
    character(1)
  )

  freq$Dominant_in <- dominant_groups

  # Maximum frequency of each species
  freq$max_freq <- apply(
    freq[, groups, drop = FALSE],
    1,
    function(z) {
      if (all(is.na(z))) {
        NA_real_
      } else {
        max(z, na.rm = TRUE)
      }
    }
  )

  # Filter:
  # diagnostic species are always retained
  freq <- freq[
    !is.na(freq$Diagnostic_group) |
      (!is.na(freq$max_freq) &
        freq$max_freq >= min_frequency),
    ,
    drop = FALSE
  ]

  # Sort sections
  freq$section_order <- match(
    freq$Diagnostic_group,
    groups
  )

  freq$section_order[
    is.na(freq$section_order)
  ] <- length(groups) + 1

  freq <- freq[
    order(
      freq$section_order,
      -freq$Phi,
      -freq$max_freq,
      freq$Species,
      na.last = TRUE
    ),
    ,
    drop = FALSE
  ]

  # Round frequencies
  freq[, groups] <- lapply(
    freq[, groups, drop = FALSE],
    round,
    digits = digits
  )

  # Create workbook
  wb <- openxlsx::createWorkbook()

  openxlsx::addWorksheet(
    wb,
    "Synoptic_table",
    gridLines = FALSE
  )

  openxlsx::addWorksheet(
    wb,
    "Original_data",
    gridLines = FALSE
  )

  openxlsx::writeData(
    wb,
    "Original_data",
    x,
    withFilter = TRUE
  )

  # Styles
  header_style <- openxlsx::createStyle(
    fgFill = "#30465B",
    fontColour = "#FFFFFF",
    textDecoration = "bold",
    halign = "center"
  )

  section_style <- openxlsx::createStyle(
    fgFill = "#E7EBF0",
    textDecoration = "bold"
  )

  diagnostic_style <- openxlsx::createStyle(
    fgFill = "#D2DCE6",
    textDecoration = "bold",
    halign = "center"
  )

  freq_format <- if (digits == 0) {
    '0;0;"-"'
  } else {
    paste0(
      "0.",
      strrep("0", digits),
      ";0.",
      strrep("0", digits),
      ';"-"'
    )
  }

  freq_style <- openxlsx::createStyle(
    numFmt = freq_format,
    halign = "center"
  )

  phi_style <- openxlsx::createStyle(
    numFmt = "0.000",
    halign = "center"
  )

  p_style <- openxlsx::createStyle(
    numFmt = "0.0000",
    halign = "center"
  )

  # Headers
  headers <- c(
    "Species",
    paste0(groups, " (%)"),
    "Phi",
    "p-value",
    "Dominant in"
  )

  ncols <- length(headers)

  openxlsx::writeData(
    wb,
    "Synoptic_table",
    "Synoptic table - Species frequency (%)",
    startRow = 1
  )

  openxlsx::writeData(
    wb,
    "Synoptic_table",
    matrix(headers, nrow = 1),
    startRow = 3,
    colNames = FALSE
  )

  openxlsx::addStyle(
    wb,
    "Synoptic_table",
    header_style,
    rows = 3,
    cols = seq_len(ncols),
    gridExpand = TRUE
  )

  # Number of relevés (optional)
  if (!is.null(group_sizes)) {
    if (
      is.null(names(group_sizes)) ||
        !all(groups %in% names(group_sizes))
    ) {
      stop(
        "group_sizes deve avere nomi corrispondenti alle etichette originali dei gruppi."
      )
    }

    n_row <- c(
      "No. of relevés",
      as.integer(group_sizes[groups]),
      "",
      "",
      ""
    )

    openxlsx::writeData(
      wb,
      "Synoptic_table",
      matrix(n_row, nrow = 1),
      startRow = 4,
      colNames = FALSE
    )

    row <- 6
  } else {
    row <- 5
  }

  # Sections to include
  sections <- c(
    groups[groups %in% freq$Diagnostic_group],
    "Other species"
  )

  # Write the table
  for (s in sections) {
    if (s == "Other species") {
      blocco <- freq[
        is.na(freq$Diagnostic_group),
        ,
        drop = FALSE
      ]

      section_name <- "Other frequent species"
    } else {
      blocco <- freq[
        !is.na(freq$Diagnostic_group) &
          freq$Diagnostic_group == s,
        ,
        drop = FALSE
      ]

      section_name <- paste("Diagnostic species", s)
    }

    if (nrow(blocco) == 0) {
      next
    }

    # Section heading
    openxlsx::writeData(
      wb,
      "Synoptic_table",
      section_name,
      startRow = row
    )

    openxlsx::mergeCells(
      wb,
      "Synoptic_table",
      cols = seq_len(ncols),
      rows = row
    )

    openxlsx::addStyle(
      wb,
      "Synoptic_table",
      section_style,
      rows = row,
      cols = seq_len(ncols),
      gridExpand = TRUE
    )

    # Columns for publication
    dati <- blocco[,
      c(
        "Species",
        groups,
        "Phi",
        "p_value",
        "Dominant_in"
      ),
      drop = FALSE
    ]

    n <- nrow(dati)
    rows_data <- (row + 1):(row + n)

    openxlsx::writeData(
      wb,
      "Synoptic_table",
      dati,
      startRow = row + 1,
      colNames = FALSE
    )

    # Format frequencies
    openxlsx::addStyle(
      wb,
      "Synoptic_table",
      freq_style,
      rows = rows_data,
      cols = 2:(length(groups) + 1),
      gridExpand = TRUE,
      stack = TRUE
    )

    # Format Phi
    openxlsx::addStyle(
      wb,
      "Synoptic_table",
      phi_style,
      rows = rows_data,
      cols = length(groups) + 2,
      gridExpand = TRUE,
      stack = TRUE
    )

    # Format p-values
    openxlsx::addStyle(
      wb,
      "Synoptic_table",
      p_style,
      rows = rows_data,
      cols = length(groups) + 3,
      gridExpand = TRUE,
      stack = TRUE
    )

    # Highlight diagnostic cells
    for (g in groups) {
      idx_diag <- which(vapply(
        blocco$Species,
        function(sp) {
          g %in% diag_groups[[sp]]
        },
        logical(1)
      ))

      if (length(idx_diag) > 0) {
        openxlsx::addStyle(
          wb,
          "Synoptic_table",
          diagnostic_style,
          rows = rows_data[idx_diag],
          cols = match(g, groups) + 1,
          gridExpand = TRUE,
          stack = TRUE
        )
      }
    }

    row <- row + n + 2
  }

  # Final formatting
  openxlsx::setColWidths(
    wb,
    "Synoptic_table",
    cols = 1,
    widths = 34
  )

  openxlsx::setColWidths(
    wb,
    "Synoptic_table",
    cols = 2:ncols,
    widths = 15
  )

  openxlsx::setColWidths(
    wb,
    "Original_data",
    cols = seq_along(names(x)),
    widths = "auto"
  )

  openxlsx::freezePane(
    wb,
    "Synoptic_table",
    firstActiveRow = 4
  )

  # Export
  openxlsx::saveWorkbook(
    wb,
    file = file,
    overwrite = TRUE
  )

  message("Tabella sinottica esportata: ", file)

  invisible(freq)
}
