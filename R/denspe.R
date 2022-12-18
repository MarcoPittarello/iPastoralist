#' Matrix for cluster analysis with surveys labelled with the first species ordered by decreasing abundance
#'
#' @description After creating the dendrogram it may be appropriate to append the species sorted by decreasing abundance to each survey in order to facilitate the interpretation of the analysis. The function makes it possible to generate a database with the row names coded as survey code concatenated with a certain number of species ordered by decreasing abundance. Therefore, this database can be used in place of the original database (matrix survey by species) for the calculation of the dissimilarity matrix and for the creation of the dendrogram (e.g. with \link[base]{hclust}). 
#' @param nspe number of species to show in the labels.
#' @param SpeAbund object generated from \link[iPastoralist]{first_ten_species}. #' @param dbClust matrix used for the computation of surveys' distance matrix (e.g. with either \link[amap]{Dist} or \link[vegan]{vegdist}). This matrix has surveys as rows and species as columns.  
#' @return numeric matrix to use for the computation of surveys' distance matrix. The dendrogram plot derived from such a numeric matrix will show the survey ID concatenated with a certain number of species ordered by decreasing abundance.
#' @examples see vignettes
#' @export

denspe=function(nspe=5,SpeAbund,dbClust){
  nspeSel<-3+(nspe-1)
  
  mycols<-names(SpeAbund)[c(1,3:nspeSel)]
  newLabs<-data.frame(do.call(paste,c(SpeAbund[mycols],sep=" | ")))
  newLabs$oldLabs<-SpeAbund$Survey
  colnames(newLabs)<-c("newLab","oldLab")
  
  db.clustLab<-dbClust
  row.names(db.clustLab)<-newLabs$newLab[match(rownames(dbClust),newLabs$oldLab,)]
  return(db.clustLab)
}
