
# R Script: 01 MERGE LEAFLET AND POP FIGURES.R
#
# Import external script using: source("UI/ui_population_figures.R",local =TRUE) 
#
# 1 Load population figures
# 2 Include those countries with no data
# 3 Merge population figures with countries with no data (left_join)

getwd()
setwd("C:/Pablo UK/43 R projects 2021/04 My Shiny app/04 Mycovid19 app")

# # Include population figures 
source("UI/ui_get_population_figures.R",local =TRUE) 

getwd()
# PLOT_POP_RATESC.csv

library(readr)
library(dplyr)
library(ggplot2)

# Load now these two data sets
# Data set: PLOT_LEAFLET_CDR_NUM 
# Data set: PLOT_LEAFLET_MAPS

head(PLOT_LEAFLET_CDR_NUM)
head(PLOT_LEAFLET_MAPS)

#POP_POPULATED <- read_csv("08 POP FIGURES BACKUP/PLOT_POP_RATESC.csv")
# CLEAN POPULATION FIGURES 
# POPD
POPD <- POP_POPULATED %>% select( country,year,population) 
# 2 Include those countries with no data
noData<-data.frame(
  country=c("Burma","Czechia","Diamond Princess","Holy See","Laos","MS Zaandam","Taiwan*"),
  population=c(54050000,10650000,3700,825,7169000,2047,23816775)
  
)

str(noData) 
head(noData)
head(POPD)

# mERGE IT WITU POP-ULATION 
# POPE
POPE <- left_join(POPD, noData, by = c("country"="country","population"="population"))
head(POPE)
 
# Get unique country names
# We have got multiple rows per country with the SAME population
# Group by country and get the FIRST ROW
# group_by(Country)
# filter(row_number()==1)
POPEFIXE <- POPE %>% 
  group_by(country) %>% 
  filter(row_number()==1)

# MERGE POP AND RATES
POPF <- PLOT_LEAFLET_CDR_NUM %>% 
            left_join(POPEFIXE,
            by=c("Country"="country"))

# we only keep
# PLOT_LEAFLET_MAPS
# PLOT_POP
rm(POPD,POPE)
save.image("C:/Pablo UK/43 R projects 2021/04 My Shiny app/04 Mycovid19 app/CHECKS/POP_FIGURES_FINAL.RData")

file_pathCHK <-('C://Pablo UK//43 R projects 2021//04 My Shiny app//04 Mycovid19 app//CHECKS')
File_name <-'/PLOT_POP.csv' 
write.csv(POPF,paste0(file_pathCHK,File_name),row.names = T)


File_name <-'/PLOT_LEAFLET_MAPS.csv' 
write.csv(PLOT_LEAFLET_MAPS,paste0(file_pathCHK,File_name),row.names = T)


# Check there are not missing values
# [1] "Country"    "date"       "Confirmed"  "Death"      "Recovered"  "year"       "population"
names(POPF)

TEST_MISSING_CONF  <- POPF  %>% filter(year=="2019" & is.na(Confirmed))
TEST_MISSING_DEATH  <- POPF  %>% filter(year=="2019" & is.na(Death))
TEST_MISSING_RECOV  <- POPF  %>% filter(year=="2019" & is.na(Recovered))

TEST_MISSING_CONF
TEST_MISSING_DEATH
TEST_MISSING_RECOV

rm(TEST_MISSING_CONF,TEST_MISSING_DEATH,TEST_MISSING_RECOV)

# There are not missing values

# FINALLY THE DATASET WE WANT TO MERGE AND USE IS CALLED
POPF_CLEAN <- POPF

file_pathCHK <-('C://Pablo UK//43 R projects 2021//04 My Shiny app//04 Mycovid19 app//CHECKS')
File_name <-'/POPF_CLEAN.csv' 
write.csv(POPF_CLEAN,paste0(file_pathCHK,File_name),row.names = T)

# FINALLY THIS IS THE RIGHT DATASET TO COMPUTE RATES
POPG <- POPF_CLEAN

# Compute rates: (per thousand population)
#  Country     date       Confirmed Death Recovered  year population

### GET INDIVIDUAL FIGURES (NOT CUMULATIVE ones)
# This calculation is important. It gets daily figures instead of cumulative ones. 
names(POPG)
POPG_RATES <- POPG %>% 
                  arrange(Country,date) %>% 
                  mutate(
                          ConD = Confirmed - lag(Confirmed, n=1),
                          RecD = Recovered - lag(Recovered, n=1),
                          DeathD = Death - lag(Death, n=1)
                  )
tail(POPG_RATES)

# Now we compute the rates again
#
# CONFR =ceiling((ifelse(ConfM==0,0,ConfM/population)*10000)),
# DEATHR =ceiling( (ifelse(DeathfM==0,0,DeathfM/population)*10000)),
# RECR = ceiling((ifelse(RecfM==0,0,RecfM/population)*10000)),
#
#
# Now we compute rates with daily figures *not cumulative ones*
POPG_RATESF <- POPG_RATES %>% 
  select(Country, date,year,population,ConD,RecD,DeathD) %>% 
  mutate(
            CONFR =ceiling(((ConD/population)*10000)),
            RECR = ceiling(((RecD/population)*10000)),
            DEATHR =ceiling(((DeathD/population)*10000))
        )

tail(POPG_RATESF)


## NOW IT IS WHEN WE COMPUTE THE 7D AVERAGE FOR EACH COUNTRY
# Using a GROUP_BY
#  group_by(Country) %>% 
# function rollmean

library(zoo)

head(POPG_RATESF)
names(POPG_RATESF)

# Check missing values
# rollmean doesnt' work with NA
CHCK_NA <- is.na(POPG_RATESF)

#"ConD"       "RecD"      
#[7] "DeathD"     "CONFR"      "RECR"      
#[10] "DEATHR"    


names(POPG_RATESF)
TEST_MISS <- POPG_RATESF  %>% 
            filter(
              # OR (|)
              # Variables to check:
              # ConD, RecD, DeathD, CONFR,  RECR,  DEATHR
                is.na(ConD)|
                is.na(RecD)|
                is.na(DeathD)|
                is.na(CONFR)|
                is.na(RECR)|
                is.na(DEATHR)
              )


getwd()

# Replace NA by 0 for specific variables
file_pathCHK <-('C://Pablo UK//43 R projects 2021//04 My Shiny app//04 Mycovid19 app//CHECKS')
File_name <-'/POPG_RATESF.csv' 
write.csv(POPG_RATESF,paste0(file_pathCHK,File_name),row.names = T)

# Check values
head(POPG_RATESG)

# REMOVE MISSING VALUES 
POPRATESG <- POPG_RATESF %>% 
             drop_na()

file_pathCHK <-('C://Pablo UK//43 R projects 2021//04 My Shiny app//04 Mycovid19 app//CHECKS')
File_name <-'/POPRATESG.csv' 
write.csv(POPRATESG,paste0(file_pathCHK,File_name),row.names = T)

# Save worksapce 
save.image("C:/Pablo UK/43 R projects 2020/04 My Shiny app/04 Mycovid19 app/CHECKS/POPRATESG.RData")

# compute rolling average on POPRATESG WITHOUT ANY MISSING VALUE
library(zoo)

RATES7DGAVG <- POPRATESG %>%
                group_by(Country) %>%   
                select(date, Country,population,ConD,RecD,DeathD) %>%
                mutate(CONF_ma07 = rollmean(ConD, k = 7, fill = NA),
                       REC_ma07 = rollmean(RecD,k = 7, fill = NA),
                       DEATH_ma07 = rollmean(DeathD, k = 7, fill = NA))

# Save worksapce 
save.image("C:/Pablo UK/43 R projects 2020/04 My Shiny app/04 Mycovid19 app/CHECKS/RATES7DGAVG.RData")

# final dataset for SHINY APP
file_pathCHK <-('C://Pablo UK//43 R projects 2020//04 My Shiny app//04 Mycovid19 app//CHECKS')
File_name <-'/RATESREADYSHINY.CSV' 
write.csv(RATES7DGAVG,paste0(file_pathCHK,File_name),row.names = T)

# FINAL DATASET THAT GOES INTO SHINY APP
# Name: POP_POPULATED
 
POP_POPULATED <- RATES7DGAVG
head(POP_POPULATED)
names(POP_POPULATED)

POP_POPULATED_RENAME <- RATES7DGAVG %>% 
                        select( date, Country,Population = population, Confirmed = ConD, Recovered = RecD,Death = DeathD,
                                Confirmed_Rate = CONF_ma07,
                                Recovered_Rate = REC_ma07,
                                Death_Rate = DEATH_ma07)

POP_POPULATEDT <- POP_POPULATED_RENAME %>% 
                 mutate(
                          Confirmed_10000 = round(Confirmed_Rate,digits=0),
                          Recovered_10000 = round(Recovered_Rate,digits=0),
                          Deaths_10000 = round(Death_Rate,digits=0)
                      )
head(POP_POPULATEDT)  

POP_POPULATED_prev <- POP_POPULATEDT %>%  select(date,Country,Population,Confirmed,Recovered,Death,Confirmed_10000,Recovered_10000,Deaths_10000)

head(POP_POPULATED_prev)

POP_POPULATED <- POP_POPULATED_prev %>% 
                  select(
                            date,Country,Population,Confirmed,Recovered,Death,
                            Conf_7D_10000 = Confirmed_10000,
                            Rec_7D_10000 = Recovered_10000,
                            Death_7D_10000 = Deaths_10000)
POP_POPULATED

# AND FINALLY SAVE PLOT_LEAFLEFT database as PLOT_LEAFLET.Rdata 
save.image("C:/Pablo UK/43 R projects 2021/04 My Shiny app/04 Mycovid19 app/DATA_FOR_SHINY_APP.Rdata")
save.image("C:/Pablo UK/43 R projects 2021/04 My Shiny app/04 Mycovid19 app/RATES_FOR_SHINY_APP.Rdata")
load("C:/Pablo UK/43 R projects 2021/04 My Shiny app/04 Mycovid19 app/PLOT LEAFLET CDR NUM.RData")
rm(list=ls()[!(ls()%in%c('RATES7DGAVG','POP_POPULATED','PLOT_LEAFLET_CDR_NUM','PLOT_LEAFLET_MAPS'))])

# PLOT_LEAFLET_MAPS
# POP_POPULATED

rm(list=ls()[!(ls()%in%c('POP_POPULATED','PLOT_LEAFLET_MAPS'))]) 

save.image("C:/Pablo UK/43 R projects 2021/04 My Shiny app/04 Mycovid19 app/RATES_FOR_SHINY_APP_FINAL.Rdata")

