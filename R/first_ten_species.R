#' First ten species for dendrogram
#'
#' @description For each survey, plant species names and their abundance are listed in a decreasing order of abundance allowing an easier interpretation of the dendrogram. 
#' @param data_SRA_SC database with abundance data expressed as SRA or SC, calculated with \link[iPastoralist]{vegetation_abundance}.Database class must be *data.frame*. Rows are species and Columns are surveys. Species names must be included as row names and not in the data.
#' @param join.dendrogram LOGICAL. TRUE if species abundance need to be joined with a dendrogram.  
#' @param cluster.hclust Only if 'join.dendrogram = TRUE'. The output from 'hclust' function of 'stats' package has to be specified
#' @return when 'join.dendrogram' = TRUE: a dataframe in which surveys are orderd in the same way of the dendrogram and for each of them are listed the species orderd decreasingly by their abundance. 
#' when 'join.dendrogram' = FALSE: a dataframe in which for each survey the species are ordered decreasingly by their abundance
#' @export

first_ten_species=function(data_SRA_SC, join.dendrogram, cluster.hclust){
  
  
  if (join.dendrogram==FALSE){
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
    df_def<-df_final[,-ncol(df_final)]
    return(df_def)
  }
  
  else if (join.dendrogram==TRUE){
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
    df_def<-df_final[,-ncol(df_final)]
    df_def_t<-t(df_def)
    
    ###
    survey.oder<-iPastoralist::clustOrder(cluster.hclust = cluster.hclust,cluster.group = F)

    order.clust.join<-merge(survey.oder,df_def_t,by.x = "Survey",by.y = "row.names")
    order.clust.join$Survey.order<-as.numeric(order.clust.join$Survey.order)
    
    order.clust.join1<-order.clust.join[order(order.clust.join$Survey.order),]
    return(order.clust.join1)
    
  }
  
  
}


