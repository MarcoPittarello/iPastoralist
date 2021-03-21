#' Transform Frequency of occurrence (FO) to Species relative abundance (SRA) or Species percentage cover(%SC)
#'
#' @description From a database with Frequency of occurrences of species identified along a linear transect and occasional species (i.e. species found within vegetation plots but not along the linear transects), Species relative abundance (SRA) and percentage species cover(%SC) are computed, either considering or not considering occasional species.\cr
#'
#' Terminology:
#' * Frequency of occurrence **(FO)** : number of species occurrences out of 'N' points of vegetation measurements along a transect line
#' * Species relative abundance **(SRA)** : ratio between frequency of occurrence and the sum of frequency of occurrences values for all species in the transect, then multiplied by 100
#' * Species percentage cover **(%SC)**: conversion of frequency of occurrence to 100 measurements (e.g. if a species had a FO= 20 measurements out of 50 total measurements along the transect line, the FO will be multiplied by 2). To all occasional species (i.e. species found within vegetation plots but not along the linear transects) a %SC value = 0.3% is attributed.\cr
#' 
#' see \href{https://raw.githubusercontent.com/MarcoPittarello/iPastoralist/main/image/Wrkflw_abundance_conversion.png}{MarcoPittarello/iPastoralist} for a full graphical explanation
#'
#' @param database database with FO and occasional species as 999. Rows are species and columns are surveys. The first column of the database reports the species names. Database class must be *data.frame*
#' @param method * **"SRA_fo"**: SRA calculated from FO without occasional species.see \href{https://raw.githubusercontent.com/MarcoPittarello/iPastoralist/main/image/Wrkflw_abundance_conversion.png}{MarcoPittarello/iPastoralist} for a full graphical explanation
#' * **"SC_fo"**: %SC calculated by multiplying FO for a coeffient so that the number of total measurements along the transect line refer to 100 (occasional species are excluded). see \href{https://raw.githubusercontent.com/MarcoPittarello/iPastoralist/main/image/Wrkflw_abundance_conversion.png}{MarcoPittarello/iPastoralist} for a full graphical explanation
#' * **"SC_fo_occ"**: like SC_fo but with in addition the occasional species, considered as 0.3%. The total %SC  per each surveys will be > 100 %. see \href{https://raw.githubusercontent.com/MarcoPittarello/iPastoralist/main/image/Wrkflw_abundance_conversion.png}{MarcoPittarello/iPastoralist} for a full graphical explanation
#' * **"SRA_SC.fo.occ"**: SRA calculated from SC_fo_occ, i.e. rescale SC_fo_occ so that the total sum per each survey sum up to 100 %. see \href{https://raw.githubusercontent.com/MarcoPittarello/iPastoralist/main/image/Wrkflw_abundance_conversion.png}{MarcoPittarello/iPastoralist} for a full graphical explanation
#' @param species.cover.coefficient Coeffient that multiplies FO so that the number of total touches refer to 100. Only required when method = "SC_fo_occ","SC_fo", "SRA_SC.fo.occ"
#' @param export Logical. TRUE if you want export data in a csv format
#' @return database with abundance data
#' @references Pittarello, M., Probo, M., Lonati, M., Lombardi, G., 2016. Restoration of sub-alpine shrub-encroached grasslands through pastoral practices: effects on vegetation structure and botanical composition. Appl. Veg. Sci. 19, 381–390. https://doi.org/10.1111/avsc.12222
#' @examples  Structure of the database to use as input:
#'
#'       Rows: species
#'       Columns: vegetation survey
#'       Headings and row names must be imported
#'
#'        	  Species   ril1     ril2
#'             spe1      12
#'             spe2              5
#'             spe3      2      999
#'             spe4      10
#'             spe5             20
#'
#'           Note 1: For species without FO leave the cells empty (NA values)
#'           Note 2: occasional species (i.e. "+") as 999
#' @export


vegetation_abundance<-function(database,method,species.cover.coefficient,export){
  veg1<-database
  row.names(veg1)<-veg1[,1]#attribuzione nome specie come nome righe
  veg2<-veg1[,-1]#elimina colonna nomi specie
  
  veg2[is.na(veg2)]<-0#sostituzione na con 0
  veg.03<-ifelse(veg2==999,yes = 0.3,0)#nuovo database con selezione degli 0.3
  veg.no.piu<-veg2
  veg.no.piu[veg.no.piu==999]<-0 # rimozione 0.3 dal database principale, per calcolo SRA
  
  ## SRA_fo
  if (method=="SRA_fo"){
    if (export=="TRUE"){
      return(data.frame(apply(veg.no.piu, MARGIN = 2, function(veg.no.piu) veg.no.piu/sum(veg.no.piu)*100))) # calcolo SRA senza 0.3
      write.table(data.frame(apply(veg.no.piu, MARGIN = 2, function(veg.no.piu) veg.no.piu/sum(veg.no.piu)*100)),
                  file="SRA_fo.csv",sep = ";")
      
    } else if (export =="FALSE") {
      return(data.frame(apply(veg.no.piu, MARGIN = 2, function(veg.no.piu) veg.no.piu/sum(veg.no.piu)*100))) # calcolo SRA senza 0.3
    }
    
  }
  
  ## SC_fo_occ
  
  else if (method=="SC_fo_occ"){
    if (export=="TRUE"){
      veg.sc<-apply(veg.no.piu, MARGIN = 2, function(veg.no.piu) veg.no.piu*species.cover.coefficient) # calcolo SC senza 0.3
      return(data.frame(veg.sc+veg.03))
      write.table(data.frame(veg.sc+veg.03),file="SC_fo_occ.csv",sep = ";")

    } else if (export =="FALSE") {
      veg.sc<-apply(veg.no.piu, MARGIN = 2, function(veg.no.piu) veg.no.piu*species.cover.coefficient) # calcolo SC senza 0.3
      return(data.frame(veg.sc+veg.03))
    }
  }
  #SC_fo
  else if (method=="SC_fo"){
    if (export=="TRUE"){
      return(data.frame(apply(veg.no.piu, MARGIN = 2, function(veg.no.piu) veg.no.piu*species.cover.coefficient)))
      write.table(data.frame(apply(veg.no.piu, MARGIN = 2, function(veg.no.piu) veg.no.piu*species.cover.coefficient)),file="SC_fo.csv",sep = ";")
      
    } else if (export =="FALSE") {
      return(data.frame(apply(veg.no.piu, MARGIN = 2, function(veg.no.piu) veg.no.piu*species.cover.coefficient)))
      
    }
  }
  
  #SRA_SC.fo.occ
  else if (method=="SRA_SC.fo.occ"){
    if (export=="TRUE"){
      veg.sc<-apply(veg.no.piu, MARGIN = 2, function(veg.no.piu) veg.no.piu*species.cover.coefficient) # calcolo SC senza 0.3
      SC_fo_occ<-data.frame(veg.sc+veg.03) # aggiunta al database SRA degli 0.3, la somma fara' piu' di 100
      return(data.frame(apply(SC_fo_occ, MARGIN = 2, function(SC_fo_occ) SC_fo_occ/sum(SC_fo_occ)*100)))
      write.table(data.frame(apply(SC_fo_occ, MARGIN = 2, function(SC_fo_occ) SC_fo_occ/sum(SC_fo_occ)*100)),
                  file="SRA_SC.fo.occ.csv",sep = ";")
      
    } else if (export =="FALSE") {
      veg.sc<-apply(veg.no.piu, MARGIN = 2, function(veg.no.piu) veg.no.piu*species.cover.coefficient) # calcolo SC senza 0.3
      SC_fo_occ<-data.frame(veg.sc+veg.03) # aggiunta al database SRA degli 0.3, la somma fara' piu' di 100
      return(data.frame(apply(SC_fo_occ, MARGIN = 2, function(SC_fo_occ) SC_fo_occ/sum(SC_fo_occ)*100)))
      
    }
  }
}
