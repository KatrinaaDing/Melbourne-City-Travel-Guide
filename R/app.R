## app.R ##
library(shiny)
library(shinydashboard)

###################
# CONSTANT VALUES #
###################

SIDEBAR_WIDTH <- 260

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
  tabName = "hotel",
  h1("Hotel"),
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
      menuItem("Hotel", tabName = "hotel", icon = icon("bed")),
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

server <- function(input, output) { }

# Run the application
shinyApp(ui, server)