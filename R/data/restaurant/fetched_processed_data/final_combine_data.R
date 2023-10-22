trip_data <- read_rds('trip_data_all.rds')
trip_location <- read_csv('trip_location.csv')

# Combine data from Google Places and Tripadvisor
df <- data.frame()
list <- list(list())
for(key in names(trip_data)) {
  tryCatch(
    {row <- list(location_id = key, 
                rating = ifelse(is.null(trip_data[[key]]$rating), "0.0", as.character(trip_data[[key]]$rating)), 
                num_reviews = ifelse(is.null(trip_data[[key]]$num_reviews), "0", as.character(trip_data[[key]]$num_reviews)), 
                price_level = ifelse(is.null(trip_data[[key]]$price_level), '$$ - $$$', as.character(trip_data[[key]]$price_level)),
                cuisine = ifelse(length(trip_data[[key]]$cuisine) == 0, 'Other', str_to_title(trip_data[[key]]$cuisine$name[1])))
    df <- bind_rows(df,  data.frame(row))
    }, error = function(cond) {
      browser()
    }
  )
}

df$price_level <- unlist(lapply(df$price_level, function(x) {
  if(x == "$$ - $$$") {
    return(3)
  } else if (x == "$$$$") {
    return(4)
  } else if (x == "$$") {
    return(2)
  } else if (x == '$') {
    return(1)
  } else if (x == '$$$') {
    return(3)
  } else {
    stop("not supported")
  }
}))

write_csv(df, "trip_data_selected.csv")

trip_location <- read_csv('trip_location.csv')
trip_location$location_id <- as.character(trip_location$location_id)

trip_data_with_place_id <- left_join(df, trip_location[, c('location_id', 'place_id')], by= 'location_id', multiple = 'any')

google_data <- read_csv('all_data.csv')

google_place_data <- google_data[, c('place_id', 'name', 'suburb')]
google_other_data <- google_data[, c('rating', "delivery", "dine_in", "reservable", "serves_beer", "serves_breakfast", 
                                      "serves_brunch", "serves_dinner", "serves_lunch", "serves_vegetarian_food",
                                      "serves_wine","takeout")]

google_other_data[is.na(google_other_data)] <- FALSE

google_all_data <- cbind(google_place_data, google_other_data)

final_data <- left_join(trip_data_with_place_id, google_all_data, by = 'place_id', multiple = 'any')

write_csv(final_data, 'final_data_for_tableau.csv')

api_key <- "xxxxx"

final_data <- read_csv('final_data_for_tableau.csv')
url <- "https://maps.googleapis.com/maps/api/place/details/json"
detail_list <- list()
for(pid in final_data$place_id) {
  response <- httr::GET(url, query = list(place_id = pid, key = api_key))
  content <- jsonlite::fromJSON(httr::content(response, as = "text"), flatten = TRUE)
  detail_list[[pid]] <- content$result
}
write_rds(detail_list, 'detail_list.rds')

detail_list <- read_rds('detail_list.rds')

rating_google <- c()
for(key in names(detail_list)) {
  rating_google <- append(rating_google, ifelse(is.null(detail_list[[key]]$rating), 0, detail_list[[key]]$rating))
}

final_data$rating_trip <- final_data$rating
final_data$rating <- rating_google

