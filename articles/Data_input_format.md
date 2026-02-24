# Data input format

The database of input has to be structured like this:

- **Rows**: species
- **Columns**: surveys
- **Values** are Frequency of occurrence (FO)
- **Occasional species** are coded as 999
- Leave other cells empty (i.e NA)
- database class MUST BE a **dataframe**

| Species   | Survey_1 | Survey_2 | Survey_3 |
|-----------|----------|----------|----------|
| species_1 | 12       | 1        |          |
| species_2 |          | 3        |          |
| species_3 |          |          | 4        |
| species_4 | 9        | 18       | 999      |
| …         |          |          |          |

Here is an real example image from an excel file:

![“”](Diapositiva1.jpg)

“”

- Columns in GREEN are the Landolt indicator values of each plant
  species
- Column in BLUE contains the Index of Specific Quality (ISQ) for each
  species.
- Column named Rxx are the vegetation survey codes

In this database, the total number of measurements along the transect
line is **25**.

We can import the dataframe in R environment:

    data <- read_excel("~/yourdata.xlsx")
    View(data)

Important note: make sure that the database class is **data.frame**. If
not convert it as shown:

    data<-as.data.frame(data)
