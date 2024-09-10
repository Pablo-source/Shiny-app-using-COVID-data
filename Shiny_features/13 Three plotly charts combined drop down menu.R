# Shiny_app_script
# File: 10 Table and plotly barchart COMPLETED.R

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
    # 1.2 All content from this "map" tab must be enclosed in this tabItems() function:
    tabItems(
      # 1.3 Then individual content of this map tab must be INSIDE this tabItem() function:  
      tabItem(
        
        # Building content for map tabName INSIDE the tabItem() function
        # Main title for this MAP tab
        tabName ="main_tab",
        h2("World map COVID19 deaths by contry -hover over dots for country info"),

        # Each tab element goes inside a fluidRow() function
        
        # 1. Element 01: Here we include time slider for map
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
        
        # 2. Drop down menu to choose country for Plotly Line charts section
        # 
        
        fluidRow(h2("Covid 19 Timeline measures by country")),
        fluidRow(h4("Select country from dropdown menu - Interactive Plotly line charts")),
        
        # 2.1 Actual dropdown menu
        fluidRow(column(4,
                        selectInput("country",
                                    "Country:",
                                    c("All",
                                      unique(as.character(metric_rates$country)))))
        ),
        # 3. Three Plotly line charts
        fluidRow( box(  
          column(4, plotlyOutput("Confcountries")),
          column(4, plotlyOutput("Reccountries")),
          column(4, plotlyOutput("Deathscountries")),
          width =12))
        
        )
      
      
    )
  )
) 
# [2-2] Server   
server <- function(input,output) {
  
  # dailydata     (this DATAFRAME comes from PLOT_LEAFLET_MAPS)
  # dailyDatatbl  (this DATAFRAME comes from POP_POPULATED )
  # prevdailyData (this DATAFRAME comes from PLOT_LEAFLET_MAPS but previous day)
  
  
  ## Dynamic data set to build dynamic tables  
  RATESTable <- reactive(metric_rates[metric_rates$date == format(input$Time_Slider,"%Y/%m/%d"),])
  
  # Dynamic data set to build plotly chart 
  PLOTLYcharts <- reactive(metric_rates[metric_rates$date == format(input$Time_Slider,"%Y/%m/%d"),])
  
  # New data set for Plotly bar charts 
  
  # Metrics: confirmed_d, recovered_d, deaths_d

  # OUTPUT 01 "DATA TABLE" 
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
  
  # OUTPUT 02 > Confirmed cases plotly line chart - Country displayed select from UI Drop down menu
  output$Confcountries = renderPlotly({
    
    data_confpl <- metric_rates
    if (input$country != "All") {
      data_confpl <- data_confpl[metric_rates$country == input$country,] 
    }
    # Confirmed cases PLOTLY line chart
    plot_ly(data_confpl, x = ~date, y = ~conf_7Days_moving_avg, type = 'scatter', mode = 'lines', color = 'blue')%>%
      layout(title="Confirmed cases")
    

  })
  
  # OUTPUT 03 > Recovered cases plotly line chart - Country displayed select from UI Drop down menu
  output$Reccountries = renderPlotly({
    
    data_recpl <- metric_rates
    if (input$country != "All") {
      data_recpl <- data_recpl[metric_rates$country == input$country,] 
    }
    # Confirmed cases PLOTLY line chart
    plot_ly(data_recpl, x = ~date, y = ~rec_7Days_moving_avg, type = 'scatter', mode = 'lines', color = 'red')%>%
      layout(title="Recovered cases")
    
    
  })
    # OUTPUT 04 > Death cases plotly line chart - Country displayed select from UI Drop down menu
  output$Deathscountries = renderPlotly({
    
    data_deathpl <- metric_rates
    if (input$country != "All") {
      data_deathpl <- data_deathpl[metric_rates$country == input$country,] 
    }
    # Confirmed cases PLOTLY line chart
    plot_ly(data_deathpl, x = ~date, y = ~deaths_7Days_moving_avg, type = 'scatter', mode = 'lines', color = 'orange')%>%
      layout(title="Deaths")
    
    
  })
  
}

# Launch it
shinyApp(ui = ui,server = server)
