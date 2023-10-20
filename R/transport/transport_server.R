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
      this_nearby_airbnb <- tram_stops_nearby_airbnb[tram_stops_nearby_airbnb$"STOP_NAME" == stop_Name,] 
      this_nearby_airbnb <- this_nearby_airbnb[1, ]
      num_airbnb <- length(unlist(strsplit(this_nearby_airbnb$airbnb_ids, ",")))

      output$near_Airbnb_show <- renderUI({
        tagList(
          # Show the descriptive text
          HTML(paste0(
            "There are ", num_airbnb, " Airbnb near this tram stop.",
            "<button id='jump_to_Airbnb_Button' value='",
              this_nearby_airbnb$STOP_ID,
            "' class='btn btn-primary btn-sm' style='margin-left: 10px;'>View</button>")
          )
        )
      })
    }
    script_body <- multi_select_filter_script("Sensor Name", sensor_Name)
    runjs(create_filter_transport_script(script_body))
  })

  # observeEvent(input$view_nearby_stops_id, {
  #   updateTabItems(session, "tabs", "transport")
  #     nearby_stops_string <- hotel_nearby_tram_stops[hotel_nearby_tram_stops$id ==input$view_nearby_stops_id, ]$nearby_stops
  #     #script_body <- sprintf("sheet.selectMarksAsync('STOP_NAME', %s, tableau.SelectionUpdateType.REPLACE)", nearby_stops_string);
  #     script_body <- "sheet.selectMarksAsync('STOP_NAME','5-Swanston St/Flinders St (Melbourne City)', tableau.SelectionUpdateType.REPLACE)"
  #     js_code <- "
  #      setTimeout(function() {
  #      console.log('2222');
  #       let viz = document.getElementById('tramStop_Pedestrian_Map'); let sheet = viz.workbook.activeSheet;
  #       console.log(sheet);
  #           sheet.selectMarksAsync('STOP_NAME','5-Swanston St/Flinders St (Melbourne City)', FilterUpdateType.Replace);
  #      }, 5000);
  #       "
  #     runjs(js_code)
  # })

  #
  output$dynamic_title <- renderUI({
    tram_stop_name <- input$tramStop_Pedestrian_Map_mark_selection_changed$"STOP_NAME"
    if (!is.null(tram_stop_name)) {
      if (length(tram_stop_name) > 1) {
        title <- paste("Pedestrian Count per Hour on Multiple Tram Stops")
      } else {
        title <- paste("Pedestrian Count per Hour on ", tram_stop_name)
      }
    } else {
      title <- paste("Please select the point to see more details")
    }
    return(title)
  })
}
