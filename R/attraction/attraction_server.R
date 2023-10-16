attractionServer <- function(input, output, session) {

  ################### reactive ##################
  # filter dynamically load data
  poi_data_map <- reactive({
    attractions %>%
      filter(category %in% input$attraction_selected)
  })

  ################### outputs ##################
  # Leaflet map 
  output$attraction_map <- renderLeaflet({

    # landmarks_content <- paste0(
    #   "<b> selected: </b>",
    #   poi_data_map()$category,
    #   "<br>",
    #   "<b> Name: </b>",
    #   poi_data_map()$name,
    #   "<br>",
    #   "<b> Theme: </b>",
    #   poi_data_map()$theme)
    # content <- paste(sep = "<br/>",
    #   "<b><a href='http://www.samurainoodle.com'>Samurai Noodle</a></b>",
    #   "606 5th Ave. S",
    #   "Seattle, WA 98138"
    # )

    leaflet(poi_data_map()) %>% 
      addProviderTiles(providers$CartoDB.PositronNoLabels) %>%
      addPolygons(
        data = city_boundary,
        fillColor = "transparent",
        weight = 2,
        color = "#000000",
        fillOpacity = 0.5,
      ) %>%
      addMarkers(
        ~longitude, ~latitude,
        clusterOptions = markerClusterOptions(),
        icon = ~ attraction_icons[poi_data_map()$category],
        # popup = ~ content
      )
  })

}