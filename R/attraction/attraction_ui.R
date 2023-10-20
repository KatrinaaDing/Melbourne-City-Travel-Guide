box_height <- 650

attraction_tab <- tabItem(
  tabName = "attraction",
  h4("Attraction"),
  fluidRow(
    box(
      width = 9,
      title = "Distribution of Attractions and Facilities",
      height = box_height,
      leafletOutput("attraction_map", height = box_height - 85)
    ),

    fluidRow(
      box(
        width = 3,
        title = "Filter",
        status = "primary",
        solidHeader = TRUE,
        collapsible = TRUE,
        checkboxGroupInput(
          "attraction_selected",
          "Attractions",
          choiceNames = POI_CHOICE_NAMES,
          choiceValues = POI_CHOICE_VALUES,
          selected = POI_CHOICE_VALUES
        ),
        checkboxGroupInput(
          "facility_selected",
          "Facilities",
          choiceNames = FACILITY_CHOICE_NAMES,
          choiceValues = FACILITY_CHOICE_VALUES,
          selected = FACILITY_CHOICE_VALUES,
        ),
        style = "height: calc(100vh - 440px); overflow-y: scroll;",
      ),
      box(
        width = 3,
        title = "Pedestrian Count",
        status = "primary",
        solidHeader = TRUE,
        collapsible = TRUE,
        style = "height: 300px",
        tableauPublicViz(
          id = res_cuisine_chart_id,
          url = "",
          height = paste0(280, "px")
        )
      )
    )

  )
)