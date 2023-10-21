tramStop_Pedestrian_Map_id <- 'tramStop_Pedestrian_Map'
pedestrian_Count_per_Hour <- 'pedestrian_Count_per_Hour'
transport_tab <- tabItem(
  tabName = "transport",
  h4("Transport"),
  column(
    width = 8,
    box(width = 12,
        status = 'primary',
        tableauPublicViz(id = 'tramStop_Pedestrian_Map',
                         url = "https://public.tableau.com/views/TramMapwithPedestrianCount/Tramandsensormap?:language=zh-CN&publish=yes&:display_count=n&:origin=viz_share_link",
                         height=paste0(chart_box_height + 200, "px")
        )
    )
  ),
  column(
    width = 4,
    box(
      id = 'Pedestrian_Count_per_Hour_Box',
      width = 12,
      status = 'primary',
      title = uiOutput("dynamic_title"),
      tableauPublicViz(id = pedestrian_Count_per_Hour,
                       url = "https://public.tableau.com/views/ThePedestrianCountbyHours/EachSensorBarChart?:language=en-US&publish=yes&:display_count=n&:origin=viz_share_link",
                       height=paste0(chart_box_height - 60, "px"),
      )
    ),
    box(
      id = 'near_Airbnb_Box',
      width = 12,
      status = 'primary',
      uiOutput("near_Airbnb_show"),
    )
  )
)