# Group_by_ungroup_sunmmary_example.R

# 1. Subset data for AUSTRALIA:

METRICS_AUS <-METRICS %>% 
              select(Country, Lat,Long,date,Confirmed,Recovered,Deaths) %>% 
              filter(Country == 'Australia') %>% 
              arrange(date)
METRICS_AUS

# 2. There are several records per day I need to group data by day to obtain one row per day
METRICSD_aus_daily_initial <- METRICS_AUS %>% 
  select(Country, Lat,Long,date,Confirmed,Recovered,Deaths)%>% 
  group_by(Country, Lat,Long,date) %>%
  summarise(
    Confirmed_d = sum(Confirmed),
    Recovered_d = sum(Recovered),
    Deaths_d = sum(Deaths)) 
METRICSD_aus_daily_initial

str(METRICSD_aus_daily_initial)

# 3. Repeating the same calculation but including always ungroup() at the end: 
# This is the CORRECT way !! , we don't see now this "gropd_df [558 × 7] (S3: grouped_df/tbl_df/tbl/data.frame)"
# when running str()
METRICSD_aus_daily_ungroup <- METRICS_AUS %>% 
                     select(Country, Lat,Long,date,Confirmed,Recovered,Deaths)%>% 
                      group_by(Country, Lat,Long,date) %>%
                      summarise(
                        Confirmed_d = sum(Confirmed),
                        Recovered_d = sum(Recovered),
                        Deaths_d = sum(Deaths)) %>% 
                      ungroup()
METRICSD_aus_daily_ungroup
str(METRICSD_aus_daily_ungroup)

