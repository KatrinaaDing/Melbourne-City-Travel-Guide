hotelServer <- function(input, output, session) {
  ################### Observers ##################
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

  ############# reactive functions #############
  # get the geometry shape of selected suburbs
  getSelectedHotelsSuburbs <- reactive({
    selected_suburbs <- suburb_boundaries[suburb_boundaries$SA2_NAME %in% input$suburb_select, ]
    return(selected_suburbs)
  })
  getFilteredHotels <- reactive({
    # Initialize an empty list to collect filtered hotels
    filtered_hotels_list <- list()
    selected_suburbs <- getSelectedHotelsSuburbs()
    # Loop through each suburb
    # reference: https://www.w3schools.com/r/r_for_loop.asp
    for (i in 1:nrow(selected_suburbs)) {
      single_suburb <- selected_suburbs[i, ]
      # Filter hotels within the single suburb
      # reference: https://cran.r-project.org/web/packages/sf/vignettes/sf3.html
      hotels_in_suburb <- hotels[st_intersects(hotels, single_suburb, sparse = FALSE), ]
      # Append to the list
      filtered_hotels_list[[i]] <- hotels_in_suburb
    }
    # Combine all filtered hotels into one dataset
    filtered_hotels <- do.call(rbind, filtered_hotels_list)
    filtered_hotels <- na.omit(filtered_hotels)

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
    if (!is.na(input$min_nights) && input$min_nights >= min_min_nights && input$min_nights <= max_min_nights) {
      filtered_hotels <- filtered_hotels[as.numeric(filtered_hotels$minimum_nights) >= input$min_nights, ]
    }
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
      addProviderTiles(providers$CartoDB.PositronNoLabels) %>%
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
        popup = ~ paste0(
          # listing name, can navigate to Airbnb listing site
          "Name: <a href='https://www.airbnb.com.au/rooms/",
          filtered_hotels$id, "'><strong>", filtered_hotels$name, "</strong></a><br>",
          # host name, can navigate to host site
          "Host:  <a href='https://www.airbnb.com.au/users/show/",
          filtered_hotels$host_id, "'><strong>", filtered_hotels$host_name, "</strong></a><br>",
          "Price: <strong>$", filtered_hotels$price, "/night</strong><br>",
          "Price class: <strong>", filtered_hotels$price_class, "</strong><br>",
          "Minimum nights: <strong>", filtered_hotels$minimum_nights, "</strong><br>",
          "Rating: <strong>", filtered_hotels$rating, "</strong><br>",
          "Last Review: <strong>", filtered_hotels$last_review, "</strong><br>"
        ),
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
    # note: custom js code is in www/js/onRenderAirbnb.js
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
  observe({
    click <- input$hotel_map_marker_click
    if (is.null(click)) {
      return()
    }
    filtered_hotels <- getFilteredHotels()
    # get marker hotel data
    hotel_data <- filtered_hotels[as.numeric(filtered_hotels$id) == as.numeric(click$id), ]
    leafletProxy("hotel_map") %>%
      clearControls() %>%
      addControl(
        html = paste0(
          "<div id='hotel_info_popup' style='height: 160px; padding: 5px; background-color: white; width: 100%;'>",
          "<h5>", hotel_data$name, "</h5>",
          "<button type='button' id='closeButton' class='btn btn-secondary' style='position: absolute; top: 5px; right: 5px;' >x</button>",
          "<a href='https://www.airbnb.com.au/rooms/'", hotel_data$id, "'>View Listing</a>",
          "</div>"
        ),
        position = "bottomleft"
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
    output$Click_text <- renderText({
      hotel_data$name
    })
  })
  # # close control box when clicking the button
  # observe({
  #   if (isTRUE(input$closeControl)) {
  #     leafletProxy("hotel_map") %>% clearControls()
  #   }
  # })
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
      width = 3,
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
      width = 3,
      icon = icon("dollar"),
      color = "green"
    )
  })
}