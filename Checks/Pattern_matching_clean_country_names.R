# Pattern_matching_clean_country_names.R

##  1 Country names Text to be written must be a length-one character vector.

# Use pattern matching and replacement function (grep)
# 1. Remove punctuation in variable content 
LEAFLET_MAPS_DATA_FINAL <- LEAFLET_MAPS_DATA %>% mutate(Country = gsub("[[:punct:]]", "",Country))
# 2. Replace emtpy spaces replacing them by “_”  symbol in variable content
LEAFLET_MAPS_DATA_FINAL <- LEAFLET_MAPS_DATA %>% mutate(Country = gsub(" ","_",Country))
# 1. Remove apostrophes in variable content
LEAFLET_MAPS_DATA_FINAL <- LEAFLET_MAPS_DATA %>% mutate(Country = gsub("'","",Country))