# installed package
install.packages(c("sf", "tidyverse"))
library(sf)
library(tidyverse)

# read the shp file and transfer to dataframe
data_shp <- st_read("./PTV_METRO_TRAM_STOP.shp")
data <- as.data.frame(data_shp)
# clean the dataset by seperating the tram route in one tram stop
tidy_data <- data %>%
  separate_rows(ROUTEUSSP, sep = ",", convert = TRUE)
head(tidy_data)

st_write(st_as_sf(tidy_data), "CLEANED_PTV_METRO_TRAM_STOP.shp")
