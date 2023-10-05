## app.R ##
library(shiny)
library(shinydashboard)
library(maps)
library(leaflet)
library(sf)

# common references
# icons: https://fontawesome.com/v4/icons/
# dashboard layout: http://rstudio.github.io/shinydashboard/structure.html

###################
# CONSTANT VALUES #
###################

SIDEBAR_WIDTH <- 260
DEFAULT_NA_HINT <- "NA"

########
# DATA #
########

### Import data
city_boundary <- st_read("data/geographic/municipal-boundary.geojson")
hotels <- read.csv("data/airbnb/listings-clean.csv")

# filter data with city boundary
# reference: https://r-spatial.github.io/sf/reference/geos_binary_pred.html
hotels_sf <- st_as_sf(hotels, coords = c("longitude", "latitude"), crs = 4326)
hotels <- hotels_sf[st_within(hotels_sf, city_boundary, sparse = FALSE), ]

##################
# USER INTERFACE #
##################

intro_tab <- tabItem(
  tabName = "intro",
  h1("Introduction"),
)

restaurant_tab <- tabItem(
  tabName = "restaurant",
  h1("Restaurant"),
)

hotel_tab <- tabItem(
  tabName = "airbnb",
  h1("Airbnb"),
  fluidRow(
    valueBoxOutput("total_hotels_num", width = 4),
    valueBoxOutput("average_hotels_rating", width = 4),
    valueBoxOutput("average_hotels_price", width = 4),
  ),
  fluidRow(
    # map box
    box(
      width = 8,
      title = "Airbnb Listings in Melbourne City",
      status = "primary",
      solidHeader = TRUE,
      leafletOutput("hotel_map", height = "calc(100vh - 350px)")
    ),
    # TODO: add filter controls here
    box(
      width = 4,
      title = "Filter",
      solidHeader = TRUE,
      HTML(paste0(
        "TODO <br>",
        "select suburb <br>",
        "select price range <br>",
        "select rating range <br>",
        "select minimum nights <br>",
        "select range of number of bedrooms <br>",
        "select range of number of beds <br>",
        "select range of number of bathrooms <br>"
      ))
    )
  )
)

attraction_tab <- tabItem(
  tabName = "attraction",
  h1("Attraction"),
)

transport_tab <- tabItem(
  tabName = "transport",
  h1("Transport"),
)

data_source_tab <- tabItem(
  tabName = "data_source",
  h1("Data Source"),
)

# create a shiny dashboard
# reference: http://rstudio.github.io/shinydashboard/get_started.html
ui <- dashboardPage(
  dashboardHeader(
    title = "Melbourne City Travel Guide",
    titleWidth = SIDEBAR_WIDTH
  ),
  dashboardSidebar(
    width = SIDEBAR_WIDTH,
    sidebarMenu(
      menuItem("Introduction", tabName = "intro", icon = icon("info-circle")),
      menuItem("Restaurant", tabName = "restaurant", icon = icon("cutlery")),
      menuItem("Airbnb", tabName = "airbnb", icon = icon("bed")),
      menuItem("Attraction", tabName = "attraction", icon = icon("map-marker")),
      menuItem("Transport", tabName = "transport", icon = icon("bus")),
      menuItem("Data Source", tabName = "data_source", icon = icon("database"))
    )
  ),
  dashboardBody(
    # add custom css
    # reference: https://rstudio.github.io/shinydashboard/appearance.html
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
    ),
    tabItems(
      intro_tab,
      restaurant_tab,
      hotel_tab,
      attraction_tab,
      transport_tab,
      data_source_tab
    )
  )
)

################
# SHINY SERVER #
################

server <- function(input, output, session) {
  ############# reactive functions #############
  getFilteredHotels <- reactive({
    # TODO: filter hotels data here
    hotels
  })
  ################### outputs ##################
  # map
  output$hotel_map <- renderLeaflet({
    leaflet(city_boundary) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addPolygons(
        fillColor = "transparent",
        weight = 2,
        color = "#000000",
        fillOpacity = 0.5
      ) %>%
      addCircleMarkers(
        data = getFilteredHotels(),
        clusterOptions = markerClusterOptions(maxClusterRadius = 80),
        popup = ~ paste0(
          # listing name, can navigate to Airbnb listing site
          "Name: <a href='https://www.airbnb.com.au/rooms/",
          hotels$id, "'><strong>", hotels$name, "</strong></a><br>",
          # host name, can navigate to host site
          "Host:  <a href='https://www.airbnb.com.au/users/show/",
          hotels$host_id, "'><strong>", hotels$host_name, "</strong></a><br>",
          "Price: <strong>$", hotels$price, "/night</strong><br>",
          "Minimum nights: <strong>", hotels$minimum_nights, "</strong><br>",
          "Rating: <strong>", hotels$rating, "</strong><br>",
          "Last Review: <strong>", hotels$last_review, "</strong><br>"
        ),
        label = ~ paste(hotels$name),
        labelOptions = labelOptions(direction = "top")
      )
  })

  ################### value boxes ##################

  # value box that render total number of hotels
  output$total_hotels_num <- renderValueBox({
    valueBox(
      nrow(getFilteredHotels()),
      "Total Number of Listings",
      icon = icon("bed"),
      color = "light-blue"
    )
  })

  # value box that render average rating of hotels
  output$average_hotels_rating <- renderValueBox({
    avg_rating <- mean(getFilteredHotels()$rating, na.rm = TRUE)
    avg_rating <- format(round(avg_rating, 3))
    valueBox(
      ifelse(is.na(avg_rating), DEFAULT_NA_HINT, avg_rating),
      "Average Rating",
      width = 3,
      icon = icon("thumbs-up"),
      color = "yellow"
    )
  })

  # value box that render average price of hotels
  output$average_hotels_price <- renderValueBox({
    avg_price <- mean(getFilteredHotels()$price, na.rm = TRUE)
    avg_price <- format(round(avg_price, 2))
    valueBox(
      ifelse(is.na(avg_price), DEFAULT_NA_HINT, paste0("$", avg_price)),
      "Average Price per Night",
      width = 3,
      icon = icon("dollar"),
      color = "green"
    )
  })
}

# Run the application
shinyApp(ui, server)
