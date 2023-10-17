###################
# CONSTANT VALUES #
###################

SIDEBAR_WIDTH <- 260
ICON_SIZE <- 20
DEFAULT_NA_HINT <- "NA"
CITY_SUBURBS <- c(
  "Carlton", "Carlton North - Princes Hill", "Docklands", "East Melbourne", "Kensington (Vic.)",
  "Melbourne", "North Melbourne", "Parkville", "Southbank", "South Yarra - West", "West Melbourne",
  "Flemington Racecourse", "Port Melbourne Industrial"
)

##############
# HOTEL DATA #
##############

### Hotels (Airbnb) - Import data
city_boundary <- st_read("data/geographic/municipal-boundary.geojson")
hotels <- read.csv("data/airbnb/listings-clean.csv")

### get melbourne suburb boundaries
# reference: https://rdrr.io/cran/geojsonsf/man/geo_melbourne.html
melbourne_surburbs_data <- geo_melbourne
# Convert to sf object and Filter for specific suburbs
melbourne_surburbs_sf <- geojson_sf(melbourne_surburbs_data)
suburb_boundaries <- melbourne_surburbs_sf[melbourne_surburbs_sf$SA2_NAME %in% CITY_SUBURBS, ]
suburb_boundaries <- st_make_valid(suburb_boundaries)
# only keep the suburb polygon that are within the city boundary
# reference: https://stackoverflow.com/questions/62442150/why-use-st-intersection-rather-than-st-intersects
suburb_boundaries <- st_intersection(suburb_boundaries, city_boundary)
# filter data with city boundary
# reference: https://r-spatial.github.io/sf/reference/geos_binary_pred.html
hotels_sf <- st_as_sf(hotels, coords = c("longitude", "latitude"), crs = 4326)
hotels <- hotels_sf[st_within(hotels_sf, city_boundary, sparse = FALSE), ]
hotels <- na.omit(hotels)
# remove those with price 0
hotels <- hotels[hotels$price != 0, ]

### add suburb to each airbnb listing
# Initialize a column to store suburb names
hotels$suburb <- NA
# Loop through each suburb
# reference: https://www.w3schools.com/r/r_for_loop.asp
for (i in 1:nrow(suburb_boundaries)) {
  single_suburb <- suburb_boundaries[i, ]
  # Find hotels within the single suburb
  # reference: https://cran.r-project.org/web/packages/sf/vignettes/sf3.html
  hotels_in_suburb <- st_intersects(hotels, single_suburb, sparse = FALSE)
  # Update suburb column for those hotels
  hotels$suburb[which(hotels_in_suburb)] <- as.character(single_suburb$SA2_NAME)
}
# To ensure no NA values are present after the loop
hotels <- na.omit(hotels)

### calculate price quantiles
# reference: https://www.rdocumentation.org/packages/stats/versions/3.6.2/topics/quantile
quantiles <- quantile(hotels$price, probs = c(0.33, 0.66), na.rm = TRUE)
cheap_threshold <- as.numeric(quantiles[1])
medium_threshold <- as.numeric(quantiles[2])

### add icon type based on interval of happiness score
# reference: https://www.statology.org/cut-function-in-r/
hotels$price_class <- cut(hotels$price,
  breaks = c(-Inf, cheap_threshold, medium_threshold, Inf),
  labels = c("cheap", "medium", "expensive"),
  right = FALSE
)
# Extracting longitude and latitude
hotels$Longitude <- sapply(strsplit(gsub("c\\(|\\)", "", hotels$geometry), ","), function(x) as.numeric(x[1]))
hotels$Latitude <- sapply(strsplit(gsub("c\\(|\\)", "", hotels$geometry), ","), function(x) as.numeric(x[2]))

# Removing the original geometry column
hotels$geometry <- NULL

# write the data for tableau
# write.csv(hotels, "data/hotels_with_suburb.csv", row.names = FALSE)


# calculate some statistics
min_hotel_price <- min(hotels$price, na.rm = TRUE)
max_hotel_price <- max(hotels$price, na.rm = TRUE)
min_min_nights <- min(hotels$minimum_nights, na.rm = TRUE)
max_min_nights <- max(hotels$minimum_nights, na.rm = TRUE)

###################
# RESTAURANT DATA #
###################

# Restaurant - Import Data
restaurants <- read_csv("data/restaurant/melbourne_restaurants.csv")
suburb_boundary <- st_read("data/restaurant/suburbs_data.geojson")


#########
# ICONS #
#########

# create icons
# reference: https://stackoverflow.com/questions/61512228/leaflet-in-r-how-to-generate-multiple-icons
dollar_icons <- iconList(
  cheap = makeIcon("www/icons/cheap.svg", "www/icons/cheap.svg", ICON_SIZE, ICON_SIZE),
  medium = makeIcon("www/icons/medium-price.svg", "www/icons/medium-price.svg", ICON_SIZE, ICON_SIZE),
  expensive = makeIcon("www/icons/expensive.svg", "www/icons/expensive.svg", ICON_SIZE, ICON_SIZE)
)

