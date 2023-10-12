hotel_tab <- tabItem(
  tabName = "airbnb",
  tags$head(
    tags$style(HTML("
      .leaflet-bottom.leaflet-left {
        width: 65%;
      }
      .leaflet-bottom.leaflet-left .info.legend.leaflet-control {
        width: 100%;
      }
      [class^='col-sm-'] {
        padding: 0;
      }
      .shiny-html-output.col-sm-12.shiny-bound-output {
        padding-left: 0;
        padding-right: 0;
      }
      .small-box {
        height: 89px;
        margin-bottom: 10px;
      }
      .small-box .inner {
        transform: scale(0.9) translate(-10px, -5px)；
      }
      .small-box .icon-large {
        font-size: 60px;
        right: 10px;
      }
      .row {
        width: 100%;
      }
      .row .col-sm-6 {
        padding-left: 0;
        padding-right: 0;
      }
      #average_hotels_rating.shiny-html-output.col-sm-6.shiny-bound-output {
        padding-right: 10px;
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
    ")),
  ),
  h1("Airbnb"),
  column(
    width = 8,
    tabBox(
      width = 12,
      title = "Airbnb Listings in Melbourne City",
      # The id lets us use input$tabset1 on the server to find the current tab
      id = "hotel_statistics_tabset",
      tabPanel(
        "Chart",
        "Tab content 2"
      ),
      tabPanel(
        "Map",
        leafletOutput("hotel_map", height = "calc(100vh - 240px)"), # 330
      )
    )
  ),
  column(
    width = 4,
    div(
      style = "display: flex; flex-direction: column; align-items: center; padding-left: 10px;",
      valueBoxOutput("total_hotels_num", width = 12),
      fluidRow(
        width = 12,
        valueBoxOutput("average_hotels_rating", width = 6),
        valueBoxOutput("average_hotels_price", width = 6),
      ),
      box(
        width = 12,
        style = "height: calc(100vh - 415px); overflow-y: scroll;",
        title = "Filter",
        status = "primary",
        solidHeader = TRUE,
        collapsible = TRUE,
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
        numericInput(
          "min_nights", "Select minimum nights range:",
          min = min_min_nights, max = max_min_nights,
          value = 1,
          step = 1
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

    # tabBox(
    #   title = "Statistics",
    #   width = 4,
    #   height = "250px",
    #   # The id lets us use input$tabset1 on the server to find the current tab
    #   id = "hotel_statistics_tabset",
    #   tabPanel(
    #     "Nearby",
    #     HTML(paste0(
    #       "Transport: There are 4 bus stops nearby. <br>",
    #       "Restaurant: There are 3 restaurants nearby.",
    #       verbatimTextOutput("Click_text")
    #     ))
    #   ),
    #   tabPanel("Compare", "Tab content 2")
    # ),
  )
)
