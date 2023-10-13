# Restaurant - Filter Variables
review_amount_step_size <- 100
min_review_amount <- min(restaurants$num_reviews)
max_review_amount <- max(restaurants$num_reviews)
upper_review_amount <- 1000
upper_review_amount_plus <- paste0(upper_review_amount, "+")
rounded_review_amounts <- seq(ceiling(min_review_amount / upper_review_amount) * review_amount_step_size, 
                              floor(upper_review_amount / review_amount_step_size) * review_amount_step_size, by = review_amount_step_size)
review_amounts <- c(rounded_review_amounts, upper_review_amount_plus)
ratings <- seq(0, 5)
price_levels <- sort(unique(restaurants$price_level))
price_levels_dollar <- c('All', "$", "$$ - $$$", "$$$$")

# UI - configurations
chart_box_height <- 575
res_cuisine_chart_id <- "res_cuisine"
res_topn_chart_id <- "res_topn_rating"
res_suburb_filter_id <- "res_suburb"
res_special_options <- list("Vegetarian" = "serves_vegetarian_food", "Wine" = "serves_wine", "Delivery" = "delivery", "Reservable" = "reservable")
res_special_options_tableau <- list("Vegetarian" = "Serves Vegetarian Food", "Wine" = "Serves Wine", "Delivery" = "Delivery", "Reservable" = "Reservable")

# UI - components
restaurant_tab <- tabItem(
  tabName = "restaurant",
  h1("Restaurant"),
  fluidRow(
    column(9,
           fluidRow(
             infoBoxOutput("res_total_amount"),
             infoBoxOutput("res_best_cuisine"),
             infoBoxOutput("res_best_restaurant")
           ),
           fluidRow(
             box(width = 6, status = 'primary',
                 height = chart_box_height + 20, tableauPublicViz(id = res_cuisine_chart_id,
                                                                  url = "https://public.tableau.com/views/CuisineDistribution/Cuisine?:language=en-GB&publish=yes&:display_count=n&:origin=viz_share_link", 
                                                                  height = paste0(chart_box_height + 34, "px"))),
             box(width = 6, status = 'primary',
                 height = chart_box_height + 20, tableauPublicViz(id = res_topn_chart_id, 
                                                                  url = "https://public.tableau.com/views/Top10RatedRestaurants/TopN?:language=en-GB&publish=yes&:display_count=n&:origin=viz_share_link", 
                                                                  height = paste0(chart_box_height + 34, "px"))  
             )
           )),
    
    box(width = 3, height = 700, status = "warning",title = "Filters",
        HTML('<label class="control-label" id="res-suburb-filter-label" for="num_review">Suburbs</label>'),
        leafletOutput(res_suburb_filter_id, width = "100%", height = "300px"),
        pickerInput(inputId = "res_price_level",label = "Price Level", choices = price_levels_dollar), 
        sliderTextInput(inputId = "res_num_review", label = "Number of Reviews", 
                        choices = review_amounts, selected = c(min_review_amount, upper_review_amount_plus),
                        grid = TRUE),
        awesomeCheckboxGroup(inputId = "res_special_options", label = "Special Options", choices = names(res_special_options))
    )
  ))

render_res_suburb_filter_unselected <- function() {
  base_map <- leaflet(options = leafletOptions(zoomControl = FALSE, dragging = FALSE, minZoom = 12, maxZoom = 12, doubleClickZoom= FALSE, attributionControl=FALSE))  %>%
    addProviderTiles(providers$CartoDB.Positron) %>%
    addPolygons(data = suburb_boundary, label = ~featurenam, group = "original", weight = 2, color = "#000000",
                highlightOptions = highlightOptions(fillColor = "#628bcf", fillOpacity = 0.6, weight = 2, bringToFront = TRUE),
                layerId = ~featurenam)
  return(base_map)
}

render_res_suburb_filter_selected <- function(selected_suburb = NULL) {
  unselected_polygon <- leafletProxy(res_suburb_filter_id) %>% 
    addPolygons(data = suburb_boundary, label = ~featurenam, group = "original", weight = 2, color = "#000000",
                highlightOptions = highlightOptions(fillColor = "#628bcf", fillOpacity = 0.6, weight = 2, bringToFront = TRUE),
                layerId = ~featurenam)
  if(!is.null(selected_suburb)) {
    suburb_data <- suburb_boundary[suburb_boundary$featurenam == selected_suburb, ]
    unselected_polygon %>% addPolygons(data = suburb_data, layerId = selected_suburb, label = ~featurenam, weight = 2, fillOpacity = 0.6, fillColor = "#628bcf",color = "#000000")
  }
}