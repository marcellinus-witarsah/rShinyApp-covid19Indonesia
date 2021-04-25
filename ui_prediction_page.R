predictionBody <- dashboardBody(
  sidebarLayout(
    sidebarPanel(selectInput(inputId = "selectLevell", label = "Select Level",
                             choices = c("Country", "Province")),
                 selectInput(inputId = "selectProvinceee", label = "Select Province",
                             choices = sort(unique(mapLeafletProvince$Location))),
                 selectInput(inputId = "selectCase", label = "Select Cases",
                             choices = c("Cases", "Deaths", 
                                         "Recovered", "Active")),
                 actionButton(inputId = "predictButton", label = "Predict")),
    mainPanel(
        box(width = 12, dygraphOutput("predictionPlot"))
      )
  )
  
)

pagePrediction <- dashboardPage(
  title = "Prediction",
  header = dashboardHeader(disable = TRUE),
  sidebar = dashboardSidebar(disable = TRUE),
  body = predictionBody
)