if (!require("shiny")) install.packages("shiny")
if (!require("geojsonio")) install.packages("geojsonio")
if (!require("shinydashboard")) install.packages("shinydashboard")
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("wbstats"))  install.packages("wbstats")
if (!require("DT")) install.packages("DT")
if (!require("fs")) install.packages("fs")
if (!require("plotly")) install.packages("plotly")
if (!require("leaflet")) install.packages("leaflet")
if (!require("dygraphs")) install.packages("dygraphs")
if (!require("shinyWidgets")) install.packages("shinyWidgets")
if (!require("shinyjs")) install.packages("shinyjs")
source("Data Preparation and Preprocessing.R")
source("ui_description_page.R")
source("ui_map_page.R")
source("ui_plot_page.R")
source("ui_prediction_page.R")
library("shiny") 
library("shinydashboard")
library("shinyWidgets")
library("geojsonio")
library("tidyverse") 
library("leaflet") 
library("plotly") 
library("wbstats")
library("DT")
library("fs")
library("prophet")
library("dygraphs")
library("shinyjs")

ui <- fluidPage(
  title = "Covid-19 Cases in Indonesia",
  theme = shinythemes::shinytheme("simplex"),
  tags$style(type="text/css", ".container-fluid {padding-left: 0px; padding-right: 0px !important;}"),
  tags$style(type="text/css", ".navbar {margin-bottom: 0px;}"),
  tags$style(type="text/css", ".content {padding: 0px;}"),
  tags$style(type="text/css", ".row {margin-left: 0px; margin-right: 0px;}"),
  tags$style(HTML(".col-sm-12 { padding: 5px; margin-bottom: -15px; }")),
  tags$style(HTML(".col-sm-12 { padding: 5px; margin-bottom: -15px; }")),
  navbarPage(
    title = div("COVID-19 App", style = "padding-left: 15px"), #giving title name
    fluid = TRUE, #fluid layout
    collapsible = TRUE,
    tabPanel("Map Tracker", pageMap),
    tabPanel("Graphs", pagePlot),
    tabPanel("Prediction", pagePrediction),
    tabPanel("Project Description", pageDescription)
  )
)

server <- function(input, output, session) {
  
  #Map Leaflet
  filtered_data <- reactive({
    mapLeafletProvince %>%
      filter(Date==input$date)
  })
  
  observe({
    #req(input$date)
     
    map_leaflet <- filtered_data()#mapProvince %>% filter(Date==input$date)
    
    leafletProxy("map", data = province) %>%
    clearMarkers() %>%
    addPolygons(fillColor= ~palTotalDeaths(map_leaflet$max_deaths),
                fillOpacity = 0.7, smoothFactor = 0.2, color="grey",
                weight = 3, dashArray = "5",
                highlight=highlightOptions(weight=5,
                                           dashArray = "3",
                                           fillOpacity = 0.5)) %>%
    addCircleMarkers(lat=~map_leaflet$Latitude, lng=~map_leaflet$Longitude,
                     radius=~log(map_leaflet$max_cases), color="red",
                     fillOpacity = 0.6, stroke = FALSE,
                     label = ~sprintf(
                      "<strong>%s</strong><br>
                      Total Cases: %g<br>
                      Total Deaths: %g<br>
                      Total Recovered: %g<br>",map_leaflet$Location,
                      map_leaflet$max_cases, map_leaflet$max_deaths,
                      map_leaflet$max_recovered) %>% lapply(htmltools::HTML))
  })
  
  key_figures <- function(){
    current_data <- filtered_data() %>% 
      summarise(sumTotalCases = sum(max_cases),
                sumTotalDeaths = sum(max_deaths),
                sumTotalRecovered = sum(max_recovered),
                sumTotalProvinces = n_distinct(Location))
    
    yesterday_data =  mapLeafletProvince %>%
      filter(Date==(input$date - 1)) %>% 
      summarise(sumTotalCases = sum(max_cases),
                sumTotalDeaths = sum(max_deaths),
                sumTotalRecovered = sum(max_recovered),
                sumTotalProvinces = n_distinct(Location))
    
    calculate_data <- list(
      diffTotalCases = (current_data$sumTotalCases - yesterday_data$sumTotalCases) / yesterday_data$sumTotalCases*100,
      diffTotalDeaths = (current_data$sumTotalDeaths - yesterday_data$sumTotalDeaths) / yesterday_data$sumTotalDeaths*100,
      diffTotalRecovered = (current_data$sumTotalRecovered - yesterday_data$sumTotalRecovered) / yesterday_data$sumTotalRecovered*100,
      diffTotalProvinces = current_data$sumTotalProvinces - yesterday_data$sumTotalProvinces
    )
    
    keyFigures <- list(
      "cases" = HTML(paste(format(current_data$sumTotalCases, big.mark = " "), sprintf("<h4>(%+.1f %%)</h4>", calculate_data$diffTotalCases))),
      "death" = HTML(paste(format(current_data$sumTotalDeaths, big.mark = " "), sprintf("<h4>(%+.1f %%)</h4>", calculate_data$diffTotalDeaths))),
      "recovered"  = HTML(paste(format(current_data$sumTotalRecovered, big.mark = " "), sprintf("<h4>(%+.1f %%)</h4>", calculate_data$diffTotalRecovered))),
      "provinces" = HTML(paste(format(current_data$sumTotalProvinces, big.mark = " "), "/ 34", sprintf("<h4>(%+d)</h4>", calculate_data$diffTotalProvinces)))
    )
    return (keyFigures)
  }
  
  output$valueBox_cases <- renderValueBox({
    valueBox(
      key_figures()$cases,
      subtitle = "Total Cases",
      icon     = icon("file-medical"),
      color    = "orange"
    )
  })

  output$valueBox_deaths <- renderValueBox({
    valueBox(
      key_figures()$death,
      subtitle = "Total Deaths",
      icon     = icon("heartbeat"),
      color    = "red"
    )
  })
  
  output$valueBox_recovered <- renderValueBox({
    valueBox(
      key_figures()$recovered,
      subtitle = "Total Estimated Recoveries",
      icon     = icon("heart"),
      color    = "green"
    )
  })
  
  
  output$valueBox_provinces <- renderValueBox({
    valueBox(
      key_figures()$provinces,
      subtitle = "Total Affected Provinces",
      icon     = icon("flag"),
      color    = "blue"
    )
  })

  #Map Tracker
  output$map <- renderLeaflet({
    map
  })
  
  #Table
  output$table <- renderDT({
    filtered_data() %>% 
      select(Date, Location, max_cases, max_deaths, max_recovered, max_active) %>% 
      arrange(desc(max_cases))
  })
  
  
  #plot page
  observeEvent(input$level,{
    if (input$level == "Country"){
      updatePickerInput(session = session, inputId = "selectProvince",
                        choices = "none")
      
    }
    else if (input$level == "Province"){
      updatePickerInput(session = session, inputId = "selectProvince",
                        choices = sort(unique(mapLeafletProvince$Location)))
    }
  }
  )
  
  observeEvent(input$plotType,{
    if (input$plotType == "Line plot"){
      updatePickerInput(session = session, inputId = "selectProvince",
                        choices = "none")
      updatePickerInput(session = session, inputId = "selectPlot",
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
                                    "Daily Active Cases"))
      
    }
    
    else if (input$plotType == "Bar plot"){
      updatePickerInput(session = session, inputId = "selectProvince",
                        choices = "none")
      updatePickerInput(session = session, inputId = "selectPlot",
                        choices = c( "Cases", 
                                     "Deaths",  
                                     "Recovered", 
                                     "Active"))
    }
  }
  )
  
  
  filtered_data_plot <- reactive({
      type_of_data(input$level)%>%
      filter(between(Date,min(covidProvince$Date),input$datePlot))
  })

  type_of_data <- function(dataType){
    if (dataType == "Province"){
      return(covidProvince)
    }
    return(covidCountry)
  }
  
  data_summary <- function(){
      data <- filtered_data_plot() %>% group_by(Date)
      cum_data <- data %>% 
      summarise(cumCases = sum(max_cases),
                cumDeaths = sum(max_deaths),
                cumRecovered = sum(max_recovered),
                cumActive = sum(max_active)) %>% ungroup() %>%
      pivot_longer(cols = -Date,
                   names_to = "Category",
                   values_to = "Total") %>% arrange(Date)
      
      cum_data_per_mill <- data %>%
        summarise(cumCasesPerMill = sum(max_cases_per_mill),
                  cumDeathsPerMill = sum(max_deaths_per_mill)) %>% ungroup() %>%
        pivot_longer(cols = -Date,
                     names_to = "Category",
                     values_to = "Total") %>% arrange(Date)
      
      daily_data <- data %>% 
        summarise(dailyCases = sum(max_new_cases),
                  dailyDeaths = sum(max_new_deaths),
                  dailyRecovered = sum(max_new_recovered),
                  dailyActive = sum(max_new_active)) %>% ungroup() %>%
        pivot_longer(cols = -Date,
                     names_to = "Category",
                     values_to = "Total") %>% arrange(Date)
      
      result = switch(
        input$selectPlot,
        "All Cumulative" = cum_data, 
        "Cumulative Cases" = cum_data %>% filter(Category == "cumCases"), 
        "Cumulative Deaths" = cum_data %>% filter(Category == "cumDeaths"),  
        "Cumulative Recovered" = cum_data %>% filter(Category == "cumRecovered"), 
        "Cumulative Active" = cum_data %>% filter(Category == "cumActive"),
        "All Cumulative per Million" = cum_data_per_mill,
        "Cumulative Cases per Million" = cum_data_per_mill %>% filter(Category == "cumCasesPerMill"),
        "Cumulative Deaths per Million" = cum_data_per_mill %>% filter(Category == "cumDeathsPerMill"), 
        "All Daily Cases" = daily_data,
        "Daily Cases" = daily_data %>% filter(Category == "dailyCases"), 
        "Daily Deaths" = daily_data %>% filter(Category == "dailyDeaths"), 
        "Daily Recovered" = daily_data %>% filter(Category == "dailyRecovered"),
        "Daily Active Cases" = daily_data %>% filter(Category == "dailyActive")
      )
      return (result)
  }
  

  data_line_plot <- function(){
    if (input$level == "Province"){
      data <- filtered_data_plot() %>% group_by(Date) %>% 
        filter(Location == input$selectProvince)
    }
    
    else if (input$level == "Country"){
      data <- filtered_data_plot() %>% group_by(Date)
    }
    
    cum_data <- data %>% 
      summarise(cumCases = sum(max_cases),
                cumDeaths = sum(max_deaths),
                cumRecovered = sum(max_recovered),
                cumActive = sum(max_active)) %>% ungroup() %>%
      pivot_longer(cols = -Date,
                   names_to = "Category",
                   values_to = "Total") %>% arrange(Date)
    
    cum_data_per_mill <- data %>% 
      summarise(cumCasesPerMill = sum(max_cases_per_mill),
                cumDeathsPerMill = sum(max_deaths_per_mill)) %>% ungroup() %>%
      pivot_longer(cols = -Date,
                   names_to = "Category",
                   values_to = "Total") %>% arrange(Date)
    
    daily_data <- data %>% 
      summarise(dailyCases = sum(max_new_cases),
                dailyDeaths = sum(max_new_deaths),
                dailyRecovered = sum(max_new_recovered),
                dailyActive = sum(max_new_active)) %>% ungroup() %>%
      pivot_longer(cols = -Date,
                   names_to = "Category",
                   values_to = "Total") %>% arrange(Date)
    
    result = switch(
      input$selectPlot,
      "All Cumulative" = cum_data, 
      "Cumulative Cases" = cum_data %>% filter(Category == "cumCases"), 
      "Cumulative Deaths" = cum_data %>% filter(Category == "cumDeaths"),  
      "Cumulative Recovered" = cum_data %>% filter(Category == "cumRecovered"), 
      "Cumulative Active" = cum_data %>% filter(Category == "cumActive"),
      "All Cumulative per Million" = cum_data_per_mill,
      "Cumulative Cases per Million" = cum_data_per_mill %>% filter(Category == "cumCasesPerMill"),
      "Cumulative Deaths per Million" = cum_data_per_mill %>% filter(Category == "cumDeathsPerMill"), 
      "All Daily Cases" = daily_data,
      "Daily Cases" = daily_data %>% filter(Category == "dailyCases"), 
      "Daily Deaths" = daily_data %>% filter(Category == "dailyDeaths"), 
      "Daily Recovered" = daily_data %>% filter(Category == "dailyRecovered"),
      "Daily Active Cases" = daily_data %>% filter(Category == "dailyActive")
    )
    
    return (result)
  }
  
  data_bar_plot <- function(){
    data <- filtered_data_plot()
    
    data <- data %>% 
      group_by(Location)%>%
      summarise(Cases = sum(max_cases),
                Deaths = sum(max_deaths),
                Recovered = sum(max_recovered),
                Active = sum(max_active)) %>% 
      ungroup()
    
    result = switch(
      input$selectPlot,
      "Cases" = data %>% select(Location, Cases), 
      "Deaths" = data %>% select(Location, Deaths),  
      "Recovered" = data %>% select(Location, Recovered), 
      "Active" = data %>% select(Location, Active),
    )
    
    return(result);
  }
  
  output$plotlyData <- renderPlotly(
    if (input$plotType == "Line plot"){
      if (input$level == "Country"){
        ggplotly(ggplot(data=data_line_plot(),aes(x=Date, y=Total, color=Category))+
                   geom_area(aes(color=Category, fill=Category),alpha=0.4,
                             position = position_dodge(0.8))+
                   labs(x = "Date",
                        y = "Total")+scale_y_continuous(labels=scales::comma))
      }
      
      else if (input$level == "Province"){
        ggplotly(ggplot(data=data_line_plot(),aes(x=Date, y=Total, color=Category))+
                   geom_line()+
                   labs(x = "Date", y = "Total")+
                   scale_y_continuous(labels=scales::comma))
      }
    }
    else {
      if (input$selectPlot == "Cases"){
        ggplotly(ggplot(data=data_bar_plot(),
                        aes(x=reorder(Location,Cases), y=Cases))+
                   geom_bar(stat="summary")+coord_flip()+
                   scale_y_continuous(labels = scales::comma)+labs(x="Location in Indonesia"))
      }
      else if (input$selectPlot == "Deaths"){
        ggplotly(ggplot(data=data_bar_plot(),
                        aes(x=reorder(Location,Deaths), y=Deaths))+
                   geom_bar(stat="summary")+coord_flip()+
                   scale_y_continuous(labels = scales::comma)+labs(x="Location in Indonesia"))
      }
      else if (input$selectPlot == "Recovered"){
        ggplotly(ggplot(data=data_bar_plot(),
                        aes(x=reorder(Location,Recovered), y=Recovered))+
                   geom_bar(stat="summary")+coord_flip()+
                   scale_y_continuous(labels = scales::comma)+labs(x="Location in Indonesia"))
      }
      else if (input$selectPlot == "Active"){
        ggplotly(ggplot(data=data_bar_plot(),
                        aes(x=reorder(Location, Active), y=Active))+
                   geom_bar(stat="summary")+coord_flip()+
                   scale_y_continuous(labels = scales::comma)+labs(x="Location in Indonesia"))
      }
    }
  )
  
  observeEvent(input$selectLevell,{
    if (input$selectLevell == "Country"){
      updateSelectInput(session = session, inputId = "selectProvinceee",
                        choices = "none")
      
    }
    else if (input$selectLevell == "Province"){
      updateSelectInput(session = session, inputId = "selectProvinceee",
                        choices = sort(unique(mapLeafletProvince$Location)))
    }
  }
  )
  
  prophet_model <- eventReactive(input$predictButton,{
    if (input$selectLevell == "Country"){
      d <- covidCountry %>%
        group_by(Date) %>%
        summarise(Cases= sum(max_new_cases),
                  Deaths = sum(max_new_deaths),
                  Recovered = sum(max_new_recovered),
                  Active = sum(max_new_active)) %>% ungroup()%>%
        select(Date, input$selectCase) %>%
        rename(ds=Date, y=input$selectCase)
    }
    else if ((input$selectLevell == "Province")){
      d <- covidProvince %>%
        filter(Location == input$selectProvinceee) %>%
        group_by(Date) %>%
        summarise(Cases= sum(max_new_cases),
                  Deaths = sum(max_new_deaths),
                  Recovered = sum(max_new_recovered),
                  Active = sum(max_new_active)) %>% ungroup()%>%
                  select(Date, input$selectCase) %>%
                  rename(ds=Date, y=input$selectCase)
    }
    return(prophet(d, n.changepoints = 20, changepoint.range = 0.8,
            changepoint.prior.scale = 0.05, daily.seasonality = TRUE))
  })
  
  future <- eventReactive(input$predictButton,{
    req(prophet_model())
    return(make_future_dataframe(prophet_model(), periods = 90, freq = "day"))
  })
  
  
  data_prediction_plot_cases <- function(){
    req(prophet_model(),future())
    forecast <- predict(prophet_model(), future())
    
    return(dyplot.prophet(prophet_model(), forecast, main = input$selectCase))

  }

  
  output$predictionPlot <- renderDygraph({
    data_prediction_plot_cases()
  })

}

shinyApp(ui, server)
