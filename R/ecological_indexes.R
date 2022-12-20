#' Computation of Ecological indicators (Landolt, Ellenberg) from vertical point-quadrat method surveys
#'
#' @description Computation of Ecological indicators, which can be either weighted or not weighted with SRA. Occasional species can be taken into
#' account. If occasional species are considered, SRA correspond to "SRA_SC.fo.occ" (see \link[iPastoralist]{vegetation_abundance})
#' @param database.vegetation database with Frequency of occurrence (FO) and occasional species as 999 (see \link[iPastoralist]{vegetation_abundance}). Rows are species and columns are surveys. The column of species names must be imported. Database class must be *data.frame*
#' @param database.indexes database with Ecological indicators, without the column of species names. NA values must indicated as 999
#' @param occasional.species Logical. TRUE if you want to take into account occasional species. If occasional species are considered, SRA correspond to "SRA_SC.fo.occ" (see \link[iPastoralist]{vegetation_abundance})
#' @param species.cover.coefficient only if "occasional.species=TRUE". Coeffient that multiplies FS so that the number of total touches refer to 100
#' @param weight Logical. TRUE if you want to weight Ecological indicators with SRA.
#' @return database with Ecological indicators for each survey.
#' @import reshape2
#' @examples Structure of the database with Ecological Indicators to use as input:
#'
#'       Headings must be imported. Species name column has not to be considered.
#'
#'             N_Landolt T_Landolt
#'             2         5
#'             5         1
#'             4         999
#'
#'       Note: For species without an Index value specify a value of 999.\cr
#'  see also vignettes
#' @export

ecological_indexes=function(database.vegetation,database.indexes,occasional.species,species.cover.coefficient,weight){
  database<-database.vegetation
  index<-database.indexes
  index[index==999]<-0
  veg1<-database
  row.names(veg1)<-veg1[,1]#attribuzione nome specie come nome righe
  veg2<-veg1[,-1]#elimina colonna nomi specie
  veg2[is.na(veg2)]<-0#sostituzione na con 0
  
  survey.name<-data.frame(names(veg2))
  
  if (occasional.species==TRUE){
    veg.03<-ifelse(veg2==999,yes = 0.3,0)#nuovo database con selezione degli 0.3
    veg.no.piu<-veg2
    veg.no.piu[veg.no.piu==999]<-0 # rimozione 0.3 dal database principale, per calcolo SRA
    
    veg.sc<-apply(veg.no.piu, MARGIN = 2, function(veg.no.piu) veg.no.piu*species.cover.coefficient) # calcolo SC senza 0.3
    SC_fs_occ<-data.frame(veg.sc+veg.03) # aggiunta al database SRA degli 0.3, la somma fara' piu' di 100
    SRA_SC.fs.occ<-data.frame(apply(SC_fs_occ, MARGIN = 2, function(SC_fs_occ) SC_fs_occ/sum(SC_fs_occ)*100)) # calcolo SRA senza 0.3
    
    if(weight==TRUE){
      db<-cbind(index,SRA_SC.fs.occ)
      db.rshp <- melt(data = db,
                      id.vars=c((ncol(index)+1):ncol(db)), #those that remain in columns
                      measure.vars=c(1:ncol(index))) # those that get "moved to the top"
      
      lev<-levels(db.rshp$variable)
      
      index.w<-list()
      
      
      for(i in lev){
        
        index.subset<-subset(db.rshp,variable==i& value > 0)
        
        Selection_column_index<-as.data.frame(index.subset[,ncol(index.subset)])
        Selection_column_SRA<-as.data.frame(index.subset[,c(1:ncol(veg2))])
        
        Sum_selection_column_SRA<-as.matrix(apply(Selection_column_SRA, 2, sum)) #sum of SRA for each survey
        
        Sum_SRAxIndex<-as.matrix(apply(Selection_column_SRA, 2,function(x) sum(x*Selection_column_index)))# sum for each survey of the
        #product between SRAi and Indexi
        
        Index_weighted<-as.data.frame(apply(Sum_SRAxIndex,2,function(x) x/Sum_selection_column_SRA))
        #rownames(Index_weighted)<-colnames(abundance)
        colnames(Index_weighted)<-unique(index.subset$variable)
        
        index.w[[i]]<-Index_weighted
        
      }
      
      index.weighted.with.occasional<-cbind(survey.name,do.call(cbind,index.w))
      colnames(index.weighted.with.occasional)[1]<-"survey"
      print("INDEX WEIGHTED WITH OCCASIONAL SPECIES")
      return(index.weighted.with.occasional)
      
    }
    else if(weight==FALSE)
    {
      abundance<-database[,-1]
      abundance_pa<-database[,-1]
      abundance_pa[abundance_pa>0]<-1 # convert FS database in presence/absence database
      abundance_pa[is.na(abundance_pa)]<-0
      
      db<-cbind(index,abundance_pa)
      db.rshp.nw <- melt(data = db,
                         id.vars=c((ncol(index)+1):ncol(db)), #those that remain in columns
                         measure.vars=c(1:ncol(index))) # those that get "moved to the top"
      
      lev.nw<-levels(db.rshp.nw$variable)
      
      index.nw<-list()
      
      
      for(i in lev.nw){
        
        indexnw.subset<-subset(db.rshp.nw,variable==i & value > 0)
        
        Selection_column_index<-as.data.frame(indexnw.subset[,ncol(indexnw.subset)])
        Selection_column_pa<-as.data.frame(indexnw.subset[,c(1:ncol(veg2))])
        
        Sum_selection_column_pa<-as.matrix(apply(Selection_column_pa, 2, sum)) #sum of SRA for each survey
        
        Sum_paxIndex<-as.matrix(apply(Selection_column_pa, 2,function(x) sum(x*Selection_column_index)))# sum for each survey of the
        #product between SRAi and Indexi
        
        Index_not_weighted<-as.data.frame(apply(Sum_paxIndex,2,function(x) x/Sum_selection_column_pa))
        #rownames(Index_not_weighted)<-colnames(abundance)
        colnames(Index_not_weighted)<-unique(indexnw.subset$variable)
        
        index.nw[[i]]<-Index_not_weighted
        
      }
      
      
      index.NOT.weighted.with.occasional<-cbind(survey.name,do.call(cbind,index.nw))
      colnames(index.NOT.weighted.with.occasional)[1]<-"survey"
      print("INDEX NOT WEIGHTED WITH OCCASIONAL SPECIES")
      return(index.NOT.weighted.with.occasional)
      
    }
    
  }
  else if (occasional.species==FALSE){
    veg.no.piu<-veg2
    veg.no.piu[veg.no.piu==999]<-0 # rimozione 0.3 dal database principale, per calcolo SRA
    SRA_fs<-data.frame(apply(veg.no.piu, MARGIN = 2, function(veg.no.piu) veg.no.piu/sum(veg.no.piu)*100)) # calcolo SRA senza 0.3
    
    
    if(weight==TRUE){
      db<-cbind(index,SRA_fs)
      db.rshp <- melt(data = db,
                      id.vars=c((ncol(index)+1):ncol(db)), #those that remain in columns
                      measure.vars=c(1:ncol(index))) # those that get "moved to the top"
      
      lev<-levels(db.rshp$variable)
      
      index.w<-list()
      
      
      for(i in lev){
        
        index.subset<-subset(db.rshp,variable==i& value > 0)
        
        Selection_column_index<-as.data.frame(index.subset[,ncol(index.subset)])
        Selection_column_SRA<-as.data.frame(index.subset[,c(1:ncol(veg2))])
        
        Sum_selection_column_SRA<-as.matrix(apply(Selection_column_SRA, 2, sum)) #sum of SRA for each survey
        
        Sum_SRAxIndex<-as.matrix(apply(Selection_column_SRA, 2,function(x) sum(x*Selection_column_index)))# sum for each survey of the
        #product between SRAi and Indexi
        
        Index_weighted<-as.data.frame(apply(Sum_SRAxIndex,2,function(x) x/Sum_selection_column_SRA))
        #rownames(Index_weighted)<-colnames(abundance)
        colnames(Index_weighted)<-unique(index.subset$variable)
        
        index.w[[i]]<-Index_weighted
        
      }
      
      index.weighted.withOUT.occasional<-cbind(survey.name,do.call(cbind,index.w))
      colnames(index.weighted.withOUT.occasional)[1]<-"survey"
      print("INDEX WEIGHTED WITHOUT OCCASIONAL SPECIES")
      return(index.weighted.withOUT.occasional)
      
      
    }
    else if(weight==FALSE)
    {
      abundance_pa<-veg.no.piu
      abundance_pa[abundance_pa>0]<-1 # convert FS database in presence/absence database
      abundance_pa[is.na(abundance_pa)]<-0
      
      db<-cbind(index,abundance_pa)
      db.rshp.nw <- melt(data = db,
                         id.vars=c((ncol(index)+1):ncol(db)), #those that remain in columns
                         measure.vars=c(1:ncol(index))) # those that get "moved to the top"
      
      lev.nw<-levels(db.rshp.nw$variable)
      
      index.nw<-list()
      
      
      for(i in lev.nw){
        
        indexnw.subset<-subset(db.rshp.nw,variable==i & value > 0)
        
        Selection_column_index<-as.data.frame(indexnw.subset[,ncol(indexnw.subset)])
        Selection_column_pa<-as.data.frame(indexnw.subset[,c(1:ncol(veg2))])
        
        Sum_selection_column_pa<-as.matrix(apply(Selection_column_pa, 2, sum)) #sum of SRA for each survey
        
        Sum_paxIndex<-as.matrix(apply(Selection_column_pa, 2,function(x) sum(x*Selection_column_index)))# sum for each survey of the
        #product between SRAi and Indexi
        
        Index_not_weighted<-as.data.frame(apply(Sum_paxIndex,2,function(x) x/Sum_selection_column_pa))
        #rownames(Index_not_weighted)<-colnames(abundance)
        colnames(Index_not_weighted)<-unique(indexnw.subset$variable)
        
        index.nw[[i]]<-Index_not_weighted
        
      }
      
      index.NOT.weighted.withOUT.occasional<-cbind(survey.name,do.call(cbind,index.nw))
      colnames(index.NOT.weighted.withOUT.occasional)[1]<-"survey"
      print("INDEX NOT WEIGHTED WITHOUT OCCASIONAL SPECIES")
      return(index.NOT.weighted.withOUT.occasional)
      
    }
    
  }
  
}
