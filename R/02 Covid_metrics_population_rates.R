# 02 Covid_metrics_population_rates.R

# Important: This scripts runs using source_all() adhoc function from \R sub-folder


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


# We will apply some calculations on this METRICS file below

METRICS <- METRICS_original

write.csv(METRICS,here("original_data_processed","METRICS_original.csv"), row.names = TRUE)

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
# CALC01: Obtain one row per DAY

## Follow example from # Metric_population_rates_checks.R to obtain one single row per day summarising
## Confirmed, Recovered and Deaths figures 

METRICS_daily <- METRICS 
head(METRICS_daily)
#   Country       Lat  Long date       Confirmed Recovered Deaths

nrow(METRICS_daily)
# 
#> nrow(METRICS_daily)
#[1] 31434


rm(list=ls()[! ls() %in% c("METRICS_daily","POPULATION_original")])

METRICS_daily_calc <- METRICS_daily %>% 
  select(Country,date,Lat,Long,Confirmed,Recovered,Deaths) %>% 
  group_by(Country,date,Lat,Long) %>%
  summarise(
    Confirmed_d = sum(Confirmed),
    Recovered_d = sum(Recovered),
    Deaths_d = sum(Deaths)
  ) %>% 
    ungroup()  # Include ungroup() after using group_by() to avoid "- attr(*, "groups")= tibble [30,938 × 4] (S3: tbl_df/tbl/data.frame)"
               # so we can compute lag() on ungrouped integer variables.
METRICS_daily_calc
nrow(METRICS_daily_calc)
# [1] 31000

write.csv(METRICS_daily_calc,here("original_data_processed","METRICS_daily_calc.csv"), row.names = TRUE)

# Remove previous intermediate data sets:(retain just METRICS and POPULATION_original data frames)
rm(list=ls()[! ls() %in% c("METRICS_daily_calc","POPULATION_original","LEAFLET_MAPS_DATA","METRICS_FOR_POP_RATES")])



# 3.2 Apply regex expresions before merge to both METRICS_original and POPULATION_original files
# Remove punctuation symbols Country_name = gsub("[[:punct:]]", "", Country)

METRICS_cleansing <- METRICS_daily_calc %>% 
           mutate(Country_name = gsub("[[:punct:]]", "", Country))

METRICS <- METRICS_cleansing %>% select(
                                        Country = Country_name,
                                        Lat, Long, date, 
                                        Confirmed = Confirmed_d, 
                                        Recovered = Recovered_d, 
                                        Deaths = Deaths_d)

write.csv(METRICS,here("original_data_processed","METRICS.csv"), row.names = TRUE)


POPULATION_cleansing <- POPULATION_original %>% 
  mutate(Country_name = gsub("[[:punct:]]", "", Country))

names(POPULATION_cleansing)
# [1] "Country"      "year"         "population"   "Country_name"

POPULATION_Recode <- POPULATION_cleansing %>% select(Country = Country_name,
                                              year,population)
str(POPULATION_Recode)
names(POPULATION_Recode)

# 3.3 Prior to merging POPULATION and MERTICS files, rename POPULATION contry names so they math METRICS names
#   Country    name_METRICS name_POPULATION
# 2 Brunei    	Brunei	Brunei Darussalam
# 3 Cape Verde   	Cape Verde	Cabo Verde
# 8 East Timor  	East Timor	POPULATION country name “Timor-Leste”
# 9 Egypt	Egypt	POPULATION country name “Egypt, Arab Rep.”
# 10 French Guiana	French Guiana	POPULATION country name “Guyana”
# 11 Gambia, The	Gambia, The	POPULATION country name “Gambia, The” 
# 15 Iran	Iran	POPULATION country name  “Iran, Islamic Rep.”
# 18 Korea, South	Korea, South	POPULATION country name  Korea, Rep. 51764822
# 19 Kyrgyzstan	Kyrgyzstan	POPULATION country name  “Kyrgyz Republic” 6456200
# 22 Republic of the Congo	Republic of the Congo	Congo, Rep. 5570733
# 24 Russia	Russia	POPULATION country name Russian Federation 145453291
# 25 Saint Lucia	Saint Lucia	POPULATION country name St. Lucia 178583
# 26 Saint Vincent and the Grenadines	Saint Vincent and the Grenadinesenadines	POPULATION country name St. Vincent and the Grenadines 104924
# 27 Slovakia	Slovakia	POPULATION country name Slovak Republic 5454147
# 28 Syria	Syria	POPULATION country name Syrian Arab Republic 20098251
# 30 The Bahamas	The Bahamas	POPULATION country name Bahamas, The 404557 
# 31 The Gambia	The Gambia	POPULATION country name Gambia, The 2508883
# 32 Turkey	Turkey	POPULATION country nameTurkiye 82579440
# 33 US	US	POPULATION country nameUnited States 328329953
# 34 Venezuela	Venezuela	POPULATION country nameVenezuela, RB 28971683

names(POPULATION_Recode)
str(POPULATION_Recode)

# [1] "Country"    "year"       "population"

# Original POPULATION names


POP_ORIGINAL <-c("Brunei Darussalam","Cabo Verde","TimorLeste","Egypt Arab Rep",
                 "Gambia The","Iran Islamic Rep", "Korea Rep","Kyrgyz Republic",
                 "Congo Rep","Russian Federation","St Lucia",
                 "St Vincent and the Grenadines","Slovak Republic",
                 "Syrian Arab Republic","Bahamas The","Turkiye","United States")
length(POP_ORIGINAL) 
# 18

POP_TOMERGE <-c("Brunei","Cape Verde","East Timor","Egypt",
                "Gambia The","Iran","Korea South","Kyrgyzstan",
                "Republic of the Congo","Russia","Saint Lucia",
                "Saint Vincent and the Grenadines","Slovakia",
                "Syria","Bahamas The","Turkey","US")
length(POP_TOMERGE)
# 18 

# Then we replace non-standard country names by standardized country names values 
# POPULATION_Recode$Country_name[which(POPULATION_Recode_comp$Country_name %in% POP_ORIGINAL ), "Country_name"] <- POP_TOMERGE


# 3.3.1 Another option is to use standard recode and case_when() functions
# New variable Country_names includes matching country names with METRICS data set
head(POPULATION_Recode)
POPULATION_Recode$Country_names <- case_when(POPULATION_Recode$Country %in% c("Brunei Darussalam") ~ "Brunei",
                                             POPULATION_Recode$Country %in% c("Cabo Verde") ~ "Cape Verde",
                                             POPULATION_Recode$Country %in% c("TimorLeste") ~ "East Timor",
                                             POPULATION_Recode$Country %in% c("Egypt Arab Rep") ~ "Egypt",
                                             POPULATION_Recode$Country %in% c("Gambia The") ~ "Gambia The",
                                             POPULATION_Recode$Country %in% c("Iran Islamic Rep") ~ "Iran",
                                             POPULATION_Recode$Country %in% c("Korea Rep") ~ "Korea South",
                                             POPULATION_Recode$Country %in% c("Kyrgyz Republic") ~ "Kyrgyzstan",
                                             POPULATION_Recode$Country %in% c("Congo Rep") ~ "Republic of the Congo",
                                             POPULATION_Recode$Country %in% c("Russian Federation") ~ "Russia",
                                             POPULATION_Recode$Country %in% c("St Lucia") ~ "Saint Lucia",
                                             POPULATION_Recode$Country %in% c("St Vincent and the Grenadines") ~ "Saint Vincent and the Grenadines",
                                             POPULATION_Recode$Country %in% c("Slovak Republic") ~ "Slovakia",
                                             POPULATION_Recode$Country %in% c("Syrian Arab Republic") ~ "Syria",
                                             POPULATION_Recode$Country %in% c("Bahamas The") ~ "Bahamas The",
                                             POPULATION_Recode$Country %in% c("Turkiye") ~ "Turkey",
                                             POPULATION_Recode$Country %in% c("United States") ~ "US",
                                             )
POPULATION_Recode_clean <- POPULATION_Recode
POPULATION_Recode_clean$Country_names[is.na(POPULATION_Recode_clean$Country_names)] <- POPULATION_Recode_clean$Country[is.na(POPULATION_Recode_clean$Country_names)]

# Countries with missing population figures
# no_pop_countries <- METRICS_POP_RATES_checks %>% 
#  filter(is.na(population)) %>% 
#  distinct(Country)
# no_pop_countries
# write.csv(no_pop_countries,here("original_data_processed","countries_missing_population_figures.csv"), row.names = TRUE)

# Datasets: 
#  > METRICS
#  > POPULATION_Recode_clean

rm(list=ls()[! ls() %in% c("METRICS","POPULATION_Recode_clean")])

## METRICS dataset. Variables ()
names(METRICS)
# [1] "Country"   "Lat"       "Long"      "date"      "Confirmed" "Recovered" "Deaths" 
names(POPULATION_Recode_clean)
# [1] "Country"       "year"          "population"    "Country_names"
# keep  "year"          "population"    "Country_names"

# 3.4 MERGE METRICS WITH POPULATION_Recode_clean data frames 
# At this stage the null values we will obtain for population are 
# variable Country_names includes matching country names with METRICS data set

METRICS_merge <- METRICS %>% select(Country,Lat,Long,date,Confirmed,Recovered,Deaths)
POPULATION_merge <- POPULATION_Recode_clean %>% select(Country_names,population)

METRICS_POP_RATES_initial <- left_join(METRICS,POPULATION_Recode_clean,
                                      by = join_by(Country == Country_names))
METRICS_POP_RATES_initial

# Check which Countries still have missing population figures
# sort previous dataset by population using arrange()
METRICS_POP_RATES_clean <- METRICS_POP_RATES_initial %>% 
                           select(Country,Lat,Long,date,Confirmed,Recovered,Deaths,year,population)
                           arrange(population)
METRICS_POP_RATES_clean

# Get countries list missing population figures
missing_countries_pop <- METRICS_POP_RATES_clean %>% 
                         arrange(population) %>% 
                         filter(is.na(population)) %>% 
                         select(Country) %>% 
                         distinct(Country)
missing_countries_pop

write.csv(missing_countries_pop,here("original_data_processed","missing_countries_pop.csv"), row.names = TRUE)

# 3.4.1 Create adhoc dataset with population figures from Word bank website
# https://datatopics.worldbank.org/world-development-indicators/
# Adding all missing population countries figures to this new data frame below
Country <-c("Bahamas","Congo Brazzaville","Congo Kinshasa","Cruise Ship","Czechia","Guadeloupe",
            "Guernsey","Holy See","Israel","Jersey","Martinique","Mayottev","Reunion","Taiwan",
            "Vietnam")
length(Country) 
# [1] 15
population <-c(404557, 5571557,89910000,3711,10670000,395485,62365,604,9050000,96200,
               372245,270372,861200,23600000,95780000)
length(population) 
# [1] 15

## Exclude some duplicated countries (after merging data)
# "The Bahamas"

Pop_missing_countries <-cbind.data.frame(Country,population)
str(Pop_missing_countries)

# Turn data.frame into a tibble
Pop_missing_countries_data <- Pop_missing_countries %>% 
                              select(Country,population) %>% 
                              as_tibble()

rm(list=ls()[! ls() %in% c("Pop_missing_countries_data","METRICS_POP_RATES_clean")])

# 3.4.2 Merge METRICS_POP_RATES_clean with Pop_missing_countries dataframe
METRICS_POP_RATES_wrangling <- left_join(METRICS_POP_RATES_clean,Pop_missing_countries_data,
                               by = join_by(Country))

# Using new coalesce() function from DPLYR to find the first non-missing element
# After the merge I want to keep non missing values from population.x, population.y columns
# into a newly created column called population
METRICS_POP_RATES_inc_population <- METRICS_POP_RATES_wrangling %>% 
                     group_by(Country) %>% 
                     mutate(population = coalesce(population.x, population.y)) %>% 
                     select(Country,Lat,Long,date,Confirmed,Recovered,Deaths,year,population)
METRICS_POP_RATES_inc_population

# Check again missing countries
missing_countries_pop <- METRICS_POP_RATES_inc_population %>% 
  arrange(population) %>% 
  filter(is.na(population)) %>% 
  select(Country) %>% 
  distinct(Country)
missing_countries_pop

# It seems only 7 countries still are missing population figures
# Population (2019)
# 1 Cabo Verde     577030 
# 2 French Guiana  285568
# 3 Mayotte        270372
# 4 The Bahamas    404557
# 5 The Gambia     2509000 
# 6 TimorLeste     1280000
# 7 Venezuela      28970000

# Repeat previous process 
Country <-c("Cabo Verde","French Guiana","Mayotte","The Bahamas","The Gambia","TimorLeste","Venezuela")
length(Country) 
# [1] 7
population <-c(577030, 285568,270372,404557,2509000,1280000,28970000)
length(population) 
# [1] 7
# Merge both datasets
# rm(METRICS_POP_RATES)

remaining_missing_pop_figures <-cbind.data.frame(Country,population)
str(remaining_missing_pop_figures)

remaining_missing_pop_figures_data <- remaining_missing_pop_figures %>% 
  select(Country,population) %>% 
  as_tibble()


# 3.4.3 Final merge
METRICS_POP_RATES_cleansed <- left_join(METRICS_POP_RATES_inc_population,remaining_missing_pop_figures_data,
                                         by = join_by(Country))

METRICS_POP_RATES_data <- METRICS_POP_RATES_cleansed %>% 
  group_by(Country) %>% 
  mutate(population = coalesce(population.x, population.y)) %>% 
  select(Country,Lat,Long,date,Confirmed,Recovered,Deaths,year,population)
METRICS_POP_RATES_data

# Check now we have matched all countries with population figures.
# The code below should return: A tibble 0 * 1 Country [0]
missing_countries_pop_final <- METRICS_POP_RATES_data %>% 
  arrange(population) %>% 
  filter(is.na(population)) %>% 
  select(Country) %>% 
  distinct(Country)
missing_countries_pop_final

rm(list=ls()[! ls() %in% c("METRICS_POP_RATES_data","missing_countries_pop_final")])


save.image("~/Documents/Pablo_zorin/Github_Pablo_source_zorin/Shiny-app-using-COVID-data/new_data/METRICS_AND_LEAFLETS_DATA.RData")

# # A tibble: 0 × 1 There is no missing countries, all population figures have been included.

LEAFLET_MAPS_DATA_cleansed <- METRICS_POP_RATES_data


# 3.5 COMPUTE x10,000 POPULATION RATES for each indicator

# From input file: METRICS_POP_RATES_data

# 3.5.0 Before computing rates, ensure I have just one record per day on each country
#       come countries display data by province, I need to aggregate it at country level.
# Input file METRICS_POP_RATES_data
# Output file  DAILY_METRICS_POP_RATES_data

# 3.5.0.1 This will aggregate all Confirmed cases by day. Obtaining just one row per day

# Confirmed cases
METRICS_conf_DAILY <- METRICS_POP_RATES_data %>% 
  select(Country,date,Confirmed,year) %>% 
  group_by(Country,date) %>%
  summarise(Confirmed_d = sum(Confirmed))
METRICS_conf_DAILY

#  Recovered cases 
METRICS_recovered_DAILY <- METRICS_POP_RATES_data %>% 
  select(Country,date,Recovered,year) %>% 
  group_by(Country,date) %>%
  summarise(Recovered_d = sum(Recovered))
METRICS_recovered_DAILY

#  Deaths cases 
METRICS_deaths_DAILY <- METRICS_POP_RATES_data %>% 
  select(Country,date,Deaths,year) %>% 
  group_by(Country,date) %>%
  summarise(Deaths_d = sum(Deaths))
METRICS_deaths_DAILY


# 3.5.0.2 Now that I have all three metrics data (Confirmed, Recovered, Deaths) aggregated at daily level for each country 
# Then I merge them back with POPULATION figures I had initially included on my original METRICS_POP_RATES_data file:





# 3.5.0.3 Then I merge together Unique Metrics by day
METRICS_POP_RATES_data_prep <- left_join(METRICS_conf_DAILY,METRICS_recovered_DAILY,
                               by = join_by(Country,date))

METRICS_POP_RATES_data_prep2 <- left_join(METRICS_POP_RATES_data_prep,METRICS_deaths_DAILY,
                                          by = join_by(Country,date))

# remove extra files
rm(list=ls()[!(ls()%in%c('LEAFLET_MAPS_DATA_cleansed','METRICS_POP_RATES_data_prep2','METRICS_POP_RATES_data'))])

# Now we get 

# I only need to retain the first row of data for each country as this file includes severals rows per country
# Subset just first row per country:

# Created new variable to flag duplicated values "dup_value = duplicated(Country))
METRICS_POP_RATES_population_figures <- METRICS_POP_RATES_data %>% select(Country,population)
METRICS_POP_RATES_population_figures

Countries_population_duplicates <- METRICS_POP_RATES_population_figures %>% 
  group_by(Country) %>% 
  mutate(dup_value = duplicated(Country)) %>% 
  ungroup()
Countries_population_duplicates

# Applying this principle we can keep just first value of each set of countries, flagged by "dup_value" = FALSE
# Keep just records with FALSE
Countries_population_unique <- METRICS_POP_RATES_population_figures %>% 
  group_by(Country) %>% 
  mutate(dup_value = duplicated(Country)) %>% 
  ungroup() %>% 
  filter(dup_value=="FALSE")
Countries_population_unique

# 3.5.0.4 Finally I can merge these rates with population figures
Countries_population_unique_merge <- Countries_population_unique %>% select(Country,population)

METRICS_POP_RATES_data_population <- left_join(METRICS_POP_RATES_data_prep2,
                                               Countries_population_unique_merge,
                                               by = join_by(Country))

# Finally I can compute the rates for each of the countries with just one row per day and country



# 3.5.1 Standard rates for each metric (Confirmed, Recovered, Deaths)
METRICS_POP_RATES <- METRICS_POP_RATES_data_population %>% 
  select(Country,date,Confirmed = Confirmed_d,
                      Recovered = Recovered_d,
                      Deaths = Deaths_d,date, population) %>% 
  mutate(
    CONFR =ceiling(((Confirmed/population)*10000)),
    RECR = ceiling(((Recovered/population)*10000)),
    DEATHR =ceiling(((Deaths/population)*10000))
  )

METRICS_POP_RATES

save.image("~/Documents/Pablo_zorin/Github_Pablo_source_zorin/Shiny-app-using-COVID-data/new_data/METRICS_POP_RATES.RData")

# 3.5.2 # compute rolling average on POPRATESG WITHOUT ANY MISSING VALUE
library(zoo)
names(METRICS_POP_RATES)
#  [1] "Country"    "Lat"        "Long"       "date"       "Confirmed"  "Recovered"  "Deaths"     "year"      
# [9] "population" "CONFR"      "RECR"       "DEATHR"   

# Keep all previous variables, include 7 days rolling average.
# Also computed 7 days moving average on daily Confirmed, Recovered and Deaths cases
METRICS_RATES_DATA_prep <- METRICS_POP_RATES %>%
  select(Country,date,Confirmed,Recovered,Deaths, population,CONFR,RECR,DEATHR) %>% 
  mutate(
    Confirmed_7DMA = rollmean(Confirmed, k = 7, fill = NA),
    Recovered_7DMA = rollmean(Recovered, k = 7, fill = NA),
    Deaths_7DMA = rollmean(Deaths, k = 7, fill = NA)
  )
  
METRICS_RATES_DATA_final <- METRICS_RATES_DATA_prep %>%
  group_by(Country) %>%   
  mutate(CONF_ma07_rates = ceiling(((Confirmed_7DMA/population)*10000)),
         REC_ma07_rates = ceiling(((Recovered_7DMA/population)*10000)),
         DEATH_ma07_rates  = ceiling(((Deaths_7DMA/population)*10000))
  )

METRICS_RATES_DATA_final

# FINAL DATASETS FOR SHINY DASHBOARD

# Keep just these two data frames in our work space at the end of this script 
# LEAFLET_MAPS_DATA : > This file includes LAT and LONG variables to be used just on the LEAFLET map 
# METRICS_RATES_DATA : > This file does not include LAT and LONG variables, but it 
#                   includes POPULATION RATES calculated for Confirmed, Recovered, Deaths metrics. 
#                   Also this file includes a 7 day rolling average to plot Curves in PLOTLY charts.
#                   For comparison across countries, we will use this rate for TABLES. 
LEAFLET_MAPS_DATA <- LEAFLET_MAPS_DATA_cleansed

METRICS_POP_RATES_DATA <-   METRICS_RATES_DATA_final

rm(list=ls()[!(ls()%in%c('LEAFLET_MAPS_DATA','METRICS_POP_RATES_DATA'))])

## I need to address one more issue - When working with Country names variable:
## - Text to be written must be a length-one character vector.

# 4. Perform aggregation on LEAFLET_MAPS_DATA to ensure only one row per day of data is present

# 4.1 Isolate non-aggregated variables
nrow(LEAFLET_MAPS_DATA)
LEAFLET_MAPS_coord <-  LEAFLET_MAPS_DATA %>% 
                       select(Country,Lat,Long) %>% 
                       distinct(Country,Lat,Long)
LEAFLET_MAPS_coord
nrow(LEAFLET_MAPS_coord)

# IMPORTANT, I NEED A UNIQUE TABLE OT Lat Long for each country, with one row of Lat Long for each country !!!
# Issue LEAFLET_MAPS_coord INCLUDES several rows per country !!!

# See example below 
# > LEAFLET_MAPS_coord

# A tibble: 500 × 3
# Groups:   Country [183]
# Country               Lat   Long
#<chr>               <dbl>  <dbl>
#  1 Afghanistan          33    65   
# 2 Albania              41.2  20.2 
# 3 Algeria              28.0   1.66
# 4 Andorra              42.5   1.52
# 5 Angola              -11.2  17.9 
# 6 Antigua and Barbuda  17.1 -61.8 
# 7 Argentina           -38.4 -63.6 
# 8 Armenia              40.1  45.0 
# 9 Australia           -41.5 146.    *
# 10 Australia           -37.8 145.   *

# 4.1.1 FIXING LAT LONG VALUES:
# To fix this issue see script: # \Checks\API_Obtain_countries_Lat_long_values.R
# I use an API from # Using {tidygecoder} package to retrieve specific Lat and Long country values
# From the original unique list of countries in LEAFLET_MAPS_DATA data frame:
LEAFLET_MAPS_country_names  <-  LEAFLET_MAPS_DATA %>% 
                                select(Country) %>% 
                                distinct(Country)
LEAFLET_MAPS_country_names
write.csv(LEAFLET_MAPS_country_names,here("new_data","LEAFLET_country_names.csv"), row.names = TRUE)
write.csv(LEAFLET_MAPS_country_names,here("Checks","LEAFLET_country_names.csv"), row.names = TRUE)

# 4.2 Then I will aggregate cases just by day

# 4.2.1 Confirmed cases 
# Input Data frame: LEAFLET_MAPS_DATA (Confirmed)

# This will aggregate all Confirmed cases by day. Obtaining just one row per day
LEAFLET_MAP_conf_DAILY <- LEAFLET_MAPS_DATA %>% 
  select(Country,Lat,Long,date,Confirmed,year) %>% 
  group_by(Country,date) %>%
  summarise(Confirmed_d = sum(Confirmed))
LEAFLET_MAP_conf_DAILY

nrow(LEAFLET_MAP_conf_DAILY)

# 4.2.1 Recovered cases 
# Input Data frame: LEAFLET_MAPS_DATA (Recovered)
LEAFLET_MAP_recovered_DAILY <- LEAFLET_MAPS_DATA %>% 
  select(Country,Lat,Long,date,Recovered,year) %>% 
  group_by(Country,date) %>%
  summarise(Recovered_d = sum(Recovered))
LEAFLET_MAP_recovered_DAILY

# 4.2.1 Deaths cases 
# Input Data frame: LEAFLET_MAPS_DATA (Deaths)
LEAFLET_MAP_deaths_DAILY <- LEAFLET_MAPS_DATA %>% 
  select(Country,Lat,Long,date,Deaths,year) %>% 
  group_by(Country,date) %>%
  summarise(Deaths_d = sum(Deaths))
LEAFLET_MAP_deaths_DAILY

# Then we merge them 
LEAFLET_MAPS_FINAL_daily_recovered <- left_join(LEAFLET_MAP_conf_DAILY,
                                LEAFLET_MAP_recovered_DAILY,
                                by = join_by(Country,date))

LEAFLET_MAPS_FINAL_daily_recovered_deaths <- left_join(LEAFLET_MAPS_FINAL_daily_recovered,
                                LEAFLET_MAP_deaths_DAILY,
                                by = join_by(Country,date))

LEAFLET_MAPS_DATA <- LEAFLET_MAPS_FINAL_daily_recovered_deaths


# 5. THEN MERGE IT WITH LAT LONG DATA 
LEAFLET_MAPS_DATA

# Load new data created
library(janitor)

ALL_COUNTRIES_LAT_LONG_merge <-read.table(here("new_data", "ALL_COUNTRIES_LAT_LONG.csv"),header =TRUE, sep =',',stringsAsFactors =TRUE) %>% clean_names() 
ALL_COUNTRIES_LAT_LONG_merge

ALL_COUNTRIES_LAT_LONG_to_merve <- ALL_COUNTRIES_LAT_LONG_merge %>% select(Country = address,
                                                                           lat,long)
# LEAFLET_MAPS_DATA with LAT LONG
LEAFLET_DATA_LAT_LONG <-   left_join(LEAFLET_MAPS_DATA,
                                     ALL_COUNTRIES_LAT_LONG_to_merve,
                                     by = join_by(Country))
                                     
LEAFLET_DATA_LAT_LONG

# Using some regex expression to fix it
# gsub() for pattern matching and replacement.
LEAFLET_MAPS_DATA_FINAL <- LEAFLET_DATA_LAT_LONG %>% mutate(Country_map = gsub(" ","",Country))

METRICS_POP_RATES_DATA_FINAL <- METRICS_POP_RATES_DATA %>% mutate(Country_filter = gsub(" ","_",Country))
  
# unique(LEAFLET_MAPS_DATA_FINAL$Country)
# unique(METRICS_POP_RATES_DATA_FINAL$Country)

rm(list=ls()[!(ls()%in%c('LEAFLET_MAPS_DATA_FINAL','METRICS_POP_RATES_DATA_FINAL'))])

# Save final image to \new_data sub-folder
save.image("~/Documents/Pablo_zorin/Github_Pablo_source_zorin/Shiny-app-using-COVID-data/new_data/FINAL_SHINY_DATASETS.RData")

# Save final two datasets as .csv files to \new_data sub-folder
write.csv(LEAFLET_MAPS_DATA_FINAL,here("new_data","LEAFLET_MAPS_DATA.csv"), row.names = TRUE)
write.csv(METRICS_POP_RATES_DATA_FINAL,here("new_data","METRICS_POP_RATES_DATA.csv"), row.names = TRUE)

# Note: In Shiny some filters and drop down menus only work with "legth-one character", meaning I can't use
#       two word countries. Replacing spacpes by hyphons.