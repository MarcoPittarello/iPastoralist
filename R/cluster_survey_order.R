#' Extraction of the position and/or the group of appartenance of survey in a dendrogram
#'
#' @param database.cluster: database used for generate the cluster. Rows are survey and Columns are species 
#' @param cluster.hclust: output from 'hclust' function of 'stats' package 
#' @param cluster.group: Logical. TRUE if you want to specify the number of groups of the dendrogram. 
#' @param cluster.number: To be specified only if 'cluster.group' is TRUE. Set the number of groups the dendrogram will be divided
#' @return when 'cluster.group' = TRUE: a dataframe in which for each survey is specified the group id of appartenance and its position in the dendrogram
#' when 'cluster.group' = FALSE: a dataframe in which for each survey its position in the dendrogram
#' @export

clustOrder<-function(database.cluster,cluster.hclust,cluster.group,cluster.number){
  
  if (cluster.group==TRUE){
    #database with cluster groups
    cluster.groups<-data.frame(cutree(cluster.hclust,k=cluster.number))#cut dendrogram with k groups
    cluster.groups$Survey<-row.names(cluster.groups)#add column with survey name
    colnames(cluster.groups)[1] <- "cluster"#rename column cluster groups as cluster
    cluster.groups<-cluster.groups[order(cluster.groups$Survey),]#order db by survey name
    
    #database with the survey order in the dendrogram
    survey.order<-data.frame(cbind(cluster.hclust$labels[c(cluster.hclust$order)],
                                   c(1:nrow(database.cluster))))#dataframe with survey name and its order in the dendrogram
    colnames(survey.order)[1] <- "Survey"
    colnames(survey.order)[2] <- "Survey.order"
    survey.order<-survey.order[order(survey.order$Survey),]#order db by survey name
    
    table<-data.frame(cbind(cluster.groups,survey.order))#merge od database
    table1<-table[,c(2,1,4)]#selection of columns
    rownames(table1)<-NULL
    return(table1)
    
  }
  
  else if (cluster.group==FALSE){
    return(data.frame(cbind(cluster$labels[c(cluster$order)],
                     c(1:nrow(dendro)))))
  }
  
}
