library("dplyr") 
library(tidyverse)
# Global data
api_key <- "XXXXXX"
suburbs <- c(
  "Carlton", "Parkville", "East Melbourne", "West Melbourne", "North Melbourne",
  "Kensington", "Docklands", "South Yarra", "Southbank", "CBD Hoddle Grid", 
  "Fishermans Bend")

data_folder <- file.path(getwd(), 'data_folder')

get_service_in_surburb_data <- function(suburb, service = "restaurant") {
  url <- "https://maps.googleapis.com/maps/api/place/textsearch/json"
  text <- paste(service, " in ", suburb)
  response <- httr::GET(url, query = list(query = text, key = api_key))
  content <- jsonlite::fromJSON(httr::content(response, as = "text"))
  # file_name <- file.path(data_folder, paste0(service, "-", suburb, '.csv'))
  # write_csv(content$results, file_name, quote = TRUE)
  df <- content$results
  # Loop to get and save next page
  next_page_token <- content$next_page_token
  while(!is.null(next_page_token)) {
    Sys.sleep(5)
    next_response <- httr::GET(url, query = list(pagetoken = next_page_token, key = api_key))
    next_content <- jsonlite::fromJSON(httr::content(next_response, as = "text"))
    # browser()
    # write_csv(next_content$results, file_name, append =  TRUE, quote = TRUE)
    df <- bind_rows(df, next_content$results)
    browser()
    next_page_token <- next_content$next_page_token
    print(next_page_token)
  }
  browser()
  message(suburb, " ", service, " is saved successfully.")
}

# for(suburb in suburbs) {
#   get_service_in_surburb_data(suburb = suburb)  
# }
get_service_in_surburb_data(suburb = suburbs[[1]])  
################################################################################
# Get Details #
################################################################################

process_details <- function(detail) {
  for(key in names(detail)) {
    if(is.character(detail[[key]])) {
      detail[[key]] <- toString(detail[[key]])
    }
    if(is.list(detail[[key]])) {
      detail[[key]] <- toString(serialize(detail[[key]], connection = NULL))
    }
  }
  return(detail)
}

get_and_save_details <- function(suburb, service = 'restaurant') {
  suburb_data <- read.csv(paste0('./google-data/', service, '-', suburb, '.csv'))
  url <- "https://maps.googleapis.com/maps/api/place/details/json"
  detail_df <- NULL
  for(pid in suburb_data$place_id) {
    response <- httr::GET(url, query = list(place_id = pid, key = api_key))
    content <- jsonlite::fromJSON(httr::content(response, as = "text"), flatten = TRUE)
    res <- process_details(content$result)
    detail_df <- bind_rows(detail_df, data.frame(res))
  }
  file_name <- file.path(getwd(), "google-data", paste0(service, "-", suburb, "-detail", '.csv'))
  write.table(detail_df, file_name, row.names = FALSE, sep = ",")
}

for(i in 2:length(suburbs)) {
  get_and_save_details(suburbs[[i]])
}

get_and_save_details(suburbs[[11]])


### Combine Data

all_places <- data.frame()
all_details <- data.frame()

place_cols <- c('place_id', 'name', 'formatted_address', 'user_ratings_total', 
                'rating', 'geometry.location.lat', 'geometry.location.lng', 
                'price_level')
detail_cols <- c('place_id', 'delivery', 'dine_in', 'reservable', 'serves_beer', 
                 'serves_breakfast', 'serves_brunch', 'serves_dinner', 
                 'serves_lunch', 'serves_vegetarian_food', 'serves_wine', 
                 'takeout', 'wheelchair_accessible_entrance', 'curbside_pickup')


for(suburb in suburbs) {
  service <- 'restaurant'
  place_file_path <- file.path(getwd(), 'google-data', paste0(service, "-", suburb, '.csv'))
  detail_file_path <- file.path(getwd(), "google-data", paste0(service, "-", suburb, "-detail", '.csv'))
  sub_places <- read_csv(place_file_path) %>% select(place_cols) %>% mutate(across(.fns = as.character))
  sub_places$suburb <- suburb
  sub_details <- read_csv(detail_file_path) %>% select(detail_cols) %>% mutate(across(.fns = as.character))
  all_places <- bind_rows(all_places, sub_places)
  all_details <- bind_rows(all_details, sub_details)
}

all_places <- all_places[!duplicated(all_places$place_id), ]
all_data <- inner_join(all_places, all_details, by ='place_id')
all_data <- all_data[!duplicated(all_data$place_id), ]

# Trip Ad

# all_data <- read_csv(file.path(getwd(), 'google-data', 'all-data.csv'))

trip_key <- 'xxxxxx'

library(httr)

url <- "https://api.content.tripadvisor.com/api/v1/location/search"

trip_location <- data.frame()

for(i in 1:nrow(all_data)) {
  row <- all_data[i, ]
  queryString <- list(
    language = "en",
    key = trip_key,
    searchQuery = row$name,
    category = "restaurant",
    latLong = paste0(row$geometry.location.lat, ",", row$geometry.location.lng)
  )
  response <- VERB("GET", url, query = queryString, content_type("application/octet-stream"), accept("application/json"))
  res <- jsonlite::fromJSON(content(response, "text"), flatten = TRUE)$data
  if(length(res) != 0) {
    res <- res[1, c('location_id', 'name')]
    res$place_id <- all_data[i, ]$place_id
    print(all_data[i, ]$place_id)
    trip_location <- bind_rows(trip_location, res)    
  } else {
    message('No data')
  }
}

# write_csv(trip_location, 'trip_location.csv')
# 
# 
# jsonlite::fromJSON(content(response, "text"))

trip_data_all <- list()
trip_data <- data.frame()
for(i in 1:nrow(trip_location)) {
  url <- paste0("https://api.content.tripadvisor.com/api/v1/location/", trip_location[i, ]$location_id, "/details")
  queryString <- list(
    language = "en",
    currency = "AUD",
    key = trip_key
  )
  response <- VERB("GET", url, query = queryString, content_type("application/octet-stream"), accept("application/json"))
  res <- jsonlite::fromJSON(content(response, "text"))
  trip_data_all[[trip_location[i, ]$location_id]] <- res
  print(res$cuisine)
  trip_data <- bind_rows(trip_data, data.frame(location_id = trip_location[i,]$location_id, 
                                               cuisine = ifelse(length(res$cuisine) == 0, "unknown", res$cuisine$name[[1]])))
}

trip_data_join <- left_join(trip_location, trip_data, by = 'location_id', multiple = "any")

all_data_with_cusine <- left_join(all_data, trip_data_all[, c('place_id', 'cuisine')])

saveRDS(trip_data_all, "trip_data_all.rds")

write_csv(all_data_with_cusine, 'all_with_cuisine.csv')

