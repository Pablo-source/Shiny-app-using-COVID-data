![R](https://img.shields.io/badge/r-%23276DC3.svg?style=for-the-badge&logo=r&logoColor=white)
![GitHub all releases](https://img.shields.io/github/downloads/Pablo-source/Shiny-app-using-COVID-data/total?label=Downloads&style=flat-square)
![GitHub language count](https://img.shields.io/github/languages/count/Pablo-source/Shiny-app-using-COVID-data)

# Shiny-app-using-COVID-data

Basic bootstrap shiny app including leaflet maps, plots and dt tables

This is a basic Shiny app to practice how to create interactive visualizations in R. Using drop down filters to display information by countries and also adding  animations to show progress in time of covid19 cases around the world.

Data is refreshed daily from JHU Github repository and daily 10,000 population rates are calculated in two different R scripts that feed into the Shiny app displayed on the Shiny server. 

The Shiny app is structured into two sections: Maps and plots. Two tabs display grographical information in a leaflet map alllowing user to hover over countries to display tooltips on specific metircs for each country that change daily as the animation updates. 

I am using this app to test new Shiny, CSS and HTML features, I will build the app to include other technologies such as React and node.js. I intend to learn them to enhance the interactivity of this existing app.

## Downloaded data for the app from John Hopkins University 2019 Novel Coronavirus Visual Dashboard

Data for this app is produced by the Johns Hopkins University Center for Systems Science and Engineering (JHU CSSE) for their 2019 Novel Coronavirus Visual Dashboard and Supported by ESRI Living Atlas Team and the Johns Hopkins University Applied Physics Lab (JHU APL).

John Hopkins repository stores daily CODIV-19 data files for each country worldwide

https://github.com/CSSEGISandData/COVID-19 
 
The data folder containes the downloaded compressed .csv files from John Hopkins Github repository 

Specific file to get latest Covid19 figures JHU: 
https://github.com/CSSEGISandData/COVID-19/archive/master.zip

Once the compressed file is dowloaded into the data folder, we obtain three input files for the Shiny app:

- "time_series_covid19_confirmed_global.csv",
- "time_series_covid19_deaths_global.csv",
- "time_series_covid19_recovered_global.csv"

These three files are the COVID indicators used in the Shiny app: new, deaths and recovered cases merged with population data to obtain specific population reates to allow comparisons across countries.

- *Map tab using leaflet and animated maps*
![Shiny Map tab](https://user-images.githubusercontent.com/76554081/192869006-37079f52-5278-4415-a88b-95ae34d29b05.png)

- *Plots tab using Potly interactive library*
![Plot tab PLOTLY interactive plots](https://user-images.githubusercontent.com/76554081/192869436-b413e6e0-a8fd-4310-b5a7-5bd8cf833278.png)

## Shiny app re-design

On **August 2024**, I have started to introduce some changes in the existing Shiny app design. Both in the back end and app design: 

Back end:
-   Define new functions to download data from CSSEGIS github repo: https://github.com/CSSEGISandData/COVID-19
https://github.com/Pablo-source/Shiny-app-using-COVID-data/blob/main/00_Initial_data_download.R
-   From {tidygeocoder} package, use geo() function to conduct specific calls to the API to retrieve Lat and Long values. Using batches of 10 up to 50 countries to test the API response time. It worked fine.
https://github.com/Pablo-source/Shiny-app-using-COVID-data/blob/main/Checks/API_Obtain_countries_Lat_Long.R


Front end:
- Re-designing Shiny app into a single tab combining all previous charts and plots. I will change slightly the existing charts.
- I will incorporate new chart types in this new dashboard version
- Included pop-up tooltips containing daily confirmed, recovered and death cases by country

This is still an ongoing re-design of this shiny app that will be completed in coming weeks

![02_Shiny_App_Including_table_02092024](https://github.com/user-attachments/assets/fd43f963-a1d3-42a3-b8a4-7bf65d05f2d8)




