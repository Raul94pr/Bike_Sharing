# Importing necessary libraries
library(dplyr)
library(tidyverse)
library(skimr)
library(units)
library(NISTunits)
library(ggplot2)
library(data.table)

# Importing data from CSV file into data frame
df <- read.csv("A:/Data_Analysis_Projects/Bike_Sharing/2_Cleaning_SQL/Cyclistic_clean.csv")

#Quick data overview and last corrections
colnames(df)

  #Columns names imported incorrectly at first, changed in source
glimpse(df)

  #Apply correct data types 
df[["ride_start"]] <- as.POSIXct(df[["ride_start"]], format = "%Y-%m-%d %H:%M:%S")
df[["ride_end"]] <- as.POSIXct(df[["ride_end"]], format = "%Y-%m-%d %H:%M:%S")
df[["start_lat"]] <- as.numeric(df[["start_lat"]])
df[["start_lng"]] <- as.numeric(df[["start_lng"]])
df[["end_lat"]] <- as.numeric(df[["end_lat"]])
df[["end_lng"]] <- as.numeric(df[["end_lng"]])


  #Final Check
skim_without_charts(df)
str

#Calculate ride time Length
df[["Trip_len_min"]] <-round(as.numeric(difftime(df[["ride_end"]],df[["ride_start"]], units ="mins")), digits=2)

# Date properties expansion
df[["Date"]] <- as.Date(df[["ride_start"]])
df[["Month"]] <- format(df[["ride_start"]],"%B")
df[["Day"]] <- weekdays(df[["ride_start"]])
df[["Hour"]] <- format(df[["ride_start"]],"%H")

#Calculate Distance 
  #Define Constants
r<- 6371 *1000 #Radius of the Earth in m
order_d <- c("Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday")

  #Calculations
df[["d_lat"]] <- NISTdegTOradian(df[["end_lat"]]-df[["start_lat"]])
df[["d_lng"]] <- NISTdegTOradian(df[["end_lng"]]-df[["start_lng"]])
df[["distance_m"]] <- 2* asin(sqrt(sin(df[["d_lat"]] / 2)^2 + cos(NISTdegTOradian(df[["start_lat"]])) * cos(NISTdegTOradian(df[["end_lat"]])) * sin(df[["d_lng"]] / 2)^2))*r

#Remove columns
df_clean <- subset(df,select = -c(ride_start,ride_end,d_lat,d_lng,ï..ride_id))
df_clean <- subset(df_clean, Trip_len_min > 0.5)
df_clean <- subset(df_clean, Trip_len_min< 250)

# Analysis

    #Overview Whole userbase
overview <- df_clean %>% summarise(
  max_trip_len_min = max(Trip_len_min), min_Trip_len_min = min(Trip_len_min), mean_trip_len_min = mean(Trip_len_min), std_trip_len_min = sd(Trip_len_min),
  max_dist_m = max(distance_m), min_dist_m = min(distance_m), mean_dist_m = mean(distance_m), std_dist_m = sd(distance_m),
  Casuals_perc = sum(Membership =="casual")/ nrow(df_clean),members_perc = sum(Membership =="member")/ nrow(df_clean), 
  docked_bikes_perc = sum(rideable_type=="docked_bike")/nrow(df_clean), classic_bike_perc = sum(rideable_type=="classic_bike")/nrow(df_clean), electric_bike_perc = sum(rideable_type =="electric_bike")/nrow(df_clean))

    #time axis
timeax <- ggplot(df_clean,aes(x=Date)) + geom_bar()
timeax
    #weekdays Overall
weekdays_overall <- df_clean %>% group_by(Day) %>% summarise(n = n())

    #trip overview
ggplot(data=df_clean, aes(x=Trip_len_min)) + geom_histogram() + stat_bin(bins=30) + ggtitle("trip len min ov")
ggplot(data=df_clean, aes(x=distance_m)) + geom_histogram() + stat_bin(bins=30) + ggtitle("dist ov")

  #By user type 

    #Casuals Overview
df_casuals<- filter(df_clean, Membership =="casual")
overview_casuals <- df_casuals %>% summarise(
  max_trip_len_min = max(Trip_len_min), min_trip_len_min = min(Trip_len_min), mean_trip_len_min = mean(Trip_len_min), std_trip_len_min = sd(Trip_len_min),
  max_dist_m = max(distance_m), min_dist_m = min(distance_m), mean_dist_m = mean(distance_m), std_dist_m = sd(distance_m),
  Casuals_perc = sum(Membership =="casual")/ nrow(df_casuals),members_perc = sum(Membership =="member")/ nrow(df_casuals), 
  docked_bikes_perc = sum(rideable_type=="docked_bike")/nrow(df_casuals), classic_bike_perc = sum(rideable_type=="classic_bike")/nrow(df_casuals), electric_bike_perc = sum(rideable_type =="electric_bike")/nrow(df_casuals))
      #weekdays casuals  
weekdays_casuals <- df_casuals %>% group_by(day) %>% summarise(n = n())
weekdays_casuals <-  weekdays_casuals %>% slice(match(order_d,day))

      #hours casuals 
hours_casuals <- df_casuals %>% group_by(hour) %>% summarise(n = n())
ggplot(hours_casuals,aes(x=hour, y=n,group=1)) + geom_line() + ggtitle("hours casual")#

      #trip casuals
ggplot(data=df_casuals, aes(x=trip_len_min)) + geom_histogram() + stat_bin(bins=30) + ggtitle("trip len min cas")
ggplot(data=df_casuals, aes(x=distance_m)) + geom_histogram() + stat_bin(bins=30) + ggtitle("dist cas")

    # Members Overview
df_members<- filter(df_clean, Membership =="member")
overview_members <- df_members %>% summarise(
  max_trip_len_min = max(Trip_len_min), min_trip_len_min = min(Trip_len_min), mean_trip_len_min = mean(Trip_len_min), std_trip_len_min = sd(Trip_len_min),
  max_dist_m = max(distance_m), min_dist_m = min(distance_m), mean_dist_m = mean(distance_m), std_dist_m = sd(distance_m),
  Casuals_perc = sum(Membership =="casual")/ nrow(df_members),members_perc = sum(Membership =="member")/ nrow(df_members), 
  docked_bikes_perc = sum(rideable_type=="docked_bike")/nrow(df_members), classic_bike_perc = sum(rideable_type=="classic_bike")/nrow(df_members), electric_bike_perc = sum(rideable_type =="electric_bike")/nrow(df_members))

      # weekdays members  
weekdays_members <- df_members %>% group_by(Day) %>% summarise(n = n())
weekdays_members <- weekdays_members %>% slice(match(order_d,Day))

      # hours members 
hours_members <- df_members %>% group_by(Hour) %>% summarise(n = n())
ggplot(hours_members,aes(x=Hour, y=n,group=1)) + geom_line() +ggtitle("hours members")

      # trip overview members
ggplot(data=df_members, aes(x=Trip_len_min)) + geom_histogram() + stat_bin(bins=30) + ggtitle("trip len min mem")
ggplot(data=df_members, aes(x=distance_m)) + geom_histogram() + stat_bin(bins=30) + ggtitle("dist mem")

#export dataframes
write.csv(df_clean,"A:/Data_Analysis_Projects/Bike_Sharing/3_Analysis//all_users_2020.csv")
write.csv(df_casuals,"A:/Data_Analysis_Projects/Bike_Sharing/3_Analysis//casuals_2020.csv")
write.csv(df_members,"A:/Data_Analysis_Projects/Bike_Sharing/3_Analysis//members_2020.csv")



