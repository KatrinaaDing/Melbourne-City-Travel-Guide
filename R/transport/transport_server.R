transportServer <- function(input, output, session) {
    observeEvent(input$tramStop_Pedestrian_Map_id_mark_selection_changed, {
        print("Test here")
        print(input$tramStop_Pedestrian_Map_id_mark_selection_changed)
    })
}