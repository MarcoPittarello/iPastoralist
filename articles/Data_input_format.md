# Data input format

## Purpose and input structure

This vignette creates a complete example directly in R. No spreadsheet,
image, saved workspace, or other external data file is required.

The example represents point-quadrat vegetation surveys with **25
measurement points per transect**. Its column layout, species names,
codes, and selected indicator values follow the example used to
illustrate the package’s input format. The survey observations are a
small illustrative example, not a full transcription of the original
surveys. The indicator values illustrate data handling and should not be
treated as an authoritative ecological reference.

The combined table contains two kinds of information:

- **Species metadata:** names, unique species codes, Landolt indicator
  values, and the Index of Specific Quality (`ISQ`).
- **Vegetation observations:** survey columns named `R1`, `R2`, and so
  on. Rows represent species; entries are frequency of occurrence (FO).

The following conventions apply to **survey columns**:

- An integer from 1 to 25 is the number of measurement points at which
  the species was recorded.
- `999` identifies an occasional species recorded in the survey area but
  outside the transect measurement points. It is a code, not a
  frequency.
- `NA` represents an absent species in this example, matching an empty
  cell in the input table. It does not represent an unknown observation
  here.
- A zero may also be used for absence.

FO is checked per species: the sum across species in a survey need not
equal 25, because multiple species can occur at the same measurement
point.

## Create the example in R

[`data.frame()`](https://rdrr.io/r/base/data.frame.html) creates the
required base-R data frame. Character columns are kept as text and
survey columns contain numeric values.

``` r

example_data <- data.frame(
  species.name = c(
    "Achillea macrophylla",
    "Achillea millefolium aggr.",
    "Achillea moschata",
    "Acinos alpinus",
    "Aconitum lamarckii",
    "Adenostyles alliariae",
    "Agrostis capillaris",
    "Alchemilla vulgaris aggr.",
    "Anthoxanthum alpinum",
    "Arnica montana"
  ),
  species.name.code = c(
    "Achmacr",
    "Achmill",
    "Achmosc",
    "Acialpi",
    "Acolama",
    "Adealli",
    "Agrcapi",
    "Alcvulg",
    "Antalpi",
    "Arnmont"
  ),
  E_Landolt = c(3, 999, 3, 2, 4, 3.5, 2.5, 999, 3, 3.5),
  R_Landolt = c(3, 3, 2, 3, 5, 3, 2, 999, 3, 2),
  N_Landolt = c(4, 999, 2, 2, 4, 4, 2, 999, 2, 2),
  ISQ = c(1, 1, 0, 0, 0, 0, 2, 1.5, 1, 0),
  R1 = c(NA, NA, NA, NA, 999, NA, 5, 999, 6, 999),
  R2 = c(NA, 3, NA, NA, NA, 999, 2, 999, 999, NA),
  R3 = c(1, NA, 999, NA, NA, NA, 1, 4, 999, NA),
  R4 = c(NA, NA, NA, 2, NA, NA, 1, 6, 999, NA),
  R5 = c(NA, NA, NA, NA, NA, NA, 999, 4, 5, NA),
  R6 = c(NA, NA, NA, NA, NA, NA, 12, 4, 3, 999),
  stringsAsFactors = FALSE
)

n_measurements <- 25L
survey_columns <- grep("^R[0-9]+$", names(example_data), value = TRUE)
```

The pattern `^R[0-9]+$` selects survey names such as `R1` or `R24`,
while excluding the indicator column `R_Landolt`.

| species.name.code | E_Landolt | R_Landolt | N_Landolt | ISQ |
|:------------------|----------:|----------:|----------:|----:|
| Achmacr           |       3.0 |         3 |         4 | 1.0 |
| Achmill           |     999.0 |         3 |       999 | 1.0 |
| Achmosc           |       3.0 |         2 |         2 | 0.0 |
| Acialpi           |       2.0 |         3 |         2 | 0.0 |
| Acolama           |       4.0 |         5 |         4 | 0.0 |
| Adealli           |       3.5 |         3 |         4 | 0.0 |
| Agrcapi           |       2.5 |         2 |         2 | 2.0 |
| Alcvulg           |     999.0 |       999 |       999 | 1.5 |
| Antalpi           |       3.0 |         3 |         2 | 1.0 |
| Arnmont           |       3.5 |         2 |         2 | 0.0 |

Species metadata (species codes identify the rows). {.table}

| species.name.code |  R1 |  R2 |  R3 |  R4 |  R5 |  R6 |
|:------------------|----:|----:|----:|----:|----:|----:|
| Achmacr           |  NA |  NA |   1 |  NA |  NA |  NA |
| Achmill           |  NA |   3 |  NA |  NA |  NA |  NA |
| Achmosc           |  NA |  NA | 999 |  NA |  NA |  NA |
| Acialpi           |  NA |  NA |  NA |   2 |  NA |  NA |
| Acolama           | 999 |  NA |  NA |  NA |  NA |  NA |
| Adealli           |  NA | 999 |  NA |  NA |  NA |  NA |
| Agrcapi           |   5 |   2 |   1 |   1 | 999 |  12 |
| Alcvulg           | 999 | 999 |   4 |   6 |   4 |   4 |
| Antalpi           |   6 | 999 | 999 | 999 |   5 |   3 |
| Arnmont           | 999 |  NA |  NA |  NA |  NA | 999 |

Survey observations: FO, occasional species (999), and absences (NA).
{.table}

## Check the observations

These checks verify the data-frame class, unique species identifiers,
numeric survey columns, admissible FO values, and the presence of at
least one transect observation in each survey.

``` r

stopifnot(
  is.data.frame(example_data),
  !anyNA(example_data$species.name),
  all(nzchar(example_data$species.name)),
  !anyDuplicated(example_data$species.name),
  !anyNA(example_data$species.name.code),
  !anyDuplicated(example_data$species.name.code),
  length(survey_columns) > 0L,
  all(vapply(example_data[survey_columns], is.numeric, logical(1)))
)

fo <- as.matrix(example_data[survey_columns])
observed_fo <- fo[!is.na(fo) & fo != 999]

stopifnot(
  all(is.finite(observed_fo)),
  all(observed_fo >= 0 & observed_fo <= n_measurements),
  all(observed_fo == floor(observed_fo)),
  all(colSums(!is.na(fo) & fo != 999 & fo > 0) > 0)
)
```

## Separate the inputs used by the package

The combined table is convenient for data management, but its metadata
must not be interpreted as vegetation observations. For
[`vegetation_abundance()`](https://marcopittarello.github.io/iPastoralist/reference/vegetation_abundance.md),
the **first column must contain species names**, followed only by the
numeric survey columns. Species remain in rows; no transposition is
needed.

``` r

vegetation_data <- example_data[,
  c("species.name", survey_columns),
  drop = FALSE
]

indicator_columns <- c("E_Landolt", "R_Landolt", "N_Landolt")
ecological_data <- example_data[, indicator_columns, drop = FALSE]
isq_data <- example_data[, "ISQ", drop = FALSE]

# Preserve the same species order in all inputs.
rownames(vegetation_data) <- example_data$species.name
rownames(ecological_data) <- example_data$species.name
rownames(isq_data) <- example_data$species.name

stopifnot(
  is.data.frame(vegetation_data),
  identical(rownames(vegetation_data), rownames(ecological_data)),
  identical(rownames(vegetation_data), rownames(isq_data))
)
```

For
[`ecological_indexes()`](https://marcopittarello.github.io/iPastoralist/reference/ecological_indexes.md),
use `vegetation_data` as `database.vegetation` and `ecological_data` as
`database.indexes`. For
[`pastoral_value()`](https://marcopittarello.github.io/iPastoralist/reference/pastoral_value.md),
use `isq_data` as the ISQ input and a previously calculated SRA table as
the abundance input. The indicator and ISQ inputs do not include a
species-name column: these functions associate species by **row
position**, so keep their rows aligned even when row names are present.

**The meaning of `999` depends on the input:**

| Input | Meaning of `999` |
|:---|:---|
| Survey observations | Occasional species, not an FO of 999 |
| Ecological indicators | Missing indicator value, using the package convention |
| ISQ input | Missing ISQ value, using the package convention |

An ISQ of **zero is a valid value**, not a missing value. Do not replace
`999` throughout the combined table without first separating these
inputs.

## A first calculation

With 25 measurement points, the coefficient for converting FO to
percentage cover is `100 / 25 = 4`. The `SC_fo_occ` method also assigns
a percentage cover of 0.3 to each occasional species.

``` r

cover_data <- iPastoralist::vegetation_abundance(
  database = vegetation_data,
  method = "SC_fo_occ",
  species.cover.coefficient = 100 / n_measurements
)

knitr::kable(
  cover_data,
  digits = 1,
  caption = "Percentage cover, including occasional species."
)
```

|                            |   R1 |   R2 |   R3 |   R4 |   R5 |   R6 |
|:---------------------------|-----:|-----:|-----:|-----:|-----:|-----:|
| Achillea macrophylla       |  0.0 |  0.0 |  4.0 |  0.0 |  0.0 |  0.0 |
| Achillea millefolium aggr. |  0.0 | 12.0 |  0.0 |  0.0 |  0.0 |  0.0 |
| Achillea moschata          |  0.0 |  0.0 |  0.3 |  0.0 |  0.0 |  0.0 |
| Acinos alpinus             |  0.0 |  0.0 |  0.0 |  8.0 |  0.0 |  0.0 |
| Aconitum lamarckii         |  0.3 |  0.0 |  0.0 |  0.0 |  0.0 |  0.0 |
| Adenostyles alliariae      |  0.0 |  0.3 |  0.0 |  0.0 |  0.0 |  0.0 |
| Agrostis capillaris        | 20.0 |  8.0 |  4.0 |  4.0 |  0.3 | 48.0 |
| Alchemilla vulgaris aggr.  |  0.3 |  0.3 | 16.0 | 24.0 | 16.0 | 16.0 |
| Anthoxanthum alpinum       | 24.0 |  0.3 |  0.3 |  0.3 | 20.0 | 12.0 |
| Arnica montana             |  0.3 |  0.0 |  0.0 |  0.0 |  0.0 |  0.3 |

Percentage cover, including occasional species. {.table}

The output has species in its row names and surveys in its columns. For
example, the FO of 5 for *Agrostis capillaris* in `R1` becomes 20%,
while the occasional record of *Arnica montana* in `R1` becomes 0.3%.

Alternatively, calculate species relative abundance using only transect
observations. With `SRA_fo`, occasional records do not contribute to the
abundance totals.

``` r

sra_data <- iPastoralist::vegetation_abundance(
  database = vegetation_data,
  method = "SRA_fo"
)

round(colSums(sra_data), 6)
#>  R1  R2  R3  R4  R5  R6 
#> 100 100 100 100 100 100
```

Each survey sums to 100% in this SRA table. Percentage cover and
relative abundance are different quantities: percentage cover need not
sum to 100%.
