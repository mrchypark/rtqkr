if (!require("rvest")) install.packages("rvest")
if (!require("stringi")) install.packages("stringi")
library(stringi)
library(rvest)

geine <- function(){
  geine <- readLines("http://www.genie.co.kr/search/searchMain?query=%25EC%2595%2584%25EC%259D%25B4%25EC%259C%25A0%2520%28IU%29",warn=F)
  Encoding(geine)<-"UTF-8"
  geine <- unique(geine[grep("fnGoSearchKeyword",geine)])
  geine <- gsub("<(/)?([a-zA-Z]*)(\\s[a-zA-Z]*=[^>]*)?(\\s)*(/)?>","",geine)
  return(geine)
}
