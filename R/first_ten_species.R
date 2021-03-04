#' First ten species for dendrogram
#'
#' @param data_SRA_SC database with abundance data expressed as SRA or SC, calculated with \link[iPastoralist]{vegetation_abundance}.Database class must be *data.frame*
#' @param export Logical. TRUE if you want export data in a csv format
#' @export


first_ten_species=function(data_SRA_SC,export){
  
  database_spe<-data.frame(data_SRA_SC)
  round_SRA_species<-round(database_spe,1)
  database_species<-data.frame(cbind(rownames(database_spe),round_SRA_species))
  options(max.print=5000E5)
  
  df <- data.frame(matrix(ncol = ncol(database_species)*3,
                          nrow = nrow(database_species)))
  
  database_species_no_species_names<-database_species[-c(1)]
  
  for(k in 1:ncol(database_species_no_species_names)){
    df[,(k*3)-2]=database_species[,1]
  }
  df2<-df
  
  for(k in 1:ncol(database_species_no_species_names)){
    df2[,((k*3)-1)]=database_species_no_species_names[,k]
  }
  df3<-df2
  
  for(k in 1:ncol(database_species_no_species_names)){
    df3[,(k*3)]=with(df3,paste0(df3[,(k*3-2)]," ",df3[,(k*3-1)]))
  }
  df4<-df3
  
  df_order <- data.frame(matrix(ncol = ncol(df4),
                                nrow = nrow(df4)))
  
  for(k in 1:ncol(database_species_no_species_names)){
    d1<-df4[,c(((k*3)-2),(((k*3)-2))+1,((k*3)-2)+2)]
    d1_ordered <- d1[order(-d1[,2]),]
    df_order[,((k*3)-2)]=d1_ordered[,1]
    df_order[,(((k*3)-2)+1)]=d1_ordered[,2]
    df_order[,(((k*3)-2)+2)]=d1_ordered[,3]
  }
  
  df_final <- data.frame(matrix(ncol = ncol(df_order)/3,
                                nrow = nrow(df_order)))
  
  for(k in 1:ncol(df_final)){
    df_final[,k]=df_order[,k*3]
  }
  
  
  colnames(df_final)<-names(database_species_no_species_names)
  first_ten_aggregation<-df_final
  return(first_ten_aggregation)
  
  #print(head(first_ten_aggregation,10))
  
  #first_ten_aggregation<<-first_ten_aggregation
  
  if(export==TRUE){
    write.table(t(first_ten_aggregation),"first_ten_species.txt", sep=";")#save data
    
    print("Results (first_ten_species.txt) are stored in")
    getwd()
  }
  
}
