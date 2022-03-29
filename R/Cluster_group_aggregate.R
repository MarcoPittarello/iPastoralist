#' Computation of means for cluster groups (aggregate)
#'
#' @description Once the groups of a cluster have been identified, the average value for each species (or target variable) are computed for each group. Moreover,
#' within each group, species (or target variables) are sorted decreasingly by their cover (or value).
#' @param database a dataframe in which Rows are surveys and Columns are Species. The first column is the identifier of dendrogram groups see @example for a graphical detail
#' @return dataframe with the average value of abundance for each species (or target variable) within each group sorted decreasingly by the abundance
#' @examples  Structure of the database to use as input:
#'
#'       Rows: Vegetation survey
#'       Columns: species
#'       Headings and row names must be imported
#'
#'         Group	  Spe1	  Spe2	...
#'           1     12.3	   0.0
#'           1     0.0     5.0
#'           1     2.0     0.0
#'           1     10.4    0.0
#'           2     0.0     20.7
#'           2     0.0     2.0
#'           2     2.3     0.0
#'           3     0.0     23.3
#'           3     14.3    0.0
#'
#'   Note 1: the column of Group has to be in the first position\cr
#'   
#'   see also vignettes
#' @export



clustGroupAggregate=function(database){
  
  options(max.print=5000E5)
  
  database<-database
  database2<-rbind(database,colnames(database))
  database_heading<-database2[c(nrow(database2),1:(nrow(database2)-1)),]
  
  colnames(database)[1] <- "Group"
  colnames(database_heading)[1] <- "Group"
  
  database_group_numeric<-transform(database,Group=as.numeric(database$Group))
  id_ok<-data.frame(database[,c("Group")])
  id_cod<-data.frame(database_group_numeric[,c("Group")])
  database_id<-cbind(id_ok,id_cod) 
  unique_values_id<-database_id[!duplicated(database_id), ]
  colnames(unique_values_id)<-c("Group name","Id")
  unique_values_id_orderd<- unique_values_id[order(unique_values_id[,2]),]
  
  un_2<-unique_values_id_orderd
  un_3<-unique_values_id_orderd
  
  merge<-rbind(unique_values_id_orderd,un_2,un_3)
  merge_ordered<- merge[order(merge[,2]),]
  
  
  aggregation<-aggregate(database_group_numeric,by=list(database_group_numeric$Group),mean)
  aggregation_t<-t(aggregation)
  aggregation_t1<-aggregation_t[-c(1),]
  
  df <- data.frame(matrix(ncol = ncol(aggregation_t1)*3,
                          nrow = nrow(aggregation_t1)))
  
  for(k in 1:ncol(aggregation_t1)){   
    df[,(k*3)-1]=aggregation_t1[,k]
  } 
  df2<-df
  
  selection_species_names<-as.data.frame(database_heading[1,])
  species_names<-t(selection_species_names)
  
  for(k in 1:ncol(aggregation_t1)){   
    df2[,((k*3)-2)]=species_names[,1]
  } 
  df3<-df2
  
  df4<-df3[-c(1),]
  
  df_final <- data.frame(matrix(ncol = ncol(df4), 
                                nrow = nrow(df4)))
  
  colnames(df_final)<-merge_ordered[,1]
  
  
  for(k in 1:ncol(aggregation_t1)){
    d1<-df4[,c(((k*3)-2),(((k*3)-2))+1)]
    d1_ordered <- d1[order(-d1[,2]),]
    df_final[,((k*3)-2)]=d1_ordered[,1]
    df_final[,(((k*3)-2)+1)]=round(d1_ordered[,2],1)
  }
  
  df_final[is.na(df_final)] <- "" 
  aggregation_cluster.table<-df_final
  return(aggregation_cluster.table)
}

