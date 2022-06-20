#library(DT)
library(shiny)
library(shinydashboard)
library(shinydashboardPlus)

instruccion1 = 'Please upload yout file'
instruccion2 = 'Your file must contain the following column as predictor: name'

ui <- dashboardPage(
  dashboardHeader(title = "Gender Classification"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Classification", tabName = "tab1")
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "tab1",
              tabsetPanel(
                id = "tab1",
                tabPanel("Files",
                         fluidRow(
                           column(width = 3,
                                  radioButtons("extension", 
                                               label = h3("File format"),
                                               choices = list("CSV" = 'csv', 
                                                              "xlsx" = 'xlsx', 
                                                              "sav" = 'sav'), 
                                               selected = 'csv')
                           ),
                           column(width = 4,
                                  fileInput("file1", label = h3("File")),
                                  p(class = "text-muted", h6(instruccion1)),
                                  p(class = "text-muted", h5(instruccion2))
                           ),
                           column(width = 4,
                                  h3('File Info'),
                                  verbatimTextOutput("value"),
                                  downloadButton("downloadData", "Download Predictions")
                           )
                         )
                )
              ),  
      )
    )
  )
)
