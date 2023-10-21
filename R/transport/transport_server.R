nearby_airbnb_hint <- function(number) {
  if (number == 0) {
    return("There is no Airbnb listing nearby.")
  } else if (number == 1) {
    return("There is <strong>1</strong> Airbnb listing nearby.")
  } else {
    return(paste("There are<strong>", number, "</strong>Airbnb listings nearby."))
  }
}

transport_script_head <- paste0('let viz = document.getElementById("pedestrian_Count_per_Hour"); let sheet = viz.workbook.activeSheet; ')

transport_map_script_head <- paste0('let viz = document.getElementById("tramStop_Pedestrian_Map"); let sheet = viz.workbook.activeSheet; ')

create_filter_transport_script <- function(script_body) {
  paste0(transport_script_head, script_body)
}

create_select_markers_script <- function(script_body) {
  paste0(transport_map_script_head, script_body)
}

transportServer <- function(input, output, session) {
  observeEvent(input$tramStop_Pedestrian_Map_mark_selection_changed, {
    sensor_Name <- input$tramStop_Pedestrian_Map_mark_selection_changed$"Sensor Name"
    stop_Name <- input$tramStop_Pedestrian_Map_mark_selection_changed$"STOP_NAME"
    if (length(stop_Name) == 1) {
      # get nearby airbnb listings
      this_nearby_airbnb <- tram_stops_nearby_airbnb[tram_stops_nearby_airbnb$"STOP_NAME" == stop_Name,] 
      this_nearby_airbnb <- this_nearby_airbnb[1, ]
      num_airbnb <- length(unique(unlist(strsplit(this_nearby_airbnb$airbnb_ids, ","))))

      # get nearby poi
      buffer <- tram_stops_buffer[tram_stops_buffer$STOP_NAME == stop_Name,]$near_airbnb_polygon
      num_polygons <- length(buffer)
      buffer <- st_transform(buffer, 4326)
      num_poi <- ceiling(get_num_poi_in_polygon(buffer, attractions) / num_polygons)
      
      output$near_Airbnb_show <- renderUI({
        tagList(
          # Show the descriptive text
          HTML(paste0(
              
              nearby_airbnb_hint(num_airbnb),
              "<button id='tramStopToAirbnbButton' value='",
                this_nearby_airbnb$STOP_ID,
              "' class='btn btn-primary btn-sm' style='margin-left: 10px; margin-bottom: 10px;'>View</button>"
          )),
          br(),
          HTML(paste0(
            nearby_poi_hint(num_poi),
            "<button id='tramStopToPoiButton' value='",
                this_nearby_airbnb$STOP_ID,
              "' class='btn btn-primary btn-sm' style='margin-left: 10px;'>View</button>"
          ))

        )
      })
    }
    script_body <- multi_select_filter_script("Sensor Name", sensor_Name)
    runjs(create_filter_transport_script(script_body))
  })

  output$dynamic_title <- renderUI({
    tram_stop_name <- input$tramStop_Pedestrian_Map_mark_selection_changed$"STOP_NAME"
    sensor_name <- input$tramStop_Pedestrian_Map_mark_selection_changed$"Sensor Name"
    if (!is.null(tram_stop_name)) {
        if (sensor_name == "%null%") {
            title <- paste("There is no nearby sensor on ", tram_stop_name)
            return(title)
        } 
        if (length(tram_stop_name) > 1) {
            title <- paste("Busyness per Hour on Multiple Tram Stops")
        } else {
            title <- paste("Busyness per Hour on ", tram_stop_name)
        }
    } else {
      title <- paste("Please select the point to see more details")
    }
    return(title)
  })
}
