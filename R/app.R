## app.R ##
library(shiny)
library(shinydashboard)
library(maps)
library(leaflet)
library(sf)
library(tidyverse)
library(shinyjs)
library(shinyWidgets)

source('restaurant.R')

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

# setUpTableauInShiny()

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
    useShinyjs(),
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "custom.css"),
      tags$head(setUpTableauInShiny()[[2]])
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
  
  reactive_res_sum_data <- reactive({
    return(apply_filter_to_data(restaurants, reactive_values$res_suburb, input$res_price_level, input$res_num_review, input$res_special_options))
  })
  
  output$res_total_amount <- renderInfoBox({
    infoBox("Number of Restaurants", reactive_res_sum_data()[1], width = 4, color = "yellow", fill = TRUE, icon = icon("hashtag"))
  })
  
  output$res_best_cuisine <- renderInfoBox({
    infoBox("Most Popular Cuisine", reactive_res_sum_data()[3], width = 4, color = "purple", fill = TRUE, icon = icon("utensils"))  
  })
  
  output$res_best_restaurant <- renderInfoBox({
    infoBox("Best Rated Restaurant", reactive_res_sum_data()[2], width = 4, color = "green", fill = TRUE, icon = icon("house"))  
  })
  
  ################### outputs ##################
  
  # Restaurant
  
  reactive_values <- reactiveValues(res_suburb = 'All', old_special_options = NULL)
  output[[res_suburb_filter_id]] <-  renderLeaflet({render_res_suburb_filter_unselected()})
  
  observeEvent(input[[suburb_filter_click_event]], {
    suburb_filter_shape_click_info <- input[[suburb_filter_shape_click_event]]
    suburb_filter_click_info <- input[[suburb_filter_click_event]]
    if(all(unlist(suburb_filter_shape_click_info[c('lat', 'lng')]) == unlist(suburb_filter_click_info[c('lat', 'lng')]))) {
      render_res_suburb_filter_selected(suburb_filter_shape_click_info$id)
      reactive_values$res_suburb <- suburb_filter_shape_click_info$id
      update_tableau_charts('suburb', suburb_filter_shape_click_info$id)
    } else {
      render_res_suburb_filter_selected(NULL)
      reactive_values$res_suburb <- 'All'
      update_tableau_charts('suburb', 'All')
    }
  })
  
  observeEvent(input$res_price_level, {
    update_tableau_charts('price_level', input$res_price_level)
  }, ignoreInit = TRUE)

  observeEvent(input$res_num_review, {
    update_tableau_charts('num_review', input$res_num_review)
  }, ignoreInit = TRUE)
  
  observeEvent(input$res_special_options, {
    if(length(input$res_special_options) > length(reactive_values$old_special_options)) {
      update_tableau_charts('special_options', setdiff(input$res_special_options, reactive_values$old_special_options), "add")
    } else {
      update_tableau_charts('special_options', setdiff(reactive_values$old_special_options, input$res_special_options), "remove")
    }
    reactive_values$old_special_options <- isolate(input$res_special_options)
  },ignoreNULL = FALSE, ignoreInit = TRUE)

  # output$hotel_map <- renderLeaflet({
  #   leaflet(test[test$LOC_NAME == "West Melbourne", ]) %>%
  #     addProviderTiles(providers$CartoDB.Positron) %>%
  #     addPolygons(
  #       fillColor = "transparent",
  #       weight = 2,
  #       color = "#000000",
  #       fillOpacity = 0.5
  #     ) %>%
  #     addCircleMarkers(
  #       data = getFilteredHotels(),
  #       clusterOptions = markerClusterOptions(maxClusterRadius = 80),
  #       popup = ~ paste0(
  #         # listing name, can navigate to Airbnb listing site
  #         "Name: <a href='https://www.airbnb.com.au/rooms/",
  #         hotels$id, "'><strong>", hotels$name, "</strong></a><br>",
  #         # host name, can navigate to host site
  #         "Host:  <a href='https://www.airbnb.com.au/users/show/",
  #         hotels$host_id, "'><strong>", hotels$host_name, "</strong></a><br>",
  #         "Price: <strong>$", hotels$price, "/night</strong><br>",
  #         "Minimum nights: <strong>", hotels$minimum_nights, "</strong><br>",
  #         "Rating: <strong>", hotels$rating, "</strong><br>",
  #         "Last Review: <strong>", hotels$last_review, "</strong><br>"
  #       ),
  #       label = ~ paste(hotels$name),
  #       labelOptions = labelOptions(direction = "top")
  #     )
  # # })

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
