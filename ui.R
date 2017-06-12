library(shiny)
library(leaflet)

shinyUI(
  pageWithSidebar(
    headerPanel("pete's shiny app"),
    sidebarPanel(
      h2('sidebar'),
      checkboxInput('indpak','Indian/Pakistani',TRUE),
      checkboxInput('burgers','burgers',TRUE)
      ),
    mainPanel(
      leafletOutput("map",width="100%")
    )
    )
    
  
  
)