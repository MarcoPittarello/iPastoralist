
<!-- README.md is generated from README.Rmd. Please edit that file -->

# iPastoralist

<!-- badges: start -->

<!-- badges: end -->

## What it does

iPastoralist allows you to:

1.  Transform **Frequency of occurrences (FO)** of species identified
    along a linear transect (either with or without occasional species)
    to:
      - **Species relative abundance (SRA)** : ratio between frequency
        of occurrence and the sum of frequency of occurrences values for
        all species in the transect, then multiplied by 100
      - **Species percentage cover (%SC)**: conversion of frequency of
        occurrence to 100 measurements (e.g. if a species had a FO= 20
        measurements out of 50 total measurements along the transect
        line, the FO will be multiplied by 2). To all occasional species
        (i.e. species found within vegetation plots but not along the
        linear transects) a %SC value = 0.3% is attributed.
2.  Compute:
      - **Biodiversity indexes**: Species richness, Shannon diversity
        index, Shannon max, Equitability
      - **Forage Pastoral Value (PV)**
      - **Ecological indexes**: Landolt, Ellenberg (either weighted or
        not weighted with plant species abundance)
3.  Sort species descendingly each survey First ten species

## Installation

You can install the development version of iPastoralist from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("MarcoPittarello/iPastoralist")
```

## Data input format

  - **Rows**: species
  - **Columns**: surveys
  - **Values** are Frequency of occurrence (FO)
  - **Occasional species** are coded as 999
  - Leave other cells empty (i.e NA)

| Species    | Survey\_1 | Survey\_2 | Survey\_3 |
| ---------- | --------- | --------- | --------- |
| species\_1 | 12        | 1         |           |
| species\_2 |           | 3         |           |
| species\_3 |           |           | 4         |
| species\_4 | 9         | 18        | 999       |
| …          |           |           |           |

## Example

The dataframe setting should looks like the below one:

![esempio](image/datainput/Diapositiva1.JPG)

Then import the dataframe in R environment

``` r
'data <- read_excel("~/yourdata.xlsx")
View(data)'
```

|        species.name        | species.name.code | F\_Landolt | R\_Landolt | N\_Landolt | ISQ | R1  | R2  | R3 | R4 | R5 | R6 | R7  | R8 | R9 | R10 | R11 | R12 | R13 | R14 | R15 | R16 | R17 | R18 | R19 | R20 | R21 | R22 | R23 | R24 |
| :------------------------: | :---------------: | :--------: | :--------: | :--------: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
|    Achillea macrophylla    |      Achmacr      |    3.0     |     3      |     4      |  1  | NA  | NA  | NA | NA | NA | NA | NA  | NA | NA | NA  | NA  | NA  | NA  |  1  | NA  | NA  | 999 | NA  | NA  | NA  | NA  | NA  | NA  | NA  |
| Achillea millefolium aggr. |      Achmill      |   999.0    |     3      |    999     |  1  | NA  | NA  | NA | NA | NA | NA | 999 | NA | 5  | 999 | 999 | 10  | NA  | NA  | NA  | NA  | NA  | NA  | NA  | 999 | NA  | NA  | NA  | NA  |
|     Achillea moschata      |      Achmosc      |    3.0     |     2      |     2      |  0  | NA  | NA  | NA | NA | NA | NA | NA  | NA | NA | 999 | NA  | NA  | NA  | NA  | NA  | NA  | NA  | NA  | NA  | NA  | 999 | NA  | NA  | NA  |
|       Acinos alpinus       |      Acialpi      |    2.0     |     3      |     2      |  0  | NA  | NA  | NA | NA | NA | NA | NA  | NA | NA | 999 |  2  |  2  | NA  | NA  | NA  | NA  | NA  | NA  | NA  | 999 | NA  | NA  | NA  | NA  |
|     Aconitum lamarckii     |      Acolama      |    4.0     |     5      |     4      |  0  | 999 | NA  | NA | NA | NA | NA | NA  | NA | NA | NA  | NA  | NA  | NA  |  1  | NA  | NA  | 999 | NA  | NA  | NA  | NA  | NA  | NA  | NA  |
|   Adenostyles alliariae    |      Adealli      |    3.5     |     3      |     4      |  0  | NA  | 999 | NA | NA | NA | NA | NA  | NA | NA | NA  | NA  | NA  | NA  |  8  | NA  | NA  |  3  | NA  | 999 | NA  | NA  | NA  | NA  | NA  |

In this database example, the total number of measurements along the
transect line was **25**.

Now we can select extract from the whole database only the columns with
plant species names and surveys, i.e. as specified in “Data input
format” section

``` r
vegetation<-data[,c(2,7:30)]
kable(head(vegetation),align = 'c')
```

| species.name.code | R1  | R2  | R3 | R4 | R5 | R6 | R7  | R8 | R9 | R10 | R11 | R12 | R13 | R14 | R15 | R16 | R17 | R18 | R19 | R20 | R21 | R22 | R23 | R24 |
| :---------------: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
|      Achmacr      | NA  | NA  | NA | NA | NA | NA | NA  | NA | NA | NA  | NA  | NA  | NA  |  1  | NA  | NA  | 999 | NA  | NA  | NA  | NA  | NA  | NA  | NA  |
|      Achmill      | NA  | NA  | NA | NA | NA | NA | 999 | NA | 5  | 999 | 999 | 10  | NA  | NA  | NA  | NA  | NA  | NA  | NA  | 999 | NA  | NA  | NA  | NA  |
|      Achmosc      | NA  | NA  | NA | NA | NA | NA | NA  | NA | NA | 999 | NA  | NA  | NA  | NA  | NA  | NA  | NA  | NA  | NA  | NA  | 999 | NA  | NA  | NA  |
|      Acialpi      | NA  | NA  | NA | NA | NA | NA | NA  | NA | NA | 999 |  2  |  2  | NA  | NA  | NA  | NA  | NA  | NA  | NA  | 999 | NA  | NA  | NA  | NA  |
|      Acolama      | 999 | NA  | NA | NA | NA | NA | NA  | NA | NA | NA  | NA  | NA  | NA  |  1  | NA  | NA  | 999 | NA  | NA  | NA  | NA  | NA  | NA  | NA  |
|      Adealli      | NA  | 999 | NA | NA | NA | NA | NA  | NA | NA | NA  | NA  | NA  | NA  |  8  | NA  | NA  |  3  | NA  | 999 | NA  | NA  | NA  | NA  | NA  |

Suppose we want to convert Frequency of occurrence (FO) to Species
percentage cover (%SC), considering also occasional species. As the
total measurements per transect was 25, FO should be multiplied by **4**
so that they refer to 100 measurements

``` r
library(iPastoralist)
vegetation.sc<-vegetation_abundance(database = vegetation,
                                    species.cover.coefficient = 4,
                                    method = "SC_fo_occ",
                                    export = F)
                                    
```
