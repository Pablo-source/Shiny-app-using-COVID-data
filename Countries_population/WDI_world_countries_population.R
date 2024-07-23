# R Script: WDI_world_countries_population.R

library(tidyverse)
library(here)
if (!require("WDI")) install.packages("WDI")
library(WDI)

# 1. Load  World Bank Total population by country indicator "SP.POP.TOTL" from {WDI} package

WDI_population <- WDI(indicator = c("SP.POP.TOTL"), extra = TRUE)
WDI_population

# 2 using here() function to save data in data folder (using relative paths)
write.csv(WDI_population,here("original_data_processed","WDIinputdata.csv"), row.names = TRUE)
