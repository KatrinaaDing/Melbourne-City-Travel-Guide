box_height <- 650

attraction_tab <- tabItem(
  tabName = "attraction",
  tags$head(
    tags$script(HTML("
      $(document).on('click', '#viewNearbyPoiButton', function() {
        let random_id = this.value + '-' + Math.random();
        Shiny.setInputValue('view_nearby_poi_id', random_id);
      })   
      $(document).on('click', '#tramStopToPoiButton', function() {
        let random_id = this.value + '-' + Math.random();
        Shiny.setInputValue('stop_nearby_poi_id', random_id);
      })    
    "))
  ),
  h4("Attraction"),
  fluidRow(
    box(
      width = 8,
      title = "Distribution of Attractions and Facilities",
      leafletOutput("attraction_map", height = "calc(100vh - 220px)")
    ),
    fluidRow(
      box(
        width = 4,
        title = "Filter",
        status = "primary",
        solidHeader = TRUE,
        collapsible = TRUE,
        actionButton("clear_attraction_radius", "Clear Circle Bounds", class = "btn btn-danger"),
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
        style =
          "
            height: calc(100vh - 540px);
            max-height: 400px;
            overflow-y: scroll;
          ",
      ),
      box(
        width = 4,
        title = "Popularity",
        status = "primary",
        solidHeader = TRUE,
        collapsible = TRUE,
        style = "height: 270px",
        tableauPublicViz(
          id = "attraction_ped_chart",
          url = "https://public.tableau.com/views/attraction_ped_count/FacilitiesPedestrainCount?:language=en-US&publish=yes&:display_count=n&:origin=viz_share_link",
          height = paste0(250, "px")
        )
      )
    )

  )
)