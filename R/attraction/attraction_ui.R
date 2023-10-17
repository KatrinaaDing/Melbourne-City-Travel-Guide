attraction_tab <- tabItem(
  tabName = "attraction",

  h4("Attraction"),
  column(
    width = 8,
    div(
      width = 12,
      title = "Attraction Listings in Melbourne City",
      # The id lets us use input$tabset1 on the server to find the current tab
      id = "attraction_statistics_tabset",
      # tabPanel(
      #   "Chart",
      #   "Tab content 2"
      # ),
      tabPanel(
        "Map",
        leafletOutput("attraction_map", height = "calc(100vh - 240px)"), # 330
      )
    )
  ),
  column(
    width = 4,
    div(
      style = "display: flex; flex-direction: column; align-items: center; padding-left: 10px;",
      valueBoxOutput("total_attractions_num", width = 12),
      fluidRow(
        width = 12,
        valueBoxOutput("average_attractions_rating", width = 6),
        valueBoxOutput("average_attractions_price", width = 6),
      ),
      box(
        width = 12,
        style = "height: calc(100vh - 415px); overflow-y: scroll;",
        title = "Filter",
        status = "primary",
        solidHeader = TRUE,
        checkboxGroupInput(
          "attraction_selected", "Attractions:",
          choiceNames = POI_CHOICE_NAMES,
          choiceValues = POI_CHOICE_VALUES,
          selected = POI_CHOICE_VALUES,
        ),
        checkboxGroupInput(
          "facility_selected", "Facilities:",
          choiceNames = FACILITY_CHOICE_NAMES,
          choiceValues = FACILITY_CHOICE_VALUES,
          selected = FACILITY_CHOICE_VALUES,
        )
      ),
    )
  )
)