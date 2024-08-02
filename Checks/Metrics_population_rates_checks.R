# Metric_population_rates_checks.R

# Subset AUSTRALIA data just for one day:
# 2020-03-19
METRICS_DAILY_aus_19 <- METRICS %>% 
                        select(Country_name, Lat,Long,date,Confirmed,Recovered,Deaths) %>% 
                        filter(Country_name == 'Australia' &
                                 date == '2020-03-19') %>% 
                        arrange(date)
METRICS_DAILY_aus_19

nrow(METRICS_DAILY_aus_19)
write.csv(METRICS_DAILY_aus_19,here("Checks","METRICS_DAILY_aus_19.csv"), row.names = TRUE)


# Get distinct days
METRICS_DAILY_aus_19_date <- METRICS_DAILY_aus_19 %>% select(date) %>% distinct()
METRICS_DAILY_aus_19_date
nrow(METRICS_DAILY_aus_19_date)
# [1] 1

# Aggregating metrics by Country_name and date 
# Summarising a variable by group
# https://stackoverflow.com/questions/1660124/how-to-sum-a-variable-by-group
METRICSD_aus_summarised <- METRICS_DAILY_aus_19 %>% 
            select(Country_name,date,Confirmed,Recovered,Deaths) %>% 
  group_by(Country_name,date) %>%
  summarise(
    Confirmed_d = sum(Confirmed),
    Recovered_d = sum(Recovered),
    Deaths_d = sum(Deaths)
  )
METRICSD_aus_summarised
4+307+1+144+42+10+121+52
write.csv(METRICSD_aus_summarised,here("Checks","METRICSD_aus_summarised.csv"), row.names = TRUE)
