# app_launch_TRIGGER.R script

# 1. Open this Rscript and press the "Source" button to trigger this Shiny app.
# This script will trigger the entire Shiny app and it will be displayed on your browser
# Initialising renv for this project 
library(renv)

# 1. Install shiny and load shiny and shinydashboard libraries
install.packages("shiny", type = "binary", dependencies = TRUE)
library(shiny)
library(shinydashboard)

# 2. Source script to launch Shiny app
source("app_launcher.R")

