#' Computation of Pastoral Value (PV)
#'
#' @description The forage productivity and quality can be expressed through the 
#' Pastoral Value (PV), which is a unique and synthetic index derived from sward botanical 
#' composition summarizing forage yield, quality, and palatability for livestock (Daget and Poissonet, 1969, Pittarello et al. 2018, 2020).\cr
#' 
#' Computation of PV from a database with SRA, either SRA_fo or SRA_SC.fo.occ (see \link[iPastoralist]{vegetation_abundance})
#' @param SRA_data database with SRA values, either 'SRA_fo' or 'SRA_SC.fo.occ' (see \link[iPastoralist]{vegetation_abundance}). Database class must be *data.frame*
#' @param isq_data database with ISQ values. Species without an ISQ have to be specified with 999.Database class must be *data.frame*
#' @return database with PV computed per each survey
#' @references * Daget, P., Poissonet, J., 1969. Analyse phytologique des praries, Centre Nat. ed, Applications agronomiques. Montpellier - France
#' * Pittarello, M., Lonati, M., Gorlier, A., Perotti, E., Probo, M., Lombardi, G., 2018. Plant diversity and pastoral value in alpine pastures are maximized at different nutrient indicator values. Ecol. Indic. 85, 518–524. https://doi.org/10.1016/j.ecolind.2017.10.064
#' * Pittarello, M., Lonati, M., Ravetto Enri, S., Lombardi, G., 2020. Environmental factors and management intensity affect in different ways plant diversity and pastoral value of alpine pastures. Ecol. Indic. 115, 106429. https://doi.org/10.1016/j.ecolind.2020.106429
#' @export

pastoral_value=function (SRA_data,isq_data){
  database<-cbind(isq_data,SRA_data)
  
  colnames(database)[1]<-"ISQ"
  ISQ_selection<-subset(database, ISQ< 999)# selection of species with ISQ ranging
  #between 0 and 1. NA values are excluded
  
  #Extraction of ISQ column from PV_database
  ISQ<-subset(ISQ_selection, select=c(ISQ))
  
  #Extraction of FS columns from PV_database
  abundance<-ISQ_selection[ -c(1) ]#exclude only the first column
  
  #computation of PV for each Ril column
  PV<-apply(abundance, 2, function(x) sum(x*ISQ)*0.2)
  return(data.frame(PV))
}
