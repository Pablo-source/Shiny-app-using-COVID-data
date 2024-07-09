# 00 Maps data prep_SHINY.R
# Updated on 10th Dec 2022
 
# Install required packages 
# [shiny,shinydashboard,DT,fs,webstats,leaflet,plotly,tidyverse]
#install.packages("shinydashboard",dependencies = TRUE) 
#install.packages("DT",dependencies = TRUE)
#install.packages("webstats",dependencies = TRUE)
#install.packages("leaflet",dependencies = TRUE)
#install.packages("plotly",dependencies = TRUE)

# Load required packages library(tidyverse) library(readr)
# Library here for relative paths creation

# Optmised: Using p_load() function from pacman package to load several libraries in one go
#library("here")
#library("shiny")
#library("shinydashboard")
#library("DT")
#library("fs")
# library("webstats")
#library("leaflet")
#library("plotly")
#library("tidyverse")

# Load required libraries 
pacman::p_load(here,shiny,shinydashboard,DT,fs,leaflet,plotly,tidyverse)

ChecksFlag = FALSE # or TRUE
# Check your project directory
My_project_directory <- here()
My_project_directory

# Check installed packages 
Mypath <-.libPaths() 
(.packages())

# 1 Read in Github data as ZIP file
#  https://github.com/CSSEGISandData/COVID-19/archive/master.zip
DownloadCOVIDData <- function() {
  
  # Create data directory if doesn't exist
    if(!dir.exists("data")){dir.create("data")}
    if(!dir.exists("Checks")){dir.create("Checks")}
  # Download master.zip file 
  download.file(
    url = "https://github.com/CSSEGISandData/COVID-19/archive/master.zip",
    destfile = "data/covid19JH.zip"
  )
  data_path <- "COVID-19-master/csse_covid_19_data/csse_covid_19_time_series/"
  
  # Unzip covid19JH.zip file to extract .csv metric files (confirmed, deaths, recovered)
  # time_series_covid19_confirmed_global.csv, time_series_covid19_deaths_global.csv, 
  # time_series_covid19_recovered_global.csv
  unzip(zipfile = "data/covid19JH.zip",
    
    files = paste0(data_path, c("time_series_covid19_confirmed_global.csv",
                                "time_series_covid19_deaths_global.csv",
                                "time_series_covid19_recovered_global.csv")),
    exdir = "data",
    junkpaths = T
  ) 
}

DownloadCOVIDData()

# FUNCTION 02-02
# UPDATE AND DOWNLOAD (UNZIP my data):
# Code explained

Dataupdate <- function(){
                              T_refresh = 0.5  # hours
                              if(!dir_exists("data")){
                              dir.create("data")
                              DownloadTheCOVIDData()
  }
  else if((!file.exists("data/covid19JH.zip"))||as.double( Sys.time() - file_info("data/covid19JH.zip")$change_time, units = "hours")>T_refresh ){
    # If the latest refresh exceeds 30 minutes, then you download it again
    DownloadTheCOVIDData()
  }
}

# Call this function for testing
Dataupdate()

#  2. Read in the downloaded .csv files

#file_Name <-c("time_series_covid19_confirmed_global.csv","time_series_covid19_deaths_global.csv",
# "time_series_covid19_recovered_global.csv")

getwd()

input_covid <- list.files("data/", pattern = "time_series.*\\.csv")

NFILES <- length(input_covid)

file_Name <- c("confirmed", "deaths", "recovered")

for (name in file_Name) {
  match_name <- input_covid[grepl(name, input_covid)]
  if(length(match_name) > 0) {
    assign(paste0("data_",name), read_csv(paste0("data/",match_name)))
  }
}

# Tidy up original datasets
library(tidyr)

# CONFIRMED TIDY
names(data_confirmed)

# First rename the two first columns using rename() function 
confirmed_tidy <- data_confirmed %>% 
                  rename(Province = 'Province/State',
                         Country = 'Country/Region') %>% 
                  pivot_longer(names_to = "date", 
                  cols = 5:ncol(data_confirmed)) %>% 
                  group_by(Province,Country,Lat,Long,date) %>% 
                  summarise("Confirmed"= sum(value,na.rm = T)) %>% 
                  mutate(date =as.Date(date,"%m/%d/%y"))


# DECEASED TIDY
deceased_tidy <- data_deaths %>% 
                  rename(Province = 'Province/State',
                  Country = 'Country/Region') %>% 
                    pivot_longer(names_to = "date",
                    cols = 5:ncol(data_deaths)) %>% 
                    group_by(Province,Country,Lat,Long,date) %>% 
                    summarise("Deaths" = sum(value,na.rm = T)) %>% 
                    mutate(date = as.Date(date,"%m/%d/%y"))

# RECOVERED TIDY
recovered_tidy <- data_recovered %>% 
                        rename(Province = 'Province/State',
                        Country = 'Country/Region') %>% 
                        pivot_longer(names_to = "date",
                        cols = 5:ncol(data_recovered)) %>% 
                        group_by(Province,Country,Lat,Long,date) %>% 
                        summarise("Recovered" = sum(value,na.rm = T)) %>% 
                        mutate(date = as.Date(date,"%m/%d/%y"))
head(recovered_tidy)



# Save checks in new sub_folder called Checks using HERE package 
if (!file.exists("Checks")) {
  dir.create("Checks")
}

if(ChecksFlag){
  write.csv(confirmed_tidy,here("Checks","PITVOTED_CONFIRMED.csv"), row.names = TRUE)
  write.csv(deceased_tidy,here("Checks","PITVOTED_DECEASED.csv"), row.names = TRUE)
  write.csv(recovered_tidy,here("Checks","PITVOTED_RECOVERED.csv"), row.names = TRUE)
}

# Now we merge CONFIRMED, DECEASED AND RECOVERED data frames together

# 01-02 Merge DECEASED and CONFIRMED files
MAPDATA <- confirmed_tidy %>% 
              full_join(deceased_tidy)

# Write mapdata to checks folder
if(ChecksFlag){
  write.csv(MAPDATA,here("Checks","FULL_JOIN_conf_dec.csv"), row.names = TRUE)
}
# 01-02 Merge DECEASED AND CONFIRMED with RECOVERED data
MAPDATAF <- MAPDATA %>% 
              full_join(recovered_tidy) %>% 
              arrange(Province,Country,date) %>% 
              # Recode NA values into 0 
              mutate(  
                Confirmed = ifelse(is.na(Confirmed),0,Confirmed),
                Deaths = ifelse(is.na(Deaths),0,Deaths),
                Recovered = ifelse(is.na(Recovered),0,Recovered)
                    )

MAPDATAG <- MAPDATAF

# 7 PIVOT_LONGER
# We need to change the data structure to group Confirmed, Deaths, Recovered 
# into a single variable on its own column in the dataset
MAPDATAH <- MAPDATAG %>% 
            pivot_longer(names_to = "Metric",
                         cols = c("Confirmed","Deaths","Recovered")) %>% 
            ungroup()

# we only need the data_evolution dataset
rm(list=ls()[! ls() %in% c("MAPDATAH")])

#### **5. Two output files: COVID19 metrics by day and COVID metrics plus Lat Long variable for Leaflet maps 
#
#  COVID19 Leaflet Map, file :  "PLOT_LEAFLET_MAPS"
#  COVID19 population rates, file: "PLOT_LEAFLET_CDR_NUM" 

### **5.1 COVID19 Leaflet Map, file :  "PLOT_LEAFLET_MAPS"
PLOT_LEAFLET_MAPS <- MAPDATAH %>%
                     pivot_wider(names_from = Metric, values_from = c(value))

File_name <-'/PLOT_LEAFLET_MAPS.csv' 
MAPcountrieslist <-unique(PLOT_LEAFLET_MAPS$Country)

### **5.2 COVID19 population rates, file: "PLOT_LEAFLET_CDR_NUM"
# Remove  (removing coordinates variables)
PLOT_LEAFLET2_conf <- PLOT_LEAFLET_MAPS %>% 
                select(Country,date,Confirmed) %>% 
                group_by(Country,date) %>% 
                summarise("Confirmed" = sum(Confirmed,na.rm = T))

PLOT_LEAFLET2_death <- PLOT_LEAFLET_MAPS %>% 
                       select(Country,date,Deaths) %>% 
                       group_by(Country,date) %>% 
                        summarise("Death" = sum(Deaths,na.rm = T))
            
PLOT_LEAFLET2_Recov <- PLOT_LEAFLET_MAPS %>% 
                            select(Country,date,Recovered) %>% 
                            group_by(Country,date) %>% 
                            summarise("Recovered" = sum(Recovered,na.rm = T))

# Join together
PLOT_LEAFLET_RATES <- PLOT_LEAFLET2_conf %>% 
                       full_join(PLOT_LEAFLET2_death) %>% 
                       arrange(Country,date)

PLOT_LEAFLET_RATES <- PLOT_LEAFLET_RATES %>% 
                      full_join(PLOT_LEAFLET2_Recov) %>% 
                      arrange(Country,date)

PLOT_LEAFLET_CDR_NUM <-PLOT_LEAFLET_RATES

# Keep just plot_leaflet_rates
rm(list=ls()[!(ls()%in%c('PLOT_LEAFLET_CDR_NUM','PLOT_LEAFLET_MAPS'))])

#### We only keep these two files: 
# PLOT_LEAFLET_CDR_NUM
# PLOT_LEAFLET_MAPS
save.image("~/SHINY APP DATA SETS.RData")



