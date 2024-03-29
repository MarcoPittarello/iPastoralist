% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ecological_indexesPHYTO.R
\name{ecological_indexesPHYTO}
\alias{ecological_indexesPHYTO}
\title{Computation of Ecological indicators (Landolt, Ellenberg) from phytosociological surveys}
\usage{
ecological_indexesPHYTO(database.vegetation, database.indexes)
}
\arguments{
\item{database.vegetation}{database with species cover or abundance. Rows are species and columns are surveys. The column of species names must be imported. Database class must be \emph{data.frame}}

\item{database.indexes}{database with Ecological indicators, without the column of species names. NA values must indicated as 999}
}
\value{
a list with weighted and not weighted ecological indicators for each survey.
}
\description{
Computation of Ecological indicators, which can be either weighted or not weighted with SRA. Occasional species can be taken into account.
}
\examples{
Structure of the database with Ecological Indicators to use as input:

      Headings must be imported. Species name column has not to be considered.

            N_Landolt T_Landolt
            2         5
            5         1
            4         999

      Note: For species without an Index value specify a value of 999.\cr
 see also vignettes
}
