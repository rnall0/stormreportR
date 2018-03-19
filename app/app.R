library(shiny)
library(leaflet)
library(RColorBrewer)
library(RCurl)
library(RPostgreSQL)
library(leaflet.extras)
library(DBI)

ui <- bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  leafletOutput("mymap", width = "100%", height = "100%"),
  absolutePanel(top = 230, left = 10,
		draggable = TRUE,
                # sliderInput("date_range",
                #     "Choose a Date Range:",
                #     min = as.Date("2017-07-01"),
                #     max = as.Date("2017-10-14"),
                #     value = c(as.Date("2017-10-07"), Sys.Date()))
                dateRangeInput('date_range',
                               label = 'Select Date Range',
                               start = Sys.Date() - 5, end = Sys.Date() - 1
                )
  )
)

server <- function(input, output, session) {
  
  output$mymap <- renderLeaflet({
    leaflet() %>% addTiles() %>%
      #fitBounds(~min(wind_fileredData()$Lon), ~min(wind_fileredData()$Lat), ~max(wind_fileredData()$Lon), ~max(wind_fileredData()$Lat))
      #fitBounds(30.1375217437744, 35.0080299377441, -88.4731369018555, -84.8882446289062) %>%
      setView(-95.35, 39.50, zoom = 4) %>%
      
      addLayersControl(
        #baseGroups = c("OSM (default)", "Toner", "Toner Lite"),
        overlayGroups = c("Past Hail Reports", "Past Tornado Reports", "Past Wind Reports", "Current Weather Radar"),
        position = c("topleft"),
        options = layersControlOptions(collapsed = FALSE))
  })
  
  drv <- dbDriver("PostgreSQL")
  
  con <- dbConnect(drv, dbname = "dbname", 
                   host = "host.url", 
                   port = 5432,
                   user = "user", password = "pw")
  
  hail_filteredData <- reactive({
    hail.rs<-dbSendQuery(con, paste("SELECT * FROM \"public\".\"hail_service\" WHERE \"public\".\"hail_service\".\"Date\" >= ", "'", input$date_range[1], "'", " AND \"public\".\"hail_service\".\"Date\" <= ", "'", input$date_range[2], "'"))
    hail.fil<-fetch(hail.rs, n=-1)
    return(hail.fil)
    on.exit(DBI::dbDisconnect(con))
   })
   
   torn_filteredData <- reactive({
     torn.rs<-dbSendQuery(con, paste("SELECT * FROM \"public\".\"tornado_service\" WHERE \"public\".\"tornado_service\".\"Date\" >= ", "'", input$date_range[1], "'", " AND \"public\".\"tornado_service\".\"Date\" <= ", "'", input$date_range[2], "'"))
     torn.fil<-fetch(torn.rs, n=-1)
     return(torn.fil)
     on.exit(DBI::dbDisconnect(con))
   })
   
   wind_filteredData <- reactive({
     wind.rs<-dbSendQuery(con, paste("SELECT * FROM \"public\".\"wind_service\" WHERE \"public\".\"wind_service\".\"Date\" >= ", "'", input$date_range[1], "'", " AND \"public\".\"wind_service\".\"Date\" <= ", "'", input$date_range[2], "'"))
     wind.fil<-fetch(wind.rs, n=-1)
     return(wind.fil)
     on.exit(DBI::dbDisconnect(con))
    })
  
#insert dummy variable
   types = c("wind", "hail", "tornado")
   df = data.frame(types)
  
  observe({
    if(nrow(df) == 0) {leafletProxy("mymap") %>% clearMarkers()}
    else{
    leafletProxy("mymap") %>%
      clearMarkers() %>%
      addCircleMarkers(as.numeric(hail_filteredData()$Lon),
                       as.numeric(hail_filteredData()$Lat),
                       color = "green",
                       group = "Past Hail Reports",
		       popup = paste("<b>Comments:</b>", hail_filteredData()$Comments, "<br/>", "<br/>",
				     "<b>Size</b>: ", hail_filteredData()$Size, "<br/>", "<br/>",
				     "<b>Time</b>: ", hail_filteredData()$Time, "<br/>", "<br/>",
				     "<b>Date</b>: ", hail_filteredData()$Date)) %>%
      addCircleMarkers(as.numeric(torn_filteredData()$Lon), 
                       as.numeric(torn_filteredData()$Lat), 
                       color = "red", 
                       group = "Past Tornado Reports",
                       popup = paste("<b>Comments:</b>", torn_filteredData()$Comments, "<br/>", "<br/>", 
                                     "<b>F-Scale</b>: ", torn_filteredData()$F_Scale, "<br/>", "<br/>",
                                     "<b>Time</b>: ", torn_filteredData()$Time, "<br/>", "<br/>", 
                                     "<b>Date</b>: ", torn_filteredData()$Date)) %>%
      addCircleMarkers(as.numeric(wind_filteredData()$Lon), 
                       as.numeric(wind_filteredData()$Lat), 
                       color = "blue", 
                       group = "Past Wind Reports",
                       popup = paste("<b>Comments:</b>", wind_filteredData()$Comments, "<br/>", "<br/>", 
                                     "<b>Speed</b>: ", wind_filteredData()$Speed, "<br/>", "<br/>",
                                     "<b>Time</b>: ", wind_filteredData()$Time, "<br/>", "<br/>", 
                                     "<b>Date</b>: ", wind_filteredData()$Date))
	addWMSTiles(
                  "https://nowcoast.noaa.gov/arcgis/services/nowcoast/radar_meteo_imagery_nexrad_time/MapServer/WmsServer?",
                  layers = "1",
                  options = WMSTileOptions(format = "image/png", transparent = "TRUE"),
                  attribution = "NOAA",
                  group = "Current Weather Radar") #%>% 
	    
      #hideGroup("Past Tornado Reports") %>%
      #hideGroup("Past Hail Reports") %>% 
      #hideGroup("Past Wind Reports")
    }
  })
  
  
  # output$stormreport1 <- renderDataTable({
  #   if (input$hail_data) {
  #     #head(hail_data, 3)
  #     hail_data2<-subset(hail_data, hail_data$Date > input$date_range[1] & hail_data$Date < input$date_range[2])
  #     hail_data2 }
  #   })
  # output$stormreport2 <- renderDataTable({
  #   if (input$wind_data) {
  #     wind_data2<-subset(wind_data, wind_data$Date > input$date_range[1] & wind_data$Date < input$date_range[2])
  #     wind_data2 }
  # })
  # 
  # output$stormreport3 <- renderDataTable({
  #   if (input$torn_data) {
  #     torn_data2<-subset(torn_data, torn_data$Date > input$date_range[1] & torn_data$Date < input$date_range[2])
  #     torn_data2 }
  #})

}

shinyApp(ui, server)
