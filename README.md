![R](https://img.shields.io/badge/r-%23276DC3.svg?style=for-the-badge&logo=r&logoColor=white)
![GitHub all releases](https://img.shields.io/github/downloads/Pablo-source/Shiny-app-using-COVID-data/total?label=Downloads&style=flat-square)
![GitHub language count](https://img.shields.io/github/languages/count/Pablo-source/Shiny-app-using-COVID-data)

# Shiny-app-using-COVID-data

Basic bootstrap shiny app including leaflet maps, plots and dt tables

This is a basic Shiny app to practice how to create interactive visualizations in R. Using drop down filters to display information by countries and also adding  animations to show progress in time of covid19 cases around the world.

## Downloaded data for the app from John Hopkins University 2019 Novel Coronavirus Visual Dashboard

Data for this app is produced by the Johns Hopkins University Center for Systems Science and Engineering (JHU CSSE) for their 2019 Novel Coronavirus Visual Dashboard and Supported by ESRI Living Atlas Team and the Johns Hopkins University Applied Physics Lab (JHU APL).

John Hopkins repository stores daily CODIV-19 data files for each country worldwide

https://github.com/CSSEGISandData/COVID-19 
 


## Shiny app re-design

On **August 2024**, I have started to introduce re-design changes to the app. Imrpvpving its design and applying RAP principles to project: 

Back end:
-   Built new functions to download CSSEGIS data from original repo: https://github.com/CSSEGISandData/COVID-19
https://github.com/Pablo-source/Shiny-app-using-COVID-data/blob/main/00_Initial_data_download.R
-   From {tidygeocoder} package, used geo() function to conduct specific calls to the API to retrieve Lat and Long values. Using batches of 10 up to 50 countries to test the API response time. It worked fine.
https://github.com/Pablo-source/Shiny-app-using-COVID-data/blob/main/Checks/API_Obtain_countries_Lat_Long.R
-	Following RAP principles, applied **renv::init()** to initialise environment and also taken a snapshot of the project using **renv::snapshot()**. By creating the lockfile, we ensure all packages required for this project are available. These actions create a  project library directory, ensuring we have loaded the right packages and the right versions. 
https://github.com/Pablo-source/Shiny-app-using-COVID-data/blob/main/Setting%20renv%20for%20this%20project.R

Front end:
- Re-designing Shiny app into a single tab combining all previous charts and plots. I will change slightly the existing charts arrangement in the dashboard.
- I will incorporate new chart types in this new dashboard version
- Included pop-up tooltips containing daily confirmed, recovered and death cases by country

This is still an ongoing re-design of this shiny app that will be completed in coming weeks

![04_Shiny_App_Including_table_03092024_FMTD](https://github.com/user-attachments/assets/051632fe-8f24-4e41-b035-48a804c3ac94)

Added legend to Leaflet map

![06_Leaflet_map_number_of_deaths_legend](https://github.com/user-attachments/assets/16734f33-d54f-44bd-9de0-9cfee53d8ed8)

- Included new dynamic **plotly** bar chart displaying total cases, based on time slider animation date values

![05_Dynamic_table_bar_chart_plots](https://github.com/user-attachments/assets/700f4235-44aa-4123-9ced-cc0c5288f404)

- Added new section at the end of the dashboard including **interactive plotly line charts** by selected country from drop down menu

![10_Plotly_interactive_charts_Germany](https://github.com/user-attachments/assets/6304c90c-8696-4688-a1f0-a700cc692c0c)

 



