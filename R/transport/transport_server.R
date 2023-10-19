transport_script_head <- paste0('let viz = document.getElementById("pedestrian_Count_per_Hour"); let sheet = viz.workbook.activeSheet; ')

create_filter_transport_script <- function(script_body) {
  paste0(transport_script_head, script_body)
}

transportServer <- function(input, output, session) {
    observeEvent(input$tramStop_Pedestrian_Map_mark_selection_changed, {
        print(input$tramStop_Pedestrian_Map_mark_selection_changed)
        sensor_Name <- input$tramStop_Pedestrian_Map_mark_selection_changed$"Sensor Name"
        script_body <- multi_select_filter_script("Sensor Name", sensor_Name)
        
        runjs(create_filter_transport_script(script_body))
    })

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

