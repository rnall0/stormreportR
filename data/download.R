library(googlesheets)
library(dplyr)
library (RPostgreSQL)

#------Configure Date--------
Date<-Sys.Date() - 1
Date<-gsub("20", "", Date)
Date<-gsub("-", "", Date)

#------------Hail Reports----
Csv<-"_rpts_hail.csv"
hail<-data.frame(Date, Csv)

link<-"http://www.spc.noaa.gov/climo/reports/"

counter<-0
total<-nrow(hail)
hail.final<-NULL
system.time(for (i in 1:nrow(hail)){
  counter <<- counter + 1;
  message(paste(counter, "of", total))
  dl<-paste(link,hail[i,1], hail[i,2], sep="")
  tbl<-read.csv(dl)
  if(nrow(tbl) == 0){
    print("Die Daten sind leer.")
  } else {
    tbl$Date<-as.Date(as.character(hail[i,1]), "%y%m%d")
    hail.final<-rbind(hail.final, tbl)
  }
})


if (is.null(hail.final) == TRUE){
  print("No Hail Events Yesterday...")
} else {
  drv <- dbDriver("PostgreSQL")

  con <- dbConnect(drv, dbname = "db", 
                 host = "host.elephantsql.com", 
                 port = 5432,
                 user = "username", password = "password")

  dbWriteTable(con,"hail_service", hail.final, row.names = FALSE, append = TRUE)

  dbDisconnect(con)
  print("Hail Event(s) Written to Database...")
}


#------Tornado Reports------
Csv<-"_rpts_torn.csv"
torn<-data.frame(Date, Csv)

link<-"http://www.spc.noaa.gov/climo/reports/"

counter<-0
total<-nrow(torn)
torn.final<-NULL
system.time(for (i in 1:nrow(torn)){
  counter <<- counter + 1;
  message(paste(counter, "of", total))
  dl<-paste(link,torn[i,1], torn[i,2], sep="")
  tbl<-read.csv(dl)
  if(nrow(tbl) == 0){
    print("Die Daten sind leer.")
  } else {
    tbl$Date<-as.Date(as.character(torn[i,1]), "%y%m%d")
    torn.final<-rbind(torn.final, tbl)
  }
})

if (is.null(torn.final) == TRUE){
  print("No Tornado Events Yesterday...")
} else {
  drv <- dbDriver("PostgreSQL")

  con <- dbConnect(drv, dbname = "db", 
                 host = "host.elephantsql.com", 
                 port = 5432,
                 user = "username", password = "password")

  dbWriteTable(con,"tornado_service", torn.final, row.names = FALSE, append = TRUE)

  dbDisconnect(con)
  print("Tornado Event(s) Written to Database...")
}


#-----Wind Reports----
Csv<-"_rpts_wind.csv"
wind<-data.frame(Date, Csv)

link<-"http://www.spc.noaa.gov/climo/reports/"

counter<-0
total<-nrow(wind)
wind.final<-NULL
system.time(for (i in 1:nrow(wind)){
  counter <<- counter + 1;
  message(paste(counter, "of", total))
  dl<-paste(link,wind[i,1], wind[i,2], sep="")
  tbl<-read.csv(dl)
  if(nrow(tbl) == 0){
    print("Die Daten sind leer.")
  } else {
    tbl$Date<-as.Date(as.character(wind[i,1]), "%y%m%d")
    wind.final<-rbind(wind.final, tbl)
  }
})

if (is.null(wind.final) == TRUE){
  print("No Wind Events Yesterday...")
} else {
  drv <- dbDriver("PostgreSQL")

  con <- dbConnect(drv, dbname = "db", 
                 host = "host.elephantsql.com", 
                 port = 5432,
                 user = "username", password = "password")

  dbWriteTable(con,"wind_service", wind.final, row.names = FALSE, append = TRUE)

  dbDisconnect(con)
  print("Wind Event(s) Written to Database...")
}
