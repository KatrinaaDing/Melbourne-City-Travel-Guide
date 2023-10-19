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
      "<b> Attraction Category: </b>",
      attractions_data_map()$category,
      "<br>",
      "<b> Name: </b>",
      attractions_data_map()$name,
      "<br>",
      "<b> Classification: </b>",
      attractions_data_map()$classification,
      "<br>",
      "<b> Organisation: </b>",
      attractions_data_map()$organisation,
      "<br>",
      "<b> Created Date: </b>",
      attractions_data_map()$created_date,
      "<br>",
      "<b> Address: </b>",
      attractions_data_map()$address
    )

    music_venues_content <- paste0(
      "<b> Attraction Category: </b>",
      attractions_data_map()$category,
      "<br>",
      "<b> Name: </b>",
      attractions_data_map()$name,
      "<br>",
      "<b> Type: </b>",
      attractions_data_map()$type,
      "<br>",
      "<b> Website: </b>",
      "<a>",
      attractions_data_map()$website,
      "</a>"
    )

    plaques_content <- paste0(
      "<b> Attraction Category: </b>",
      attractions_data_map()$category,
      "<br>",
      "<b> Tree Common Name: </b>",
      attractions_data_map()$tree_common_name,
      "<br>",
      "<b> Tree Scientific Name: </b>",
      attractions_data_map()$tree_scientific_name,
      "<br>",
      "<b> Planted Date: </b>",
      attractions_data_map()$date_of_tree_planted,
      "<br>",
      "<b> Info: </b>",
      attractions_data_map()$title
    )

    memorials_content <- paste0(
      "<b> Attraction Category: </b>",
      attractions_data_map()$category,
      "<br>",
      "<b> Title: </b>",
      attractions_data_map()$title
    )

    landmarks_content <- paste0(
      "<b> Attraction Category: </b>",
      attractions_data_map()$category,
      "<br>",
      "<b> Name: </b>",
      attractions_data_map()$name,
      "<br>",
      "<b> Theme: </b>",
      attractions_data_map()$theme,
      "<br>",
      "<b> Sub Theme: </b>",
      attractions_data_map()$sub_theme
    )

    drink_fountains_content <- paste0(
      "<b> Facility Category: </b>",
      attractions_data_map()$category,
      "<br>",
      "<b> Type: </b>",
      attractions_data_map()$type,
      "<br>",
      "<b> Info: </b>",
      attractions_data_map()$info
    )

    playgrounds_content <- paste0(
      "<b> Facility Category: </b>",
      attractions_data_map()$category,
      "<br>",
      "<b> Name: </b>",
      attractions_data_map()$name,
      "<br>",
      "<b> Info: </b>",
      attractions_data_map()$info
    )

    toilets_content <- paste0(
      "<b> Facility Category: </b>",
      attractions_data_map()$category,
      "<br>",
      "<b> Type: </b>",
      attractions_data_map()$type,
      "<br>",
      "<b> Operator: </b>",
      attractions_data_map()$operator,
      "<br>",
      "<b> Female: </b>",
      attractions_data_map()$female,
      "<br>",
      "<b> Male: </b>",
      attractions_data_map()$male,
      "<br>",
      "<b> Baby Facility: </b>",
      attractions_data_map()$baby_facil,
      "<br>",
      "<b> Address: </b>",
      "<a>",
      attractions_data_map()$address,
      "</a>"
    )




    # List of popup contents
    popup_contents <- list(
      artworks = artworks_content,
      music_venues = music_venues_content,
      plaques = plaques_content,
      memorials = memorials_content,
      landmarks = landmarks_content,
      drinking_fountains = drink_fountains_content,
      playgrounds = playgrounds_content,
      toilets = toilets_content
    )


    # get_popup_content <- function(category) {
    #   if (category == "")
    #   return(popup_contents$category)
    # }
    # popup_contents["artworks"] <- artworks_content
    # popup_contents["music_venues"] <- music_venues_content
    # popup_contents["plaques"] <- plaques_content
    # popup_contents["memorials"] <- memorials_content
    # popup_contents["landmarks"] <- landmarks_content
    # popup_contents["drinking_fountains"] <- drink_fountains_content
    # popup_contents["playgrounds"] <- plaques_content
    # popup_contents["toilets"] <- toilets_content

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

    attraction_map <- addMarkers(
      map=attraction_map,
      ~longitude, ~latitude,
      clusterOptions = markerClusterOptions(maxClusterRadius = 50),
      icon = ~ attraction_icons[attractions_data_map()$category],
      popup = ~ popup_contents[attractions_data_map()$category]
    )
  })

}