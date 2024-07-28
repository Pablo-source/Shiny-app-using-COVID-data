# 02 Covid_metrics_population_rates.R

# AIM
# merge original METRICS_FOR_POP_RATES.csv file stored in \original_data_processed 
# with WDI_countries_pop_2019_clean.csv file stored in the same folder. 
# This new R script will replace previous existing “02 Leaf and pop figures_SHINY.R” file. 

# Load required libraries
library(readr)
library(dplyr)
library(ggplot2)
library(here)

# 1. Load METRICS_FOR_POP_RATES.csv file from \original_data_processed folder

metrcs_input_file  <- list.files("original_data_processed/", pattern = "METRICS_FOR_POP_RATES.*\\.csv")
metrcs_input_file

file_Name <- c("METRICS_FOR_POP_RATES")

for (name in file_Name) {
  
  match_name <- metrcs_input_file[grepl(name, metrcs_input_file)]
  
  if(length(match_name) > 0) {
    assign(paste0("data_",name), read_csv(paste0("original_data_processed/",match_name)))
  }
}

# Imported file "data_METRICS_FOR_POP_RATES"

METRICS <-  data_METRICS_FOR_POP_RATES %>% select(Country, Lat, Long, date, Confirmed, Recovered, Deaths)
METRICS

# Unique countries names in METRICS file
METRICS_country_unique <- METRICS %>% 
                          select(Country) %>% 
                          distinct(Country)
METRICS_country_unique
nrow(METRICS_country_unique)
# 183
write.csv(METRICS_country_unique,here("original_data_processed","METRICS_country_unique.csv"), row.names = TRUE)

# 2. Subset variables and merge it with "WDI_countries_pop_2010_clean.csv" file

population_data  <- list.files("original_data_processed/", pattern = "WDI_countries_pop_2019_.*\\.csv")
population_data

file_Name <- c("WDI_countries_pop_2019_clean")

for (name in file_Name) {
  
  match_name <- population_data[grepl(name, population_data)]
  
  if(length(match_name) > 0) {
    assign(paste0("data_",name), read_csv(paste0("original_data_processed/",match_name)))
  }
}

POPULATION <-  data_WDI_countries_pop_2019_clean %>% select (Country = country, year, population)
POPULATION

POPULATION_country_unique <- POPULATION %>% 
                        select(Country) %>% 
                        distinct(Country)
POPULATION_country_unique
nrow(POPULATION_country_unique)
# 190
write.csv(POPULATION_country_unique,here("original_data_processed","POPULATION_country_unique.csv"), row.names = TRUE)

# 3. Reconcile COUNTRY NAMES in both files METRICS and POPULATION



