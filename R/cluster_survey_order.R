#' Individuation of the position and/or the group of appartenance of surveys in a dendrogram
#' @description After the creation of a dendrogram image, it would be helpful to associate to it also the survey code in a text format. The 'clustOrder' function allows to extract the survey codes in a text format with associated the respective position in the dendrogram.
#' If groups of a dendrogram have been identified, also the ID group will be associated to each survey code.
#' @param cluster.hclust: output from 'hclust' function of 'stats' package 
#' @param cluster.group: Logical. TRUE if you want to specify the number of groups of the dendrogram. 
#' @param cluster.number: To be specified only if 'cluster.group' is TRUE. Set the number of groups the dendrogram will be divided
#' @return when 'cluster.group' = TRUE: a dataframe in which for each survey is specified the group id of appartenance and its position in the dendrogram
#' when 'cluster.group' = FALSE: a dataframe in which for each survey its position in the dendrogram
#' @examples see vignettes
#' @export

clustOrder<-function(cluster.hclust,cluster.group,cluster.number){
  
  if (cluster.group==TRUE){
    #database with cluster groups
    cluster.groups<-data.frame(cutree(cluster.hclust,k=cluster.number))#cut dendrogram with k groups
    cluster.groups$Survey<-row.names(cluster.groups)#add column with survey name
    colnames(cluster.groups)[1] <- "cluster"#rename column cluster groups as cluster
    cluster.groups<-cluster.groups[order(cluster.groups$Survey),]#order db by survey name
    
    #database with the survey order in the dendrogram
    survey.order<-cluster.hclust$labels[c(cluster.hclust$order)]
    survey.order1<-data.frame(survey.order,c(1:length(survey.order)))
    colnames(survey.order1)[1] <- "Survey"
    colnames(survey.order1)[2] <- "Survey.order"

    table<-data.frame(merge(cluster.groups,survey.order1,by="Survey"))#merge od database
    return(table)
    
  }
  
  else if (cluster.group==FALSE){
    survey.order<-cluster.hclust$labels[c(cluster.hclust$order)]
    survey.order1<-data.frame(survey.order,c(1:length(survey.order)))
    colnames(survey.order1)[1] <- "Survey"
    colnames(survey.order1)[2] <- "Survey.order"
    
    return(survey.order1)
    
  }
  
}
