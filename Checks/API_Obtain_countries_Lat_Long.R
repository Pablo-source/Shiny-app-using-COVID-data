
# 26/08/2024
# \Checks\API_Obtain_countries_Lat_long_values.R
# Using {tidygecoder} package

# Using geo() function from {tidygeocoder} package to obtain countries unique Lat and Long values

# https://jessecambon.github.io/tidygeocoder/articles/tidygeocoder.html#introduction
# Tidygeocoder provides a unified interface for performing both forward and reverse geocoding queries with 
# a variety of geocoding services. In forward geocoding you provide an address to the geocoding service and you get latitude and longitude coordinates in return. In reverse geocoding you provide the latitude and longitude and the geocoding service will return that location’s address. In both cases, other data about the location can be provided by the geocoding service.
# The geocode() and geo() functions are for forward geocoding 

# 1. Install and load required libraries
# This is a package to obtain Lat Long values for each individual country. Based on their centroids. 
# install.packages('tidygeocoder')

library(tidyverse)
library(tidygeocoder)

# 1. Example on how to use geo() function to obtain Lat and Long values Using geo_limit
geo_limit_countries <- geo(
  c("Peru", "Egypt"),
  method = "osm",
  limit = 3, full_results = TRUE
)

# 1.1 Then we filter data by "addresstype=country"
geocoding_lat_long <- geo_limit_countries %>% 
                      select(address,lat,long,addresstype) %>% 
                      filter(addresstype == "country")
geocoding_lat_long

# This works fine
> geocoding_lat_long
# A tibble: 2 × 4
address   lat  long addresstype
<chr>   <dbl> <dbl> <chr>      
  1 Peru    -6.87 -75.0 country    
2 Egypt   26.3   29.3 country 

Countries_lat_Long <- geocoding_lat_long %>% select(address, lat, long, addresstype)
Countries_lat_Long
names(Countries_lat_Long)
# [1] "address"     "lat"         "long"        "addresstype"

# Write .csv output countires Lat and Long values to "\new_data" sub-folder
write.csv(Countries_lat_Long,here("Checks","Countries_lat_Long_values_01_10.csv"), row.names = TRUE)
# address   lat  long addresstype

# 2. Using list of Countries from LEAFLET_MAPS file, saved in folder below
# write.csv(LEAFLET_MAPS_country_names,here("new_data","LEAFLET_country_names.csv"), row.names = TRUE)

# 2.1 Retrieve lat and long values for each country from "LEAFLET_MAPS_country_names" data frame

Countries_list <- LEAFLET_MAPS_country_names %>%  ungroup()
str(Countries_list)
names()

# 2.1.1 First 10 countries

# Afghanistan, Albania,Algeria,Andorra,Angola,Antigua and Barbuda,Argentina,Armenia,Australia,Austria
# Select country, press SHIFT+2 to enclose each of them in ""
ome_ten <-c("Afghanistan", "Albania","Algeria","Andorra","Angola","Antigua and Barbuda","Argentina","Armenia","Australia","Austria")
length(ome_ten)
# [1] 10

lat_long_01_10 <- geo(
  ome_ten,
  method = "osm",
  limit = 3, full_results = TRUE
)

# address               lat   long addresstype
# <chr>               <dbl>  <dbl> <chr>      
#  1 Afghanistan          33.8  66.2  country    
# 2 Algeria              28.0   3.00 country 

geocoding_lat_long_01_10 <- lat_long_01_10 %>%  
  select(address,lat,long,addresstype) %>% 
  filter(addresstype == "country")
geocoding_lat_long_01_10

# address   lat  long address type
# Missing countries from above list (Albania,Armenia)
# Retrieve Lat and Long values for those missing countries from Google maps
# Albania: 40.99713364108268, 20.179232997817287
# Armenia: 40.27901150808908, 44.66847731303665

address <- c("Albania","Armenia")
lat <- c(40.99713364108268,40.27901150808908)
long <-c(20.179232997817287,44.66847731303665) 
addresstype <- c(replicate(2,"country"))

miss_count_Albania_Armenia_1_10 <- cbind.data.frame(address,lat,long,addresstype)
miss_count_Albania_Armenia_1_10

# 2.1.1.1 FINAL 10 countries from LEAFLET_MAPS file 
geocoding_lat_long_01_10_all <- bind_rows(geocoding_lat_long_01_10, miss_count_Albania_Armenia_1_10)
write.csv(geocoding_lat_long_01_10_all,here("new_data","Countries_lat_Long_values_01_10.csv"), row.names = TRUE)

# 2.1.2 Next 10 countries
# 11-20
eleven_twenty <-c("Azerbaijan","Bahamas The","Bahrain","Bangladesh","Barbados","Belarus","Belgium","Benin","Bhutan","Bolivia")
lat_long_11_20 <- geo(eleven_twenty,  method = "osm",  limit = 3, full_results = TRUE)
lat_long_11_20
geocoding_lat_long_11_20 <- lat_long_11_20 %>% select(address,lat,long,addresstype) %>% filter(addresstype == "country")
geocoding_lat_long_11_20

# Missing countries from above list (Bahamas The)
# Retrieve Lat and Long values for those missing countries from Google maps
# The Bahamas: 24.830939160155005, -78.03582742002267
# 24.830939160155005, -78.03582742002267
address <- c("Bahamas The")
lat <- c(24.830939160155005)
long <- c(-78.03582742002267)
addresstype <- c(replicate(1,"country"))

miss_count_11_20 <- cbind.data.frame(address,lat,long,addresstype)
miss_count_11_20
geocoding_lat_long_11_20_all <- bind_rows(geocoding_lat_long_11_20, miss_count_11_20)
geocoding_lat_long_11_20_all
write.csv(geocoding_lat_long_11_20_all,here("new_data","Countries_lat_Long_values_11_20.csv"), row.names = TRUE)

# 2.1.3 Next 11 countries
# 21-31
tw_one_thirty_one <-c("Bosnia and Herzegovina","Brazil","Brunei","Bulgaria","Burkina Faso","Cabo Verde","Cambodia","Cameroon","Canada","Cape Verde","Central African Republic")
lat_long_21_31 <- geo(tw_one_thirty_one,  method = "osm",  limit = 3, full_results = TRUE)
lat_long_21_31
geocoding_lat_long_21_31 <- lat_long_21_31 %>% select(address,lat,long,addresstype) %>% filter(addresstype == "country")
geocoding_lat_long_21_31
# No missing countries this time
geocoding_lat_long_21_31_all <- bind_rows(geocoding_lat_long_21_31)
geocoding_lat_long_21_31_all
write.csv(geocoding_lat_long_21_31_all,here("new_data","Countries_lat_Long_values_21_31.csv"), row.names = TRUE)

# 2.1.4 Next 11 countries
# 32-41
thirty_one_fourty_one <-c("Chad","Chile","China","Colombia","Congo Brazzaville","Congo Kinshasa","Costa Rica","Cote dIvoire","Croatia","Cruise Ship")
lat_long_32_41 <- geo(thirty_one_fourty_one,  method = "osm",  limit = 3, full_results = TRUE)
lat_long_32_41
geocoding_lat_long_32_41 <- lat_long_32_41 %>% select(address,lat,long,addresstype) %>% filter(addresstype == "country" |
                                                                                                  addresstype == "road"  |
                                                                                                  addresstype == "tourism")
# Select top 8 rows                                                                                                                                                                                                 addresstype == "tourism")
geocoding_lat_long_32_41_subset_top <- head(geocoding_lat_long_32_41,8)
geocoding_lat_long_32_41_subset_top
# Select bottom 10,11 rows (We want to ommit row 9)
geocoding_lat_long_32_41_subset_bottom <- geocoding_lat_long_32_41 %>% 
                                            slice(10:11)
geocoding_lat_long_32_41_subset <- bind_rows(geocoding_lat_long_32_41_subset_top,geocoding_lat_long_32_41_subset_bottom)
geocoding_lat_long_32_41_subset

write.csv(geocoding_lat_long_32_41_subset,here("new_data","Countries_lat_Long_values_32_41.csv"), row.names = TRUE)

# 2.1.5 Next 31 countries
# 42-72 - SHIFT + 2 > Enclose word in double quotes
forty_one_seventy_two <-c("Cuba","Cyprus","Czechia","Denmark","Djibouti","Dominica","Dominican Republic","East Timor","Ecuador",
                          "Egypt","El Salvador","Equatorial Guinea","Eritrea","Estonia","Eswatini","Ethiopia","Fiji","Finland",
                          "France","French Guiana","Gabon","Gambia The","Georgia","Germany","Ghana","Greece","Greenland","Grenada",
                          "Guadeloupe","Guam","Guatemala")
length(forty_one_seventy_two)
# 31
lat_long_42_72 <- geo(forty_one_seventy_two,  method = "osm",  limit = 3, full_results = TRUE)
geocoding_lat_long_42_71 <- lat_long_42_72 %>% select(address,lat,long,addresstype) %>% filter(addresstype == "country")
geocoding_lat_long_42_71_all <- geocoding_lat_long_42_71
write.csv(geocoding_lat_long_42_71,here("new_data","Countries_lat_Long_values_42_72.csv"), row.names = TRUE)

# 2.1.6 Next 31 countries
# 73-104 - SHIFT + 2 > Enclose word in double quotes
seventy_three_hundred_four <-c("Guernsey","Guinea","Guyana","Haiti","Holy See","Honduras","Hungary","Iceland","India","Indonesia","Iran","Iraq","Ireland","Israel","Italy",
                               "Jamaica","Japan","Jersey","Jordan","Kazakhstan","Kenya","Korea South","Kosovo","Kuwait","Kyrgyzstan","Latvia","Lebanon","Liberia",
                               "Liechtenstein","Lithuania","Luxembourg","Madagascar")
length(seventy_three_hundred_four)
# [1] 32
lat_long_73_104 <- geo(seventy_three_hundred_four,  method = "osm",  limit = 3, full_results = TRUE)
geocoding_lat_long_73_104 <- lat_long_73_104 %>% select(address,lat,long,addresstype) %>% filter(addresstype == "country")
geocoding_lat_long_73_104_all <- geocoding_lat_long_73_104
write.csv(geocoding_lat_long_73_104_all,here("new_data","Countries_lat_Long_values_73_104.csv"), row.names = TRUE)
length(geocoding_lat_long_73_104_all)

# 2.1.7 Next 31 countries
# 105-136 - SHIFT + 2 > Enclose word in double quotes
hundred_five_hundred_thirty_six <-c("Malaysia","Maldives","Malta","Martinique","Mauritania","Mauritius","Mayotte","Mexico","Moldova","Monaco","Mongolia",
                                    "Montenegro","Morocco","Mozambique","Namibia","Nepal","Netherlands","New Zealand","Nicaragua","Niger","Nigeria",
                                    "North Macedonia","Norway","Oman","Pakistan","Panama","Papua New Guinea","Paraguay","Peru","Philippines","Poland","Portugal")
length(hundred_five_hundred_thirty_six)
lat_long_105_136 <- geo(hundred_five_hundred_thirty_six,  method = "osm",  limit = 3, full_results = TRUE)
geocoding_lat_long_105_136 <- lat_long_105_136 %>% select(address,lat,long,addresstype) %>% filter(addresstype == "country")
geocoding_lat_long_105_136_all <- geocoding_lat_long_105_136
write.csv(geocoding_lat_long_105_136_all,here("new_data","Countries_lat_Long_values_105_136.csv"), row.names = TRUE)
length(geocoding_lat_long_105_136_all)


# 2.1.8 Final_set_of_countries
# 137-183 - SHIFT + 2 > Enclose word in double quotes
hundred_thirty_seven_final <-c("Puerto Rico","Qatar","Republic of the Congo","Reunion","Romania","Russia","Rwanda","Saint Lucia","Saint Vincent and the Grenadines",
"San Marino","Saudi Arabia","Senegal","Serbia","Seychelles","Singapore","Slovakia","Slovenia","Somalia","South Africa","Spain","Sri Lanka","Sudan","Suriname","Sweden","Switzerland",
"Syria","Taiwan","Tanzania","Thailand","The Bahamas","The Gambia","TimorLeste","Togo","Trinidad and Tobago","Tunisia","Turkey","US","Uganda","Ukraine","United Arab Emirates","United Kingdom",
"Uruguay","Uzbekistan","Venezuela","Vietnam","Zambia","Zimbabwe")

length(hundred_thirty_seven_final)
lat_long_137_183 <- geo(hundred_thirty_seven_final,  method = "osm",  limit = 3, full_results = TRUE)
geocoding_lat_long_137_183 <- lat_long_137_183 %>% select(address,lat,long,addresstype) %>% filter(addresstype == "country")
geocoding_lat_long_137_183_all <- geocoding_lat_long_137_183
write.csv(geocoding_lat_long_137_183_all,here("new_data","Countries_lat_Long_values_137_183_ALL.csv"), row.names = TRUE)
length(geocoding_lat_long_137_183_all)

## FINAL FILE WITH LAT LONG FOR ALL COUNTRIES FROM LEAFLETS_MAPS file
LOAD_geocoding_lat_long_01_10 <-read.table(here("new_data", "Countries_lat_Long_values_01_10.csv"),header =TRUE, sep =',',stringsAsFactors =TRUE) %>% clean_names() 
LOAD_geocoding_lat_long_11_20 <-read.table(here("new_data", "Countries_lat_Long_values_11_20.csv"),header =TRUE, sep =',',stringsAsFactors =TRUE) %>% clean_names() 
LOAD_geocoding_lat_long_21_31 <-read.table(here("new_data", "Countries_lat_Long_values_21_31.csv"),header =TRUE, sep =',',stringsAsFactors =TRUE) %>% clean_names() 
LOAD_geocoding_lat_long_32_41 <-read.table(here("new_data", "Countries_lat_Long_values_32_41.csv"),header =TRUE, sep =',',stringsAsFactors =TRUE) %>% clean_names() 
LOAD_geocoding_lat_long_42_72 <-read.table(here("new_data", "Countries_lat_Long_values_42_72.csv"),header =TRUE, sep =',',stringsAsFactors =TRUE) %>% clean_names() 
LOAD_geocoding_lat_long_73_104 <-read.table(here("new_data", "Countries_lat_Long_values_73_104.csv"),header =TRUE, sep =',',stringsAsFactors =TRUE) %>% clean_names()
LOAD_geocoding_lat_long_105_136 <-read.table(here("new_data", "Countries_lat_Long_values_105_136.csv"),header =TRUE, sep =',',stringsAsFactors =TRUE) %>% clean_names()
LOAD_geocoding_lat_long_137_183_ALL <-read.table(here("new_data", "Countries_lat_Long_values_137_183_ALL.csv"),header =TRUE, sep =',',stringsAsFactors =TRUE) %>% clean_names()


# FINAL DATASET INCLUDING ALL COUNTRIES LAT LONG VALUES 
# bind_rows(): this is the verb to append ANY datasets. 
COUNTRIES_LAT_LONG_FINAL <- LOAD_geocoding_lat_long_01_10 %>% 
                                          bind_rows(LOAD_geocoding_lat_long_11_20) %>% 
                                          bind_rows(LOAD_geocoding_lat_long_21_31) %>% 
                                          bind_rows(LOAD_geocoding_lat_long_32_41) %>% 
                                          bind_rows(LOAD_geocoding_lat_long_42_72) %>%
                                          bind_rows(LOAD_geocoding_lat_long_105_136) %>%
                                          bind_rows(LOAD_geocoding_lat_long_137_183_ALL)
COUNTRIES_LAT_LONG_FINAL

ALL_COUNTRIES_LAT_LONG <- COUNTRIES_LAT_LONG_FINAL

write.csv(ALL_COUNTRIES_LAT_LONG,here("new_data","ALL_COUNTRIES_LAT_LONG.csv"), row.names = TRUE)

# Load new data created
ALL_COUNTRIES_LAT_LONG_merge <-read.table(here("new_data", "ALL_COUNTRIES_LAT_LONG.csv"),header =TRUE, sep =',',stringsAsFactors =TRUE) %>% clean_names() 
ALL_COUNTRIES_LAT_LONG_merge

ALL_COUNTRIES_LAT_LONG_to_merve <- ALL_COUNTRIES_LAT_LONG_merge %>% select(Country = address,
                                                                           lat,long)



# CHECKS 
# Checking the files I have created using this method in \new_data file
library(janitor)
CHECK_geocoding_lat_long_01_10_all <-read.table(here("new_data", "Countries_lat_Long_values_01_10.csv"),header =TRUE, sep =',',stringsAsFactors =TRUE) %>% clean_names() 
CHECK_geocoding_lat_long_11_20_all <-read.table(here("new_data", "Countries_lat_Long_values_11_20.csv"),header =TRUE, sep =',',stringsAsFactors =TRUE) %>% clean_names() 
