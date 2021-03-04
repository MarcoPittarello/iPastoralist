#' Computation of Pastoral Value (PV)
#'
#' Computation of PV from a database with SRA, either SRA_fs or SRA_SC.fo.occ (see \link[iPastoralist]{vegetation_abundance})
#' @param SRA_data database with SRA values, either 'SRA_fs' or 'SRA_SC.fo.occ' (see \link[iPastoralist]{vegetation_abundance}). Database class must be *data.frame*
#' @param isq_data database with ISQ values. Database class must be *data.frame*
#' @return database with PV
#' @export

pastoral_value=function (SRA_data,isq_data){
  database<-cbind(isq_data,SRA_data)
  
  colnames(database)[1]<-"ISQ"
  ISQ_selection<-subset(database, ISQ>= 0)# selection of species with ISQ ranging
  #between 0 and 1. NA values are excluded
  
  #Extraction of ISQ column from PV_database
  ISQ<-subset(ISQ_selection, select=c(ISQ))
  
  #Extraction of FS columns from PV_database
  abundance<-ISQ_selection[ -c(1) ]#exclude only the first column
  
  #computation of PV for each Ril column
  PV_df<-apply(abundance, 2, function(x) sum(x*ISQ)*0.2)
  PV<<-data.frame(PV_df)
  print(PV)
}
