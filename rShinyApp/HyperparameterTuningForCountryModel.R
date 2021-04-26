# max new cases
data <- covidCountry %>%    
  select(Date, max_new_cases) %>% 
  rename(ds=Date, y=max_new_cases)


#change point scale
cps = c(0.001, 0.01, 0.1)
#change point prior scale
cr = c(0.8, 0.95)

tuning_results_cases = data.frame()
rmse = c()

for (i in cps){
  for (j in cr){
    m<- prophet(data, changepoint.range = j,
                changepoint.prior.scale = i, daily.seasonality = TRUE)
    df <- cross_validation(m, initial = 97*3, horizon = 97, units = 'days')
    p <- performance_metrics(df)
    temp <-data.frame(i,j, p$rmse[1])
    tuning_results_cases <- rbind(tuning_results_cases, temp)
  }
}

names(tuning_results_cases) = c("changepoint.prior.scale", "changepoint.range", "rmse")
tuning_results_cases<- tuning_results_cases %>% arrange(rmse)
head(tuning_results_cases)

# max new deaths
data <- covidCountry %>%    
  select(Date, max_new_deaths) %>% 
  rename(ds=Date, y=max_new_deaths)


covidProvince$Location 
#change point scale
cps = c(0.001, 0.01, 0.1)
#change point prior scale
cr = c(0.8, 0.95)

tuning_results_deaths = data.frame()
rmse = c()

for (i in cps){
  for (j in cr){
    m<- prophet(data, changepoint.range = j,
                changepoint.prior.scale = i, daily.seasonality = TRUE)
    df <- cross_validation(m, initial = 97*3, horizon = 97, units = 'days')
    p <- performance_metrics(df)
    temp <-data.frame(i,j,p$rmse[1])
    tuning_results_deaths <- rbind(tuning_results_deaths, temp)
  }
}

names(tuning_results_deaths) = c("changepoint.prior.scale", "changepoint.range", "rmse")
tuning_results_deaths <- tuning_results_deaths %>% arrange(rmse)
head(tuning_results_deaths)

# max new recovered
data <- covidCountry %>%    
  select(Date, max_new_recovered) %>% 
  rename(ds=Date, y=max_new_recovered)

#change point scale
cps = c(0.001, 0.01, 0.1)
#change point prior scale
cr = c(0.8, 0.95)

tuning_results_recovered = data.frame()
rmse = c()

for (i in cps){
  for (j in cr){
    m<- prophet(data, changepoint.range = j,
                changepoint.prior.scale = i, daily.seasonality = TRUE)
    df <- cross_validation(m, initial = 97*3, horizon = 97, units = 'days')
    p <- performance_metrics(df)
    temp <-data.frame(i,j,p$rmse[1])
    tuning_results_recovered <- rbind(tuning_results_recovered, temp)
  }
}

names(tuning_results_recovered) = c("changepoint.prior.scale", "changepoint.range", "rmse")
tuning_results_recovered <- tuning_results_recovered %>% arrange(rmse)
head(tuning_results_recovered)



# max new active
data <- covidCountry %>%    
  select(Date, max_new_active) %>% 
  rename(ds=Date, y=max_new_active)


covidProvince$Location 
#change point scale
cps = c(0.001, 0.01, 0.1)
#change point prior scale
cr = c(0.8, 0.95)

tuning_results_active = data.frame()
rmse = c()

for (i in cps){
  for (j in cr){
    m<- prophet(data, changepoint.range = j,
                changepoint.prior.scale = i, daily.seasonality = TRUE)
    df <- cross_validation(m, initial = 97*3, horizon = 97, units = 'days')
    p <- performance_metrics(df)
    temp <-data.frame(i,j,p$rmse[1])
    tuning_results_active <- rbind(tuning_results_active, temp)
  }
}

names(tuning_results_active) = c("changepoint.prior.scale", "changepoint.range", "rmse")
tuning_results_active <- tuning_results_active %>% arrange(rmse)
head(tuning_results_active)

print("parameter for cases")
tuning_results_cases %>% 
  filter(rmse == min(rmse))

print("parameter for deaths")
tuning_results_deaths %>% 
  filter(rmse == min(rmse))

print("parameter for recovered")
tuning_results_recovered %>% 
  filter(rmse == min(rmse))

print("parameter for active")
tuning_results_active %>% 
  filter(rmse == min(rmse))

