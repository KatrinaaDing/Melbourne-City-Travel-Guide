tramStop_Pedestrian_Map_id <- 'tramStop_Pedestrian_Map'
pedestrian_Count_per_Hour <- 'pedestrian_Count_per_Hour'
transport_tab <- tabItem(
  tabName = "transport",
  h4("Transport"),
  column(
    width = 8,
    box(width = 12, 
           status = 'primary',
           height = chart_box_height + 20, 
           tableauPublicViz(id = tramStop_Pedestrian_Map_id,
                            url = "https://public.tableau.com/views/TramMapwithPedestrianCount/Tramandsensormap?:language=zh-CN&publish=yes&:display_count=n&:origin=viz_share_link",
                            height=paste0(chart_box_height + 200, "px")
                        )
        )
  ),
  column(
    width = 4,
    box(
      width = 12,
      status = 'primary',
      height = chart_box_height,
      tableauPublicViz(id = pedestrian_Count_per_Hour,
                       url = "https://public.tableau.com/views/PedestianCountbyHours/EachSensorBarChart?:language=zh-CN&:display_count=n&:origin=viz_share_link",
                       height=paste0(chart_box_height, "px"),
                       
      )
    )
  )
)
