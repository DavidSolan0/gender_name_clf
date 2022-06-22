library(dplyr)
library(shiny)
library(haven)
library(readxl)
library(tibble)
library(tidyverse)
library(tidymodels)
library(textrecipes)
library(shinydashboard)
library(shinydashboardPlus)


server = function(input, output) {
  
  source('./utils.R')
  clf = readRDS('./gender_name_clf.rds')
  
  clf_gender <- reactive({
    file <- input$file1
    ext <- tools::file_ext(file$datapath)
    
    req(file)
    #validate(need(ext %in% c("csv",'xlsx', 'xls','sav'), 
     #            "Por favor revise la extensión de su archivo"))
    
    if(input$extension == 'csv')
      df = read.csv2(file$datapath)
    
    if(input$extension == 'xlsx')
      df = read_excel(file$datapath)
     
    if(input$extension == 'sav'){
      sav_file = read_sav(file$datapath)
      sav_file[] = lapply(sav_file, function(x) {attributes(x) <- NULL;x})
      df = sav_file
      }
    
    make_predictions(df, clf)
  
  })
  
  output$value <- renderPrint({
    
    str(input$file1)
    
  })
  
  output$downloadData <- downloadHandler(
    
    filename = function() {return('input_gender_predictions.csv')},
    content = function(file)  {write.csv2(clf_gender(), file, row.names = FALSE)}
  
  )
  
}
