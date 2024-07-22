# R Script: 01_Shiny_app_data_prep.R

# Include this two lines of code to ensure {pacman} package is installed to load all remaining packages for this script.

if (!require("pacman")) install.packages("pacman")
pacman::p_load(here,shiny,shinydashboard,DT,fs,leaflet,plotly,tidyverse)

# Check your project directory
My_project_directory <- here()
My_project_directory

# Check installed packages 
Mypath <-.libPaths() 
(.packages())


#  2. Read in the downloaded .csv files

# From the download files 

# We exclude these three files "ncov" because they have date and time format in date columns
# 1/21/20 22:00	1/22/20 12:00	1/23/20 12:00
# time_series_2019-ncov-Confirmed.csv,  time_series_2019-ncov-Deaths.csv,  time_series_2019-ncov-Recovered.csv

# So we read in those files with pattern "time_series_19-covid"

#file_Name <-c("time_series_covid19_confirmed_global.csv","time_series_covid19_deaths_global.csv",
# "time_series_covid19_recovered_global.csv")

# 2.1 From downloaded folder "original_data_download
# Input files with "time_series_19-covid"

getwd()

input_covid <- list.files("original_data_download/", pattern = "time_series_19-covid-.*\\.csv")

# [1] "time_series_19-covid-Confirmed_archived_0325.csv" "time_series_19-covid-Deaths_archived_0325.csv"   
# [3] "time_series_19-covid-Recovered_archived_0325.csv"

NFILES <- length(input_covid)

# Original file names downloaded from URL contain uppercase file names:  "Confirmed,Deaths,Recovered"
file_Name <- c("Confirmed", "Deaths", "Recovered")

for (name in file_Name) {
  
  match_name <- input_covid[grepl(name, input_covid)]
  
  if(length(match_name) > 0) {
    assign(paste0("data_",name), read_csv(paste0("original_data_download/",match_name)))
  }
}

# 3. Pivot wide to long original files to TIDY data frames
# We want date to be in one single column and metric in columns too

# 3.1 Creating CONFIRMED TIDY file. Pivot file from wide to long. 
names(data_Confirmed)

# [1] "Province/State" "Country/Region" "Lat"            "Long"           "1/22/20"        "1/23/20"        "1/24/20"       
# [8] "1/25/20"        "1/26/20"        "1/27/20"        "1/28/20"        "1/29/20" 

# Working with time_series_19-covid-Confirmed_archived_0325.csv" input file saved as "data_Confirmed" data frame 
confirmed_tidy <- data_Confirmed %>% 
  rename(Province = 'Province/State',
         Country = 'Country/Region') %>% 
  pivot_longer(names_to = "date", 
               cols = 5:ncol(data_Confirmed)) %>% 
  group_by(Province,Country,Lat,Long,date) %>% 
  summarise("Confirmed"= sum(value,na.rm = T)) %>% 
  mutate(date =as.Date(date,"%m/%d/%y"))

# 3.2 Creating DECEASED TIDY file. Pivot file from wide to long. 
# DECEASED TIDY
deceased_tidy <- data_Deaths %>% 
  rename(Province = 'Province/State',
         Country = 'Country/Region') %>% 
  pivot_longer(names_to = "date",
               cols = 5:ncol(data_Deaths)) %>% 
  group_by(Province,Country,Lat,Long,date) %>% 
  summarise("Deaths" = sum(value,na.rm = T)) %>% 
  mutate(date = as.Date(date,"%m/%d/%y"))

# 3.3 Creating RECOVERED TIDY file. Pivot file from wide to long. 
# RECOVERED TIDY
recovered_tidy <- data_Recovered %>% 
  rename(Province = 'Province/State',
         Country = 'Country/Region') %>% 
  pivot_longer(names_to = "date",
               cols = 5:ncol(data_Recovered)) %>% 
  group_by(Province,Country,Lat,Long,date) %>% 
  summarise("Recovered" = sum(value,na.rm = T)) %>% 
  mutate(date = as.Date(date,"%m/%d/%y"))

# 3.4 Save checks in new sub_folder called Checks using HERE package 
if (!file.exists("Checks")) {dir.create("Checks")}

write.csv(confirmed_tidy,here("Checks","CONFIRMED_pivoted.csv"), row.names = TRUE)
write.csv(deceased_tidy,here("Checks","DECEASED_pivoted.csv"), row.names = TRUE)
write.csv(recovered_tidy,here("Checks","RECOVERED_pivoted.csv"), row.names = TRUE)

# 3.5 Create new folder to store Quarto documentation about designing this Shiny dashboard
# Folder name: "Shiny_howto_tutorials
if (!file.exists("Shiny_howto_tutorials")) {dir.create("Shiny_howto_tutorials")}
