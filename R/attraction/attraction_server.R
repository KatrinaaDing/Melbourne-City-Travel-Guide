attractionServer <- function(input, output, session) {

  ################### reactive ##################
  # filter dynamically load data
  attractions_data_map <- reactive({
    poi_data %>%
      filter(category %in% c(input$attraction_selected, input$facility_selected))
  })

  ################### outputs ##################
  # Leaflet map 
  output$attraction_map <- renderLeaflet({
    render_map(attractions_data_map())
  })

}