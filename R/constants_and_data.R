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

POI_CHOICE_NAMES <- c("Artworks", "Music Venues", "Plaques", "Memorials", "Landmarks")
POI_CHOICE_VALUES <- c("artworks", "music_venues", "plaques", "memorials", "landmarks")
FACILITY_CHOICE_NAMES <- c("Playgrounds", "Toilets", "Drinking Fountains")
FACILITY_CHOICE_VALUES <- c("playgrounds", "toilets", "drinking_fountains")
WALKS_CHOICES <- c(
  "A Walk in the Park",
  "Elegant Enclave",
  "Sports & Entertainment",
  "Melbourne Music Walk",
  "The Cosmopolitan",
  "On the Waterfront",
  "Arcades & Lanes",
  "Secret Gardens"
)
##############
# HOTEL DATA #
##############

### city boundary
city_boundary <- st_read("data/geographic/municipal-boundary.geojson")

### Hotels (Airbnb) - Import data
# hotels <- read.csv("data/airbnb/listings-clean.csv")
hotels <- read.csv("data/airbnb/hotels_with_suburb.csv")
hotel_nearby_tram_stops <- read.csv("data/airbnb/hotels_nearby_stops.csv")
hotel_nearby_buffer <- read.csv("data/airbnb/hotels_nearby_buffer.csv")
# Convert the 'geometry' column  geometry column
hotel_nearby_buffer$geometry <- st_as_sfc(hotel_nearby_buffer$geometry)
hotel_nearby_buffer <- st_as_sf(hotel_nearby_buffer)
hotel_nearby_buffer <- st_set_crs(hotel_nearby_buffer, 28355)
hotel_nearby_buffer <- st_make_valid(hotel_nearby_buffer)

# Reproject hotel_nearby_buffer to match city_boundary's CRS
hotel_nearby_buffer <- st_transform(hotel_nearby_buffer, st_crs(city_boundary))

###  melbourne suburb boundaries
# reference: https://rdrr.io/cran/geojsonsf/man/geo_melbourne.html
melbourne_surburbs_data <- geo_melbourne

# Convert to sf object and Filter for specific suburbs
melbourne_surburbs_sf <- geojson_sf(melbourne_surburbs_data)
suburb_boundaries <- melbourne_surburbs_sf[melbourne_surburbs_sf$SA2_NAME %in% CITY_SUBURBS, ]
suburb_boundaries <- st_make_valid(suburb_boundaries)
# only keep the suburb polygon that are within the city boundary
# reference: https://stackoverflow.com/questions/62442150/why-use-st-intersection-rather-than-st-intersects
suburb_boundaries <- st_intersection(suburb_boundaries, city_boundary)

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

####################
# ATTRACTIONS DATA #
####################

# Attractions - Import Data
attractions <- read_csv("data/poi/poi-clean.csv")
facilities <- read_csv("data/poi/facility-clean.csv")
attr_faci_data <- bind_rows(attractions, facilities)

attr_walks <- geojson_sf("data/poi/self-guided-walks.geojson")

##################
# TRANSPORT DATA #
##################

# tramstop data
tram_stops <- read.csv("../Tableau/Transport/data/tramStop_airbnb_Data.csv")
tram_stops_nearby_airbnb <- read.csv("../Tableau/Transport/data/tramStop_airbnb_Data.csv")

# tramstop buffer data
tram_stops_buffer <- read.csv("../Tableau/Transport/data/tramStop_airbnb_Data.csv")
tram_stops_buffer$near_airbnb_polygon <- st_as_sfc(tram_stops_buffer$near_airbnb_polygon)
tram_stops_buffer <- st_as_sf(tram_stops_buffer)
tram_stops_buffer <- st_set_crs(tram_stops_buffer, 28355)
tram_stops_buffer <- st_make_valid(tram_stops_buffer)

# trams stop point data
tram_stops_point <- read.csv("../Tableau/Transport/data/tramStop_airbnb_Data.csv")
tram_stops_point$geometry <- st_as_sfc(tram_stops_point$geometry)
tram_stops_point <- st_as_sf(tram_stops_point)
tram_stops_point <- st_set_crs(tram_stops_point, 28355)
tram_stops_point <- st_make_valid(tram_stops_point)


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

tram_icon <- makeIcon("www/icons/train-tram-solid.svg", "www/icons/train-tram-solid.svg", ICON_SIZE + 30, ICON_SIZE + 30)

# attraction icons
attraction_icons <- iconList(
  artworks = makeIcon("www/icons/artwork.svg", "www/icons/artwork.svg", ICON_SIZE, ICON_SIZE),
  music_venues = makeIcon("www/icons/music.svg", "www/icons/music.svg", ICON_SIZE, ICON_SIZE),
  plaques = makeIcon("www/icons/plaque.svg", "www/icons/plaque.svg", ICON_SIZE, ICON_SIZE),
  memorials = makeIcon("www/icons/memorial.svg", "www/icons/memorial.svg", ICON_SIZE, ICON_SIZE),
  landmarks =  makeIcon("www/icons/landmark.svg", "www/icons/landmark.svg", ICON_SIZE, ICON_SIZE),
  drinking_fountains = makeIcon("www/icons/drink.svg", "www/icons/drink.svg", ICON_SIZE, ICON_SIZE),
  playgrounds = makeIcon("www/icons/playground.svg", "www/icons/playground.svg", ICON_SIZE, ICON_SIZE),
  toilets = makeIcon("www/icons/toilet.svg", "www/icons/toilet.svg", ICON_SIZE, ICON_SIZE)
)

