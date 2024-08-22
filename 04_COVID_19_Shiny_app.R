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
      menuItem("Map", tabName = "map", icon = icon("map"))
    )
  )
  ,
  dashboardBody(  
    
    # 1. Start building dashboard content
    # 1.1 All content from this "map" tab must be enclosed in this tabItems() function:
    tabItems(
      # 1.2 Then individual content of this map tab must be INSIDE this tabItem() function:  
      tabItem(
        
        # 1. Building content for map tabName INSIDE the tabItem() function
        # 1.1 Main title for this MAP tab
        tabName ="map",h2("World map COVID19 deaths by contry"),
        
        fluidRow(  box(
          leafletOutput("map"),
          p("First map"),
          width = 12 )
        ),
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
  
  # OUTPUT 01 "map" 
  output$map = renderLeaflet ({
    
    # This is the new data frame that is modified by "Time_Slider" parameter
    # We input now this dataframe into the LEAFLEFT function
    dataframe <- dailyData()
    
    pal_sb <- colorNumeric("Greens",domain = dataframe$deaths)    
    
    # If filter date is disables the map is displayed !!
    #   filter(date == input$date[1]) %>%   
    dataframe %>% 
      leaflet() %>% 
      addTiles() %>% 
      setView(lng = -10, lat = 20, zoom = 3) %>% 
      addCircles(lng = ~ long, 
                 lat = ~lat,
                 weight = 5, 
                 radius = ~sqrt(dataframe$deaths)*1000,
                 
                 popup = paste0(
                   "<b>Country:  </b>",dataframe$country,' ',dataframe$date,
                   "<br>Confirmed=",dataframe$confirmed,
                   "<br>Deaths=",dataframe$deaths,
                   "<br>Recovered=",dataframe$recovered,
                   sep = " "
                   
                 ),
                 
                 fillColor = "lightblue",
                 highlightOptions = highlightOptions( weight = 10, color = "red", fillColor = "green")
                 
      )
  })
  
  
}

# Launch it
shinyApp(ui = ui,server = server)
