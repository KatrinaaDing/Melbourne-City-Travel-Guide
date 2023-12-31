hotel_tab <- tabItem(
  tabName = "airbnb",
  tags$head(
    tags$style(HTML("
      #shiny-tab-airbnb .leaflet-bottom.leaflet-left {
        width: 65%;
      }
      #shiny-tab-airbnb .col-sm-12 {
        padding-right: 0;
        padding-left: 0;
      }
      #shiny-tab-airbnb .leaflet-bottom.leaflet-left .info.legend.leaflet-control {
        width: 100%;
      }
      #shiny-tab-airbnb .modal-body li {
        padding-bottom: 5px;
      }
    ")),
    tags$script(HTML("
      $(document).on('click', '#closeButton', function(){
        //Shiny.setInputValue('closeControl', true, {priority: 'event'});
        $('#hotel_info_popup').parent().addClass('fade').removeClass('show');
        setTimeout(function() {
          $('#controlToRemove').parent().remove();
        }, 150); // The animation duration in milliseconds
      });
      $(document).on('mouseover', '#suburb_select .bootstrap-select .dropdown-menu.inner li', function(){
        Shiny.setInputValue('hovered_suburb_option', this.value);
      });
      $(document).on('click', '#viewNearbyTramStopButton', function(){
        Shiny.setInputValue('view_nearby_stops_id', this.value);
      });
      $(document).on('click', '#tramStopToAirbnbButton', function(){
        let random_id = this.value + '-' + Math.random();
        Shiny.setInputValue('stop_nearby_hotel_id', random_id)
      });
    ")),
  ),
  h4("Airbnb Listings"),
  column(
    width = 9,
      fluidRow(
        width = 12,
        valueBoxOutput("total_hotels_num", width = 4),
        valueBoxOutput("average_hotels_rating", width = 4),
        valueBoxOutput("average_hotels_price", width = 4),
      ),
    tabBox(
      width = 12,
      title = "Airbnb Listings in Melbourne City",
      # The id lets us use input$tabset1 on the server to find the current tab
      id = "hotel_statistics_tabset",
      tabPanel(
        "Map",
        leafletOutput("hotel_map", height = "calc(100vh - 340px)"), # 330
      ),
      tabPanel(
        "Chart",
        style = "height: calc(100vh - 340px)",
        fluidRow(
          width = 12,
          height = "calc((100vh - 340px)/2)",
          tableauPublicViz(
            id='tableauAirbnbTree',
            url = "https://public.tableau.com/views/MelbourneCityAirbnbListingsTreeMap/AveragePriceInEachSuburb?:language=en-US&publish=yes&:display_count=n&:origin=viz_share_link",
            style="height: calc((100vh - 340px)/2 + 10px); width: 100%;"
          ),
        ),
        fluidRow(
          width = 12,
          height = "calc((100vh - 340px)/2)",
          tableauPublicViz(
            id='tableauAirbnbScatter',
            url = "https://public.tableau.com/views/MelbourneCityAirbnbListingsScatterPlot/PriceDistribution?:language=en-US&publish=yes&:display_count=n&:origin=viz_share_link",
            style="height: calc((100vh - 340px)/2 - 10px); width: 100%;"
          ),
        )
      ),
    )
  ),
  column(
    width = 3,
    div(
      box(
        width = 12,
        style = "height: calc(100vh - 200px); overflow-y: scroll;",
        title = "Filter",
        status = "primary",
        solidHeader = TRUE,
        actionButton("clear_hotel_radius", "Clear Circle Bounds", class = "btn btn-danger"),
        checkboxInput("toggle_hotel_street_name", "Hide Street Name", value = FALSE),
        pickerInput(
          "suburb_select", "Select suburb:",
          choices = CITY_SUBURBS,
          selected = CITY_SUBURBS,
          multiple = TRUE,
        ),
        sliderInput(
          "hotel_price", "Select price (per night) range:",
          min = min_hotel_price, max = max_hotel_price,
          value = c(min_hotel_price, max_hotel_price),
          step = 1, pre = "$"
        ),
        pickerInput(
          "price_class_select", "Select price class:",
          choices = c("cheap", "medium", "expensive"),
          selected = c("cheap", "medium", "expensive"),
          multiple = TRUE
        ),
        sliderInput(
          "rating_range", "Select rating range:",
          min = 0, max = 5, value = c(0, 5),
          step = 0.1
        ),
        selectInput(
          "min_nights", "Select minimum nights:",
          choices = c(sort(unique(hotels$minimum_nights))),
        ),
        selectInput(
          "num_bedrooms", "Select number of bedrooms:",
          choices = c("All" = "All", sort(unique(hotels$number_of_bedrooms))),
        ),
        selectInput(
          "num_beds", "Select number of beds:",
          choices = c("All" = "All", sort(unique(hotels$number_of_beds))),
        ),
        selectInput(
          "num_baths", "Select number of baths:",
          choices = c("All" = "All", sort(unique(hotels$number_of_baths))),
        ),
      ),
    ),
  )
)
