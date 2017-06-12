library(shiny)
library(leaflet)

# makeMap
# this function loads restaurant information from a csv file into a dataframe
# The dataframe is then sliced by restaurant category
# A leaflet map of Toronto is generated, and restaurant markers are added to it
# each category is assigned a seperate group, so that they may be toggled later
makeMap<-function()
{
  # load the data 
  data<-read.csv('yelpData.csv')
  # set up color pallette
  pal<-colorFactor('Set1',domain=levels(data$category))
  
  # map the rating to a Yelp stars image
  # ratings are in increments of 0.5, so we could simplify this
  data$starsimage=""
  data$starsimage[data$rating < 1.0] <- '<img src="assets/small_0.png">'
  data$starsimage[data$rating >= 1.0 & data$rating < 1.5] <- '<img src="assets/small_1.png">'
  data$starsimage[data$rating >= 1.5 & data$rating < 2.0] <- '<img src="assets/small_1_half.png">'
  data$starsimage[data$rating >= 2.0 & data$rating < 2.5] <- '<img src="assets/small_2.png">'
  data$starsimage[data$rating >= 2.5 & data$rating < 3.0] <- '<img src="assets/small_2_half.png">'
  data$starsimage[data$rating >= 3.0 & data$rating < 3.5] <- '<img src="assets/small_3.png">'
  data$starsimage[data$rating >= 3.5 & data$rating < 4.0] <- '<img src="assets/small_3_half.png">'
  data$starsimage[data$rating >= 4.0 & data$rating < 4.5] <- '<img src="assets/small_4.png">'
  data$starsimage[data$rating >= 4.5 & data$rating < 4.95] <- '<img src="assets/small_4_half.png">'
  data$starsimage[data$rating >= 4.95] <- '<img src="assets/small_5.png">'
  
  #popup content
  data$content<-paste(
    sep='<br/>',
    paste(sep='',
          '<a href="https://www.yelp.ca/biz/',
          data$yelpid,
          '">',
          data$name,
          '</a>'),
    data$starsimage,
    data$rating,
    paste(data$reviews,
          'reviews'
          )
    )
  
  # subset data based on category
  # will have a difference marker df per group
  data$category <- as.factor(data$category)
  # subset data
  categories<-levels(data$category)
  catlist<-lapply(categories,function(x) { data[data$category==x,]})
  names(catlist)<-categories
  
  # provider tiles. These will give a black and white (grayish) map
  # so coloured markers will stand out
  streetprovider<-providers$CartoDB.PositronNoLabels
  labelprovider<-providers$CartoDB.PositronOnlyLabels
  # providers$Stamen.TonerLabels
  map<- leaflet() %>% setView(lng = -79.4, lat = 43.65, zoom = 12) %>%
    addProviderTiles(streetprovider,
                     options = providerTileOptions(opacity = 0.45)) %>%
    addProviderTiles(labelprovider)
  # add all the markers/popups
  for (cat in categories)
  {
    map<-map %>% addCircleMarkers(
      data=data[data$category == cat,],
      color=pal(cat),
      stroke=FALSE,
      fillOpacity=~rating/5.0,
      # clusterOptions=markerClusterOptions(),
      group=cat,
      label=~name, #htmlEscape(name)
      popup=~content,
      popupOptions=popupOptions(minWidth=100)
      )
  }
  # add legend to map
  map<-map %>% addLegend("topright",pal=pal,values=levels(data$category))
  # return a list containing the category names and the map
  thelist<-list(map,categories)
  return(thelist)
  
}

# server function
shinyServer(
  function(input,output,session)
  {
    # get the map and categories
    maplist<-makeMap()
    map<-maplist[[1]]
    catlist<-maplist[[2]]
    # draw the map
    output$map<-renderLeaflet(map)
    
    # Category Observers
    # These are reflexive. They look for ui interaction
    # The observer/proxy stuff means that the entire map is not redrawn when a checkbox is clicked
    
    # burgers
    observe(
      {
        proxy <- leafletProxy("map")
        if(input$burgers)
        {
          proxy %>% showGroup('burgers')
        }
        else 
        {
          proxy %>% hideGroup('burgers')
        }
      })
    # chinese 
    observe(
      {
        proxy <- leafletProxy("map")
        if(input$chinese)
        {
          proxy %>% showGroup('chinese')
        }
        else 
        {
          proxy %>% hideGroup('chinese')
        }
      })
    # french 
    observe(
      {
        proxy <- leafletProxy("map")
        if(input$french)
        {
          proxy %>% showGroup('french')
        }
        else 
        {
          proxy %>% hideGroup('french')
        }
      })
    # indpak 
    observe(
      {
        proxy <- leafletProxy("map")
        if(input$indpak)
        {
          proxy %>% showGroup('indpak')
        }
        else 
        {
          proxy %>% hideGroup('indpak')
        }
      })
    # italian 
    observe(
      {
        proxy <- leafletProxy("map")
        if(input$italian)
        {
          proxy %>% showGroup('italian')
        }
        else 
        {
          proxy %>% hideGroup('italian')
        }
      })
    # mexican 
    observe(
      {
        proxy <- leafletProxy("map")
        if(input$mexican)
        {
          proxy %>% showGroup('mexican')
        }
        else 
        {
          proxy %>% hideGroup('mexican')
        }
      })
    # mideastern 
    observe(
      {
        proxy <- leafletProxy("map")
        if(input$mideastern)
        {
          proxy %>% showGroup('mideastern')
        }
        else 
        {
          proxy %>% hideGroup('mideastern')
        }
      })
    # steak 
    observe(
      {
        proxy <- leafletProxy("map")
        if(input$steak)
        {
          proxy %>% showGroup('steak')
        }
        else 
        {
          proxy %>% hideGroup('steak')
        }
      })
    # sushi 
    observe(
      {
        proxy <- leafletProxy("map")
        if(input$sushi)
        {
          proxy %>% showGroup('sushi')
        }
        else 
        {
          proxy %>% hideGroup('sushi')
        }
      })
    
    
  }
)
