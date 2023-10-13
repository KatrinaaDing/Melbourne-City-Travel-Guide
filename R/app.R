# libraries
source("libraries.R")
# constants and data
source("constants_and_data.R")
# ui and server
# restaurant tab
source("restaurant/restaurant_ui.R")
source("restaurant/restaurant_server.R")
# hotel tab
source("hotel/hotel_ui.R")
source("hotel/hotel_server.R")
# attraction tab
source("attraction/attraction_ui.R")
source("attraction/attraction_server.R")
# transport tab
source("transport/transport_ui.R")
source("transport/transport_server.R")

# common references
# icons: https://fontawesome.com/v4/icons/
# dashboard layout: http://rstudio.github.io/shinydashboard/structure.html

##################
# USER INTERFACE #
##################

intro_tab <- tabItem(
  tabName = "intro",
  h1("Introduction"),
  actionButton("explore_restaurant", "Explore Restaurant ->", class = "btn btn-primary"),
  actionButton("explor_airbnb", "Explore Airbnb ->", class = "btn btn-primary"),
  actionButton("explore_attraction", "Explore Attraction ->", class = "btn btn-primary"),
  actionButton("explore_transport", "Explore Transport ->", class = "btn btn-primary"),
  actionButton("explore_data_source", "View Data Source ->", class = "btn btn-primary"),
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
      id = "tabs",
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
    useShinyjs(),
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "css/custom.css"),
      # bootstrap theme reference: https://bootswatch.com/3/
      tags$link(rel = "stylesheet", type = "text/css", href = "https://bootswatch.com/3/readable/bootstrap.min.css"),
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
  # Navigation from introduction tab to other tabs
  # reference: https://www.rdocumentation.org/packages/shinydashboard/versions/0.7.2/topics/updateTabItems
  observeEvent(input$explore_restaurant, {
    updateTabItems(session, "tabs", "restaurant")
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
  
  # start explore button at airbnb page
  observeEvent(input$explor_airbnb, {
    updateTabItems(session, "tabs", "airbnb")
  })
  # start explore button at attraction page
  observeEvent(input$explore_attraction, {
    updateTabItems(session, "tabs", "attraction")
  })
  # start explore button at transport page
  observeEvent(input$explore_transport, {
    updateTabItems(session, "tabs", "transport")
  })
  # start explore button at data source page
  observeEvent(input$explore_data_source, {
    updateTabItems(session, "tabs", "data_source")
  })

  # servers
  hotelServer(input, output, session)
  restaurantServer(input, output, session)
  attractionServer(input, output, session)
  transportServer(input, output, session)
}

# Run the application
shinyApp(ui, server)
