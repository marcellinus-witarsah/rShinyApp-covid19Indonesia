dataMinDate = mapLeafletProvince %>% filter(Date == min(mapLeafletProvince$Date))

map <- leaflet(province) %>%
  addProviderTiles(providers$Esri.WorldImagery, group="esri") %>%
  addProviderTiles(providers$CartoDB.DarkMatter, group="carto") %>%
  addPolygons(fillColor= ~palTotalDeaths(dataMinDate$max_deaths),
              fillOpacity = 0.7, smoothFactor = 0.2, color="grey",
              weight = 3, dashArray = "5",
              highlight=highlightOptions(weight=5,
                                         dashArray = "3",
                                         fillOpacity = 0.5)) %>%
  addCircleMarkers(lat=~dataMinDate$Latitude, lng=~dataMinDate$Longitude,
                   radius=(dataMinDate$max_cases^1/3000), color="red",
                   fillOpacity = 0.6, stroke = FALSE,
                   label = ~sprintf(
                     "<strong>%s</strong><br>
                        Total Cases: %g<br>
                        Total Deaths: %g<br>
                        Total Recovered: %g<br>",dataMinDate$Location,
                     dataMinDate$max_cases, dataMinDate$max_deaths,
                     dataMinDate$max_recovered) %>% lapply(htmltools::HTML)) %>%
  addLegend(pal=palTotalDeaths, values = dataMinDate$max_deaths,
            position = "topright",
            title="Total Deaths Covid-19 in Indonesia") %>%
  addLayersControl(
    baseGroups = c("esri", "carto"),
    position = "bottomright"
  )

bodyMap <- dashboardBody(
  fluidRow(
    fluidRow(
      column(width=12, box(width=12,
                      valueBoxOutput("valueBox_cases", width = 3),
                      valueBoxOutput("valueBox_deaths", width = 3),
                      valueBoxOutput("valueBox_recovered", width = 3),
                      valueBoxOutput("valueBox_provinces", width = 3)
                      )
          )
    ),
    fluidRow(
      column(12, box(width=12, leafletOutput("map")),
             absolutePanel(draggable = TRUE, class = "panel",
                           span(tags$i(h5("Reported Covid-19 Cases in Indonesia"))),
                           sliderInput(inputId="date", label="Select Date",
                                       min=min(mapLeafletProvince$Date), 
                                       max=max(mapLeafletProvince$Date),
                                       value=min(mapLeafletProvince$Date), ticks=FALSE,
                                       animate = animationOptions(loop = TRUE,interval=2000)))),
      column(12, box(width=12, DTOutput("table")))
            )
    )
)

pageMap <- dashboardPage(
  title = "Map",
  header = dashboardHeader(disable = TRUE),
  sidebar = dashboardSidebar(disable = TRUE),
  body = bodyMap
)
