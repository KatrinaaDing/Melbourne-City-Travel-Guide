nearby_stop_hint <- function(number) {
  if (number == 0) {
    "There is no tram stop nearby."
  } else if (number == 1) {
    "There is <strong>1</strong> tram stop nearby."
  } else {
    paste0("There are <strong>", number, "</strong> tram stops nearby.")
  }
}

nearby_poi_hint <- function(number) {
  if (number == 0) {
    "There is no attraction nearby."
  } else if (number == 1) {
    "There is <strong>1</strong> attraction nearby."
  } else {
    paste0("There are <strong>", number, "</strong> attractions nearby.")
  }
}

script_head <- paste0('let viz = document.getElementById("tableauAirbnb"); let sheet = viz.workbook.activeSheet; ')

single_select_filter_script <- function(filter_name, filter_value) {
  sprintf('sheet.applyFilterAsync("%s", ["%s"], FilterUpdateType.Replace);', filter_name, filter_value)
}

multi_select_filter_script <- function(filter_name, filter_values) {
  filter_values_string <- paste(sprintf('"%s"', filter_values), collapse = ", ")
  sprintf('sheet.applyFilterAsync("%s", [%s], FilterUpdateType.Replace);', filter_name, filter_values_string)
}

range_filter_script_for_dashboard <- function(filter_name, filter_min, filter_max) {
  range_filter <- sprintf('.applyRangeFilterAsync("%s", {min: %s, max: %s}, FilterUpdateType.Replace);', filter_name, filter_min, filter_max)
  loop_script <- paste0(
    'sheet.worksheets.forEach(w => {',
     'w', range_filter,
    '})'
  )
  loop_script
}

create_filter_script <- function(script_body) {
  paste0(script_head, script_body)
}

hotelServer <- function(input, output, session) {
  ################### observers ##################
  observeEvent(input$hovered_suburb_option, {
    # Your code here
    print(paste("Hovered over option: ", input$hovered_suburb_option))
  })

  # update hotel price range min and max value based on price class selection
  observeEvent(input$price_class_select, {
    selected_classes <- input$price_class_select

    # setting new min and max value based on selected classes
    new_min <- if ("cheap" %in% selected_classes) {
      min_hotel_price
    } else if ("medium" %in% selected_classes) {
      cheap_threshold
    } else {
      max(hotels[hotels$price_class == "medium", ]$price)
    }
    new_max <- if ("expensive" %in% selected_classes) {
      max_hotel_price
    } else if ("medium" %in% selected_classes) {
      medium_threshold
    } else {
      min(hotels[hotels$price_class == "medium", ]$price)
    }
    updateSliderInput(
      session,
      "hotel_price",
      min = new_min,
      max = new_max,
      value = c(new_min, new_max)
    )
  })

  # update tableau onclick suburb filter
  observeEvent(input$suburb_select, {
    suburbs <- input$suburb_select
    script_body <- multi_select_filter_script("Suburb", suburbs)
    runjs(create_filter_script(script_body))
  })

  # update tableau onclick price range filter
  observeEvent(input$hotel_price, {
    min <- input$hotel_price[1]
    max <- input$hotel_price[2]
    script_body <- range_filter_script_for_dashboard("Price", min, max)
    runjs(create_filter_script(script_body))
  })

  # update tableau on select rating range
  observeEvent(input$rating_range, {
    min <- input$rating_range[1]
    max <- input$rating_range[2]
    script_body <- range_filter_script_for_dashboard("Rating", min, max)
    runjs(create_filter_script(script_body))
  })

  # update tableau on enter minimum nights filter
  observeEvent(input$min_nights, {
    min_nights <- as.integer(input$min_nights)
    script_body <- range_filter_script_for_dashboard("Minimum Nights", min_nights, max_min_nights)
    runjs(create_filter_script(script_body))
  })

  # update tableau onclick suburb filter
  observeEvent(input$price_class_select, {
    price_class <- input$price_class_select
    script_body <- multi_select_filter_script("Price Class", price_class)
    runjs(create_filter_script(script_body))
  })

  # update tableau on select number of bathrooms
  observeEvent(input$num_baths, {
    if (input$num_baths == "All") {
      script_body <- multi_select_filter_script("Number Of Baths", sort(unique(hotels$number_of_baths)))
    } else {
      script_body <- single_select_filter_script("Number Of Baths", input$num_baths)
    }
    runjs(create_filter_script(script_body))
  })

  # update tableau on select number of beds
  observeEvent(input$num_beds, {
    if (input$num_beds == "All") {
      script_body <- multi_select_filter_script("Number Of Beds", sort(unique(hotels$number_of_beds)))
    } else {
      script_body <- single_select_filter_script("Number Of Beds", input$num_beds)
    }
    runjs(create_filter_script(script_body))
  })

  # update tableau on select number of bedrooms
  observeEvent(input$num_bedrooms, {
    if (input$num_bedrooms == "All") {
      script_body <- multi_select_filter_script("Number Of Bedrooms", sort(unique(hotels$number_of_bedrooms)))
    } else {
      script_body <- single_select_filter_script("Number Of Bedrooms", input$num_bedrooms)
    }
    runjs(create_filter_script(script_body))
  })
  
  ############# reactive functions #############

  # the previous clicked marker's id
  last_clicked_hotel_marker <- reactiveVal(NULL)

  # the previous shown stop buffer's id
  last_shown_stop_buffer <- reactiveVal(NULL)

  # get the geometry shape of selected suburbs
  getSelectedHotelsSuburbs <- reactive({
    selected_suburbs <- suburb_boundaries[suburb_boundaries$SA2_NAME %in% input$suburb_select, ]
    return(selected_suburbs)
  })

  # get filtered hotels listings
  getFilteredHotels <- reactive({
    # Initialize an empty list to collect filtered hotels
    filtered_hotels <- hotels[hotels$suburb %in% input$suburb_select, ]

    # filter price and ratings
    filtered_hotels <- filtered_hotels[
      # filter price class
      filtered_hotels$price_class %in% input$price_class_select &
        # filter price range
        (filtered_hotels$price >= input$hotel_price[1] & filtered_hotels$price <= input$hotel_price[2]) &
        # filter rating range
        (filtered_hotels$rating >= input$rating_range[1] & filtered_hotels$rating <= input$rating_range[2]),
    ]
    # filter minimum nights range
    filtered_hotels <- filtered_hotels[as.numeric(filtered_hotels$minimum_nights) >= as.numeric(input$min_nights), ]

    # filter number of bedrooms
    if (input$num_bedrooms != "All") {
      filtered_hotels <- filtered_hotels[filtered_hotels$number_of_bedrooms == input$num_bedrooms, ]
    }
    # filter number of beds
    if (input$num_beds != "All") {
      filtered_hotels <- filtered_hotels[filtered_hotels$number_of_beds == input$num_beds, ]
    }
    # filter number of baths
    if (input$num_baths != "All") {
      filtered_hotels <- filtered_hotels[filtered_hotels$number_of_baths == input$num_baths, ]
    }
    return(filtered_hotels)
  })

  ################### outputs ##################
  # map
  output$hotel_map <- renderLeaflet({
    filtered_hotels <- getFilteredHotels()
    leaflet_map <- leaflet() %>%
      addProviderTiles(ifelse(input$toggle_hotel_street_name, providers$CartoDB.PositronNoLabels, providers$CartoDB.Positron)) %>%
      addPolygons(
        data = city_boundary,
        fillColor = "transparent",
        weight = 2,
        color = "#000000",
        fillOpacity = 0.5,
      ) %>%
      addPolygons(
        data = getSelectedHotelsSuburbs(),
        fillColor = ~fillColor,
        stroke = TRUE,
        weight = 1,
        color = "#000000",
        fillOpacity = 0.15,
        popup = ~SA2_NAME,
      ) %>%
      addMarkers(
        data = filtered_hotels,
        clusterOptions = markerClusterOptions(maxClusterRadius = 50),
        icon = ~ dollar_icons[price_class],
        layerId = ~id,
        options = markerOptions(price = filtered_hotels$price),
        label = ~ paste(filtered_hotels$name),
        labelOptions = labelOptions(direction = "top")
      ) %>%
      # add legend
      addControl(
        html = paste0(
          "<div style='padding: 5px; background-color: white;'>",
          "<h5>Price Level</h5>",
          "<div style='padding: 5px;'><img src='icons/cheap.svg' width='", ICON_SIZE, "' height='", ICON_SIZE, "' /> Cheap (0-33%)</div>",
          "<div style='padding: 5px;'><img src='icons/medium-price.svg' width='", ICON_SIZE, "' height='", ICON_SIZE, "' /> Medium (33%-66%) </div>",
          "<div style='padding: 5px;'><img src='icons/expensive.svg' width='", ICON_SIZE, "' height='", ICON_SIZE, "' /> Expensive (66%-100%) </div>",
          "</div>"
        ),
        position = "bottomright"
      )
    # render custom clustered icons
    # reference: https://stackoverflow.com/questions/33600021/leaflet-for-r-how-to-customize-the-coloring-of-clusters
    leaflet_map %>% onRender("
      function(el, x) {
        // data from constant defined earlier
        const CHEAP_THRESHOLD = 129;
        const MEDIUM_THRESHOLD = 180;
        // get average price of markers in a cluster
        const getAvgPrice = (markers) =>
          (markers.reduce((a, b) => a + parseFloat(b.options.price), 0) / markers.length).toFixed(2)
        let map = this;
        map.eachLayer(function (layer) {
          if (layer instanceof L.MarkerClusterGroup) {
            // create cluster icon
            layer.options.iconCreateFunction = function (cluster) {
              const averagePrice = getAvgPrice(cluster.getAllChildMarkers());
              // cluster icon background style (used to be gradient but found that transparent background is better)
              iconHtml = '<div style=\"background: radial-gradient(circle at center, transparent, transparent); width: 40px; height: 40px; border-radius: 50%;\"></div>';
              // icon style
              iconStyle = 'style=\"width: 26px; height: 26px; position: relative; top: -32px; left: 8px;\"';
              if (averagePrice > MEDIUM_THRESHOLD) {
                iconHtml += '<img src=\"icons/expensive.svg\" ' + iconStyle + ' />';
              } else if (averagePrice > CHEAP_THRESHOLD) {
                iconHtml += '<img src=\"icons/medium-price.svg\" ' + iconStyle + ' />';
              } else {
                iconHtml += '<img src=\"icons/cheap.svg\" ' + iconStyle + ' />';
              }
              // cluster label (num of childern markers)
              iconHtml += '<div style=\"position: relative; top: -35px; font-size: 12px; text-align: center; font-weight: 700;\">' + cluster.getAllChildMarkers().length + '</div>';

              return L.divIcon({ html: iconHtml, className: 'my-cluster-icon', iconSize: L.point(40, 40) });
            };
            // create hover popup
            layer.on('clustermouseover', function (a) {
              let cluster = a.layer;
              const averagePrice = getAvgPrice(cluster.getAllChildMarkers());
              let popup = L.popup()
                .setLatLng(cluster.getLatLng())
                .setContent(`Numbers of Airbnb: ${cluster.getChildCount()} <br>Average price: $${averagePrice} per night`)
                .openOn(map);
            });
            layer.on('clustermouseout', function (a) {
              map.closePopup();
            });
          }
        });
      }
    ")
  })

  # leaflet map marker click event observer
  # reference: https://stackoverflow.com/questions/28938642/marker-mouse-click-event-in-r-leaflet-for-shiny
  observeEvent(input$hotel_map_marker_click, {
    click <- input$hotel_map_marker_click
    if (is.null(click)) {
      return()
    }

    # get filtered hotels
    filtered_hotels <- getFilteredHotels()
    # get marker hotel data
    hotel_data <- filtered_hotels[as.numeric(filtered_hotels$id) == as.numeric(click$id), ]
    # get nearby tram stops
    nearby_stops_string <- hotel_nearby_tram_stops[hotel_nearby_tram_stops$id == hotel_data$id, ]$nearby_stops
    nearby_stops <- strsplit(nearby_stops_string, ",")
    num_stops <- length(unlist(nearby_stops))
    # get buffer
    hotel_buffer <- hotel_nearby_buffer[hotel_nearby_buffer$id == hotel_data$id, ]
    num_pois <- get_num_poi_in_polygon(hotel_buffer$geometry, attractions)

    # remove previous added control box and buffer polygon
    leafletProxy("hotel_map") %>%
      # remove previous hotel detail control box
      removeControl(
        layerId = paste0("hotel_detail_", last_clicked_hotel_marker())
      ) %>%
    # add new control box and buffer polygon
      addControl(
        html = paste0(
          "<div id='hotel_info_popup' style='height: 160px; padding: 5px; background-color: white; width: 100%;'>",
          "<button type='button' id='closeButton' class='btn btn-secondary' style='width: 30px; height: 30px; padding: 0; position: absolute; top: 5px; right: 5px;' >x</button>",
          # listing name, can navigate to Airbnb listing site
          "<div style='font-size: 20px; padding-bottom: 10px; padding-top: 10px;'><strong>Name: <a href='https://www.airbnb.com.au/rooms/",
          hotel_data$id, "'>", hotel_data$name, "</a></strong></div>",
          # host name, can navigate to host site
          "Host:  <a href='https://www.airbnb.com.au/users/show/",
          hotel_data$host_id, "'><strong>", hotel_data$host_name, "</strong></a><br>",
          "Price: <strong>$", hotel_data$price, "/night</strong><br>",
          "Price class: <strong>", hotel_data$price_class, "</strong><br>",
          "Minimum nights: <strong>", hotel_data$minimum_nights, "</strong><br>",
          "Rating: <strong>", hotel_data$rating, "</strong><br>",
          "Last Review: <strong>", hotel_data$last_review, "</strong><br>",
          "<div style='position: absolute; right: 10px; bottom: 10px; text-align: right'>",
            # nearby tram stop
            "<div style='padding-bottom: 5px;'>",
              nearby_stop_hint(num_stops),
              ifelse(
                num_stops > 0,
                paste0("<button id='viewNearbyTramStopButton' value='",
                  hotel_data$id,
                  "' class='btn-xs btn-primary' style='margin-left: 10px;'>View</button>"
                ), 
                ""
              ),
            "</div>",
            # nearby poi
            "<div>",
              nearby_poi_hint(num_pois),
              "<button id='viewNearbyPoiButton' value='",
              hotel_data$id,
              "' class='btn-xs btn-primary' style='margin-left: 10px;'>View</button>",
            "</div>",
          "</div>",
          "</div>"
        ),
        position = "bottomleft",
        layerId = paste0("hotel_detail_", click$id)
      )

    # store the last clicked marker
    last_clicked_hotel_marker(click$id)

    output$Click_text <- renderText({
      hotel_data$name
    })
  })

  # list tram stop buffer polygon from selected tram stop
  observeEvent(input$stop_nearby_hotel_id, {
    leafletProxy("hotel_map") %>%
      # remove the previous shown stop buffer
      removeShape(
        layerId = paste0("stop_buffer_", last_shown_stop_buffer())
      ) %>%
      removeMarker(
        layerId = paste0("stop_point_", last_shown_stop_buffer())
      )
    if (is.null(input$stop_nearby_hotel_id)) {
      return()
    }
    updateTabItems(session, "tabs", "airbnb")
    # get the id value before '-'
    stop_nearby_hotel_id <- strsplit(input$stop_nearby_hotel_id, "-")[[1]][1]
    # get buffer polygon from dateset
    stop_buffer_info <- tram_stops_buffer[tram_stops_buffer$STOP_ID == stop_nearby_hotel_id, 1, ]
    stop_point_info <- tram_stops_point[tram_stops_point$STOP_ID == stop_nearby_hotel_id, 1, ]
    tram_stop_info <- tram_stops[tram_stops$STOP_ID == stop_nearby_hotel_id, ]
    # trasform the polygon to sf object
    stop_buffer <- st_transform(stop_buffer_info$near_airbnb_polygon, 4326)
    stop_point <- st_transform(stop_point_info$geometry, 4326)

    leafletProxy("hotel_map") %>%
      setView(lng = stop_point[[1]][[1]], lat = stop_point[[1]][[2]], zoom = 15) %>%
      # show the new stop buffer
      addPolygons(
        data = stop_buffer,
        fillColor = "#d4eeff",
        stroke = TRUE,
        weight = 2,
        color = "#33b1ff",
        fillOpacity = 0.3,
        layerId = paste0("stop_buffer_", input$stop_nearby_hotel_id)
      ) %>%
      addMarkers(
        data = stop_point,
        icon = tram_icon,
        label = tram_stop_info$STOP_NAME,
        layerId = paste0("stop_point_", input$stop_nearby_hotel_id)
      )
    # store the last shown stop buffer
    last_shown_stop_buffer(input$stop_nearby_hotel_id)
  })

  # toggle hiding street name on map
  # use of proxy reference: https://rstudio.github.io/leaflet/shiny.html
  observeEvent(input$toggle_hotel_street_name, {
    if (input$toggle_hotel_street_name) {
      leafletProxy("hotel_map") %>%
        addProviderTiles(providers$CartoDB.PositronNoLabels)
    } else {
      leafletProxy("hotel_map") %>%
        addProviderTiles(providers$CartoDB.Positron)
    }
  })

  # onclick clear_hotel_radius button, clear the tram stop buffer and marker
  observeEvent(input$clear_hotel_radius, {
    leafletProxy("hotel_map") %>%
      # remove the previous shown stop buffer
      removeShape(
        layerId = paste0("stop_buffer_", last_shown_stop_buffer())
      ) %>%
      removeMarker(
        layerId = paste0("stop_point_", last_shown_stop_buffer())
      )
  })

  ################### value boxes ##################

  # value box that render total number of hotels
  output$total_hotels_num <- renderValueBox({
    valueBox(
      nrow(getFilteredHotels()),
      "Total Number of Listings",
      icon = icon("bed"),
      color = "light-blue"
    )
  })

  # value box that render average rating of hotels
  output$average_hotels_rating <- renderValueBox({
    avg_rating <- mean(getFilteredHotels()$rating, na.rm = TRUE)
    avg_rating <- format(round(avg_rating, 3))
    valueBox(
      ifelse(is.na(avg_rating), DEFAULT_NA_HINT, avg_rating),
      "Average Rating",
      icon = icon("thumbs-up"),
      color = "yellow"
    )
  })

  # value box that render average price of hotels
  output$average_hotels_price <- renderValueBox({
    avg_price <- mean(getFilteredHotels()$price, na.rm = TRUE)
    avg_price <- format(round(avg_price, 2))
    valueBox(
      ifelse(is.na(avg_price), DEFAULT_NA_HINT, paste0("$", avg_price)),
      "Average Price/Night",
      icon = icon("dollar"),
      color = "green"
    )
  })
}
