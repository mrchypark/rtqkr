## load packages

if (!require("googlesheets")) {install.packages("googlesheets") }
if (!require("httr")) {install.packages("httr") }
if (!require("lubridate")) {install.packages("lubridate") }

## data.frame options

options(stringsAsFactors = F)

## load get data func

zum <- function(){
  zum <- readLines("http://zum.com",warn=F)
  Encoding(zum)<-"UTF-8"
  zum <- unique(zum[grep("keyword d_keyword",zum)])
  zum <- gsub("<(/)?([a-zA-Z]*)(\\s[a-zA-Z]*=[^>]*)?(\\s)*(/)?>","",zum)
  return(zum)
}

naver <- function(){
  naver <- readLines("http://www.naver.com",warn=F)
  Encoding(naver)<-"UTF-8"
  naver <- unlist(strsplit(naver,"<"))
  naver <- unique(naver[grep('class="ah_k"',naver)])
  naver <- paste0("<",naver)
  naver <- gsub("<(/)?([a-zA-Z]*)(\\s[a-zA-Z]*=[^>]*)?(\\s)*(/)?>","",naver)
  return(naver)
}

daum <-function(){
  daum <- readLines("http://www.daum.net",warn=F)
  Encoding(daum)<-"UTF-8"
  daum <- unique(daum[grep('class="link_issue"',daum)])
  daum <- daum[5:14]
  daum <- gsub("<(/)?([a-zA-Z]*)(\\s[a-zA-Z]*=[^>]*)?(\\s)*(/)?>","",daum)
  return(daum)
}

## load slack web_hook url for report

# web_hook = "https://hooks.slack.com/services/XXXXXXXXXXXXXXXXXXXX"
# save(web_hook,file="web_hook.RData")
load("/home/rstudio/realtimeQueryKeywordKr/web_hook.RData")

## make form for googlesheet

datetime <- as.POSIXlt(now()+9*60*60,tz="KST")
gsname   <- as.Date(datetime)

## check and assign today's sheet.
workSpace <- try(gs_title(paste0("rtqk_",gsname )))

while(workSpace[1]=="Error in curl::curl_fetch_memory(url, handle = handle) : \n  Timeout was reached\n"){
  
  workSpace <- try(gs_title(paste0("rtqk_",gsname)))
  Sys.sleep(0.1)
  
}

## if don't exist today's sheet, create, assign sheet and report to slack

if(class(workSpace)[1]!="googlesheet"){
  if(grep("Error in gs_lookup",workSpace)==1) {
    workSpace <- try(gs_new(title = paste0("rtqk_",gsname),input=dataForm))
    while(workSpace[1]=="Error in curl::curl_fetch_memory(url, handle = handle) : \n  Timeout was reached\n"){
      workSpace <- try(gs_new(title = paste0("rtqk_",gsname),input=dataForm))
      Sys.sleep(0.1)
    }
    workSpace <- try(gs_title(paste0("rtqk_", gsname)))
    while(workSpace[1]=="Error in curl::curl_fetch_memory(url, handle = handle) : \n  Timeout was reached\n"){
      workSpace <- try(gs_title(paste0("rtqk_",gsname)))
      Sys.sleep(0.1)
    }
    cont = paste0("새 파일이 생성되었습니다. 공유 설정을 진행해 주세요.")
    report <- try(POST(web_hook,body=list(text=iconv(cont,to="UTF-8")),encode="json"))
    while(report[1]=="Error in curl::curl_fetch_memory(url, handle = handle) : \n  Timeout was reached\n"){
      report <- try(POST(web_hook,body=list(text=iconv(cont,to="UTF-8")),encode="json"))
      Sys.sleep(0.1)
    }
  }
}

## get data

rtData <- rbind(data.frame(datetime = datetime, source= "daum",rank=1:10,keyword=daum()),
                data.frame(datetime = datetime, source= "naver",rank=1:20,keyword=naver()),
                data.frame(datetime = datetime, source= "zum",rank=1:20,keyword=zum()))

## upload datas

for (i in 1:nrow(rtData)) {
  workSpace <- try(gs_add_row(ss=workSpace, input = (rtData[i,])))
  while(workSpace[1]=="Error in curl::curl_fetch_memory(url, handle = handle) : \n  Timeout was reached\n"){
    workSpace <- try(gs_add_row(ss=workSpace, input = (rtData[i,])))
    Sys.sleep(0.01)
  }
  Sys.sleep(0.01)
}

rm(rtData)

## report to slack

if(i==50){
  cont = paste0(datetime,"의 데이터 업로드가 완료되었습니다.")
  report <- try(POST(web_hook,body=list(text=iconv(cont,to="UTF-8")),encode="json"))
  while(report[1]=="Error in curl::curl_fetch_memory(url, handle = handle) : \n  Timeout was reached\n"){
    report <- try(POST(web_hook,body=list(text=iconv(cont,to="UTF-8")),encode="json"))
    Sys.sleep(0.3)
  }
}

