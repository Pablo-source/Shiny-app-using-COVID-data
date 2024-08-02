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
# File: METRICS_FOR_POP_RATES.csv
metrcs_input_file  <- list.files("original_data_processed/", pattern = "METRICS_FOR_POP_RATES.*\\.csv")

file_Name <- c("METRICS_FOR_POP_RATES")

for (name in file_Name) {
  
  match_name <- metrcs_input_file[grepl(name, metrcs_input_file)]
  
  if(length(match_name) > 0) {
    assign(paste0("data_",name), read_csv(paste0("original_data_processed/",match_name)))
  }
}
METRICS_original <- data_METRICS_FOR_POP_RATES %>%  
                    select(Country, Lat, Long, date, Confirmed, Recovered, Deaths)


# Check unique country names from this METRICS file
METRICS_country_unique <- METRICS_original %>% select(Country) %>% distinct(Country)
METRICS_country_unique
nrow(METRICS_country_unique)
write.csv(METRICS_country_unique,here("original_data_processed","METRICS_country_unique.csv"), row.names = TRUE)

# 2. Load POPULATION figures from file  "WDI_countries_pop_2010_clean.csv" file
library(tidyverse)
library(here)
if (!require("WDI")) install.packages("WDI")
library(WDI)

# 2.1. Load  World Bank Total population by country indicator "SP.POP.TOTL" from {WDI} package
WDI_population <- WDI(indicator = c("SP.POP.TOTL"), extra = TRUE)
WDI_population

# 2.2. Filter values retaining Year 2019 - when pandemic started - to compute rates
# Also remove null values for capital variable
WDI_countries_pop_2019 <- WDI_population %>% 
  select(country,year,population = SP.POP.TOTL,capital) %>% 
  filter(year == 2019 &
           capital != "")  # (capital ! = " ") Removed all instances when capital variable is emtpy.
WDI_countries_pop_2019  

head(WDI_countries_pop_2019)


POPULATION_original <- WDI_countries_pop_2019 %>% select(Country = country,
                                                         year,population)
POPULATION_original
head(POPULATION_original)

# Remove previous intermediate data sets:(retain just METRICS and POPULATION_original data frames)
rm(list=ls()[! ls() %in% c("METRICS","POPULATION_original","LEAFLET_MAPS_DATA","METRICS_FOR_POP_RATES")])

# LIST OF COUNTRY NAMES FROM METRICS data frame that are slightly different written in the WDI_countries_pop_2019 file
# List of missing population figures for the following mismatching country names
# 1 Bahamas, The                            # 27 Slovakia
# 2 Brunei                                  # 28 Syria
# 3 Cape Verde                              # 29 Taiwan*
# 4 Congo (Brazzaville)                     # 30 The Bahamas       
# 5 Congo (Kinshasa)                        # 31 The Gambia
# 6 Cruise Ship                             # 32 Turkey
# 7 Czechia                                 # 33 US
# 8 East Timor                              # 34 Venezuela
# 9 Egypt                                   # 35 Vietnam
# 10 French Guiana
# 11 Gambia, The
# 12 Guadeloupe
# 13 Guernsey
# 14 Holy See
# 15 Iran
# 16 Israel
# 17 Jersey
# 18 Korea, South
# 19 Kyrgyzstan
# 20 Martinique
# 21 Mayotte
# 22 Republic of the Congo
# 23 Reunion
# 24 Russia
# 25 Saint Lucia
# 26 Saint Vincent and the Grenadines

# Re-code POPULATION_original into POPULATION file with the right country names that will match METRICS file 
# Input file: POPULATION_original
# Output file: POPULATION 

# 3 APPLY CHANGES

# 3.1 There are several records per day in the METRIC file
## Follow example from # Metric_population_rates_checks.R to obtain one single row per day summarising
## Confirmed, Recovered and Deaths figures 




# 3.2 Apply regex expresions before merge to both METRICS_original and POPULATION_original files
# Remove punctuation symbols Country_name = gsub("[[:punct:]]", "", Country)

METRICS_cleansing <- METRICS_original %>% 
           mutate(Country_name = gsub("[[:punct:]]", "", Country))

METRICS <- METRICS_cleansing %>% select(Country_name, Lat, Long, date, Confirmed, Recovered, Deaths)

POPULATION_cleansing <- POPULATION_original %>% 
  mutate(Country_name = gsub("[[:punct:]]", "", Country))

names(POPULATION_cleansing)
# [1] "Country"      "year"         "population"   "Country_name"

POPULATION <- POPULATION_cleansing %>% select(Country_name,year,population)

names(POPULATION)


# 4. In THE  “02 Covid_metrics_population_rates.R” file for the METRICS FILE, compute a SUM() for each Confirmed, Recovered and Deaths cases by date, 
#    so we have just one Row per country per day.

nrow(METRICS)
# [1] 31434
rm(list=ls()[! ls() %in% c("METRICS")])





# Apply it to the entire METRICS data frame



# This is the merge we will perform 
METRICS_POP_RATES_checks <- left_join(METRICS,POPULATION_original,
                                      by = join_by(Country == Country))
METRICS_POP_RATES_checks

# Countries with missing population figures
no_pop_countries <- METRICS_POP_RATES_checks %>% 
  filter(is.na(population)) %>% 
  distinct(Country)
no_pop_countries
write.csv(no_pop_countries,here("original_data_processed","countries_missing_population_figures.csv"), row.names = TRUE)
