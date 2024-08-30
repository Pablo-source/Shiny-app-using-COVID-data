# 03_Load_required_Shiny_files.R
library(here)
library(tidyverse)
library(janitor)
library(shiny)
library(shinydashboard)   # Library to build dashboard
library(DT)               # Library for interactive tables
library(tidyverse)        # Library for data manipulation
library(leaflet)          # Library to create interactive maps (Enables pop-ups and animations)
library(plotly)  

# LEAFLET_MAPS_DATA.csv

# 1. Load initial map data  LEAFLET_MAPS_DATA.csv file
map_data_prep  <-read.table(here("new_data", "LEAFLET_MAPS_DATA.csv"),
                            header =TRUE, sep =',',stringsAsFactors =TRUE) %>% clean_names() 
map_data_prep

str(map_data_prep)
library(lubridate)

# 2. Transform initial date variable defined as Factor into a standard R date using as.Date() function.
map_data <- map_data_prep %>% 
  select(!c("x")) %>% 
  mutate(date = as.Date(date) )
map_data    
names(map_data)

# METRICS_POP_RATES_DATA.csv

# 2. Load initial population rates file METRICS_POP_RATES_DATA.csv 
metrics_rates_prep   <-read.table(here("new_data", "METRICS_POP_RATES_DATA.csv"),
                            header =TRUE, sep =',',stringsAsFactors =TRUE) %>% clean_names() 
metrics_rates_prep


metrics_rates <- metrics_rates_prep %>% 
  select(!c("x")) %>% 
  mutate(date = as.Date(date) )
metrics_rates

rm(list=ls()[!(ls()%in%c('map_data','metrics_rates'))])


