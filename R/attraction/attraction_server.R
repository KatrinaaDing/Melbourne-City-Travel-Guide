render_map <- function(filtered_data) {
  map <- leaflet() %>% 
         addProviderTiles(providers$CartoDB.PositronNoLabels) %>%
         addPolygons(
          data = city_boundary,
          fillColor = "transparent",
          weight = 2,
          color = "#000000",
          fillOpacity = 0.5)
  
  if(nrow(filtered_data) != 0) {
    map <- map %>%
      addMarkers(
        data = filtered_data,
        lng = ~ longitude,
        lat = ~ latitude,
        clusterOptions = markerClusterOptions(maxClusterRadius = 50),
        icon = ~ attraction_icons[category],
        popup = ~ apply(filtered_data, 1, get_popup_content)
      )
  }
  return(map)
}

get_popup_content <- function(row_data) {
  if(row_data[['category']] == 'artworks') {
    return(paste0(
      "<b> Attraction Category: </b>",
      row_data['category'],
      "<br>",
      "<b> Name: </b>",
      row_data['name'],
      "<br>",
      "<b> Classification: </b>",
      row_data['classification'],
      "<br>",
      "<b> Organisation: </b>",
      row_data['organisation'],
      "<br>",
      "<b> Created Date: </b>",
      row_data['created_date'],
      "<br>",
      "<b> Address: </b>",
      row_data['address']
    ))
  } else if(row_data[['category']] == 'music_venues') {
    return(paste0(
      "<b> Attraction Category: </b>",
      row_data['category'],
      "<br>",
      "<b> Name: </b>",
      row_data['name'],
      "<br>",
      "<b> Type: </b>",
      row_data['type'],
      "<br>",
      "<b> Website: </b>",
      "<a href=",
      row_data['website'],
      " target='_blank'>",
      row_data['website'],
      "</a>"
    ))
  } else if(row_data[['category']] == 'plaques') {
    return(paste0(
      "<b> Attraction Category: </b>",
      row_data['category'],
      "<br>",
      "<b> Tree Common Name: </b>",
      row_data['tree_common_name'],
      "<br>",
      "<b> Tree Scientific Name: </b>",
      row_data['tree_scientific_name'],
      "<br>",
      "<b> Planted Date: </b>",
      row_data['date_of_tree_planted'],
      "<br>",
      "<b> Info: </b>",
      row_data['title']
    ))
  } else if(row_data[['category']] == 'memorials') {
    return(paste0(
      "<b> Attraction Category: </b>",
      row_data['category'],
      "<br>",
      "<b> Title: </b>",
      row_data['title']
     ))
  }else if(row_data[['category']] == 'landmarks') {
    return(paste0(
      "<b> Attraction Category: </b>",
      row_data['category'],
      "<br>",
      "<b> Name: </b>",
      row_data['name'],
      "<br>",
      "<b> Theme: </b>",
      row_data['theme'],
      "<br>",
      "<b> Sub Theme: </b>",
      row_data['sub_theme']
    ))
  }
  else if(row_data[['category']] == 'drinking_fountains') {
    return(paste0(
      "<b> Facility Category: </b>",
      row_data['category'],
      "<br>",
      "<b> Type: </b>",
      row_data['type'],
      "<br>",
      "<b> Info: </b>",
      row_data['info']
    ))
  } else if(row_data[['category']] == 'playgrounds') {
    return(paste0(
      "<b> Facility Category: </b>",
      row_data['category'],
      "<br>",
      "<b> Name: </b>",
      row_data['name'],
      "<br>",
      "<b> Info: </b>",
      row_data['info']
    ))
  } else if(row_data[['category']] == 'toilets'){
    return(
      paste0(
        "<b> Facility Category: </b>",
        row_data['category'],
        "<br>",
        "<b> Type: </b>",
        row_data['type'],
        "<br>",
        "<b> Operator: </b>",
        row_data['operator'],
        "<br>",
        "<b> Female: </b>",
        row_data['female'],
        "<br>",
        "<b> Male: </b>",
        row_data['male'],
        "<br>",
        "<b> Baby Facility: </b>",
        row_data['baby_facil'],
        "<br>",
        "<b> Address: </b>",
        row_data['address']
  ))
  } else {
    return('')
  }
}

attractionServer <- function(input, output, session) {
  ################### observer ##################
  # leaflet map marker click event observer
  # reference: https://stackoverflow.com/questions/28938642/marker-mouse-click-event-in-r-leaflet-for-shiny
  observe({
    attraction_clicked <- input$attraction_map_marker_click
    if (is.null(attraction_clicked)) {
      return()
    } else {
      print(attraction_clicked)
    }
    # filtered_attractions = attractions_data_map()
    # # get marker attraction data
    # attraction_data <- filtered_attractions[as.numeric(filtered_attractions$id) == as.numeric(attraction_clicked$id), ]
    # # get nearby tram stops
    # nearby_stops_string <- hotel_nearby_tram_stops[hotel_nearby_tram_stops$id == hotel_data$id, ]$nearby_stops
    # nearby_stops <- strsplit(nearby_stops_string, ",")
    # num_stops <- length(unlist(nearby_stops))

    # leafletProxy("hotel_map") %>%
    #   clearControls() %>%
    #   addControl(
    #     # html = paste0(
    #     #   "<div id='hotel_info_popup' style='height: 160px; padding: 5px; background-color: white; width: 100%;'>",
    #     #   "<h5>", hotel_data$name, "</h5>",
    #     #   "<button type='button' id='closeButton' class='btn btn-secondary' style='position: absolute; top: 5px; right: 5px;' >x</button>",
    #     #   "<a href='https://www.airbnb.com.au/rooms/'", hotel_data$id, "'>View Listing</a>",
    #     #   "</div>"
    #     # ),
    #     html = paste0(
    #       "<div id='hotel_info_popup' style='height: 160px; padding: 5px; background-color: white; width: 100%;'>",
    #       "<button type='button' id='closeButton' class='btn btn-secondary' style='width: 30px; height: 30px; padding: 0; position: absolute; top: 5px; right: 5px;' >x</button>",
    #       # listing name, can navigate to Airbnb listing site
    #       "<div style='font-size: 20px; padding-bottom: 10px;'><strong>Name: <a href='https://www.airbnb.com.au/rooms/",
    #       hotel_data$id, "'>", hotel_data$name, "</a></strong></div>",
    #       # host name, can navigate to host site
    #       "Host:  <a href='https://www.airbnb.com.au/users/show/",
    #       hotel_data$host_id, "'><strong>", hotel_data$host_name, "</strong></a><br>",
    #       "Price: <strong>$", hotel_data$price, "/night</strong><br>",
    #       "Price class: <strong>", hotel_data$price_class, "</strong><br>",
    #       "Minimum nights: <strong>", hotel_data$minimum_nights, "</strong><br>",
    #       "Rating: <strong>", hotel_data$rating, "</strong><br>",
    #       "Last Review: <strong>", hotel_data$last_review, "</strong><br>",
    #       "<div style='position: absolute; right: 10px; bottom: 10px;'>",
    #         nearby_stop_hint(num_stops),
    #         ifelse(num_stops > 0,"<button id='viewNearbyTramStopButton' class='btn-xs btn-primary' style='margin-left: 10px;'>View</button>", ""),
    #       "</div>",
    #       "</div>"
    #     ),
    #     position = "bottomleft"
    #   ) %>%
    #   # add legend
    #   addControl(
    #     html = paste0(
    #       "<div style='padding: 5px; background-color: white;'>",
    #       "<h5>Price Level</h5>",
    #       "<div style='padding: 5px;'><img src='icons/cheap.svg' width='", ICON_SIZE, "' height='", ICON_SIZE, "' /> Cheap (0-33%)</div>",
    #       "<div style='padding: 5px;'><img src='icons/medium-price.svg' width='", ICON_SIZE, "' height='", ICON_SIZE, "' /> Medium (33%-66%) </div>",
    #       "<div style='padding: 5px;'><img src='icons/expensive.svg' width='", ICON_SIZE, "' height='", ICON_SIZE, "' /> Expensive (66%-100%) </div>",
    #       "</div>"
    #     ),
    #     position = "bottomright"
    #   )
    # output$Click_text <- renderText({
    #   hotel_data$name
    # })
  })

  ################### reactive ##################
  # filter dynamically load data
  attractions_data_map <- reactive({
    attr_faci_data %>% filter(category %in% c(input$attraction_selected, input$facility_selected))
  })

  ################### outputs ##################
  # Leaflet map 
  output$attraction_map <- renderLeaflet({
    render_map(attractions_data_map())
  })
}