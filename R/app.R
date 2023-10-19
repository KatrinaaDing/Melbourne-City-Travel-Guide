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
  h4("Introduction"),
  fluidRow(
    box(width = 6, height = "550px",
        img(src='Melburnian_Skyline.jpg', width = "100%", height = "530px")),
    box(width = 6, height = "550px", 
        h4("Melbourne City Travel Guide"),
        p("The tool provides 4 types of travel guide for tourists of City of Melbourne."),
        h5("Restaurant",actionButton(inputId = "explore_restaurant", label = "Explore >>", class = "btn btn-link")),
        p("For users to look for the the best cuisine and restaurant filtered by suburb, price level, etc."),
        h5("Airbnb", actionButton("explor_airbnb", "Explore >>", class = "btn btn-link")),
        p("For users to have an overview of the distribution of airbnbs filtered by suburb, price, rating, etc."),
        h5("Attraction",  actionButton("explore_attraction", "Explore >>", class = "btn btn-link")),
        p("For user to check the locations of places of interest such as museum, playground, toilet, etc."),
        h5("Transport", actionButton("explore_transport", "Explore >>", class = "btn btn-link")),
        p("To visualize the transport routes of bus and tram."),
        )),
  # actionButton("explore_data_source", "View Data Source ->", class = "btn btn-primary"),
)

data_source_tab <- tabItem(
  tabName = "data_source",
  h4("Data Source"),
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
    tags$head(setUpTableauInShiny()),
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "css/custom.css"),
      # bootstrap theme reference: https://bootswatch.com/3/
      tags$link(rel = "stylesheet", type = "text/css", href = "https://bootswatch.com/3/readable/bootstrap.min.css"),
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
    message(123)
    updateTabItems(session, "tabs", "restaurant")
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
  observeEvent(input$tabs, {
    runjs('dispatchEvent(new Event("resize"))')
  })

  # servers
  hotelServer(input, output, session)
  restaurantServer(input, output, session)
  attractionServer(input, output, session)
  transportServer(input, output, session)
}

# Run the application
shinyApp(ui, server, options = list(launch.browser = TRUE))
