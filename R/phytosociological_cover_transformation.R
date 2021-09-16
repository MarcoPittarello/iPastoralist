#' Transformation of phytosociological cover (%) to cover-abundance values
#'
#' @description Species cover visually estimated in a phytosociological survey are transformed to:\cr
#'
#' * Braun-Blanquet cover-abundance scale **(BrBl)** : 
#' * Van Der Maarel cover-abundance scale **(VanDerMaarel)** : 
#' * Modified Braun-Blanquet frequency/abundance scale according to Tasser and Tappeiner (2005)**: \cr
#' 
#'
#' @param database database with visually estimated cover of plant species. Rare species are added as '+". Rows are species and columns are surveys. The first column of the database reports the species names (Important: no space among words must exist). Database class must be *data.frame*
#' @param method * **"BrBl"**: 
#' * **"VanDerMaarel"**: 
#' * **"TassTapp"**: modified Braun-Blanquet frequency/abundance scale
#' @return database cover-abundance values
#' @references * Braun-Blanquet J (1932) Plant sociology. The study of plant communi- ties. GD Fuller and HS Conard (Eds.). Authorized English transla- tions of 'Pflanzensoziologie'. 1st ed. Printed in the United States of America. New York and London: McGraw-Hill Book Co. Inc.\cr
#' * Westhoff V, van der Maarel E (1973) The Braun-Blanquet approach. In: Whittaker RH (Ed.) Handbook of vegetation science, part 5, Classi- fication and ordination of communities. W Junk, The Hague: 617– 726. https://doi.org/10.1007/978-94-010-2701-4_20\cr
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
#'           Note 2: rare species as "+"
#' @export




#

#funzione

PhytoCover<-function(database,method){
veg<-database[,-1]
rownames(veg)<-database[,1]

veg[is.na(veg)]<-0

veg[veg=="+"] <- 9999 
veg1<-sapply(veg, as.numeric)

if (method=="BrBl"){
  return(data.frame(apply(veg1,MARGIN = c(1,2),function(x) ifelse(x>=1 && x<=5,"1",
                                                       ifelse(x>=6 && x<=15,"2a",
                                                              ifelse(x>=16 && x<=25,"2b",
                                                                     ifelse(x>=26 && x<=50,"3",
                                                                            ifelse(x>=51 && x<=75,"4",
                                                                                   ifelse(x>=76 && x<=100,"5",
                                                                                          ifelse(x==0,"0","+"))))))))))
}

else if (method=="VanDerMaler"){
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
