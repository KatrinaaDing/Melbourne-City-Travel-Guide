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

########
# DATA #
########

### Import data
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

# calculate some statistics
min_hotel_price <- min(hotels$price, na.rm = TRUE)
max_hotel_price <- max(hotels$price, na.rm = TRUE)
min_min_nights <- min(hotels$minimum_nights, na.rm = TRUE)
max_min_nights <- max(hotels$minimum_nights, na.rm = TRUE)


# Restaurant - Import Data
restaurants <- read_csv("data/restaurant/melbourne_restaurants.csv")
suburb_boundary <- st_read("data/restaurant/suburbs_data.geojson")


# Attractions - Import Data
attraction_landmarks <- read_csv("data/poi/poi-landmarks-clean.csv")
attraction_artworks <- read_csv("data/poi/poi-artworks-clean.csv")
attraction_memorials <- read_csv("data/poi/poi-memorials-and-sculptures-clean.csv")
attraction_music <- read_csv("data/poi/poi-music-venues-clean.csv")
attraction_plaques <- read_csv("data/poi/poi-plaques-clean.csv")

attractions <- read_csv("data/poi/poi-clean.csv")
facilities <- read_csv("data/poi/facility-clean.csv")


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

# attraction icons
attraction_icons <- iconList(
  artworks = makeIcon("www/icons/artwork.svg", "www/icons/artwork.svg", ICON_SIZE, ICON_SIZE),
  music_venues = makeIcon("www/icons/music.svg", "www/icons/music.svg", ICON_SIZE, ICON_SIZE),
  plaques = makeIcon("www/icons/plaque.svg", "www/icons/plaque.svg", ICON_SIZE, ICON_SIZE),
  memorials = makeIcon("www/icons/memorial.svg", "www/icons/memorial.svg", ICON_SIZE, ICON_SIZE),
  landmarks =  makeIcon("www/icons/landmark.svg", "www/icons/landmark.svg", ICON_SIZE, ICON_SIZE),
  drink_fountains = makeIcon("www/icons/drink.svg", "www/icons/drink.svg", ICON_SIZE, ICON_SIZE),
  playgrounds = makeIcon("www/icons/playground.svg", "www/icons/playground.svg", ICON_SIZE, ICON_SIZE),
  toilets = makeIcon("www/icons/toilet.svg", "www/icons/toilet.svg", ICON_SIZE, ICON_SIZE)
)

