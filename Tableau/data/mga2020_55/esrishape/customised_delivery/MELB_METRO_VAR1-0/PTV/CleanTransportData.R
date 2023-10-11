# installed package
install.packages(c("sf", "tidyverse"))
library(sf)
library(tidyverse)

# read the shp file and transfer to dataframe
data_shp <- st_read("/Users/KOBE/Desktop/ALL/master/Information Visualizaion/ASS3/Melbourne-City-Travel-Guide/Tableau/data/Order_21E6VV/mga2020_55/esrishape/customised_delivery/MELB_METRO_VAR1-0/PTV/PTV_METRO_TRAM_STOP.shp")
data <- as.data.frame(data_shp)

# clean the dataset by seperating the 
tidy_data <- data %>%
  separate_rows(ROUTEUSSP, sep = ",", convert = TRUE)
head(tidy_data)

st_write(st_as_sf(tidy_data), "/Users/KOBE/Desktop/ALL/master/Information Visualizaion/ASS3/Melbourne-City-Travel-Guide/Tableau/data/Order_21E6VV/mga2020_55/esrishape/customised_delivery/MELB_METRO_VAR1-0/PTV/CLEANED_PTV_METRO_TRAM_STOP.shp")
