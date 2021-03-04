
<!-- README.md is generated from README.Rmd. Please edit that file -->

# iPastoralist

<!-- badges: start -->

<!-- badges: end -->

## **When to use it**

  - you surveyed botanical composition of grasslands with the vertical
    point-quadrat / pinpoint (or point‐intercept) method, i.e. plant
    species are recorded at fixed interval along a linear transect
    (Daget and Poissonet, 1971)
  - (Optional) Since occasional species are often missed by this method,
    you listed all other plant species included within a X-m buffer area
    around the transect line

## **What it does**

*iPastoralist* allows you to:

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
        linear transects) a %SC value = 0.3% is attributed. More
        detailed information are provided in the function
        “vegetation\_abundance”.
2.  Compute:
      - **Biodiversity indexes**: Species richness, Shannon diversity
        index, Shannon max, Equitability
      - **Forage Pastoral Value (PV)**
      - **Ecological indexes**: Landolt, Ellenberg (either weighted or
        not weighted with plant species abundance and either considering
        or not considering occasional species)
3.  Extract for each survey the firt ten species, ordered decreasingly
    by their abundance (Useful with dendrograms)

## Installation

You can install the development version of *iPastoralist* by running the
following code:

    install.packages("devtools")
    library(devtools)
    install_github("MarcoPittarello/iPastoralist")

## **Data input format**

  - **Rows**: species
  - **Columns**: surveys
  - **Values** are Frequency of occurrence (FO)
  - **Occasional species** are coded as 999
  - Leave other cells empty (i.e NA)
  - database class MUST BE a **dataframe**

| Species    | Survey\_1 | Survey\_2 | Survey\_3 |
| ---------- | --------- | --------- | --------- |
| species\_1 | 12        | 1         |           |
| species\_2 |           | 3         |           |
| species\_3 |           |           | 4         |
| species\_4 | 9         | 18        | 999       |
| …          |           |           |           |

## **Examples**

The dataframe setting should looks like the below one:

![esempio](image/datainput/Diapositiva1.JPG)

  - Columns in GREEN are the Landolt indicator values for each species
  - Column in BLUE contains the Index of Specific Quality (ISQ) for each
    species.
  - Column named Rxx are the vegetation survey codes

In this database, the total number of measurements along the transect
line is **25**.

We can import the dataframe in R environment:

    data <- read_excel("~/yourdata.xlsx")
    View(data)

|        species.name        | species.name.code | F\_Landolt | R\_Landolt | N\_Landolt | ISQ | R1  | R2  | R3 | R4 | R5 | R6 | R7  | R8 | R9 | R10 | R11 | R12 | R13 | R14 | R15 | R16 | R17 | R18 | R19 | R20 | R21 | R22 | R23 | R24 |
| :------------------------: | :---------------: | :--------: | :--------: | :--------: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
|    Achillea macrophylla    |      Achmacr      |    3.0     |     3      |     4      |  1  | NA  | NA  | NA | NA | NA | NA | NA  | NA | NA | NA  | NA  | NA  | NA  |  1  | NA  | NA  | 999 | NA  | NA  | NA  | NA  | NA  | NA  | NA  |
| Achillea millefolium aggr. |      Achmill      |   999.0    |     3      |    999     |  1  | NA  | NA  | NA | NA | NA | NA | 999 | NA | 5  | 999 | 999 | 10  | NA  | NA  | NA  | NA  | NA  | NA  | NA  | 999 | NA  | NA  | NA  | NA  |
|     Achillea moschata      |      Achmosc      |    3.0     |     2      |     2      |  0  | NA  | NA  | NA | NA | NA | NA | NA  | NA | NA | 999 | NA  | NA  | NA  | NA  | NA  | NA  | NA  | NA  | NA  | NA  | 999 | NA  | NA  | NA  |
|       Acinos alpinus       |      Acialpi      |    2.0     |     3      |     2      |  0  | NA  | NA  | NA | NA | NA | NA | NA  | NA | NA | 999 |  2  |  2  | NA  | NA  | NA  | NA  | NA  | NA  | NA  | 999 | NA  | NA  | NA  | NA  |
|     Aconitum lamarckii     |      Acolama      |    4.0     |     5      |     4      |  0  | 999 | NA  | NA | NA | NA | NA | NA  | NA | NA | NA  | NA  | NA  | NA  |  1  | NA  | NA  | 999 | NA  | NA  | NA  | NA  | NA  | NA  | NA  |
|   Adenostyles alliariae    |      Adealli      |    3.5     |     3      |     4      |  0  | NA  | 999 | NA | NA | NA | NA | NA  | NA | NA | NA  | NA  | NA  | NA  |  8  | NA  | NA  |  3  | NA  | 999 | NA  | NA  | NA  | NA  | NA  |

Important note: make sure that the database class is **data.frame**. If
not convert it as shown:

``` r
data<-as.data.frame(data)
```

Now we can select from the whole database only the columns with plant
species names and surveys, i.e. as specified in “Data input format”
section

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

### Example 1

Suppose we want to convert Frequency of occurrence (FO) to Species
percentage cover (%SC), considering also occasional species. As the %SC
for each survey will (likely) be greater than 100, we want to rescale
%SC of each species per each survey to obtain a sum of 100 (i.e. a
proportion of %SC). As the total measurements per transect was 25, FO
should be multiplied by **4** so that they refer to 100 measurements

``` r
library(iPastoralist)
#> 
#> Attaching package: 'iPastoralist'
#> The following object is masked _by_ '.GlobalEnv':
#> 
#>     data
vegetation.sc<-vegetation_abundance(database = vegetation,
                                    species.cover.coefficient = 4,
                                    method = "SRA_SC.fo.occ",
                                    export = F)
                                    
kable(head(vegetation.sc),align = 'c')
```

|         |    R1     |    R2     | R3 | R4 | R5 | R6 |    R7     | R8 |    R9    |   R10    |    R11    |    R12    | R13 |    R14    | R15 | R16 |    R17    | R18 |   R19    |    R20    |    R21    | R22 | R23 | R24 |
| :------ | :-------: | :-------: | :-: | :-: | :-: | :-: | :-------: | :-: | :------: | :------: | :-------: | :-------: | :-: | :-------: | :-: | :-: | :-------: | :-: | :------: | :-------: | :-------: | :-: | :-: | :-: |
| Achmacr | 0.0000000 | 0.0000000 | 0  | 0  | 0  | 0  | 0.0000000 | 0  | 0.000000 | 0.000000 | 0.0000000 | 0.000000  |  0  | 2.643754  |  0  |  0  | 0.1544004 |  0  | 0.000000 | 0.0000000 | 0.0000000 |  0  |  0  |  0  |
| Achmill | 0.0000000 | 0.0000000 | 0  | 0  | 0  | 0  | 0.0918555 | 0  | 6.118079 | 0.103484 | 0.0927357 | 11.289867 |  0  | 0.000000  |  0  |  0  | 0.0000000 |  0  | 0.000000 | 0.0884434 | 0.0000000 |  0  |  0  |  0  |
| Achmosc | 0.0000000 | 0.0000000 | 0  | 0  | 0  | 0  | 0.0000000 | 0  | 0.000000 | 0.103484 | 0.0000000 | 0.000000  |  0  | 0.000000  |  0  |  0  | 0.0000000 |  0  | 0.000000 | 0.0000000 | 0.1133359 |  0  |  0  |  0  |
| Acialpi | 0.0000000 | 0.0000000 | 0  | 0  | 0  | 0  | 0.0000000 | 0  | 0.000000 | 0.103484 | 2.4729521 | 2.257973  |  0  | 0.000000  |  0  |  0  | 0.0000000 |  0  | 0.000000 | 0.0884434 | 0.0000000 |  0  |  0  |  0  |
| Acolama | 0.0971817 | 0.0000000 | 0  | 0  | 0  | 0  | 0.0000000 | 0  | 0.000000 | 0.000000 | 0.0000000 | 0.000000  |  0  | 2.643754  |  0  |  0  | 0.1544004 |  0  | 0.000000 | 0.0000000 | 0.0000000 |  0  |  0  |  0  |
| Adealli | 0.0000000 | 0.1612903 | 0  | 0  | 0  | 0  | 0.0000000 | 0  | 0.000000 | 0.000000 | 0.0000000 | 0.000000  |  0  | 21.150033 |  0  |  0  | 6.1760165 |  0  | 0.172117 | 0.0000000 | 0.0000000 |  0  |  0  |  0  |

we can check that the sum of %SC for each survey is 100

``` r
colSums(vegetation.sc)
#>  R1  R2  R3  R4  R5  R6  R7  R8  R9 R10 R11 R12 R13 R14 R15 R16 R17 R18 R19 R20 
#> 100 100 100 100 100 100 100 100 100 100 100 100 100 100 100 100 100 100 100 100 
#> R21 R22 R23 R24 
#> 100 100 100 100
```

### Example 2

In this case we want to compute the average Landolt indicator values for
each survey, weighted with species abundance.

If the occasional species are not considered, the SRA will be used.
Conversely, if we would like to keep into account also occasional
species, the SRA will be calculated with the %SC rescaled to 100 (more
detail in “vegetation\_abundance” function).

In this case we will consider also occasional specie.

The input database is the one with the Frequency of occurrence, i.e. the
“vegetation” dataframe

``` r
ec.index<-ecological_indexes(database.vegetation = vegetation,
                             database.indexes = data[,c("F_Landolt","R_Landolt","N_Landolt")],
                             occasional.species = TRUE,
                             species.cover.coefficient = 4,
                             weight = TRUE)
#> [1] "INDEX WEIGHTED WITH OCCASIONAL SPECIES"
```

Notes about the above function:

  - **database.indexes** = database with Ecological indicators, without
    the column of species names. NA values must indicated as 999
  - **occasional.species** = Logical. TRUE if you want to take into
    account occasional species.
  - **species.cover.coefficient** = only if “occasional.species=TRUE”.
    Coeffient that multiplies FS so that the number of total touches
    refer to 100
  - **weight**: Logical. TRUE if you want to weight Ecological
    indicators with abundance

the output will be as follow:

``` r
ec.index
#>    survey F_Landolt R_Landolt N_Landolt
#> 1      R1  2.965824  2.219955  2.612569
#> 2      R2  3.624462  1.564516  2.853226
#> 3      R3  2.996234  2.728452  3.567782
#> 4      R4  3.219051  1.570052  3.083395
#> 5      R5  2.787682  2.522204  2.930308
#> 6      R6  2.790819  2.547647  2.839919
#> 7      R7  2.746938  2.280465  2.718616
#> 8      R8  3.083541  2.863599  3.944030
#> 9      R9  2.204344  2.130315  2.447537
#> 10    R10  2.604691  2.449465  2.464643
#> 11    R11  2.512983  2.629985  2.649459
#> 12    R12  2.336297  2.724809  2.540785
#> 13    R13  3.386566  2.210897  2.851104
#> 14    R14  3.411104  2.935228  4.175810
#> 15    R15  2.990157  2.190303  2.637988
#> 16    R16  3.073070  1.668550  2.091525
#> 17    R17  3.449563  2.187854  3.436953
#> 18    R18  2.457642  2.133572  2.369341
#> 19    R19  3.513769  2.036718  3.040734
#> 20    R20  2.733933  2.831368  2.947524
#> 21    R21  2.653381  2.210049  2.394787
#> 22    R22  2.889697  2.323329  2.719369
#> 23    R23  2.695533  2.274914  2.006186
#> 24    R24  2.683857  1.880419  2.004484
```
