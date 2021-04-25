if (!require("shiny")) install.packages("shiny")
if (!require("geojsonio")) install.packages("geojsonio")
if (!require("shinydashboard")) install.packages("shinydashboard")
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("wbstats")) install.packages("wbstats")
if (!require("DT")) install.packages("DT")
if (!require("fs")) install.packages("fs")
if (!require("plotly")) install.packages("plotly")
if (!require("leaflet")) install.packages("leaflet")
if (!require("devtools")) install.packages("devtools")
library("prophet")
library("shiny") 
library("shinydashboard")
library("geojsonio")
library("tidyverse") 
library("leaflet") 
library("plotly") 
library("wbstats")
library("DT")
library("fs")

#Data Processing
covid19 <- read.csv("covid_19_indonesia_time_series_all.csv")
covid19

#Check if Any of the columns contain missing values
sum(is.na(covid19))
names(which(sapply(covid19, anyNA)))
which(sapply(covid19, anyNA))

#Change Total.Cities, Total.Urban.Villages, and Total.Rural.Villages to 0
#This happens because some cities eg. Jakarta doesn't have villages
covid19$Total.Cities[is.na(covid19$Total.Cities)] <- 0
covid19$Total.Urban.Villages[is.na(covid19$Total.Urban.Villages)] <- 0
covid19$Total.Rural.Villages[is.na(covid19$Total.Rural.Villages)] <- 0

#Take a look inside the data set
str(covid19)

#looks like the i..Date, Case.Fatality.Rate, Case.Recovered.Rate 
#columns data type is char, we need to convert to date
df <- covid19 %>% 
  rename(Date=ï..Date)%>% 
  mutate(
    Date = as.Date(Date, "%m/%d/%Y"),
    Case.Fatality.Rate=(as.numeric(sub("%", "", Case.Fatality.Rate))/100), 
    Case.Recovered.Rate=(as.numeric(sub("%", "", Case.Recovered.Rate))/100)
  )
# View(df)

df <- df %>% 
  mutate(
    day   = as.numeric(format(df$ï..Date, "%d")),
    month = as.numeric(format(df$ï..Date, "%m")),
    year  = as.numeric(format(df$ï..Date, "%Y"))
  )
#check again for changes in data
str(df)

#filter data for province only
dfProvince <- df %>% filter(Location.Level != "Country")
dfCountry <- df %>% filter(Location.Level == "Country")

editData <- function(df){
  return(df %>%
           group_by(Date, Location, Longitude, Latitude) %>%
           summarise(max_cases=max(Total.Cases),
                     max_recovered=max(Total.Recovered),
                     max_deaths=max(Total.Deaths),
                     max_active=max(Total.Active.Cases),
                     max_new_cases=max(New.Cases),
                     max_new_recovered=max(New.Recovered),
                     max_new_deaths=max(New.Deaths),
                     max_new_active=max(New.Active.Cases),
                     max_cases_per_mill=max(Total.Cases.per.Million),
                     max_deaths_per_mill=max(Total.Deaths.per.Million)) %>%
           ungroup() %>% 
           arrange(Date))
}

covidProvince <- editData(dfProvince)
covidCountry <- editData(dfCountry)


#file from "https://raw.githubusercontent.com/anshori/geojsoncombine-corona/master/data/provinsi_polygon.geojson"
province <- geojson_read("provinsi_polygon.geojson", what= "sp")

covidProvince[covidProvince$Location=="Daerah Istimewa Yogyakarta"] <- "D. I. Yogyakarta" 
province$PROV

covidProvince[covidProvince$Location=="Daerah Istimewa Yogyakarta","Location"] <- "D.I. Yogyakarta"

mapLeafletProvince <- covidProvince[order(match(tolower(covidProvince$Location), tolower(province$PROV))),]

# View(mapProvince)
#color pallet for leaflet map
binsCases = c(0,25000,50000,100000,150000,200000,Inf)
palTotalCases <- colorBin(palette = "YlGnBu", 
                          domain = mapLeafletProvince$max_cases, bins=binsCases)

binsDeaths = c(0,250, 500, 1000, 2000,4000,8000,Inf)
palTotalDeaths <- colorBin(palette = "YlOrBr", 
                           domain = mapLeafletProvince$max_deaths, bins=binsDeaths)

binsRecovered = c(0,25000,50000,100000,150000,200000,Inf)
palTotalRecovered <- colorBin(palette = "Greens", 
                              domain = mapLeafletProvince$max_recovered, bins=binsRecovered)


