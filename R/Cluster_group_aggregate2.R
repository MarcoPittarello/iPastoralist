#' Computation of means for cluster groups (aggregate)
#'
#' @description Once the groups of a cluster have been identified, the average value for each species (or target variable) are computed for each group. Moreover,
#' within each group, species (or target variables) are sorted decreasingly by their cover (or value).
#' @param database a dataframe in which Rows are surveys and Columns are Species. The first column is the identifier of dendrogram groups see @example for a graphical detail
#' @return a list of three elements: 1) aggregate in matrix format (rows: group, columns: species); 2) aggregate in long format (group,species,abundance); 3) aggregate in simplified table format (group species, abundance)
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
#' @import tidyverse 
#' @export
#' 

clustGroupAggregate2<-function(database){
  ref<-database
  colnames(ref)[1]<-"group"
  ref$group<-as.character(ref$group)
  
  #compute mean per group
  aggregate.df<-ref %>% 
    group_by(group) %>% 
    summarise(across(where(is.numeric),.fns=mean))
  
  #put in a long format, sort species by decreasing abundance and remove abuncance =0
  aggregate.long<-aggregate.df %>% 
    pivot_longer(cols = -group, names_to = "species", values_to = "abundance") %>%
    group_by(group) %>%
    arrange(group, desc(abundance)) %>%
    filter(abundance>0) %>% 
    ungroup()
  
  liste_tab <- aggregate.long %>%
    group_by(group) %>%
    arrange(desc(abundance)) %>%
    group_split() %>% 
    map(~ select(.x, species, abundance))#for each list item select only species and abundance
  
  #set column names per each table
  columnNames <- map2(#mapply
    liste_tab,
    unique(aggregate.long$group),
    ~ setNames(.x, c(paste0(.y, "_species"), paste0(.y, "_abundance")))
  )
  
  #function to create final table
  cbind_fill <- function(...) {
    dfs <- list(...)
    max_rows <- max(sapply(dfs, nrow))
    dfs_padded <- lapply(dfs, function(x) {
      n_missing <- max_rows - nrow(x)
      if (n_missing > 0) {
        # crea un data.frame di NA con nomi delle colonne uguali
        na_df <- as.data.frame(matrix(NA, nrow = n_missing, ncol = ncol(x)))
        names(na_df) <- names(x)
        x <- rbind(x, na_df)
      }
      return(x)
    })
    do.call(cbind, dfs_padded)
  }
  tab <- do.call(cbind_fill, columnNames)
  
  return(list(df.wide=aggregate.df,
          df.long=aggregate.long,
          table=tab))
}