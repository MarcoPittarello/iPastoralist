#' Transformation of visually estimated cover (%) in a phytosociological survey to cover-abundance values
#'
#' @description Species cover visually estimated in a phytosociological survey are transformed to:\cr
#'
#' * Braun-Blanquet cover-abundance scale (Braun-Blanquet,1932)
#' * Van Der Maarel cover-abundance scale (Van Der Maarel, 1978)
#' * Dominance percentage (Tasser and Tappeiner, 2005) \cr
#' 
#' see @details
#'
#' @param database database with visually estimated cover of plant species. Rare species are added as '+". Rows are species and columns are surveys. The first column of the database reports the species names (Important: no space among words must exist). Database class must be *data.frame*
#' @param method * **"BrBl"**: transform cover visually estimated to the Braun-Blanquet cover-abundance scale (see @details )
#' * **"Maarel"**: transform cover visually estimated to the Van Der Maarel cover-abundance scale (see @details )
#' * **"TassTapp"**: transform cover visually estimated to dominance percentage according to Tasser and Tappeiner (2005) (see @details ) 
#' @details 
#' Conversion table
#' 
#' | Visually estimated cover (%)| Braun Blanquet | Van Der Maarel  | Tasser and Tappeiner|
#' | :-------------------: |:-------:| :------:|:------:|
#' | 0| 0 | 0 | 0 |
#' | <1|+| 2 | 0.3 |
#' |1 - 5|  1 | 3 | 2.8 |
#' | 6 -15| 2a  | 5 | 10 |
#' |16-25| 2b | 5 | 20.5 |
#' |26-50| 3 |7  | 38  |
#' |51-75| 4  | 8 | 63 |
#' |76-100| 5  | 9  | 88 |
#' @md
#' 
#' #' @return database with cover-abundance values. Rows are species and columns are surveys
#' @references * Braun-Blanquet J (1932) Plant sociology. The study of plant communi- ties. GD Fuller and HS Conard (Eds.). Authorized English translations of 'Pflanzensoziologie'. 1st ed. Printed in the United States of America. New York and London: McGraw-Hill Book Co. Inc.\cr
#' * Van der Maarel, E. (1979). Transformation of cover-abundance values in phytosociology and its effects on community similarity. Vegetatio, 39(2), 97-114.\cr
#' * Tasser E, Tappeiner U (2005) New model to predict rooting in diverse plant community compositions. Ecological Modelling 185:195-211.\cr
#' @examples  Structure of the database to use as input:
#'
#'       Rows: species
#'       Columns: vegetation survey
#'       Headings and row names must be imported
#'
#'        	  Species   ril1     ril2
#'             spe1      +
#'             spe2              3
#'             spe3      2      34
#'             spe4      10
#'             spe5             20
#'
#'           Note 1: For species without cover leave the cells empty (NA values)
#'           Note 2: rare species as '+'
#' @export

PhytoCover<-function(database,method){
veg<-database[,-1]
rownames(veg)<-database[,1]

veg[is.na(veg)]<-0

veg[veg=="+"] <- 9999 
veg1<-data.frame(sapply(veg, as.numeric))
row.names(veg1)<-row.names(veg)

if (method=="BrBl"){
  return(data.frame(apply(veg1,MARGIN = c(1,2),function(x) ifelse(x>=1 && x<=5,"1",
                                                       ifelse(x>=6 && x<=15,"2a",
                                                              ifelse(x>=16 && x<=25,"2b",
                                                                     ifelse(x>=26 && x<=50,"3",
                                                                            ifelse(x>=51 && x<=75,"4",
                                                                                   ifelse(x>=76 && x<=100,"5",
                                                                                          ifelse(x==0,"0","+"))))))))))
  
  
}

else if (method=="Maarel"){
  return(data.frame(apply(veg1,MARGIN = c(1,2),function(x) ifelse(x>=1 && x<=5,3,
                                                       ifelse(x>=6 && x<=25,5,
                                                              ifelse(x>=26 && x<=50,7,
                                                                     ifelse(x>=51 && x<=75,8,
                                                                            ifelse(x>=76 && x<=100,9,
                                                                                   ifelse(x==0,0,2)))))))))
}

else if (method=="TassTapp"){
  return(data.frame(apply(veg1,MARGIN = c(1,2),function(x) ifelse(x>=1 && x<=5,2.8,
                                                       ifelse(x>=6 && x<=15,10,
                                                              ifelse(x>=16 && x<=25,20.5,
                                                                     ifelse(x>=26 && x<=50,38,
                                                                            ifelse(x>=51 && x<=75,63,
                                                                                   ifelse(x>=76 && x<=100,88,
                                                                                          ifelse(x==0,0,0.3))))))))))
}
  
}
