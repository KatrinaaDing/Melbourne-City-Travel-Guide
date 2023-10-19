box_height <- 650

attraction_tab <- tabItem(
  tabName = "attraction",
  h4("Attraction"),
  fluidRow(
    box(
      width = 9,
      title = "Distribution of Attractions and Facilities",
      height = box_height,
      leafletOutput("attraction_map", height = box_height - 65)
    ),      
    box(width = 3,
        title = "Filter",
        status = "primary",
        solidHeader = TRUE,
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
        )
      )
  )
)