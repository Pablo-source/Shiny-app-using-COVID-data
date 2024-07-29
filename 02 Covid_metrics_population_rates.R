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

METRICS <- data_METRICS_FOR_POP_RATES %>%  
           select(Country, Lat, Long, date, Confirmed, Recovered, Deaths)
write.csv(METRICS,here("original_data_processed","METRICS.csv"), row.names = TRUE)

# Check unique country names from this METRICS file
METRICS <-  data_METRICS_FOR_POP_RATES %>% select(Country, Lat, Long, date, Confirmed, Recovered, Deaths)
METRICS_country_unique <- METRICS %>% select(Country) %>% distinct(Country)
METRICS_country_unique
nrow(METRICS_country_unique)
write.csv(METRICS_country_unique,here("original_data_processed","METRICS_country_unique.csv"), row.names = TRUE)

# 2. Load POPULATION figures from file  "WDI_countries_pop_2010_clean.csv" file
population_data  <- list.files("original_data_processed/", pattern = "WDI_countries_pop_2019_.*\\.csv")
population_data

file_Name <- c("WDI_countries_pop_2019_clean")

for (name in file_Name) {
  
  match_name <- population_data[grepl(name, population_data)]
  
  if(length(match_name) > 0) {
    assign(paste0("data_",name), read_csv(paste0("original_data_processed/",match_name)))
  }
}

write.csv(METRICS,here("data_","WDI_c.csv"), row.names = TRUE)

POPULATION <-  data_WDI_countries_pop_2019_clean %>% 
               select (Country = country, year, population)
write.csv(POPULATION,here("original_data_processed","POPULATION.csv"), row.names = TRUE)


# Check unique country names from this POPULATION file
POPULATION_country_unique <- POPULATION %>% select(Country) %>% distinct(Country)
POPULATION_country_unique
nrow(POPULATION_country_unique)
write.csv(POPULATION_country_unique,here("original_data_processed","POPULATION_country_unique.csv"), row.names = TRUE)

POPULATION <-read.table(here("original_data_processed", "POPULATION_country_unique.csv"),
                           header =TRUE, sep =',',stringsAsFactors =TRUE)

# 3. Reconcile COUNTRY NAMES in both files METRICS and POPULATION

# There are some Country names from the original METRICS file that do not have
# similar match in the POPULATION file. 

# To test it I will do a LEFT merge between METRICS and POPULATION files and 
# check NA after the merge, which countries do not have available population figures
# Then I will go back to WDI to obtain population figures for those countries and create a dataframe with those countries population
# figures and merge it again with METRICS data frame until all countries have their population figures populated in the METRICS file

# 3.1 Merge METRICS with POPULATION 

# Ljoin <-left_join(Base,New,by = join_by(Brand == Marca))
# Ljoin

# names(METRICS)
# [1] "Country"   "Lat"       "Long"      "date"      "Confirmed" "Recovered" "Deaths"  
# names(POPULATION)
# [1] "Country"    "year"       "population"

METRICS_POP_RATES_checks <- left_join(METRICS,POPULATION,
                                by = join_by(Country == Country))
METRICS_POP_RATES_checks

# Countries with missing population figures
no_pop_countries <- METRICS_POP_RATES_checks %>% 
                    filter(is.na(population)) %>% 
                    distinct(Country)
no_pop_countries
write.csv(no_pop_countries,here("original_data_processed","countries_missing_population_figures.csv"), row.names = TRUE)


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

# 4. Initial population MERGE (it has mismatching names)
METRICS_POP_RATES_incomplete <- left_join(METRICS,POPULATION,
                                      by = join_by(Country == Country))
METRICS_POP_RATES_incomplete


# 5. Populate missing countries population figures
# For this list of 35 Countries, I will go back to the {WDI} package and create a new dataset with these 35 missing countries
# When I will do a sc

library(WDI)

# 1. Load  World Bank Total population by country indicator "SP.POP.TOTL" from {WDI} package
WDI_population <- WDI(indicator = c("SP.POP.TOTL"), extra = TRUE)
WDI_population

WDI_population_reconcile <-WDI_population  %>% 
                            select(country,year,population = SP.POP.TOTL,capital) %>% 
                            filter(year == 2019 &
                            capital != "") 
WDI_population_reconcile

# 5.1 Check I am able to find each of the missing countries by doing a fizzy country name search:


