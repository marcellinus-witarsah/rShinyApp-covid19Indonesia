# rShinyApp-covid19Indonesia
# (still on progress)
Operation Research Project: Covid 19 Time Series Prediction
Members And Contribution:

NIM | Name | Contribution
----|------|-------------
01082190016 | Marcellinus Aditya Witarsah | Making the Covid-19 tracker map, Making the Covid-19 Web Application template, Assisting in creating the time series model prediction using the Prophet package. 
01082190017 | Kevin Subiyantoro | Debug and fix Web Application, Research and implement a prediction model using Facebook’s Prophet library.
01082190004 | Kevin Edward | Making Bar plot for the plot page,Inserting Bar plot to R Shiny
01082190015 | Kelvin Wyeth | Making the Line plot for the plot page, Inserting the Line plot to R Shiny
none | Klemens |  none




# Introduction
This project is aimed at predicting the outcome of Covid-19 cases in Indonesia using data provided by Hendratno who is the Government Official of the Training Center at the Ministry of Communication and Informatics of Indonesia. He shared the data on Kaggle which can be accessed using this [link](https://www.kaggle.com/hendratno/covid19-indonesia). The outline of this report will include, Covid-19 tracker map, Covid-19 line plot, Covid-19 bar plot and prediction of Covid-19 cases using the Prophet package. All analysis will be conducted using the R programming language using RStudio as its IDE and results will be presented as a web application using the RShiny package.
# Covid 19 Tracker Map (Marcel)
For making Covid 19 Tracker Map we will be needing Indonesia geojson data which can be downloaded from Github using this [link](https://github.com/anshori/geojsoncombine-corona/tree/master/data (from anshori)). This data contains longitudes and latitudes (multipolygon points) for each province in Indonesia. We need to rearrange the order of geojson data to be the same as Covid 19 data in our project. These steps will be explained below:

1. Import geojsonio Package in R and read the geojson data using geojson_read() function.
2. Take a look in the data and we need to make sure that each data has the same province name. For example, we encountered a different format name for Yogyakarta, in our data is “Daerah Istimewa Yogyakarta” but in the geojson data is "D.I. Yogyakarta". So we need to change it.
3. Then we will reorder the data so that each province in our data has the same order as the geojson data.

Then we will be using a leaflet package to draw the choropleth map. All steps of drawing the choropleth map will be explained below:

1. We use the leaflet() function and pass in the geojson data that has been read using geojson_read() as an argument. Then we will pipe it to the addProviderTiles() function to add the map.
2. After that we will pipe it to the addPolygons() function to draw the polygon according to geojson data multipolygon points. We can specify an argument inside addPolygons() function to modify and customize the look of the choropleth map. Then, we will pipe it to addCircleMarkers() function for adding a circle mark on every province using longitude and latitude point in our Covid-19 Indonesia data. Lastly we can add legend using addLegend() function to give some clarity about the data to our viewer.
 
After that we will display it in the R Shiny web application and we will add a value box which we will be colored in orange (total cases), red (total deaths), green (total recovered), and blue (total provinces). There will be a table displayed to give further information about Covid-19 cases according to input date from slider input. Further information about the rShiny web application will be displayed within the code.


# Covid 19 Line Plot (Kelvin Wyeth)
Next is the plot page, which consists of both the line graph and bar graph visualization of the COVID-19 data of Indonesia.
In order to create the line plot graph of the data, as shown above, we need to load the libraries necessary to make a simple plot graph, such as ggplot, plotly, data, and tidyverse. The simple line plot is then created using the steps below:

1. Call the ggplot() function, which will then specify the data object for the line graph.
2. Call the aes() function in order to set the data in graph, in which the X axis is the Date, and the Y axis is the Data. The colors are based on the Category chosen.
3. Call the geom functions in order to produce data based on the category chosen. The geom_area() function is meant for the Country option, while geom_line() is meant for the Province option.

In order to make a list to select the input desired, we needed to make the visualization with the updatePickerInput() function in order to form the input. The choices will then be sorted into sessions, inputID, and choices., and each of the four input levels has their own respective choices. The four input levels are:
1. Select the Type of Plot: Plot visualization, choice is between Line Plot or Bar Plot
2. Level: Level of data detail, choice is between Country or Province
3. Select Province: Chosen if Province is selected, choice is between the 33 Provinces of Indonesia
4. Select Cases: Choices are Cases, Deaths, Recovered, and Active. Additional choices are for data frequency, such as Cumulative, All, and Daily.
5. Select Date: Use the slider to adjust the date of the data update.

In order to update the plot visuals based on the selections on the page, we built the system in the ui_plot_page, for both line and bar plots. The sidebar panel and the pickerInput() function shows the choices mentioned above, and the sliderInput() shows the date selection.

# Covid 19 Bar Plot (Kevin Edward)
To make Bar Plot we first need to load the library tidyverse, ggplot & data, and plotly library. Then we  create simple bar plot using ggplot package using the following step:
1. Start by calling ggplot() function, then specify the data object. It has to be a data frame.
2. Then set the aes() function: set the categoric variable for Y axis, and numeric for X axis. 
3. Then finally call geom_bar() function that makes the height of the bar proportional to the number of cases in each group, then specify stats=”summary” for the dataset. We use coord_flip() to flip the barplot horizontally to make the group table much easier.

Then to make a select input list first we need to make the visual using updatepickertinput() to change the value of a select input on the client. Then we categorize the session, inputID and the choice. In our case we use 4 picker inputs to call our data such as Select Type of Plot, Level, Select Province, Select Cases. each of them has their choice for example Select Type of Plot consist of lone and bar plot, level consist of country and province and so on. Next we have the function of the bar plot. Our case it will show the sum of the max case, death, recovered and active by hovering the 
Next, we build our system in a new script to update our data from the select option. If we pick the plot bar the system will trigger the function which will update our data to the new data that we picked. In the new script named ui_plot_page we make the pickerinput() this function is used to display the choices that were made. Then we set the picker table size by using the box() function. 

# Predicting Covid 19 Using Prophet library (Kevin Subiyantoro)
## Machine Learning Method
For performing a machine learning method into our Covid-19 Indonesia data, we will be using a famous library package called Prophet. Prophet is an open source TIme Series Forecasting Algorithm developed by the data science team from Facebook. This library is aimed for those who are not an expert in time series forecasting and analytics.

In this Project we are using Facebook’s Prophet library, as our prediction model. Here is the link for the [Prophet documentation](https://peerj.com/preprints/3190.pdf).

## Modelling Using fbprophet
A very fundamental part in understanding time series is to be able to decompose its underlying components. A classic way in describing a time series is using General Additive Model (GAM). This definition describes time series as a summation of its components. As a starter, we will define time series with 3 different components:
* Trend (T): Long term movement in its mean
* Seasonality (S): Repeated seasonal effects
* Residuals (E): Irregular components or random fluctuations not described by trend and seasonality

The idea of GAM is that each of them is added to describe our time series:

Y(t)=T(t)+S(t)+E(t)

When we are discussing time series forecasting there is one main assumption that needs to be remembered: We assume correlation among successive observations. Means that the idea of performing a forecasting for a time series is based on its past behavior. So in order to forecast the future values, we will take a look at any existing trend and seasonality of the time series and use it to generate future values.

The Prophet enhanced the classical trend and seasonality components by adding a holiday effect. It will try to model the effects of holidays which occur on some dates and has been proven to be really useful in many cases. Take, for example: Lebaran Season. In Indonesia, it is really common to have an effect on Lebaran season. The effect, however, is a bit different from a classic seasonality effect because it shows the characteristics of an irregular schedule.
COVID-19 is something new and throws off all our daily activities and events, hence we cannot rely on the holiday effect. Our Dataset is also only a little over one year, so we can't really have a yearly seasonality effect, hence the main component in our model is the trends, and daily seasonality.
## Adjusting Trend Flexibility

Prophet provided us a tuning parameter to adjust the detection flexibility:
* n_changepoints (default = 25): The number of potential changepoints, not recommended to be tuned, this is better tuned by adjusting the regularization (changepoint_prior_scale)
* changepoint_range (default = 0.8): Proportion of the history in which the trend is allowed to change. Recommended range: [0.8, 0.95]
* changepoint_prior_scale (default = 0.05): The flexibility of the trend, and in particular how much the trend changes at the trend changepoints. Recommended range: [0.001, 0.5]

Increasing the default value of the parameter above will give extra flexibility to the trend line (overfitting the training data). On the other hand, decreasing the value will cause the trend to be less flexible (underfitting).

In our project we will not use hyperparameter tuning as a user can specify a large number of combinations to generate the predictions, and we do not have time to tune each and everyone of them.
Performance

# Prediction Result
In this page we will be showing our prediction result of Covid-19 prediction using prophet which will be displayed in R-Shiny Web Application.
Covid-19 Cases in Country Level




Covid-19 Cases in Province Level
We will show prediction cases only for DKI Jakarta city.




R-Shiny Result
Map Tracker



Graphs


Prediction



