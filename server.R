library(shiny)
library(leaflet)
makeMap<-function()
{
  # load the data 
  data<-read.csv('yelpData.csv')
  # set up marker/popup content
  pal<-colorFactor('Set1',domain=levels(data$category))
  # define a function to get the stars image based on rating
  # get stars image based on rating
  # looks like ratings are in multiples of 0.5, could probably simplify this
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
  
  streetprovider<-providers$CartoDB.PositronNoLabels
  labelprovider<-providers$CartoDB.PositronOnlyLabels
  # providers$Stamen.TonerLabels
  map<- leaflet() %>% setView(lng = -79.4, lat = 43.65, zoom = 12) %>%
    addProviderTiles(streetprovider,
                     options = providerTileOptions(opacity = 0.45)) %>%
    addProviderTiles(labelprovider)
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
  
  map<-map %>% addLegend("topright",pal=pal,values=levels(data$category))
  thelist<-list(map,categories)
  return(thelist)
  
}

#output$categories <- categories
#output$colours<-colours
# draw the legend in the sidebar
# implement the toggles/reactivity/proxy


shinyServer(
  function(input,output,session)
  {
    maplist<-makeMap()
    map<-maplist[[1]]
    catlist<-maplist[[2]]
    output$map<-renderLeaflet(map)
    #output$catlist<-catlist
    
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
        
      }
    )
  }
)
