#' ShinyServer
#' @description Main server
#' @param input Basic and required parameter for defining a server app.
#' @param output Basic and required parameter for defining a server app.
#' @param session Basic and required parameter for defining a server app.
#'
#' @return Does not return an object. The script generates different outputs used along the app.
#' @export
#' @include compareTVdata_shiny_server_landingpage.R
#'
#' @examples


ShinyServer <- function(input = input,
                        output = output,
                        session = session) {
  
  ServerLandingPage(input = input,
                    output = output,
                    session = session)
  
}
