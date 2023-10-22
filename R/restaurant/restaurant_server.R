# Events name
suburb_filter_click_event <- paste0(res_suburb_filter_id, "_click")
suburb_filter_shape_click_event <- paste0(res_suburb_filter_id, "_shape_click")

# Generate javascript code to work with Tableau graphs
generate_filtering_script <- function(type, value, action) {
  if(type == 'suburb'){
    if(value == 'All') {
      script <- 'sheet.clearFilterAsync("Suburb");'
    } else {
      script <- sprintf('sheet.applyFilterAsync("Suburb", ["%s"], FilterUpdateType.Replace);', value)
    }
  }else if(type == 'price_level'){
    if(value == 'All') {
      script <- 'sheet.clearFilterAsync("Price Level");'
    } else {
      if(value == "$$ - $$$") {
        script <- 'sheet.applyFilterAsync("Price Level", ["2", "3"], FilterUpdateType.Replace);'
      } else {
        script <- sprintf('sheet.applyFilterAsync("Price Level", ["%s"], FilterUpdateType.Replace);', nchar(value))
      }
    }
  }else if(type == 'num_review'){
    script <- sprintf('sheet.applyRangeFilterAsync("Num Reviews", {min: %s, max: %s}, FilterUpdateType.Replace)', value[1], ifelse(value[2] == upper_review_amount_plus, max_review_amount, value[2]))
  }else if(type == 'special_options'){
    if(action == 'remove') {
      script <- sprintf('sheet.clearFilterAsync("%s");', res_special_options_tableau[[value]])
    } else if (action == 'add'){
      script <- sprintf('sheet.applyFilterAsync("%s", ["True"], FilterUpdateType.Replace);', res_special_options_tableau[[value]])
    } else {
      stop(action, " not supported.")
    }
  } else {
    stop(type, ' is not supported.')
  }
  return(script)
}

# Trigger script to update Tableau charts
update_tableau_charts <- function(filter_type, filter_value, filter_action = NULl) {
  filter_script <- generate_filtering_script(filter_type, filter_value, filter_action)
  # Update Cuisine Pie Chart
  runjs(sprintf('let viz = document.getElementById("%s"); let sheet = viz.workbook.activeSheet;%s', res_cuisine_chart_id, filter_script))
  # Update Top N Chart
  runjs(sprintf('let viz = document.getElementById("%s");let sheet = viz.workbook.activeSheet;%s', res_topn_chart_id, filter_script))
}

# Apply filters to original data to be used for stigmatization value boxes
apply_filter_to_data <- function(res_data, sub, p_level, num_reviews_range, special_options) {
  if(sub != 'All') res_data <- res_data %>% filter(suburb == sub)
  if(p_level != 'All') {
    if(p_level == '$$ - $$$') {
      res_data <- res_data %>% filter(price_level %in% c(2, 3))  
    } else {
      res_data <- res_data %>% filter(price_level == nchar(p_level))
    }
  }
  res_data <- res_data %>% filter(num_reviews >= as.numeric(num_reviews_range[1]) & num_reviews <= ifelse(num_reviews_range[2] == upper_review_amount_plus, max_review_amount, as.numeric(num_reviews_range[2])))
  for(sp in special_options) {
    col <- res_special_options[[sp]]
    res_data <- res_data %>% filter(!!as.symbol(col) == TRUE)
  }
  amount <- nrow(res_data)
  best_res <- (res_data %>% arrange(desc(rating)))[1, ][['name']]
  best_cuisine <- (res_data %>% group_by(cuisine) %>% summarise(count = n()) %>% arrange(desc(count)) %>% head(1))[['cuisine']]
  return(c(amount, best_res, best_cuisine))
}

# Restaurant related server functions
restaurantServer <- function(input, output, session) {
  reactive_res_sum_data <- reactive({
    return(apply_filter_to_data(restaurants, reactive_values$res_suburb, input$res_price_level, input$res_num_review, input$res_special_options))
  })
  
  output$res_total_amount <- renderInfoBox({
    infoBox("Number of Restaurants", reactive_res_sum_data()[1], width = 4, color = "light-blue", fill = TRUE, icon = icon("hashtag"))
  })
  
  output$res_best_cuisine <- renderInfoBox({
    infoBox("Most Popular Cuisine", reactive_res_sum_data()[3], width = 4, color = "yellow", fill = TRUE, icon = icon("utensils"))  
  })
  
  output$res_best_restaurant <- renderInfoBox({
    infoBox("Best Rated Restaurant", reactive_res_sum_data()[2], width = 4, color = "green", fill = TRUE, icon = icon("house"))  
  })
  
  reactive_values <- reactiveValues(res_suburb = 'All', old_special_options = NULL)
  output[[res_suburb_filter_id]] <-  renderLeaflet({render_res_suburb_filter_unselected()})
  
  # Track event of suburb filter to update the UI correspondingly
  observeEvent(input[[suburb_filter_click_event]], {
    suburb_filter_shape_click_info <- input[[suburb_filter_shape_click_event]]
    suburb_filter_click_info <- input[[suburb_filter_click_event]]
    if(!is.null(suburb_filter_shape_click_info) &&
       !is.null(suburb_filter_click_info) &&
       all(unlist(suburb_filter_shape_click_info[c('lat', 'lng')]) == unlist(suburb_filter_click_info[c('lat', 'lng')]))) {
      render_res_suburb_filter_selected(suburb_filter_shape_click_info$id)
      reactive_values$res_suburb <- suburb_filter_shape_click_info$id
      update_tableau_charts('suburb', suburb_filter_shape_click_info$id)
    } else {
      render_res_suburb_filter_selected(NULL)
      reactive_values$res_suburb <- 'All'
      update_tableau_charts('suburb', 'All')
    }
  })
  
  observeEvent(input$res_price_level, {
    update_tableau_charts('price_level', input$res_price_level)
  }, ignoreInit = TRUE)
  
  observeEvent(input$res_num_review, {
    update_tableau_charts('num_review', input$res_num_review)
  }, ignoreInit = TRUE)
  
  observeEvent(input$res_special_options, {
    if(length(input$res_special_options) > length(reactive_values$old_special_options)) {
      update_tableau_charts('special_options', setdiff(input$res_special_options, reactive_values$old_special_options), "add")
    } else {
      update_tableau_charts('special_options', setdiff(reactive_values$old_special_options, input$res_special_options), "remove")
    }
    reactive_values$old_special_options <- isolate(input$res_special_options)
  }, ignoreNULL = FALSE, ignoreInit = TRUE)
}