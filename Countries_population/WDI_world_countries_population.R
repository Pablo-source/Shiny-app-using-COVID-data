# R Script: WDI_world_countries_population.R

library(tidyverse)
library(here)
if (!require("WDI")) install.packages("WDI")
library(WDI)

# 1. Load  World Bank Total population by country indicator "SP.POP.TOTL" from {WDI} package

WDI_population <- WDI(indicator = c("SP.POP.TOTL"), extra = TRUE)
WDI_population

# Save original WDI countries population figures in "original_data_download" folder
write.csv(WDI_population,here("original_data_download","WDIinputdata.csv"), row.names = TRUE)

# 2.Subset variables
# We can include na.strings = c("","NA") to replace empty values by NA
WDIinputdata_raw  <-read.table(here("original_data_download", "WDIinputdata.csv"),
                               header =TRUE, sep =',',stringsAsFactors =TRUE)
names(WDIinputdata_raw)

# 3. Filter values retaining Year 2019 - when pandemic started - to compute rates
# Also remove null values for capital variable
str(WDIinputdata_raw)

WDI_countries_pop_2019_raw <- WDIinputdata_raw %>% 
                          select(country,year,population = SP.POP.TOTL,capital) %>% 
                          filter(year == 2019 &
                                 capital != "")  # (capital ! = " ") Removed all instances when capital variable is emtpy.
WDI_countries_pop_2019_raw           


WDI_countries_pop_2019_raw
write.csv(WDI_countries_pop_2019_raw,here("original_data_processed","WDI_countries_pop_2019.csv"), row.names = TRUE)

# 4. Clean country variable in this WDI_countries_pop_2019 data set 
#    so it matches with my METRICS_FOR_POP_RATES previous file

# Input missing values
WDI_countries_pop_2019 <- WDI_countries_pop_2019_raw
head(WDI_countries_pop_2019)

CNpop<-c("Bahamas, The","Brunei Darussalam","Congo, Dem. Rep.", "Congo, Rep." , "Egypt, Arab Rep.", "Gambia, The","Iran, Islamic Rep.","Korea, Rep.",
         "Kyrgyz Republic", "Micronesia, Fed. Sts." ,"Russian Federation"  , "St. Kitts and Nevis",  "St. Lucia","St. Vincent and the Grenadines" ,
         "Slovak Republic","Syrian Arab Republic","United States", "Venezuela, RB", "Yemen, Rep.")

length(CNpop) 

CNindic<-c("Bahamas","Brunei","Congo (Brazzaville)","Congo (Kinshasa)","Egypt", "Gambia" , "Iran"   , "Korea, South", 
           "Kyrgyzstan"  , "Micronesia", "Russia", "Saint Kitts and Nevis"  ,"Saint Lucia",  "Saint Vincent and the Grenadines",
           "Slovakia","Syria","US", "Venezuela" ,"Yemen" )
length(CNindic)

# Then we replace non-standard country names by standardized country names values 
str(WDI_countries_pop_2019)
WDI_countries_pop_2019[which(WDI_countries_pop_2019$country %in% CNpop ), "country"] <- CNindic

WDI_countries_pop_2019_no_NA  <- WDI_countries_pop_2019 %>% 
                                  filter(!is.na(country))
  
# 5. Save this data set with 2019 countries population figures to be merged with METRICS_FOR_POP_RATES file
# We will compute RATES for each of the metrics in METRICS_FOR_POP_RATES file using this cleansed country population figures
# in the original_data_processed folder
WDI_countries_pop_2019_clean <- WDI_countries_pop_2019_no_NA
WDI_countries_pop_2019_clean

# write data set as csv into original_data_processed folder
write.csv(WDI_countries_pop_2019_clean,here("original_data_processed","WDI_countries_pop_2019_clean.csv"), row.names = TRUE)
