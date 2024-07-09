# 00_Initial_data_download.R
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
  if(!dir.exists("original_data_download")){dir.create("original_data_download")}
  if(!dir.exists("Checks")){dir.create("Checks")}
  # Download master.zip file 
  download.file(
    # File from CSSEGITandData repo: time_series_19-covid-Confirmed_archived_0325.csv
    url = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/archived_data/archived_time_series/time_series_19-covid-Confirmed_archived_0325.csv",
    destfile = "original_data_download/time_series_19-covid-Confirmed_archived_0325.csv")
  
  # File from CSSEGITandData repo: time_series_19-covid-Deaths_archived_0325.csv
  download.file(
    url = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/archived_data/archived_time_series/time_series_19-covid-Deaths_archived_0325.csv",
    destfile = "original_data_download/time_series_19-covid-Deaths_archived_0325.csv"
  )
  # File: time_series_19-covid-Recovered_archived_0325.csv
  download.file(
    url = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/archived_data/archived_time_series/time_series_19-covid-Recovered_archived_0325.csv",
    destfile = "original_data_download/time_series_19-covid-Recovered_archived_0325.csv"
  )
  #   File: https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/archived_data/archived_time_series/time_series_2019-ncov-Confirmed.csv
  download.file(
    url = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/archived_data/archived_time_series/time_series_2019-ncov-Confirmed.csv",
    destfile = "original_data_download/time_series_2019-ncov-Confirmed.csv"
  )
  #   File: https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/archived_data/archived_time_series/time_series_2019-ncov-Deaths.csv
  download.file(
    url = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/archived_data/archived_time_series/time_series_2019-ncov-Deaths.csv",
    destfile = "original_data_download/time_series_2019-ncov-Deaths.csv"
  )
  
  #   File: https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/archived_data/archived_time_series/time_series_2019-ncov-Recovered.csv
  download.file(
    url = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/archived_data/archived_time_series/time_series_2019-ncov-Recovered.csv",
    destfile = "original_data_download/time_series_2019-ncov-Recovered.csv"
  )
  
}
DownloadCOVIDData()


# OPTIONAL
# 08/07/2024 Do not required now to download zippd files from CSSEIGISamdData/COVID-19 folder
# In case we need to unzip some files: 

# UnzipCOVIDData <- function(){
# 
#   # Unzip covid19JH.zip file to extract .csv metric files (confirmed, deaths, recovered)
#   # time_series_covid19_confirmed_global.csv, time_series_covid19_deaths_global.csv, 
#   # time_series_covid19_recovered_global.csv
#   unzip(zipfile = "original_data_download/covid19JH.zip",
#     
#     
#     data_path <- "COVID-19-master/csse_covid_19_data/csse_covid_19_time_series/"    
#     files = paste0(data_path, c("time_series_covid19_confirmed_global.csv",
#                                 "time_series_covid19_deaths_global.csv",
#                                 "time_series_covid19_recovered_global.csv")),
#     exdir = "data",
#     junkpaths = T
#   ) 
# }
# 
# UnzipCOVIDData()

# FUNCTION 02-02
# UPDATE AND DOWNLOAD (UNZIP my data):
# Code explained

Dataupdate <- function(){
  T_refresh = 0.5  # hours
  if(!dir_exists("data")){
    dir.create("data")
    DownloadCOVIDData()
  }
  else if((!file.exists("original_data_download/time_series_19-covid-Confirmed_archived_0325.csv"))||as.double( Sys.time() - file_info("original_data_download/time_series_19-covid-Confirmed_archived_0325.csv")$change_time, units = "hours")>T_refresh ){
    # If the latest refresh exceeds 30 minutes, then you download it again
    DownloadTheCOVIDData()
  }
}

# Call this function for testing
Dataupdate()