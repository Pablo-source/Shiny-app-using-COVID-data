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
      infoBoxOutput("Confirmed_cases_UK", width = 3),
      infoBoxOutput("Recovered_cases_UK", width = 3),
      infoBoxOutput("Death_cases_UK", width = 3),
      infoBoxOutput("Date", width = 3)
      
    ),
    
    # 1.2 All content from this "map" tab must be enclosed in this tabItems() function:
    tabItems(
      # 1.3 Then individual content of this map tab must be INSIDE this tabItem() function:  
      tabItem(
        
        # 1. Building content for map tabName INSIDE the tabItem() function
        # 1.1 Main title for this MAP tab
        tabName ="main_tab",
        h2("World map COVID19 deaths by contry -hover over dots for country info"),
        
        
        
        # First output is going to be a map, hence I call it "map"
        fluidRow( box(leafletOutput("map"),p("Map displaying COVID-19 confirmed,recovered and deaths cases"),   width = 12 )),
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
        ),
        fluidRow(
          box(
            dataTableOutput("sitreptable"), width = 15)),
        
        # Testing Two new Tables
        # UI side to test  a couple of tables:
        fluidRow( box(  
          column(6, dataTableOutput("tableleft")),
          column(6, dataTableOutput("tableright")), width =15))
        
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
  prevDay <- reactive(map_data[map_data$date == format(input$Time_Slider-1,"%Y/%m/%d"),])
  ## New dataset for table
  ## New data set for table
  RATESTable <- reactive(metric_rates[metric_rates$date == format(input$Time_Slider,"%Y/%m/%d"),])
  
  # Metrics: confirmed_d, recovered_d, deaths_d
    # FIRST DASHBOARD SECTION - KPIs
    # KPI 01 - Total confirmed cases - KPI 1-4
  # Daily values and difference between today vs yesterday values
  # Variable: confirmed_d
  output$Confirmed_cases_UK <- renderValueBox({
    
    prevday_conf <- prevDay()
    prevday_conf2 <- prevday_conf %>%
      select(country_map,date,confirmed_d) %>%
      filter( country_map == "UnitedKingdom")
    
    day_conf <- dailyData()
    day_conf2 <- day_conf %>%
      select(country_map,date,confirmed_d) %>%
      filter( country_map == "UnitedKingdom")
    
    valueBox(paste0(
      # Main figure dispplays daily confirmed cases
      format(day_conf2$confirmed_d, big.mark = ','),
      
      # Percentage change from previous day
      paste0("[",
             round(
               (
                 (day_conf2$confirmed_d-prevday_conf2$confirmed_d)/
                   prevday_conf2$confirmed_d
               )*100
               ,1),"%"
             ,"]")
    ), "Confirmed | % change prev day | UK", icon = icon("list"),
    color = "blue")
    
    
  })
  
    # KPI 02 - Total recovered cases  - KPI 2-4
  # Daily values and difference between today vs yesterday values
  # Variable: recovered_d
  output$Recovered_cases_UK <- renderValueBox({
    
    prevday_rec <- prevDay()
    prevday_rec2 <- prevday_rec %>%
      select(country_map,date,recovered_d) %>%
      filter( country_map == "UnitedKingdom")
    
    day_rec <- dailyData()
    day_rec2 <- day_rec %>%
      select(country_map,date,recovered_d) %>%
      filter( country_map == "UnitedKingdom")
    
    valueBox(paste0(
      # Main figure dispplays daily confirmed cases
      format(day_rec2$recovered_d, big.mark = ','),
      
      # Percentage change from previous day
      paste0("[",
             round(
               (
                 (day_rec2$recovered_d-prevday_rec2$recovered_d)/
                   prevday_rec2$recovered_d
               )*100
               ,1),"%"
             ,"]")
    ), "Recovered | % change prev day | UK", icon = icon("check"),
    color = "green")
    
    
  })
  
  # KPI 03 - Total death cases - KPI 3-4
  # Daily values and difference between today vs yesterday values
  # Variable: deaths_d
  output$Death_cases_UK <- renderValueBox({
    
    Cases <- dailyData()
    Cases2 <- Cases %>% 
      select(country_map,date,confirmed_d) %>% 
      filter( country_map == "UnitedKingdom")
    
    Casesprev <- prevDay() 
    Casesprev2 <- Casesprev %>% 
      select(country_map,date,confirmed_d) %>% 
      filter(country_map =="United Kingdom")
    
    valueBox(paste0(
      format(Cases2$confirmed_d, big.mark = ','),
      paste0("[",
             round(
               (
                 (Cases2$confirmed_d - Casesprev2$confirmed_d)/
                   Casesprev2$confirmed_d
               )*100,1)
             ,"%","]")
    ), "Deaths | % change prev day | UK", icon = icon("user-doctor"),
    color = "orange"
    )
    
    
  })
  
  # KPI 04 - Total death cases - KPI 4-4
  # DATE
  # Variable: date
  output$Date   <- renderValueBox({
    
    Datebox <- dailyData()
    Datebox2 <- Datebox %>% 
      select(country_map,date,recovered_d) %>% 
      filter( country_map == "UnitedKingdom")
    
    valueBox(Datebox2$date,
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
  
  # OUTPUT 06 "DATA TABLE" 
  output$sitreptable <- renderDataTable({
    
    Tabledesc <- RATESTable()
    
    Tabledesc  %>%
      select(country, date, confirmed,recovered,deaths,population,
             conf_7Days_moving_avg,
             rec_7Days_moving_avg, 
             deaths_7Days_moving_avg,
             'conf_x10,000pop_rate',
             'rec_x10,000pop_rate',
             'deaths_x10,000pop_rate') %>% 
      arrange(desc(confirmed))
    
  })
  
 # OUTPUT 07   - Test TableLEFT
  output$tableleft <- renderDataTable({
    
    TableLEFT <- RATESTable()
    
    TableLEFT  %>%
      select(country, date, 
             'conf_x10,000pop_rate',
             'rec_x10,000pop_rate',
             'deaths_x10,000pop_rate') %>% 
      arrange(desc('conf_x10,000pop_rate'))

 })
  
  # OUTPUT 08 - Test TableRIGHT
 
  output$tableright <- renderDataTable({
    
    TableRIGHT <- RATESTable()
    
    TableRIGHT  %>%
      select(country, date, 
             'conf_x10,000pop_rate',
             'rec_x10,000pop_rate',
             'deaths_x10,000pop_rate') %>% 
      arrange(desc('rec_x10,000pop_rate'))
    
  })
}

# Launch it
shinyApp(ui = ui,server = server)
