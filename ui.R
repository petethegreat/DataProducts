library(shiny)
library(leaflet)

shinyUI(
  pageWithSidebar(
    headerPanel("Toronto Restaurants"),
    sidebarPanel(
      h2('Categories'),
      checkboxInput('burgers','burgers',TRUE),
      checkboxInput('chinese','Chinese',TRUE),
      checkboxInput('french','French',TRUE),
      checkboxInput('indpak','Indian/Pakistani',TRUE),
      checkboxInput('italian','Italian',TRUE),
      checkboxInput('mexican','Mexican',TRUE),
      checkboxInput('mideastern','Middle Eastern',TRUE),
      checkboxInput('steak','Steakhouse',TRUE),
      checkboxInput('sushi','Sushi',TRUE),
      h5('Help'),
      p('Select the restaurant categories to display in the map'),
      p('Restaurant names will be displayed on mouseover'),
      p('A link to the restaurant\'s Yelp page (as well as it\'s rating) will be displayed when a marker is clicked')
      ),
    mainPanel(
      tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}"),
      leafletOutput("map")
    )
    )
    
  
  
)