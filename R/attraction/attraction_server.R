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
    # Popup contents for different categories
    artworks_content <- paste0(
      "<b> selected: </b>",
      attractions_data_map()$category,
      "<br>",
      "<b> Name: </b>",
      attractions_data_map()$name,
      "<br>",
      "<b> Theme: </b>",
      attractions_data_map()$theme
    )

    music_venues_content <- paste0(
      "<b> selected: </b>",
      attractions_data_map()$category,
      "<br>",
      "<b> Name: </b>",
      attractions_data_map()$name,
      "<br>",
      "<b> Theme: </b>",
      attractions_data_map()$theme
    )

    plaques_content <- paste0(
      "<b> selected: </b>",
      attractions_data_map()$category,
      "<br>",
      "<b> Name: </b>",
      attractions_data_map()$name,
      "<br>",
      "<b> Theme: </b>",
      attractions_data_map()$theme
    )

    memorials_content <- paste0(
      "<b> selected: </b>",
      attractions_data_map()$category,
      "<br>",
      "<b> Name: </b>",
      attractions_data_map()$name,
      "<br>",
      "<b> Theme: </b>",
      attractions_data_map()$theme
    )

    landmarks_content <- paste0(
      "<b> selected: </b>",
      attractions_data_map()$category,
      "<br>",
      "<b> Name: </b>",
      attractions_data_map()$name,
      "<br>",
      "<b> Theme: </b>",
      attractions_data_map()$theme
    )

    drink_fountains_content <- paste0(
      "<b> selected: </b>",
      attractions_data_map()$category,
      "<br>",
      "<b> Name: </b>",
      attractions_data_map()$name,
      "<br>",
      "<b> Theme: </b>",
      attractions_data_map()$theme
    )

    playgrounds_content <- paste0(
      "<b> selected: </b>",
      attractions_data_map()$category,
      "<br>",
      "<b> Name: </b>",
      attractions_data_map()$name,
      "<br>",
      "<b> Theme: </b>",
      attractions_data_map()$theme
    )

    toilets_content <- paste0(
      "<b> selected: </b>",
      attractions_data_map()$category,
      "<br>",
      "<b> Name: </b>",
      attractions_data_map()$name,
      "<br>",
      "<b> Theme: </b>",
      attractions_data_map()$theme
    )

    # Add components to attraction map
    attraction_map <- leaflet(attractions_data_map()) %>% 
      addProviderTiles(providers$CartoDB.PositronNoLabels)

    attraction_map <- addPolygons(
      map=attraction_map,
      data = city_boundary,
      fillColor = "transparent",
      weight = 2,
      color = "#000000",
      fillOpacity = 0.5,
    )

    # Add attraction markers with different categories
    attraction_map <- addMarkers(
      map=attraction_map,
      ~longitude, ~latitude,
      clusterOptions = markerClusterOptions(maxClusterRadius = 50),
      icon = ~ attraction_icons[attractions_data_map()$category],
      popup = artworks_content,
    )

    attraction_map <- addMarkers(
      map=attraction_map,
      ~longitude, ~latitude,
      clusterOptions = markerClusterOptions(maxClusterRadius = 50),
      icon = ~ attraction_icons[attractions_data_map()$category],
      popup = music_venues_content,
    )

    attraction_map <- addMarkers(
      map=attraction_map,
      ~longitude, ~latitude,
      clusterOptions = markerClusterOptions(maxClusterRadius = 50),
      icon = ~ attraction_icons[attractions_data_map()$category],
      popup = plaques_content,
    )

    attraction_map <- addMarkers(
      map=attraction_map,
      ~longitude, ~latitude,
      clusterOptions = markerClusterOptions(maxClusterRadius = 50),
      icon = ~ attraction_icons[attractions_data_map()$category],
      popup = memorials_content,
    )

    attraction_map <- addMarkers(
      map=attraction_map,
      ~longitude, ~latitude,
      clusterOptions = markerClusterOptions(maxClusterRadius = 50),
      icon = ~ attraction_icons[attractions_data_map()$category],
      popup = landmarks_content,
    )

    # Add attraction markers with different categories
    attraction_map <- addMarkers(
      map=attraction_map,
      ~longitude, ~latitude,
      clusterOptions = markerClusterOptions(maxClusterRadius = 50),
      icon = ~ attraction_icons[attractions_data_map()$category],
      popup = drink_fountains_content
    )

    attraction_map <- addMarkers(
      map=attraction_map,
      ~longitude, ~latitude,
      clusterOptions = markerClusterOptions(maxClusterRadius = 50),
      icon = ~ attraction_icons[attractions_data_map()$category],
      popup = toilets_content
    )

    attraction_map <- addMarkers(
      map=attraction_map,
      ~longitude, ~latitude,
      clusterOptions = markerClusterOptions(maxClusterRadius = 50),
      icon = ~ attraction_icons[attractions_data_map()$category],
      popup = playgrounds_content
    )
  })

}