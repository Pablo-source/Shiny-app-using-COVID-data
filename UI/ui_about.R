# ui_about.R
# THIS IS THE FINAL ABOUT TAB CONTENT PLACED INTO A SINGLE FILE  

fluidPage ( 
  title = div("ABOUT",style ="padding-right:10px",class="h3"),
    fluidRow( 
      box(
                     column(6,
                               h3("This dashboard describes latest daily data on Covid-19 new, recovered cases and deaths 
                               COVID-19 deaths are defined as patients died of covid as primary diagnosis, COVID-19 recovered 
                               patients are defined as patients recovered from it although they might present health complications
                               from the disease. And COVID-19 New cases are patients diaganosed with COVID-19")
                              ),    
                     column(6,
                              h3("Data is updated daily from John Hopkings Github repository. 
                              Novel Coronavirus (COVID-19) Cases, provided by JHU CSSE|
                              https://github.com/CSSEGISandData/COVID-19/archive/master.zip")
                              ),
                            width=15
                            )
    ),
    fluidRow(   
     box(
                    column(6,
                             h3("Four tabs describe COVID19 daily metrics using interactive maps, 
                                tables and plots to explore the daily number of cases. 
                                Data is refreshed daily from JHU Github repository and 10,000 population rates are calculated 
                                in two different R scripts that feed into the Shiny app. 
                                  The Shiny app is structured into strong(three) sections: Map, Plots and Forecast tabs")
                              ), 
                    column(6,
                           h3("The frst two tabs display grographical information alllowing usert to hover 
                              over country pop-up circle shapes to display 
                               tooltips on specific metircs for each country. Daily figures for each country are 
                               animated every five seconds")
                              ),
                             width=15
                            )
      ),
  fluidRow(   
    box(
      column(6,
             h3("The details of the Shiny deployment and app R scripts running under the Shiny app, 
                can be found in the following GIthub repo MYREPO")
      ), 
      column(6,
             h3("Pablo Leon-Rodenas  https://uk.linkedin.com/in/pabloleonrodenas/en  Analytics Developer at NHS Improvement")
      ),
      width=15
    )
  )
)


