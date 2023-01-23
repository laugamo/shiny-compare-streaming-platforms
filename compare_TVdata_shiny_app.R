#'
#' @return Does not return an object. This function only runs the app.
#' @export
#' @include shiny_ui.R shiny_server.R
#'
#' @examples


RunTVComparisonShinyApp<-function(){

  # -- Create Shiny object ------------
  shiny::shinyApp(ui = ShinyUi,
                  server = ShinyServer)
}


