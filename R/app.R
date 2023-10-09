## app.R ##
library(shiny)
library(shinydashboard)
library(maps)
library(leaflet)
library(sf)
library(htmlwidgets)
library(shinyWidgets)

# library(shinyjs)

# common references
# icons: https://fontawesome.com/v4/icons/
# dashboard layout: http://rstudio.github.io/shinydashboard/structure.html

###################
# CONSTANT VALUES #
###################

SIDEBAR_WIDTH <- 260
ICON_SIZE <- 20
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

# remove those with price 0
hotels <- hotels[hotels$price != 0, ]

# calculate price quantiles
# reference: https://www.rdocumentation.org/packages/stats/versions/3.6.2/topics/quantile
quantiles <- quantile(hotels$price, probs = c(0.33, 0.66), na.rm = TRUE)
cheap_threshold <- quantiles[1]
medium_threshold <- quantiles[2]

# add icon type based on interval of happiness score
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
      leafletOutput("hotel_map", height = "calc(100vh - 350px)"), #330
    ),
    box(
      style = "height: calc(100vh - 600px); overflow-y: scroll;",
      width = 4,
      title = "Filter",
      status = "primary",
      solidHeader = TRUE,
      collapsible = TRUE,
      sliderInput(
        "hotel_price", "Select price range:",
        min = min_hotel_price, max = max_hotel_price,
        value = c(min_hotel_price, max_hotel_price),
        step = 1
      ),
      pickerInput(
        "price_class_select", "Select price class:",
        choices = c("cheap", "medium", "expensive"),
        selected = c("cheap", "medium", "expensive"),
        multiple = TRUE
      ),
      sliderInput(
        "rating_range", "Select rating range:",
        min = 0, max = 5, value = c(0, 5),
        step = 0.1
      ),
      numericInput(
        "min_nights", "Select minimum nights range:",
        min = min_min_nights, max = max_min_nights,
        value = 1,
        step = 1
      ),
      selectInput(
        "num_bedrooms", "Select number of bedrooms:",
        choices = c("All" = "All", sort(unique(hotels$number_of_bedrooms))),
      ),
      selectInput(
        "num_beds", "Select number of beds:",
        choices = c("All" = "All", sort(unique(hotels$number_of_beds))),
      ),
      selectInput(
        "num_baths", "Select number of baths:",
        choices = c("All" = "All", sort(unique(hotels$number_of_baths))),
      ),
    ),
    tabBox(
      title = "Statistics",
      width = 4,
      height = "250px",
      # The id lets us use input$tabset1 on the server to find the current tab
      id = "hotel_statistics_tabset",
      tabPanel("Neaby",
        HTML(paste0(
          "Transport: There are 4 bus stops nearby. <br>",
          "Restaurant: There are 3 restaurants nearby."
        ))
      ),
      tabPanel("Restaurant", "Tab content 2")
    ),
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
    # useShinyjs(),
    # extendShinyjs("www/js/onRenderAirbnbMap.js", functions = c("onRenderAirbnbMap")),
    # add custom css
    # reference: https://rstudio.github.io/shinydashboard/appearance.html
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "css/custom.css")
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
    # filter price range
    filtered_hotels <- hotels[hotels$price >= input$hotel_price[1] & hotels$price <= input$hotel_price[2], ]
    # filter price class
    filtered_hotels <- filtered_hotels[filtered_hotels$price_class %in% input$price_class_select, ]
    # filter rating range
    filtered_hotels <- filtered_hotels[filtered_hotels$rating >= input$rating_range[1] &
      filtered_hotels$rating <= input$rating_range[2], ]
    # filter minimum nights range
    if (!is.na(input$min_nights) && input$min_nights >= min_min_nights && input$min_nights <= max_min_nights) {
      filtered_hotels <- filtered_hotels[as.numeric(filtered_hotels$minimum_nights) >= input$min_nights, ]
    }
    # filter number of bedrooms
    if (input$num_bedrooms != "All") {
      filtered_hotels <- filtered_hotels[filtered_hotels$number_of_bedrooms == input$num_bedrooms, ]
    }
    # filter number of beds
    if (input$num_beds != "All") {
      filtered_hotels <- filtered_hotels[filtered_hotels$number_of_beds == input$num_beds, ]
    }
    # filter number of baths
    if (input$num_baths != "All") {
      filtered_hotels <- filtered_hotels[filtered_hotels$number_of_baths == input$num_baths, ]
    }
    filtered_hotels
  })
  ################### outputs ##################
  # map
  output$hotel_map <- renderLeaflet({
    filtered_hotels <- getFilteredHotels()
    leaflet_map <- leaflet() %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addPolygons(
        data = city_boundary,
        fillColor = "transparent",
        weight = 2,
        color = "#000000",
        fillOpacity = 0.5
      ) %>%
      addMarkers(
        data = filtered_hotels,
        clusterOptions = markerClusterOptions(maxClusterRadius = 50),
        icon = ~ dollar_icons[price_class],
        options = leaflet::markerOptions(price = filtered_hotels$price),
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
      ) %>% 
      # add legend
      addControl(
        html = paste0(
          "<div style='padding: 5px; background-color: white;'>",
          "<h5>Price Level</h5>",
          "<div style='padding: 5px;'><img src='icons/cheap.svg' width='", ICON_SIZE, "' height='", ICON_SIZE, "' /> Cheap </div>",
          "<div style='padding: 5px;'><img src='icons/medium-price.svg' width='", ICON_SIZE, "' height='", ICON_SIZE, "' /> Medium </div>",
          "<div style='padding: 5px;'><img src='icons/expensive.svg' width='", ICON_SIZE, "' height='", ICON_SIZE, "' /> Expensive </div>",
          "</div>"
        ),
        position = "bottomleft"
      )
    # render custom clustered icons
    # reference: https://stackoverflow.com/questions/33600021/leaflet-for-r-how-to-customize-the-coloring-of-clusters
    # note: custom js code is in www/js/onRenderAirbnb.js
    leaflet_map %>% onRender("
      function(el, x) {
        // data from constant defined earlier
        const CHEAP_THRESHOLD = 124;
        const MEDIUM_THRESHOLD = 180;
        // get average price of markers in a cluster
        const getAvgPrice = (markers) =>
          (markers.reduce((a, b) => a + parseFloat(b.options.price), 0) / markers.length).toFixed(2)
        let map = this;
        map.eachLayer(function (layer) {
          if (layer instanceof L.MarkerClusterGroup) {
            // create cluster icon
            layer.options.iconCreateFunction = function (cluster) {
              const averagePrice = getAvgPrice(cluster.getAllChildMarkers());
              // cluster icon background style (used to be gradient but found that transparent background is better)
              iconHtml = '<div style=\"background: radial-gradient(circle at center, transparent, transparent); width: 40px; height: 40px; border-radius: 50%;\"></div>';
              // icon style
              iconStyle = 'style=\"width: 26px; height: 26px; position: relative; top: -32px; left: 8px;\"';
              if (averagePrice > MEDIUM_THRESHOLD) {
                iconHtml += '<img src=\"icons/expensive.svg\" ' + iconStyle + ' />';
              } else if (averagePrice > CHEAP_THRESHOLD) {
                iconHtml += '<img src=\"icons/medium-price.svg\" ' + iconStyle + ' />';
              } else {
                iconHtml += '<img src=\"icons/cheap.svg\" ' + iconStyle + ' />';
              }
              // cluster label (num of childern markers)
              iconHtml += '<div style=\"position: relative; top: -35px; font-size: 12px; text-align: center; font-weight: 700;\">' + cluster.getAllChildMarkers().length + '</div>';

              return L.divIcon({ html: iconHtml, className: 'my-cluster-icon', iconSize: L.point(40, 40) });
            };
            // create hover popup
            layer.on('clustermouseover', function (a) {
              let cluster = a.layer;
              const averagePrice = getAvgPrice(cluster.getAllChildMarkers());
              let popup = L.popup()
                .setLatLng(cluster.getLatLng())
                .setContent(`Numbers of Airbnb: ${cluster.getChildCount()} <br>Average price: $${averagePrice} per night`)
                .openOn(map);
            });
            layer.on('clustermouseout', function (a) {
              map.closePopup();
            });
          }
        });
      }
    ")
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
