# app_launch_TRIGGER.R script

# 1. Open this Rscript and press the "Source" button to trigger this Shiny app.
# This script will trigger the entire Shiny app and it will be displayed on your browser
# Initialising renv for this project 
library(renv)

# 2. Load shiny and shinydashboard libraries

# Following readme file we would have loaded rqeuired packages into R after executing renv::restore() command
# renv::restore()
# The following package(s) will be updated:
# CRAN -----------------------------------------------------------------------
# - base64enc           [* -> 0.1-3]
# ...
# - Installing shiny ...                          OK [linked from cache in 0.00029s]
# - Installing shinydashboard ...                 OK [linked from cache in 0.00029s]
# We can install them manually
install.packages(c("shiny","shinydashboard"),dependencies = TRUE)
install.packages(c("janitor"),dependencies = TRUE)

library(shiny)
library(shinydashboard)

# 3. Source script to launch Shiny app
source("app_launcher.R")

