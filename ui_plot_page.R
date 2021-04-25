bodyPlot <- 
  dashboardBody(
    sidebarLayout(
     
      sidebarPanel(pickerInput(inputId = "plotType", label="Select Type of Plot",
                               choices = c("Line plot", "Bar plot"),
                               multiple = FALSE),
                   pickerInput("level", label = "Level",
                               choices = c("Province", "Country"),
                               selected = c ("Country"),
                               multiple=FALSE),
                   pickerInput(inputId = "selectProvince", label = "Select Province",
                               choices = sort(unique(mapLeafletProvince$Location))),
                   pickerInput(inputId = "selectPlot", label = "Select Cases",
                               choices = c("All Cumulative", 
                                           "Cumulative Cases", 
                                           "Cumulative Deaths",  
                                           "Cumulative Recovered", 
                                           "Cumulative Active",
                                           "All Cumulative per Million",
                                           "Cumulative Cases per Million",
                                           "Cumulative Deaths per Million", 
                                           "All Daily Cases",
                                           "Daily Cases", 
                                           "Daily Deaths", 
                                           "Daily Recovered",
                                           "Daily Active Cases"),
                                multiple = FALSE),
                   sliderInput(inputId = "datePlot", label = "Select Date",
                               min = min(covidProvince$Date),
                               max = max(covidProvince$Date),
                               value = as.Date("2020-06-01"),
                               ticks = FALSE,
                               animate = animationOptions(loop = TRUE,interval=2000))
      ),
      mainPanel(
        box(width=12, plotlyOutput("plotlyData"))
      )
    )
)

pagePlot <- dashboardPage(
  title = "Plot",
  header = dashboardHeader(disable = TRUE),
  sidebar = dashboardSidebar(disable = TRUE),
  body = bodyPlot
)

