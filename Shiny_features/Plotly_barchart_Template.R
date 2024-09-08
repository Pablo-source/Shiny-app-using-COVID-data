# File: Plotly_barchart_template.R

# Description: Build a bar chart using ggplot2, format it and turn into an interactive plotly chart using 
#             ggplotly() function on the fully formatted ggplot2 object built previously. 

# Input dataset: metric_rates
library(tidyverse)
library(plotly)

# 1. Create variable to flag max date

conf_top_cases <- metric_rates  %>%
  select(country,date,confirmed) %>% 
  mutate(Max_date = max(metric_rates$date)) %>% 
  mutate(Flag_max_date = ifelse(Max_date == date,1,0)) %>% 
  filter(Flag_max_date==1) %>% 
  arrange(desc('conf_x10,000pop_rate')) %>% 
  group_by(date) %>% 
  slice(1:10) %>% 
  ungroup()

# 1 Standard bar chart

# 2. Build standard ggplot bar chart with labels on top
COUNTRIES_chart <- ggplot(conf_top_cases,aes(x=country, y = confirmed, fill = date)) +
  geom_bar(position = 'dodge', stat = 'identity') +
  geom_text(aes(label = confirmed), position = position_dodge(width = 0.9),
            vjust = -0.30) +  # Set vjust to -0.30 to display just a small gap between chart and figure 
  ggtitle("Adding mark label to ggplot") 
COUNTRIES_chart  


# 2 Sorter bar chart

# 3. Re-order chart
# This is how you use this reorder() function: 
#  aes(x = reorder(Countries, -Population), y = Population)
COUNTRIES_sorted <- ggplot(conf_top_cases,
                           aes(x = reorder(country, -confirmed), y = confirmed), fill = date) +
  geom_bar(position = 'dodge', stat = 'identity') +
  geom_text(aes(label = confirmed), position = position_dodge(width = 0.9),
            vjust = -0.30) +  # Set vjust to -0.30 to display just a small gap between chart and figure 
  ggtitle("Adding mark label to geom_bar() and display results sort descending order") 
COUNTRIES_sorted

# 3 Flipped bar chart 

# 3.1 then flip it
# Country with top cases at the top [reorder(country,+confirmed)]
COUNTRIES_flipped <- ggplot(conf_top_cases,
                           aes(x = reorder(country, +confirmed), y = confirmed)) +
  geom_bar(position = 'dodge', stat = 'identity',fill = "deepskyblue3") +
  geom_text(aes(label = confirmed), position = position_dodge(width = 0.9),
            vjust = -0.30, hjust = + 1.20) +  # Set vjust to -0.30 to display just a small gap between chart and figure 
  ggtitle("Adding mark label to geom_bar() and display results sort descending order") +
  coord_flip()
COUNTRIES_flipped

# 4 Turn it into plotly
# 3. Use ggplotly function to convert ggplot2 graph into plotly 
ggplotly(COUNTRIES_flipped)