![R](https://img.shields.io/badge/r-%23276DC3.svg?style=for-the-badge&logo=r&logoColor=white)
![GitHub all releases](https://img.shields.io/github/downloads/Pablo-source/Shiny-app-using-COVID-data/total?label=Downloads&style=flat-square)
![GitHub language count](https://img.shields.io/github/languages/count/Pablo-source/Shiny-app-using-COVID-data)

# Shiny-app-using-COVID-data

This is a Shiny app displaying COVID cases over time. Users can explore COVID19  confirmed, recovered and death cases, interacting with maps and charts to visualize these indicators by countries.

Following RAP principles, applied **renv::init()** to initialise environment and also taken a snapshot of the project with **renv::snapshot()**, once the Shiny app has ran. The entire environment can be replicated just by running **renv::restore()** after opening the R project file. 

Features:  

- Created a couple of adhoc functions to download original .csv files from (JHU CSSE) repository, they include an automated triger to downlod the data every half an hour. This shows how to get online data for Shiny applications runing 24/7. 

- In  *API_Obtain_countries_Lat_Long.R* script, there is an example on how to use {tidygeocoder] to perform geocoding queries to obtain latitute and longitude coordinates with geo() function. The api_parameter_reference maps the API parameters for each geocoding service common set of “generic” parameters.
  
## How to run this Shiny app on your machine

To run this **Shiny-app-using-COVID-data** follow these **three** steps below:

1-3. Clone **Shiny-app-using-COVID-data** repo using git on you IDE or your terminal using local Clone HTTPS option
<https://github.com/Pablo-source/Shiny-app-using-COVID-data.git>

> **git clone https://github.com/Pablo-source/Shiny-app-using-COVID-data.git**

Navigate to the cloned repo, then open Rproject by clicking on the **Shiny-app-using-COVID-data.Rproj** file. This will display the Shiny app files on your "Files" tab in RStudio.

2-3. Run **renv::restore()** in a new Rscript. The first time the app finshed running, I captured its final state using **renv::snapshot()**
To ensure all required packages are loaded, we reinstall exact packages declared in the project lockfile renv.lock.
Then we run **renv::restore()** to ensure we have all required packages loaded and ready in our R environment.

> **renv::restore()**

In the next step when using **app_launch_TRIGGER.R** script, we will have all required packages for the app loaded by the **renv::restore()** command.

3-3. Open “**app_launch_TRIGGER.R** script”
- Then  press **"Source"** button in RStudio to trigger the Shiny app.

## Data downloaded from Johns Hopkins University Center for Systems Science and Engineering (JHU CSSE) repository

Data for this app is produced by the Johns Hopkins University Center for Systems Science and Engineering (JHU CSSE) for their 2019 Novel Coronavirus Visual Dashboard and Supported by ESRI Living Atlas Team and the Johns Hopkins University Applied Physics Lab (JHU APL).

John Hopkins repository stores daily CODIV-19 data files for each country worldwide

https://github.com/CSSEGISandData/COVID-19 

Original data to populate this Shiny dashboard can be found in the CSSEGISandData main GitHub website. <https://github.com/CSSEGISandData>

The set of three specific files used on this Shiny Dashboard, can be found found under the  “archived_time_series” folder: <https://github.com/CSSEGISandData/COVID-19/tree/master/archived_data/archived_time_series>

I have read the data directly into R with an ad hoc function DownloadCOVIDData() using download.file() function with specific URL address for each of the three individual files, this function used the **Raw** path provided on the GitHub repo location of each of the invidual input files: 

These are the three input files read into R directly from the “archived_time_series” folder of the CSSEGISandData/COVID-19 repository:  

- [1] "time_series_19-covid-Confirmed_archived_0325.csv"
- [2] "time_series_19-covid-Deaths_archived_0325.csv"   
- [3] "time_series_19-covid-Recovered_archived_0325.csv"

This is an example of the path for COVID-19 Cofirmed cases  file: 

1-2. First I located the specific file in the \archived_fime_series folder:
https://github.com/CSSEGISandData/COVID-19/blob/master/archived_data/archived_time_series/time_series_19-covid-Confirmed_archived_0325.csv

2-2. Then I obtained the final URL using the “Raw” button. This allows the the download.file() function to download the file directly from the original URL location to my local machine
"https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/archived_data/archived_time_series/time_series_19-covid-Confirmed_archived_0325.csv",


## Shiny app re-design

In **August 2024**, I introduced several re-design changes to the app. Imrpvpving its design and applying RAP principles to the project: 

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
- I have used tabsetPanel() function  to support tabbed frames,Then each tab is populated by tabPanel() function.
![image](https://github.com/user-attachments/assets/469c02b4-5255-4c47-ad3f-b9758d409ae7)

![image](https://github.com/user-attachments/assets/23d79175-e9d3-448e-9057-fae19f8102f8)


- Added new section at the end of the dashboard containing **interactive plotly line charts** by selected country from drop down menu

![10_Plotly_interactive_charts_Germany](https://github.com/user-attachments/assets/6304c90c-8696-4688-a1f0-a700cc692c0c)

 



