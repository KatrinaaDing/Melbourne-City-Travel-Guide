# calculate the number of poi in given polygon
get_num_poi_in_polygon <- function(polygon, poi_table) {
  poi_geo <- st_as_sf(poi_table, coords = c("longitude", "latitude"), crs = 4326)
  poi_geo <- st_intersection(poi_geo, polygon)
  return(nrow(poi_geo))
}

render_map <- function(filtered_data, filtered_walk_data) {
  map <- leaflet() %>% 
        addProviderTiles(providers$CartoDB.Positron) %>%
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
        layerId = ~ paste(location_id, latitude, longitude, category),
        clusterOptions = markerClusterOptions(maxClusterRadius = 50),
        icon = ~ attraction_icons[category],
        popup = ~ apply(filtered_data, 1, get_popup_content)
      )
  }

  if(nrow(filtered_walk_data) != 0) {
    palette <- colorNumeric("viridis", NULL)
    map <- map %>%
      addPolylines(
        data = filtered_walk_data,
        color = ~ palette(distance),
        popup = ~ paste0(
          "<b> Walk Name: </b>",
          filtered_walk_data$name,
          "<br>",
          "<b> Distance: </b>",
          filtered_walk_data$distance,
          " km",
          "<br>",
          "<b> Estimated Time Spent: </b>",
          filtered_walk_data$time
        )
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

attraction_script_head <- paste0('let viz = document.getElementById("attraction_ped_chart"); let sheet = viz.workbook.activeSheet; ')

filter_attraction_script <- function(script_body) {
  paste0(attraction_script_head, script_body)
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
      attraction_id <- attraction_clicked$id
      attraction_location_id <- strtoi(strsplit(attraction_id, " ")[[1]][1])
      script_body <- multi_select_filter_script(
        "Location Id", attraction_location_id
      )
      runjs(filter_attraction_script(script_body))
    }
  })


  ################### reactive ##################

  # the previous shown hotel buffer's id
  last_shown_hotel_buffer <- reactiveVal(NULL)

  # the previous shown tram stop buffer's id
  last_shown_stop_buffer <- reactiveVal(NULL)

  # filter dynamically load data
  attractions_data_map <- reactive({
    attr_faci_data %>%
      filter(
        category %in%
          c(input$attraction_selected, input$facility_selected)
      )
  })
  attractions_walk_map <- reactive({
    attr_walks$distance <- as.numeric(attr_walks$distance)
    attr_walks %>%
      filter(
        name %in%
          input$walk_selected
      )
  })
  ################### outputs ##################
  # Leaflet map
  output$attraction_map <- renderLeaflet({
    render_map(attractions_data_map(), attractions_walk_map())
  })

  # show hotel buffer on the attraction map
  observeEvent(input$view_nearby_poi_id, {
    leafletProxy("attraction_map") %>%
      removeShape(
        layerId = paste0("hotel_buffer_", last_shown_hotel_buffer())
      ) %>% 
      removeMarker(
        layerId = paste0("hotel_point_", last_shown_hotel_buffer())
      )
    if (is.null(input$view_nearby_poi_id)) {
      return()
    }
    # navigate to attraction tab 
    updateTabItems(session, "tabs", "attraction")
    # get the stop id
    hotel_id <- strsplit(input$view_nearby_poi_id, "-")[[1]][1]
    
    # get buffer polygon and point from dataset
    hotel_buffer <- hotel_nearby_buffer[hotel_nearby_buffer$id == hotel_id, ]
    hotel_point <- hotels[hotels$id == hotel_id, ]
    leafletProxy("attraction_map") %>% 
      setView(lng = hotel_point$Longitude, lat = hotel_point$Latitude, zoom = 15) %>%
      addPolygons(
        data = hotel_buffer,
        fillColor = "#d4eeff",
        stroke = TRUE,
        weight = 2,
        color = "#33b1ff",
        fillOpacity = 0.3,
        layerId = paste0("hotel_buffer_", input$view_nearby_poi_id)
      ) %>%
      addMarkers(
        data = hotel_point,
        icon = hotel_icon,
        label = paste0(hotel_point$name, "hosted by ", hotel_point$host_name),
        layerId = paste0("hotel_point_", input$view_nearby_poi_id)
      )
      
    # update the last clicked hotel marker
    last_shown_hotel_buffer(input$view_nearby_poi_id)
  })

  # show tram stop buffer on the attraction map
  observeEvent(input$stop_nearby_poi_id, {
    leafletProxy("attraction_map") %>%
      removeShape(
        layerId = paste0("stop_buffer_", last_shown_stop_buffer())
      ) %>% 
      removeMarker(
        layerId = paste0("stop_point_", last_shown_stop_buffer())
      )
    if (is.null(input$stop_nearby_poi_id)) {
      return()
    }
    # navigate to attraction tab
    updateTabItems(session, "tabs", "attraction")
    # get the stop id
    stop_id <- strsplit(input$stop_nearby_poi_id, "-")[[1]][1]
    # get buffer polygon from dateset
    stop_buffer_info <- tram_stops_buffer[tram_stops_buffer$STOP_ID == stop_id, 1, ]
    stop_point_info <- tram_stops_point[tram_stops_point$STOP_ID == stop_id, 1, ]
    tram_stop_info <- tram_stops[tram_stops$STOP_ID == stop_id, ]
    # trasform the polygon to sf object
    stop_buffer <- st_transform(stop_buffer_info$near_airbnb_polygon, 4326)
    stop_point <- st_transform(stop_point_info$geometry, 4326)

    leafletProxy("attraction_map") %>% 
      setView(lng =  stop_point[[1]][[1]], lat = stop_point[[1]][[2]], zoom = 15) %>%
      addPolygons(
        data = stop_buffer,
        fillColor = "#d4eeff",
        stroke = TRUE,
        weight = 2,
        color = "#33b1ff",
        fillOpacity = 0.3,
        layerId = paste0("stop_buffer_", input$stop_nearby_poi_id)
      ) %>%
      addMarkers(
        data = stop_point,
        icon = tram_icon,
        label = tram_stop_info$STOP_NAME,
        layerId = paste0("stop_point_", input$stop_nearby_poi_id)
      )

    # update the last clicked hotel marker
    last_shown_stop_buffer(input$stop_nearby_poi_id)
  })

  # onclick clear_attraction_radius button, clear the all the buffer and marker
  observeEvent(input$clear_attraction_radius, {
    leafletProxy("attraction_map") %>%
      removeShape(
        layerId = paste0("hotel_buffer_", last_shown_hotel_buffer())
      ) %>% 
      removeMarker(
        layerId = paste0("hotel_point_", last_shown_hotel_buffer())
      ) %>% 
      removeShape(
        layerId = paste0("stop_buffer_", last_shown_stop_buffer())
      ) %>%
      removeMarker(
        layerId = paste0("stop_point_", last_shown_stop_buffer())
      )

  })
}