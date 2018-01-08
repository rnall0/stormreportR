library(googlesheets)
library(dplyr)
library (RPostgreSQL)

gs_ls()

#------------Hail Reports----
table <- "Hail Reports"
sheet <- gs_title(table)
hail<-gs_read_csv(sheet)
hail<-tail(hail, 6)


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


drv <- dbDriver("PostgreSQL")

con <- dbConnect(drv, dbname = "db", 
                 host = "host.elephantsql.com", 
                 port = 5432,
                 user = "username", password = "password")

dbWriteTable(con,"hail_service", hail.final, row.names = FALSE, append = TRUE)

dbDisconnect(con)


#------Tornado Reports------
table <- "Tornado Reports"
sheet <- gs_title(table)
torn<-gs_read_csv(sheet)
torn<-tail(torn, 6)


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


drv <- dbDriver("PostgreSQL")

con <- dbConnect(drv, dbname = "db", 
                 host = "host.elephantsql.com", 
                 port = 5432,
                 user = "username", password = "password")

dbWriteTable(con,"tornado_service", torn.final, row.names = FALSE, append = TRUE)

dbDisconnect(con)


#-----Wind Reports----
table <- "Wind Reports"
sheet <- gs_title(table)
wind<-gs_read(sheet)
wind<-tail(wind, 6)


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


drv <- dbDriver("PostgreSQL")

con <- dbConnect(drv, dbname = "db", 
                 host = "host.elephantsql.com", 
                 port = 5432,
                 user = "username", password = "password")

dbWriteTable(con,"wind_service", wind.final, row.names = FALSE, append = TRUE)

dbDisconnect(con)

