# Define UI --------------------------------------------------------------------
#' UI for shiny app
#'
#' @return Does not return an object. Call ShinyUi define the HTML shiny app's layer.
#' @export
#' @include shiny_server.R  shiny_ui_landingpage.R
#'
#' @examples
ShinyUi <-function(){
  
  
  # 1. HEADRER: Item for total dashboard header, option for right side bar ---------------------------------------------------
  header <- shinydashboardPlus::dashboardHeader(title = "Which streaming service should I get?",
                                                disable = FALSE,
                                                titleWidth = 900
                                                
  )
  
  
  # 2. SIDEBAR: Item for having a left sidebar and items on a menu to navigate -----------------------------------------------
  sidebar <- shinydashboard::dashboardSidebar(UiLandingPage()$sidebarmenu,
                                              
                                              shinyWidgets::selectizeGroupUI(
                                                id = "my-filters",
                                                inline = FALSE,
                                                params = list(
                                                  country = list(inputId = "country",
                                                                 title = "Country you are based:",
                                                                 placeholder = 'All'),
                                                  streaming_platform = list(inputId = "streaming_platform",
                                                                            title = "Streaming platforms to compare:",
                                                                            placeholder = 'All'),
                                                  type = list(inputId = "type",
                                                              title = "Films or Movies?:",
                                                              placeholder = 'All'),
                                                  # idiom = list(inputId = "idiom",
                                                  #             title = "Idiom",
                                                  #             placeholder = 'All'),
                                                  listed_in = list(inputId = "listed_in",
                                                                   title = "Genre",
                                                                   placeholder = 'All'),
                                                  rating = list(inputId = "rating",
                                                                title = "Age classification",
                                                                placeholder = 'All'),
                                                  # decate = list(inputId = "decate",
                                                  #              title = "Decates",
                                                  #              placeholder = 'All'),
                                                  director = list(inputId = "director",
                                                                  title = "Director",
                                                                  placeholder = 'All'),
                                                  cast = list(inputId = "cast",
                                                              title = "Any actress or actor prefered?",
                                                              placeholder = 'All'),
                                                  production_country = list(inputId = "production_country",
                                                                            title = "Production Country",
                                                                            placeholder = 'All')
                                                  
                                                )
                                              )
                                              
                                            
  )
  
  
  
  # 3. BODY:  Item for main body of dashboard -------------------------------------------------------
  body = shinydashboard::dashboardBody(
    tags$head(
      tags$style(
        shiny::HTML('
               .form-group, .selectize-control {
               margin-bottom: 0px;
               }
               .body {
               padding-bottom: 0px;
               }'))),
    
    # Items for content of tabs based on the menu on the left sidebar
    shinydashboard::tabItems(UiLandingPage()$body)
  )
  

  ## put UI together --------------------
  ui <- shinydashboard::dashboardPage(header, sidebar, body )
  
  
}
