# calculate the number of poi in given polygon
get_num_poi_in_polygon <- function(polygon, poi_table) {
  poi_geo <- st_as_sf(poi_table, coords = c("longitude", "latitude"), crs = 4326)
  poi_geo <- st_intersection(poi_geo, polygon)
  return(nrow(poi_geo))
}

render_map <- function(filtered_data, filtered_walk_data) {
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
}