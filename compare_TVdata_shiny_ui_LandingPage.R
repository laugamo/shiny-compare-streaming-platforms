#' uiLandingPage
#' @description Ui for landing page tab
#' @return A list that contains two objects. One for the sidebar layer and another for the body.
#' @export
#'
#' @examples
UiLandingPage<-function(){
  
  # Item for left sidebar menu navigation
  sidebarmenu_landingpage <-
    shinydashboard::sidebarMenu(id = "tabs",
                                shinydashboard::menuItem(text = "SELECT YOUR PREFERENCES:",
                                                         tabName = "landingpagetab"
                                                         #icon = shiny::icon("tv")
                                ))
  
  # Item for content of tab
  tabitem_landingpage <-
    shinydashboard::tabItem(tabName = "landingpagetab",
                            
                            
                            # Function for fluid layout, in rows for same line appearance
                            # fluidPage(
                            #   title = "Title Here",
                            
                            fluidRow(
                              #column(12,
                              
                              # Item for holding data table
                              shinydashboard::box(title = "",
                                                  
                                                  DT::dataTableOutput(outputId = "summarytable",
                                                                      width = "auto"),
                                                  width = "11")
                              # )
                            ),
                            # # Item for holding plot
                            # shinydashboard::box(title = "",
                            #                     plotly::plotlyOutput(outputId = "forecast_plot",
                            #                                          width = "auto",
                            #                                          height = "300px"))
                            fluidRow(
                              # Item for holding plot
                              shinydashboard::box(title = "",
                                                  plotOutput(outputId = "forecast_plot",
                                                             width = "auto",
                                                             height = "300px"),
                                                  width = "11")
                            )
                            
                            #)
    )
  
  landingpage.objects <- list("sidebarmenu" = sidebarmenu_landingpage,
                              "body"= tabitem_landingpage)
  
  return(landingpage.objects)
  
}




