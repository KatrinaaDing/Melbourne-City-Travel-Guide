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
    box(
      width = 6, height = "650px",
      img(src = "Melburnian_Skyline.jpg", width = "100%", height = "630px")
    ),
    box(
      width = 6, height = "650px",
      h3("Melbourne City Travel Guide"),
      p("Welcome to Melbourne, a city full of tasty food, cool places, and fun things to do! Our app is here to help you discover the best of Melbourne. Here's what we have:"),
      br(),
      strong("Attractions", actionButton("explore_attraction", "Explore >>", class = "btn btn-link")),
      p("There's so much to see in Melbourne! Find cool stuff like Artworks, Music Venues, and historic Plaques here. We also list fun places like Playgrounds and important spots like Toilets and Drinking Fountains. "),
      strong("Restaurants", actionButton(inputId = "explore_restaurant", label = "Explore >>", class = "btn btn-link")),
      p("Hungry? Check out our 'Restaurant' tab. It has a map showing where you can find different kinds of food in Melbourne. Plus, we list the best-rated places to eat. "),
      strong("Airbnb Listings", actionButton("explor_airbnb", "Explore >>", class = "btn btn-link")),
      p("Need a place to stay? We've got info on Airbnb places all over the city. With our map and charts, you can easily find a comfy spot."),
      strong("Transport", actionButton("explore_transport", "Explore >>", class = "btn btn-link")),
      p("Want to get around Melbourne? Learn about the city's tram routes and where the tram stops are."),
      br(),
      p("Hope you enjoy your time in Melbourne and our app helps you along the way! Safe travels!")
    )
  ),

  # actionButton("explore_data_source", "View Data Source ->", class = "btn btn-primary"),
)

data_source_tab <- tabItem(
  tabName = "data_source",
  h4("Data Source"),
  box(
    width = 12,
    p("This page details the trusted sources behind our data, ensuring accurate and timely insights.Download the data from the links below."),
    h5("Restaurants"),
    tags$ul(
      tags$li("Google Place API ", a("https://developers.google.com/maps/documentation/places/web-service/overview")),
      tags$li("Tripadvisor API ", a("https://www.tripadvisor.com/developers")),
    ),
    h5("Airbnb Listings"),
    tags$ul(
      tags$li("Melbourne Airbnb listings ", a("http://insideairbnb.com/get-the-data/"))
    ),
    h5("Attractions"),
    tags$ul(
      tags$li("Artworks ", a("https://data.melbourne.vic.gov.au/explore/dataset/outdoor-artworks/information/")),
      tags$li("Places of Interest ", a("https://data.melbourne.vic.gov.au/explore/dataset/landmarks-and-places-of-interest-including-schools-theatres-health-services-spor/information/")),
      tags$li("Fountain, Art, Monument ", a("https://data.melbourne.vic.gov.au/explore/dataset/public-artworks-fountains-and-monuments/information/")),
      tags$li("Memorials and Sculptures ", a("https://data.melbourne.vic.gov.au/explore/dataset/public-memorials-and-sculptures/information/")),
      tags$li("Plaques ", a("https://data.melbourne.vic.gov.au/explore/dataset/plaques-located-at-the-shrine-of-remembrance/information/")),
      tags$li("Music Venues ", a("https://data.melbourne.vic.gov.au/explore/dataset/live-music-venues/information/")),
      tags$li("Drinking fountains ", a("https://data.melbourne.vic.gov.au/explore/dataset/drinking-fountains/information/")),
      tags$li("Public toilets ", a("https://data.melbourne.vic.gov.au/explore/dataset/public-toilets/information/")),
      tags$li("Playgrounds ", a("https://data.melbourne.vic.gov.au/explore/dataset/playgrounds/information/")),
      tags$li("Guided Walks ", a("https://data.melbourne.vic.gov.au/explore/dataset/self-guided-walks/information/"))
    ),
    h5("Transport"),
    tags$ul(
      tags$li("Pedestrian Counting System per Hour ", a("https://www.pedestrian.melbourne.vic.gov.au/#date=20-10-2023&time=14")),
      tags$li("Pedestrian Counting System Sensor Location ", a("https://data.melbourne.vic.gov.au/explore/dataset/pedestrian-counting-system-sensor-locations/information/")),
      tags$li("Tram Stop ", a("https://discover.data.vic.gov.au/dataset/ptv-metro-tram-stops")),
      tags$li("Tram Route ", a("https://discover.data.vic.gov.au/dataset/ptv-metro-tram-routes"))
    )
  ),
  h4("About Us"),
  box(
    width = 12,
    p("This app is developed by a group of students from the University of Melbourne. Last updated: 22 Oct 2023."),
    p("Group members: Shiyi Xie, Xubin Zou, Yiyun Mao, Ziqi Ding")
  )
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
      menuItem("Attractions", tabName = "attraction", icon = icon("map-marker")),
      menuItem("Restaurants", tabName = "restaurant", icon = icon("cutlery")),
      menuItem("Airbnb Listings", tabName = "airbnb", icon = icon("bed")),
      menuItem("Transport", tabName = "transport", icon = icon("bus")),
      menuItem("Data Source", tabName = "data_source", icon = icon("database"))
    )
  ),
  dashboardBody(
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
      attraction_tab,
      restaurant_tab,
      hotel_tab,
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

  # resize tableau
  observeEvent(input$hotel_statistics_tabset, {
    runjs('dispatchEvent(new Event("resize"))')
  })

  # resize map view
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
