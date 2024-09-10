# 12 Plotly line chart.R

# First we lload requried data
# # 03_Load_required_Shiny_files.R


## Previous Plotly line charts created
# TAB 02 - LINE PLOTS AND BAR PLOTS

# SERVER section 

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


# I will use  "metric_rates" data set to build these new Plotly line charts: 

# Input dataset: metric_rates
library(tidyverse)
library(plotly)

names(metric_rates)

#[1] "country"                 "date"                    "confirmed"               "recovered"               "deaths"                 
#[6] "population"              "conf_7Days_moving_avg"   "rec_7Days_moving_avg"    "deaths_7Days_moving_avg" "conf_x10,000pop_rate"   
#[11] "rec_x10,000pop_rate"     "deaths_x10,000pop_rate" 

unique(metric_rates$country)

str(metric_rates)

# 1. Subset data for a specific country and sort rows by date in ascending order

# 1.1 Italy confirmed cases - conf_7Days_moving_avg
Italy_conf_ts <- metric_rates  %>%
  select(country,date,conf_7Days_moving_avg) %>% 
  filter(country == 'Italy') %>% 
  arrange(date)

# 1.2 Italy Recovered cases - rec_7Days_moving_avg
Italy_rec_ts <- metric_rates  %>%
  select(country,date,rec_7Days_moving_avg) %>% 
  filter(country == 'Italy') %>% 
  arrange(date)

# 1.3 Italy death cases - deaths_7Days_moving_avg
Italy_death_ts <- metric_rates  %>%
  select(country,date,deaths_7Days_moving_avg) %>% 
  filter(country == 'Italy') %>% 
  arrange(date)

# 2.  use native PLOTLY chart to draw a PLOTLY line chart 

# 2.1 Plotly - Cofirmed cases - Italy  
plot_ly(Italy_conf_ts, x = ~date, y = ~conf_7Days_moving_avg, type = 'scatter', mode = 'lines', color = 'red')%>%
  layout(title="Covid19 confirmed cases - Italy")

# 2.1 Plotly - Recovered cases - Italy  
plot_ly(Italy_rec_ts, x = ~date, y = ~rec_7Days_moving_avg, type = 'scatter', mode = 'lines', color = 'orange')%>%
  layout(title="Covid19 recovered cases - Italy")

# 2.1 Plotly - Death cases - Italy  
plot_ly(Italy_death_ts, x = ~date, y = ~deaths_7Days_moving_avg, type = 'scatter', mode = 'lines')%>%
  layout(title="Covid19 death cases - Italy")



# Source: CSSEGITandData repo: https://github.com/CSSEGISandData/COVID-19/tree/master/archived_data/archived_time_series         

# It works !!!


# Interesting code

# Using scale_x_date() function to control for dates format in X axis on ggplot2 charts
# We have nearly three monhts of data, so we are interesting in displayg data every two days
# and the format we assign to the labels is "%b %Y" so we display month first and year after

# Format dates
# https://stackoverflow.com/questions/10576095/formatting-dates-with-scale-x-date-in-ggplot2
# Format dates: "%b %Y" - date_breaks = "5 days" - date_minor_breaks = "2 day"
scale_x_date(date_breaks = "5 days", date_minor_breaks = "2 day",
             date_labels = "%b %Y") 

# Build a ggplot2 chart
ITALY_confirmed_line <- ggplot(Italy_conf_ts,aes(x=date, y = conf_7Days_moving_avg, fill = date)) +
  geom_line(color="red", linewidth=1,  linetype=1) +
  ggtitle("Italy Confirmed cases") +
  # Format dates
  # https://stackoverflow.com/questions/10576095/formatting-dates-with-scale-x-date-in-ggplot2
  # Format dates: "%b %Y" - date_breaks = "5 days" - date_minor_breaks = "2 day"
  # scale_x_date(date_breaks = "5 days", date_minor_breaks = "2 day",
  #             date_labels = "%b %Y") +
  # scale_x_date(date_labels="%Y/%m",date_breaks  ="1 year") +
  labs(title = "Italy Confirmed cases",
       subtitle ="Source: CSSEGITandData repo: https://github.com/CSSEGISandData/COVID-19/tree/master/archived_data/archived_time_series",
       # Change X and Y axis labels
       x = "Period", 
       y = "COVID19-Confirmed cases") +   
  theme (axis.ticks = element_blank()) +
  theme_bw()
ITALY_confirmed_line   