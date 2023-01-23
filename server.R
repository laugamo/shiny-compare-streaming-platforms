

# Define output for Landing Page tab

#' @param input
#' @param output
#' @param session
#'
#' @return
#' @export
#'
#' @examples


#ServerLandingPage<-function(input,output,session){
server<-function(input,output,session){
  
  
  
  # Get data
  tv.streaming.data <- readRDS("final_data.rds")
  
  
  filtered.dt <- shiny::callModule(
    module = shinyWidgets::selectizeGroupServer,
    inline = FALSE,
    id = "my-filters",
    data = tv.streaming.data,
    vars = c("country", "streaming_platform", "type",  "listed_in", "rating", "director", "cast", "production_country")
  )
  
  
  max.speed.years <- 10
  speed.years <- max(tv.streaming.data$release_year) - max.speed.years
  
  
  # Create summary table -----------------------------------------------------------------------------------------
  best.option.dt <- reactive({
    
    data.table::setDT(filtered.dt())
    
    
    data <- data.table::data.table(
      `Streaming Platform` = character(),
      `Monthly Price` = numeric(),
      `Amount of Movies/Films`= numeric(),
      `New Films/Movies Introduction Delay` = numeric(),
      `Rotten Tomatoes Rating` = numeric()
    )
    
    selected.platforms <- unique(filtered.dt()$streaming_platform)
    
    
    # Add platform information if exists
    for(platform in unique(tv.streaming.data$streaming_platform)) {
      
      if(platform %in% selected.platforms) {
        
        new.row <- data.table::data.table(
          `Streaming Platform` = platform,
          `Monthly Price` = filtered.dt()[streaming_platform == platform]$price[1],
          `Amount of Movies/Films`= c(nrow(filtered.dt()[streaming_platform == platform])),
          `New Films/Movies Introduction Delay` = c(round(filtered.dt()[streaming_platform == platform & release_year >= speed.years & !is.na(year_added), mean(speed_introduction)],2)),
          `Rotten Tomatoes Rating` = c(round(filtered.dt()[streaming_platform == platform, mean(rotten_tomatoes, na.rm = TRUE)],2))
        )
        
        data <- data.table::copy(rbind(data, new.row))
        
      }
    }
    
    
    return.data <- data.table::copy(data)
    
    
  })
  
  
  
  
  output$summarytable <- DT::renderDataTable({
    DT::datatable(best.option.dt(),
                  options = list(scrollX = FALSE, info = FALSE, dom = 't'),
                  rownames= FALSE) %>%
      DT::formatStyle('Monthly Price', backgroundColor = DT::styleEqual(min(best.option.dt()$'Monthly Price', na.rm = TRUE), "mediumseagreen")) %>%
      DT::formatStyle('Amount of Movies/Films', backgroundColor = DT::styleEqual(max(best.option.dt()$'Amount of Movies/Films', na.rm = TRUE), "mediumseagreen")) %>%
      DT::formatStyle('New Films/Movies Introduction Delay', backgroundColor = DT::styleEqual(min(best.option.dt()$'New Films/Movies Introduction Delay', na.rm = TRUE), "mediumseagreen")) %>%
      DT::formatStyle('Rotten Tomatoes Rating', backgroundColor = DT::styleEqual(max(best.option.dt()$'Rotten Tomatoes Rating', na.rm = TRUE), "mediumseagreen"))
    
  })
  
  
  
  # Create histograms -----------------------------------------------------------------------------------------
  
  output$countbystream <- renderPlot({
    
    
    ggplot2::ggplot(filtered.dt()[ !is.na(year_added)], ggplot2::aes(x = as.character(year_added), fill = as.factor(streaming_platform))) +
      ggplot2::geom_histogram( stat="count", position = "identity", alpha = 0.4, bins = 50) +
      theme(legend.title=element_blank(),
            axis.title.x=element_blank()) 
    #+ theme_classic()
    
    
  })
  
  
  
  original.percentage.dt <- reactive({
    
    data.table::setDT(filtered.dt())
    
    
    data <- data.table::data.table(
      streaming_platform = character(),
      original_percentage = numeric()
    ) 
    
    selected.platforms <- unique(filtered.dt()$streaming_platform)
    
    
    # Add platform information if exists
    for(platform in unique(tv.streaming.data$streaming_platform)) {
      
      if(platform %in% selected.platforms) {
        
        new.row <- data.table::data.table(
          streaming_platform = platform,
          original_percentage = round((nrow(filtered.dt()[streaming_platform == platform & !is.na(is_self_production) & is_self_production == 1])/nrow(filtered.dt()[streaming_platform == platform & !is.na(is_self_production)]))*100,2)
        )
        
        data <- data.table::copy(rbind(data, new.row))
        
      }
    }
    
    
    return.data <- data.table::copy(data)
    
  })
  
  
  output$original <- renderPlot({
    
    ggplot(original.percentage.dt(), aes(x=streaming_platform, y=original_percentage)) + 
      geom_bar(stat = "identity", fill="#79CDCD") +
    theme(axis.title.x=element_blank()) +
      labs(y="%")
    
    
  })
  
  

  
  output$original_evolution <- renderPlot({
    
    data <- data.table::copy(filtered.dt()[!is.na(is_self_production), .(original_anual_percentage = round(sum(is_self_production)/.N*100),2),
                                                       by = c("streaming_platform", "year_added")])
    
    ggplot2::ggplot(data, aes(x=year_added, y=original_anual_percentage, fill =as.factor(streaming_platform))) + 
      ggplot2::geom_bar(stat = "identity", position = "identity", alpha = 0.4) +
      ggplot2::theme(axis.title.x=element_blank(),
            legend.title=element_blank()) +
      ggplot2::labs(y="%")
    
    
  })
  
  
  
  
  
  
  
}
