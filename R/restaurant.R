source('tableau-in-shiny-v1.0.R')

# Import Data
restaurants <- read_csv("data/restaurant/melbourne_restaurants.csv")
suburb_boundary <- st_read("data/restaurant/suburbs_data.geojson")

# Filter Variables
review_amount_step_size <- 1000
min_review_amount <- min(restaurants$num_reviews)
max_review_amount <- max(restaurants$num_reviews)
rounded_review_amounts <- seq(ceiling(min_review_amount / max_review_amount) * review_amount_step_size, 
                              floor(max_review_amount / review_amount_step_size) * review_amount_step_size, by = review_amount_step_size)
review_amounts <- c(rounded_review_amounts, max_review_amount)
ratings <- seq(0, 5)
price_levels <- sort(unique(restaurants$price_level))
price_levels_dollar <- c('All', strrep("$", price_levels))

# UI
chart_box_height <- 575
res_cuisine_chart_id <- "res_cuisine"
res_topn_chart_id <- "res_topn_rating"
res_suburb_filter_id <- "res_suburb"
res_special_options <- list("Vegetarian" = "serves_vegetarian_food", "Wine" = "serves_wine", "Delivery" = "delivery", "Reservable" = "reservable")

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
                        choices = review_amounts, selected = c(min_review_amount, max_review_amount),
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

# Events
suburb_filter_click_event <- paste0(res_suburb_filter_id, "_click")
suburb_filter_shape_click_event <- paste0(res_suburb_filter_id, "_shape_click")

# Update Tableau Chart
generate_filtering_script <- function(type, value) {
  if(type == 'suburb'){
    script <- sprintf('sheet.applyFilterAsync("Suburb", ["%s"], FilterUpdateType.Replace);', value)
  }else if(type == 'price_level'){
    script <- sprintf('sheet.applyFilterAsync("Price Level", ["%s"], FilterUpdateType.Replace);', ifelse(value == 'All', 'All', nchar(value)))
  }else if(type == 'num_review'){
    script <- sprintf('sheet.applyRangeFilterAsync("Num Reviews", {min: %s, max: %s}, FilterUpdateType.Replace)', value[1], value[2])
  }else if(type == 'special_options'){
    script <- paste0(sapply(value, function(x) {sprintf('sheet.applyFilterAsync("%s", [%s], FilterUpdateType.Replace);', res_special_options[[x]], TRUE)}), collapse = "\n")
  } else {
    stop(type, ' is not supported.')
  }
  return(script)
}

update_tableau_charts <- function(filter_type, filter_value) {
  filter_script <- generate_filtering_script(filter_type, filter_value)
  browser()
  # Update Cuisine Pie Chart
  runjs(sprintf('let viz = document.getElementById("%s"); let sheet = viz.workbook.activeSheet;%s', res_cuisine_chart_id, filter_script))
  # Update Top N Chart
  runjs(sprintf('let viz = document.getElementById("%s");let sheet = viz.workbook.activeSheet;%s', res_topn_chart_id, filter_script))
}

apply_filter_to_data <- function(res_data, sub, p_level, num_reviews_range, special_options) {
  if(sub != 'All') res_data <- res_data %>% filter(suburb == sub)
  if(p_level != 'All') res_data <- res_data %>% filter(price_level  == nchar(p_level))
  res_data <- res_data %>% filter(num_reviews >= num_reviews_range[1] & num_reviews <= num_reviews_range[2])
  for(sp in special_options) {
    col <- res_special_options[[sp]]
    res_data <- res_data %>% filter(!!as.symbol(col) == TRUE)
  }
  amount <- nrow(res_data)
  best_res <- (res_data %>% arrange(desc(rating)))[1, ][['name']]
  best_cuisine <- (res_data %>% group_by(cuisine) %>% summarise(count = n()) %>% arrange(desc(count)) %>% head(1))[['cuisine']]
  return(c(amount, best_res, best_cuisine))
}

