# 01 Maps data prep

# C:\Pablo UK\43 R projects 2020\04 My Shiny app\10 Shiny TEMPLATES\LEAFLET MAP\Interactive maps
# 00 Maps data prep github.R
# C:\Pablo UK\43 R projects 2020\04 My Shiny app\04 Mycovid19 app
setwd("C:/Pablo UK/43 R projects 2020/04 My Shiny app/04 Mycovid19 app")
getwd()
# Install required packages 
# [shiny,shinydashboard,DT,fs,webstats,leaflet,plotly,tidyverse]
#install.packages("shinydashboard",dependencies = TRUE) 
#install.packages("DT",dependencies = TRUE)
#install.packages("webstats",dependencies = TRUE)
#install.packages("leaflet",dependencies = TRUE)
#install.packages("plotly",dependencies = TRUE)

# Load required packages library(tidyverse) library(readr)
library("shiny")
library("shinydashboard")
library("DT")
library("fs")
# library("webstats")
library("leaflet")
library("plotly")
library("tidyverse")

# Check installed packages 
Mypath <-.libPaths() 
(.packages())

# 1 Read in Github data as ZIP file
#  https://github.com/CSSEGISandData/COVID-19/archive/master.zip
DownloadCOVIDData <- function() {
  
  # Create data directory if doesn't exist
    if(!dir.exists("data")){dir.create("data")}
    if(!dir.exists("CHECKS")){dir.create("CHECKS")}
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
# C:\Pablo UK\43 R projects 2020\04 My Shiny app\10 Shiny TEMPLATES\LEAFLET MAP\Interactive maps\data

#input_covid <- list.files("C:/Pablo UK/43 R projects 2020/04 My Shiny app/04 Mycovid19 app/data",pattern = "_global*.csv")
#file_Name <-c("data_confirmed","data_deceased","data_recovered")

getwd() 

input_covid <- list.files("data/",".csv")

NFILES <- length(input_covid)
file_Name <-c("data_confirmed","data_deceased","data_recovered","WDI_indicators")

for(i in 1:NFILES) {     
  assign(paste0(file_Name[i]),                                   # Read and store data frames
         read_csv(paste0("data/",
                         input_covid[i])))
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
deceased_tidy <- data_deceased %>% 
                  rename(Province = 'Province/State',
                  Country = 'Country/Region') %>% 
                    pivot_longer(names_to = "date",
                    cols = 5:ncol(data_deceased)) %>% 
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

file_pathCHK <-('C://Pablo UK//43 R projects 2021//04 My Shiny app//04 Mycovid19 app//CHECKS/')

File_name_conf <-'/PITVOTED_CONFIRMED.csv'
File_name_dec <-'/PIVOTED_DECEASED.csv' 
File_name_rec <-'/PIVOTED_RECOVERED.csv' 

write.csv(confirmed_tidy,paste0(file_pathCHK,File_name_conf),row.names = T)
write.csv(deceased_tidy,paste0(file_pathCHK,File_name_dec),row.names = T)
write.csv(recovered_tidy,paste0(file_pathCHK,File_name_rec),row.names = T)

save.image("C://Pablo UK//43 R projects 2021//04 My Shiny app//04 Mycovid19 app//CHECKS//CDR_LACATION.RData")

# Now we merge them together
# 01-02 Merge DECEASED and CONFIRMED files
MAPDATA <- confirmed_tidy %>% 
              full_join(deceased_tidy)

File_name <-'/FULL_JOIN_conf_dec.csv' 
write.csv(MAPDATA,paste0(file_pathCHK,File_name),row.names = T)

# 01-02 Merge with RECOVERED data
MAPDATAF <- MAPDATA %>% 
              full_join(recovered_tidy) %>% 
              arrange(Province,Country,date) %>% 
              #Recode NA values into 0 
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

### **5.1 COVID19 Leaflet Map
PLOT_LEAFLET_MAPS <- MAPDATAH %>%
                     pivot_wider(names_from = Metric, values_from = c(value))

File_name <-'/PLOT_LEAFLET_MAPS.csv' 
MAPcountrieslist <-unique(PLOT_LEAFLET_MAPS$Country)

save.image("C:/Pablo UK/43 R projects 2021/04 My Shiny app/04 Mycovid19 app/PLOT LEAFLET MAPS.RData")

### **5.2 COVID19 population rates
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

save.image("C:/Pablo UK/43 R projects 2021/04 My Shiny app/04 Mycovid19 app/PLOT LEAFLET CDR NUM.RData")



