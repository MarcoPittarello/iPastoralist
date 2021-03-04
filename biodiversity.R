#' Biodiversity indexes
#'
#' From a database with Frequency of occurrence (FO) and occasional species as 999 you can compute the following biodiversity indexes:
#' * Species richness
#' * Shannon diversity index (log2)
#' * Shannon max
#' * Equitability
#'
#'
#' @param database database with Frequency of occurrence (FO) and occasional species as 999. Rows are species and columns are surveys.
#' @param occasional.species Logical. TRUE if you want to take into account occasional species. If occasional species are considered, SRA correspond to "SRA_SC.fs.occ" (see \link[iPastoralism]{vegetation_abundance})
#' @param species.cover.coefficient  To set only when "occasional.species=TRUE":coeffient that multiplies FO so that the number of total touches refer to 100. SRA values for Shannon diversity index derive from the "SRA_SC.fo.occ" (see \link[iPastoralism]{vegetation_abundance})
#' @return biodiversity indexes
#' @export

biodiversity=function(database,occasional.species,species.cover.coefficient){
  if(occasional.species==FALSE){
    #se SRA senza specie occasionali --------------------------------------------------------
    
    ################################# Computation of Shannon
    FS_shann<-database[,-1]
    FS_shann[is.na(FS_shann)] <- 0 #replace NA values with 0
    FS_shann[FS_shann==999]<-0
    
    SRA<-apply(FS_shann, 2, function(x) x/sum(x)*100)# Computation of Species Relative Abundance
    
    shannon_computation<-apply(SRA,2,function(x) (x/100)*log2(x/100))
    shannon_computation
    shannon_computation[is.na(shannon_computation)] <- 0 #replace NA values with 0
    shannon<-as.matrix(apply(shannon_computation,2,function(x) sum(x)*-1))
    
    ################################# Computation of species number
    FS_number<-database[,-1]
    FS_number[is.na(FS_number)] <- 0 #replace NA values with 0
    FS_number[FS_number==999]<-0
    
    spec_numb<-as.matrix(apply(FS_number,2,function(x) length(which(x >0))))
    
    ##### Computation of Shannon max
    shannon_max<-as.matrix(log2(spec_numb))
    colnames(shannon_max)<-"Hmax"
    
    ################################# Computation of Equitability
    
    equitability<-as.matrix(apply(shannon,2,function(x) x/shannon_max))
    colnames(equitability)<-"Equitability"
    rownames(equitability)<-names(FS_number)
    
    ################################ Export
    biodiversity.no.occasional<-cbind(data.frame(spec_numb),data.frame(shannon),data.frame(shannon_max),data.frame(equitability))
    return(biodiversity.no.occasional)
  }
  else if (occasional.species==TRUE){
    #se SRA da species cover (SC) e specie occasionali --------------------------------------------------------
    veg2<-database[,-1]#elimina colonna nomi specie
    veg2[is.na(veg2)]<-0#sostituzione na con 0
    veg.03<-ifelse(veg2==999,yes = 0.3,0)#nuovo database con selezione degli 0.3
    veg.no.piu<-veg2
    veg.no.piu[veg.no.piu==999]<-0 # rimozione 0.3 dal database principale, per calcolo SRA
    
    veg.sc<-apply(veg.no.piu, MARGIN = 2, function(veg.no.piu) veg.no.piu*species.cover.coefficient) # calcolo SC senza 0.3
    SC_fs_occ<-data.frame(veg.sc+veg.03) # aggiunta al database SRA degli 0.3, la somma fara' piu' di 100
    SRA_SC.fs.occ<-data.frame(apply(SC_fs_occ, MARGIN = 2, function(SC_fs_occ) SC_fs_occ/sum(SC_fs_occ)*100)) # calcolo SRA senza 0.3
    
    ################################# Computation of Shannon
    shannon_computation<-apply(SRA_SC.fs.occ,2,function(x) (x/100)*log2(x/100))
    shannon_computation
    shannon_computation[is.na(shannon_computation)] <- 0 #replace NA values with 0
    shannon<-as.matrix(apply(shannon_computation,2,function(x) sum(x)*-1))
    
    ################################# Computation of species number
    FS_number<-database[,-1]
    FS_number[is.na(FS_number)] <- 0 #replace NA values with 0
    spec_numb<-as.matrix(apply(FS_number,2,function(x) length(which(x >0))))
    
    ##### Computation of Shannon max
    shannon_max<-as.matrix(log2(spec_numb))
    colnames(shannon_max)<-"Hmax"
    
    ################################# Computation of Equitability
    
    equitability<-as.matrix(apply(shannon,2,function(x) x/shannon_max))
    colnames(equitability)<-"Equitability"
    rownames(equitability)<-names(FS_number)
    
    ################################ Export
    biodiversity.yes.occasional<-cbind(data.frame(spec_numb),data.frame(shannon),data.frame(shannon_max),data.frame(equitability))
    return(biodiversity.yes.occasional)
  }
}
