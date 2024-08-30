# Shiny_app_script
# File: 04 COVID_19_Shiny_app.R

# 20/08/2024 Re-designing Leaflat map

library(shiny)
library(shinydashboard)   # Library to build dashboard
library(DT)               # Library for interactive tables
library(tidyverse)        # Library for data manipulation
library(leaflet)          # Library to create interactive maps (Enables pop-ups and animations)
library(plotly)           # Library to create interactive plots (Enables zoom in, zoom out, select area features)

## source 
# [1-2]  User interface
ui <- dashboardPage(
  
  dashboardHeader(title = "COVID-19"),
  # Sidebar menu allows us to include new items on the sidebar navigation menu
  dashboardSidebar(
    sidebarMenu(
      # Setting id makes input$tabs give the tabName of currently-selected tab
      id = "tabs",
      menuItem("About", tabName = "about", icon = icon("desktop")),
      menuItem("COVID-19 Dashboard", tabName = "main_tab", icon = icon("map"))
    )
  )
  ,
  dashboardBody(  
    
    # 1. Start building dashboard content
    
    # 1.1 We introduce first this section to build some KPIs at the top of the dashboard:
    
    # Infobox: Total figures KPI UK
    fluidRow(
      infoBoxOutput("Today_cases_UK", width = 3),
      infoBoxOutput("Yesterday_cases_UK", width = 3),
      infoBoxOutput("Difference_TY_UK", width = 3),
      infoBoxOutput("Date", width = 3)
      
    ),
    
    
    # 1.2 All content from this "map" tab must be enclosed in this tabItems() function:
    tabItems(
      # 1.3 Then individual content of this map tab must be INSIDE this tabItem() function:  
      tabItem(
        
        # 1. Building content for map tabName INSIDE the tabItem() function
        # 1.1 Main title for this MAP tab
        tabName ="main_tab",h2("World map COVID19 deaths by contry"),
        # First output is going to be a map, hence I call it "map"
        fluidRow( box(leafletOutput("map"),p("First map"),   width = 12 )),
        # 2. Adding content to the map tab
        
        # Each tab element goes inside a fluidRow() function
        
        # 2.1 Element 01: Here we include time slider for map
        # Input dataset is "map_data"
        #     Variables: date > mutate(date = as.Date(date) )
        fluidRow(       
          box(
            sliderInput(inputId = "Time_Slider",
                        label = "Select Date",
                        min = min(map_data$date),
                        max = max(map_data$date),
                        value = max(map_data$date),
                        width = "100%",
                        timeFormat = "%d%m%Y",
                        animate = animationOptions(interval=3000,loop = TRUE)
            ),
            class = "slider",
            width = 15,
          )
        )
        
        
        
        
        
      )
    )
  )
) 


# [2-2] Server  
server <- function(input,output) {
  
  # dailydata     (this DATAFRAME comes from PLOT_LEAFLET_MAPS)
  # dailyDatatbl  (this DATAFRAME comes from POP_POPULATED )
  # prevdailyData (this DATAFRAME comes from PLOT_LEAFLET_MAPS but previous day)
  
  dailyData <- reactive(map_data[map_data$date == format(input$Time_Slider,"%Y/%m/%d"),])
  prevDay<- reactive(map_data[map_data$date == format(input$Time_Slider-1,"%Y/%m/%d"),])
  
  # OUTPUT 01 - INFOBOX 01-03 - Today UK recovered cases
  output$Today_cases_UK <- renderValueBox({
    
    dataframeRec <- dailyData()
    dataframeRec2 <- dataframeRec %>%
      select(country_map,date,recovered_d) %>%
      filter( country_map == "UnitedKingdom")
    
    valueBox(paste0(format(
      dataframeRec2$recovered_d, big.mark = ',')
    ), "Recovered| UK", icon = icon("list"),color = "blue")
  })
  # OUTPUT 02 - Infobox 02-03 - Yesterday's confirmed cases
  # Variable: confirmed_d
  output$Yesterday_cases_UK <- renderValueBox({
    
    prevdayRec <- prevDay()
    prevdayRec2 <- prevdayRec %>%
      select(country_map,date,recovered_d) %>%
      filter( country_map == "UnitedKingdom")
    
    valueBox(paste0(format(
      prevdayRec2$recovered_d  
      
      , big.mark = ',')
    ), "Recovered prev day | UK", icon = icon("list"),color = "purple"
    )
  })
  
  # OUTPUT 03 - Difference today vs yesterday values
  output$Difference_TY_UK <- renderValueBox({
    
    prevday <- prevDay()
    prevday2 <- prevday %>%
      select(country_map,date,recovered_d) %>%
      filter( country_map == "UnitedKingdom")
    
    dataframeRec <- dailyData()
    dataframeRec2 <- dataframeRec %>%
      select(country_map,date,recovered_d) %>%
      filter( country_map == "UnitedKingdom")
    
    valueBox(paste0(
      
      format(prevday2$recovered_d, big.mark = ','),
      
      format(dataframeRec2$recovered_d, big.mark = ','),
      
      ## This code below works fine !!
      ##  paste0("[",dataframeRec2$recovered_d-prevdayDiff2$recovered_d,"]")
      paste0("[",
             round(
               (
                 (dataframeRec2$recovered_d-prevday2$recovered_d)/
                   prevday2$recovered_d
               )*100
               ,1),"%"
             ,"]")
    ),"% difference prev current day")
    
    
  })
  
  
  # OUTPUT 04 - Infobox 03-03 - Date
  # Variable: date
  output$Date   <- renderValueBox({
    dataframeDate <- dailyData()
    dataframeDate <- dataframeDate %>%
      select(country_map,date,recovered_d) %>%
      filter( country_map == "UnitedKingdom")
    valueBox(dataframeDate$date,
             "Date | Daily figures",
             icon = icon("calendar"),color = "yellow")
  })

  # OUTPUT 05 "map"
  output$map = renderLeaflet ({
    
    # This is the new data frame that is modified by "Time_Slider" parameter
    # We input now this dataframe into the LEAFLEFT function
    dataframe <- dailyData()
    
    pal_sb <- colorNumeric("Greens",domain = dataframe$deaths_d)    
    
    # If filter date is disables the map is displayed !!
    #   filter(date == input$date[1]) %>%   
    dataframe %>% 
      leaflet() %>% 
      addTiles() %>% 
      setView(lng = -10, lat = 20, zoom = 3) %>% 
      addCircles(lng = ~ long, 
                 lat = ~lat,
                 weight = 5, 
                 radius = ~sqrt(dataframe$deaths_d)*1000,
                 
                 popup = paste0(
                   "<b>Country:  </b>",dataframe$country,' ',dataframe$date,
                   "<br>Confirmed=",dataframe$confirmed_d,
                   "<br>Deaths=",dataframe$deaths_d,
                   "<br>Recovered=",dataframe$recovered_d,
                   sep = " "
                   
                 ),
                 
                 fillColor = "lightblue",
                 highlightOptions = highlightOptions( weight = 10, color = "red", fillColor = "green")
                 
      )
  })
  
  
}

# Launch it
shinyApp(ui = ui,server = server)
