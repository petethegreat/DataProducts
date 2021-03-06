library(shiny)
library(leaflet)

shinyUI(
  fluidPage(
    titlePanel('RestoMapp'),
    sidebarLayout(
      sidebarPanel(
        h3("Toronto Restaurants"),
        tabsetPanel
        (
          tabPanel("Controls",
                   sliderInput('ratingRange','Rating: ',min=0.0,max=5.0,step=0.5,value=c(0.0,5.0)),
                   uiOutput('catGroup')
                   ), # end tabPanel
          tabPanel("Help",
                   p('The map to the right shows Toronto Restaurants, colour coded by cuisine'),
                   p('Adjust the slider to filter restaurants based on their Yelp rating'),
                   p('select/deselect checkboxes to control which cuisine types will be displayed'),
                   p('Restaurant names will be displayed on mouseover'),
                   p('A link to the restaurant\'s Yelp page (as well as it\'s rating) will be displayed when a marker is clicked')
                   ) # end tabPanel
        ) # end tabsetPanel
      ), # end sidebarPanel
      mainPanel
      (
        tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}"),
        leafletOutput("map")
      ) # end mainPanel 
    ) # end sidebarLayout
  ) # end fluidPage
) # end shinyUI
