# 01 Shiny_OBSERVE_function.R

# Downloaded Shample Superstore data set from:
# https://community.tableau.com/s/question/0D54T00000CWeX8SAL/sample-superstore-sales-excelxls

# SHINY observe example

# R Script: 22 SHINY observe example.R
library(shiny)
library(dplyr)
library(here)
library(readr)
library(janitor)

here()

# Load data using readr and janitor
product_list <-read_csv("Sample - Superstore.csv") %>% 
               clean_names()

ui <- shinyUI(fluidPage(
  
  headerPanel(title = "Shiny App Conditional Filter Demo"),
  sidebarLayout(
    sidebarPanel(
      selectInput("mainproduct","Select product category",choices = c("Furniture","Office Supplies","Technology")),
      selectInput("subproduct","Select Sub Product category",choices = NULL),
      selectInput("product","Select a Product",choices = NULL)
      
    ),
    mainPanel()
  )))

server <- shinyServer(function(session,input,output){
  observe({
    print(input$mainproduct)
    
    # Subset data based on FIRST filter
    product_list_main <-product_list
    
    # 1. The selection we introduce on the FIRST filter
    suppab <- product_list_main %>% filter(category == input$mainproduct) %>% select(sub_category)
    
    # 2. Changes what we see in the SECOND filter 
    updateSelectInput(session,"subproduct","Select Sub Product category",choices = unique(suppab))
  })
  
  observe({
    # 3. Again waht we select on SECOND filter
    productdata <- product_list$product_name[product_list$sub_category == input$subproduct]
    
    # 4. Changes remaining options we can see on the THIRD filter
    updateSelectInput(session,"product","Select a Product",choices = productdata )
  })
  
})

# Launch it
shinyApp(ui = ui,server = server)

