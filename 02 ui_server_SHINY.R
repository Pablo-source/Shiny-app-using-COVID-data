# R Script: 02 ui_server_SHINY.R

# LOAD DATA SETS
# - POP POPULATED
# - PLOT_LEAFLET_MAPS
# View(POP_POPULATED)

# 00. Run script to get data from GITHUB 
# source("00 Maps data prep_SHINY.R")
# 01. Run script to create metrics and rates for plots and maps
# source("01 Leaf and pop figures_SHINY.R")

# Load required libraries to run the Shiny app 
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
                    menuItem("Map", tabName = "map", icon = icon("map")),
                    menuItem("Plots", tabName = "plot", icon = icon("wifi")),
                    menuItem("Forecast", tabName = "forecast", icon = icon("chart-line")))
  )
  ,
  dashboardBody(  # Infobox: Total figures KPI world
    fluidRow( infoBoxOutput("Total_cases_WORLD",width=3),
              infoBoxOutput("Total_recovered_WORLD",width=3),
              infoBoxOutput("Total_deaths_WORLD",width=3),
                          infoBoxOutput("Date", width = 3)
              
              ),  
    fluidRow(
                   infoBoxOutput("Totalrecovered_UK", width = 3),
                   infoBoxOutput("Totalcases_UK", width = 3),
                   infoBoxOutput("Totaldeaths_UK", width = 3)
       
                  ),
 # We include the two new items on the sidebar
    tabItems(
        tabItem(
            tabName="about", h1("About the COVID-19 app"),
        
        fluidRow(box(source("UI/ui_about.R",local =TRUE),width=11))
        ),
      
       tabItem(
         tabName ="map",
                 
          h2("World map COVID19 deaths by contry"),
                 
               fluidRow(  box(
                              leafletOutput("map"),
                                          p("Map Title"),
                                          width = 15 )
                        )
                        ,
                 
                 fluidRow(       
                        box(
                            sliderInput(inputId = "Time_Slider",
                                        label = "Select Date",
                                        min = min(PLOT_LEAFLET_MAPS$date),
                                        max = max(PLOT_LEAFLET_MAPS$date),
                                        value = max(PLOT_LEAFLET_MAPS$date),
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
                              dataTableOutput("mytable"), width = 15)
                 )
                 
                 ),
      tabItem(
      
        tabName="plot",  h2("Timeline indicators"), 
        
        fluidRow( h4("  Select country from dropdown menu")),
        fluidRow(column(4,
                 selectInput("country",
                             "Country:",
                             c("All",
                               unique(as.character(POP_POPULATED$Country))))
          )
          ),
        
        fluidRow( box(  
                column(4, plotlyOutput("Confcountries")),
                column(4, plotlyOutput("Deathscountries")),
                column(4, plotlyOutput("Reccountries")), width =12)),
      
      fluidRow( box(  
          column(4, plotlyOutput("ToptenCONF")),
          column(4, plotlyOutput("ToptenREC")),
          column(4, plotlyOutput("ToptenDEATH")), width =12))
      
        
              )
      
                        # Now in the same BODY we want to include a data table 
                      
          )
      )
  ) 


# [2-2] Server  
server <- function(input,output) {
  
  # dailydata     (this DATAFRAME comes from PLOT_LEAFLET_MAPS)
  # dailyDatatbl  (this DATAFRAME comes from POP_POPULATED )
  # prevdailyData (this DATAFRAME comes from PLOT_LEAFLET_MAPS but previous day)
  
  dailyData <- reactive(PLOT_LEAFLET_MAPS[PLOT_LEAFLET_MAPS$date == format(input$Time_Slider,"%Y/%m/%d"),])
  prevdailyData <-reactive(PLOT_LEAFLET_MAPS[PLOT_LEAFLET_MAPS$date == format(input$Time_Slider-1,"%Y/%m/%d"),])
  RATESTable <- reactive(POP_POPULATED[POP_POPULATED$date == format(input$Time_Slider,"%Y/%m/%d"),])

# TAB01 
  # OUTPUT 01-03 INFOBOXES
  output$Total_cases_WORLD <- renderValueBox({
    
    dataframeConf <- dailyData()
    
    dataframeConf2 <- dailyData() %>% 
      select(Country,Province,date,Recovered) %>% 
      filter(Country=="United Kingdom" &
               is.na(Province))
    
    dataframeConfprev <- prevdailyData() 
    
    dataframeConfprev2 <- prevdailyData() %>% 
      select(Country,Province,date,Recovered) %>% 
      filter(Country=="United Kingdom" &
               is.na(Province))
    
    valueBox(
      paste0(
        
        format(
          dataframeConf2$Recovered   
          , big.mark = ','),
        
        #prettyNum(dataframeConf$Recovered,big.mark = ","),
        
        paste0("[",round(((dataframeConf2$Recovered - dataframeConfprev2$Recovered)/dataframeConfprev2$Recovered)*100,2),"%","]")
      ), "Total cases worldwide | % change prev day |  -orange colour-", icon = icon("list"),
      color = "orange"
    )
  })
  output$Total_recovered_WORLD <- renderValueBox({
    
    dataframeConf <- dailyData()
    
    dataframeConf2 <- dailyData() %>% 
      select(Country,Province,date,Recovered) %>% 
      filter(Country=="United Kingdom" &
               is.na(Province))
    
    dataframeConfprev <- prevdailyData() 
    
    dataframeConfprev2 <- prevdailyData() %>% 
      select(Country,Province,date,Recovered) %>% 
      filter(Country=="United Kingdom" &
               is.na(Province))
    
    valueBox(
      paste0(
        
        format(
          dataframeConf2$Recovered   
          , big.mark = ','),
        
        #prettyNum(dataframeConf$Recovered,big.mark = ","),
        
        paste0("[",round(((dataframeConf2$Recovered - dataframeConfprev2$Recovered)/dataframeConfprev2$Recovered)*100,2),"%","]")
      ), "Total recovered worldwide | % change prev day |  -purple colour-", icon = icon("list"),
      color = "purple"
    )
  })
  output$Total_deaths_WORLD <- renderValueBox({
    
    dataframeConf <- dailyData()
    
    dataframeConf2 <- dailyData() %>% 
      select(Country,Province,date,Recovered) %>% 
      filter(Country=="United Kingdom" &
               is.na(Province))
    
    dataframeConfprev <- prevdailyData() 
    
    dataframeConfprev2 <- prevdailyData() %>% 
      select(Country,Province,date,Recovered) %>% 
      filter(Country=="United Kingdom" &
               is.na(Province))
    
    valueBox(
      paste0(
        
        format(
          dataframeConf2$Recovered   
          , big.mark = ','),
        
        #prettyNum(dataframeConf$Recovered,big.mark = ","),
        
        paste0("[",round(((dataframeConf2$Recovered - dataframeConfprev2$Recovered)/dataframeConfprev2$Recovered)*100,2),"%","]")
      ), "Total deaths worldwide | % change prev day |  -maroon colour-", icon = icon("list"),
      color = "maroon"
    )
  })

  output$Totalrecovered_UK <- renderValueBox({
    
    dataframeConf <- dailyData()
    
    dataframeConf2 <- dailyData() %>% 
      select(Country,Province,date,Recovered) %>% 
      filter(Country=="United Kingdom" &
               is.na(Province))
    
    dataframeConfprev <- prevdailyData() 
    
    dataframeConfprev2 <- prevdailyData() %>% 
      select(Country,Province,date,Recovered) %>% 
      filter(Country=="United Kingdom" &
               is.na(Province))
    
    valueBox(
      paste0(
        
        format(
        dataframeConf2$Recovered   
        , big.mark = ','),
        
             #prettyNum(dataframeConf$Recovered,big.mark = ","),
             
             paste0("[",round(((dataframeConf2$Recovered - dataframeConfprev2$Recovered)/dataframeConfprev2$Recovered)*100,2),"%","]")
      ), "Recovered | % change prev day | UK", icon = icon("list"),
      color = "blue"
    )
  })
  output$Totalcases_UK <- renderValueBox({
    
    dataframeConf <- dailyData()
    
    dataframeConf2 <- dailyData() %>% 
      select(Country,Province,date,Confirmed) %>%  
      filter(Country=="United Kingdom" &
               is.na(Province))
    
    dataframeConfprev <- prevdailyData() 
    
    dataframeConfprev2 <- prevdailyData() %>% 
      select(Country,Province,date,Confirmed) %>% 
      filter(Country=="United Kingdom" &
               is.na(Province))
    
    valueBox(
      paste0(
        
        format(
          dataframeConf2$Confirmed
          , big.mark = ','),

             paste0("[",round(((dataframeConf2$Confirmed - dataframeConfprev2$Confirmed)/dataframeConfprev2$Confirmed)*100,2),"%","]")
             
      ), "Confirmed | % change prev day | UK", icon = icon("bar-chart-o"),
      color = "green" 
    ) 
  })
  output$Totaldeaths_UK <- renderValueBox({
    
    dataframeD<- dailyData()
    dataframeDP <- prevdailyData() 
    
    dataframeD2 <- dailyData() %>% 
      select(Country,Province,date,Deaths) %>% 
      filter(Country=="United Kingdom" &
               is.na(Province))
    
    dataframeDP2 <- prevdailyData() %>% 
      select(Country,Province,date,Deaths) %>% 
      filter(Country=="United Kingdom" &
               is.na(Province))
    
    valueBox(paste0(format(dataframeD2$Deaths, big.mark = ','),
        paste0("[",round(((dataframeD2$Deaths - dataframeDP2$Deaths)/dataframeDP2$Deaths)*100,2),"%","]")
             
      ), "Deaths | % change prev day | UK", icon = icon("list-alt"),
      color = "purple"
    )
  })
  output$Date   <- renderValueBox({
    
    dataframeDeaths <- dailyData()
    dataframeDeaths <- dailyData() %>% 
      select(Country,Province,date,Deaths ) %>% 
      filter(Country=="United Kingdom" &
               is.na(Province))
    valueBox(
      dataframeDeaths$date
      , "Date | Daily figures", icon = icon("calendar"),
      color = "yellow")
    
  })
  
  # OUTPUT 02-03 "map" 
  output$map = renderLeaflet ({

   # This is the new data frame that is modified by "Time_Slider" parameter
  # We input now this dataframe into the LEAFLEFT function
  dataframe <- dailyData()
        
   pal_sb <- colorNumeric("Greens",domain = dataframe$Deaths)    
   
   # If filter date is disables the map is displayed !!
   #   filter(date == input$date[1]) %>%   
    dataframe %>% 
         leaflet() %>% 
      addTiles() %>% 
      setView(lng = -10, lat = 20, zoom = 3) %>% 
      addCircles(lng = ~ Long, 
                 lat = ~Lat,
                 weight = 5, 
                 radius = ~sqrt(dataframe$Deaths)*1000,
            
            popup = paste0(
              "<b>Country:  </b>",dataframe$Country,' ',dataframe$date,
              "<br><b>Province:  </b>",dataframe$Province,
              "<br>Confirmed=",dataframe$Confirmed,
              "<br>Deaths=",dataframe$Deaths,
              "<br>Recovered=",dataframe$Recovered,
              sep = " "
              
              ),
                           
                 fillColor = "lightblue",
                 highlightOptions = highlightOptions( weight = 10, color = "red", fillColor = "green")
 
            ) %>% 
      addLegend( pal = pal_sb, values = dataframe$Deaths,
                 position = "bottomleft",
                 title = "Total<br/>COVID19<br/>deaths") 
      })
  # OUTPUT 03-03 "DATA TABLE"
  output$mytable <- renderDataTable({Tabledesc <- RATESTable()
                                      Tabledesc  %>%
                                      arrange(desc(Confirmed))})
  
# TAB 02 - LINE PLOTS AND BAR PLOTS
  output$Confcountries = renderPlotly({
    
      data <- POP_POPULATED
      if (input$country != "All") {
        data <- data[POP_POPULATED$Country == input$country,] 
      }
     plot_ly(data, x = ~date, y = ~Conf_7D_10000, type = 'scatter', mode = 'lines')%>%
       layout(title=paste0("Covid19 confirmed cases",input$country))

    })
  output$Deathscountries = renderPlotly({
      data <- POP_POPULATED
      if (input$country != "All") {
        data <- data[POP_POPULATED$Country == input$country,] 
      }
      plot_ly(data, x = ~date, y = ~Death_7D_10000, type = 'scatter', mode = 'lines')%>%
        layout(title=paste0("Covid19 deaths",input$country))
      
    })
  output$Reccountries = renderPlotly({
      data <- POP_POPULATED
      if (input$country != "All") {
        data <- data[POP_POPULATED$Country == input$country,] 
      }
      plot_ly(data, x = ~date, y = ~Rec_7D_10000, type = 'scatter', mode = 'lines') %>%
        layout(title=paste0("Recovered Covid19 cases",input$country))
      
    })
     
  output$ToptenCONF = renderPlotly({
      Tabledesc1 <- POP_POPULATED  %>%
        select(Confirmed,Country,date) %>% 
        mutate(Max_date = max(POP_POPULATED$date)) %>% 
        mutate(Flag_max_date = ifelse(Max_date == date,1,0)) %>% 
        filter(Flag_max_date==1) %>% 
        arrange(desc(Confirmed)) %>% 
        group_by(date) %>% 
        slice(1:10) %>% 
        ungroup()
      
      TabledesC <- Tabledesc1 %>% 
        arrange(Confirmed)
      Top10_D <- data.frame(TabledesC,stringsAsFactors = FALSE)
      Top10_D$Country <- factor(Top10_D$Country, 
                                levels = unique(Top10_D$Country)[order(Top10_D$Confirmed, decreasing = FALSE)])
      
      # Barplot top 10 countries sorted by CONFIRMED cases
      
      plot_ly(Top10_D, x = ~Confirmed, y = ~Country,
              type = 'bar', orientation = 'h')%>%
        layout(title="Top 10 countries Covid19 Confirmed cases")
      
      
    })
  output$ToptenREC = renderPlotly({
      Tabledesc1 <- POP_POPULATED  %>%
        select(Recovered,Country,date) %>% 
        mutate(Max_date = max(POP_POPULATED$date)) %>% 
        mutate(Flag_max_date = ifelse(Max_date == date,1,0)) %>% 
        filter(Flag_max_date==1) %>% 
        arrange(desc(Recovered)) %>% 
        group_by(date) %>% 
        slice(1:10) %>% 
        ungroup()
      
      TabledesC <- Tabledesc1 %>% 
        arrange(Recovered)
      Top10_D <- data.frame(TabledesC,stringsAsFactors = FALSE)
      Top10_D$Country <- factor(Top10_D$Country, 
                                levels = unique(Top10_D$Country)[order(Top10_D$Recovered, decreasing = FALSE)])
      
      # Barplot top 10 countries sorted by CONFIRMED cases
      
      plot_ly(Top10_D, x = ~Recovered, y = ~Country,
              type = 'bar', orientation = 'h')%>%
        layout(title="Top 10 countries Covid19 Recovered cases")
      
      
    })
  output$ToptenDEATH = renderPlotly({
      Tabledesc1 <- POP_POPULATED  %>%
        select(Death,Country,date) %>% 
        mutate(Max_date = max(POP_POPULATED$date)) %>% 
        mutate(Flag_max_date = ifelse(Max_date == date,1,0)) %>% 
        filter(Flag_max_date==1) %>% 
        arrange(desc(Death)) %>% 
        group_by(date) %>% 
        slice(1:10) %>% 
        ungroup()
      
      TabledesC <- Tabledesc1 %>% 
        arrange(Death)
      Top10_D <- data.frame(TabledesC,stringsAsFactors = FALSE)
      Top10_D$Country <- factor(Top10_D$Country, 
                                levels = unique(Top10_D$Country)[order(Top10_D$Death, decreasing = FALSE)])
      
      # Barplot top 10 countries sorted by CONFIRMED cases
      
      plot_ly(Top10_D, x = ~Death, y = ~Country,
              type = 'bar', orientation = 'h')%>%
        layout(title=paste0("Top 10 countries Covid19 Deaths"))
      
      
    })
  
}
# Launch it
shinyApp(ui = ui,server = server)
