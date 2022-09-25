![R](https://img.shields.io/badge/r-%23276DC3.svg?style=for-the-badge&logo=r&logoColor=white)
![GitHub all releases](https://img.shields.io/github/downloads/Pablo-source/Shiny-app-using-COVID-data/total?label=Downloads&style=flat-square)
![GitHub language count](https://img.shields.io/github/languages/count/Pablo-source/Shiny-app-using-COVID-data)

# Shiny-app-using-COVID-data

Basic bootstrap shiny app including leaflet maps, plots and dt tables

This is a basic Shiny app to practice how to create interactive visualizations in R. Using drop down filters to display information by countries and also adding  animations to show progress in time of covid19 cases around the world.

Data is refreshed daily from JHU Github repository and daily 10,000 population rates are calculated in two different R scripts that feed into the Shiny app displayed on the Shiny server. 

The Shiny app is structured into two sections: Maps and plots. Two tabs display grographical information in a leaflet map alllowing user to hover over countries to display tooltips on specific metircs for each country that change daily as the animation updates. 

I am using this app to test new Shiny, CSS and HTML features, I will build the app to include other technologies such as React and node.js. I intend to learn them to enhance the interactivity of this existing app.

# Data produced by John Hopkins University 2019 Novel Coronavirus Visual Dashboard

All data for this shiny app comes from the data repository for the 2019 Novel Coronavirus Visual Dashboard operated by the Johns Hopkins University Center for Systems Science and Engineering (JHU CSSE). Also, Supported by ESRI Living Atlas Team and the Johns Hopkins University Applied Physics Lab (JHU APL).

John Hopkins website sotoring daily CODIV-19 data files for each country

https://github.com/CSSEGISandData/COVID-19
 
The data folder containes the downloaded compressed .csv files from John Hopkins Github repository 
- covid19JH.zip

The specific file to get latest Covid19 figures from is this github repo below: 
https://github.com/CSSEGISandData/COVID-19/archive/master.zip

Once the compressed file is dowloaded into the data folder, we obtain three input files for the Shiny app:

- "time_series_covid19_confirmed_global.csv",
- "time_series_covid19_deaths_global.csv",
- "time_series_covid19_recovered_global.csv"

These three files are the COVID indicators: new, deaths and recovered cases that we will merge with population data to obtain specific population reates to compare values across countries.
                                
                                

