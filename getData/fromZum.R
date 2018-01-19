if (!require("rvest")) install.packages("rvest")
if (!require("stringi")) install.packages("stringi")
library(stringi)
library(rvest)

zum <- function(){
  zum <- readLines("http://zum.com",warn=F)
  Encoding(zum)<-"UTF-8"
  zum <- unique(zum[grep("keyword d_keyword",zum)])
  zum <- gsub("<(/)?([a-zA-Z]*)(\\s[a-zA-Z]*=[^>]*)?(\\s)*(/)?>","",zum)
  return(zum)
}