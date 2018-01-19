if (!require("rvest")) install.packages("rvest")
if (!require("stringi")) install.packages("stringi")
library(stringi)
library(rvest)

daum <-function(){
  daum <- readLines("http://www.daum.net",warn=F)
  Encoding(daum)<-"UTF-8"
  daum <- unique(daum[grep('class="link_issue"',daum)])
  daum <- daum[5:14]
  daum <- gsub("<(/)?([a-zA-Z]*)(\\s[a-zA-Z]*=[^>]*)?(\\s)*(/)?>","",daum)
  return(daum)
}