library(shiny)
library(leaflet)

# makeMap
# this function loads restaurant information from a csv file into a dataframe
# A leaflet map of Toronto is generated, and restaurant markers are added to it
# each category is assigned a seperate group, so that they may be toggled later
makeMap<-function()
{
  # load the data 
  data<-read.csv('yelpData.csv')
  # set up color palete
  # pal<-colorFactor('Set1',domain=levels(data$category))
  
  # map the rating to a Yelp stars image
  # ratings are in increments of 0.5, so we could simplify this
  data$starsimage=""
  data$starsimage[data$rating < 1.0] <- '<img src="small_0.png">'
  data$starsimage[data$rating >= 1.0 & data$rating < 1.5] <- '<img src="small_1.png">'
  data$starsimage[data$rating >= 1.5 & data$rating < 2.0] <- '<img src="small_1_half.png">'
  data$starsimage[data$rating >= 2.0 & data$rating < 2.5] <- '<img src="small_2.png">'
  data$starsimage[data$rating >= 2.5 & data$rating < 3.0] <- '<img src="small_2_half.png">'
  data$starsimage[data$rating >= 3.0 & data$rating < 3.5] <- '<img src="small_3.png">'
  data$starsimage[data$rating >= 3.5 & data$rating < 4.0] <- '<img src="small_3_half.png">'
  data$starsimage[data$rating >= 4.0 & data$rating < 4.5] <- '<img src="small_4.png">'
  data$starsimage[data$rating >= 4.5 & data$rating < 4.95] <- '<img src="small_4_half.png">'
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
  
  data$category <- as.factor(data$category)
  #list of categories in data
  categories<-levels(data$category)
  
  # provider tiles. These will give a black and white (grayish) map
  # so coloured markers will stand out
  streetprovider<-providers$CartoDB.PositronNoLabels
  labelprovider<-providers$CartoDB.PositronOnlyLabels
  map<- leaflet() %>% setView(lng = -79.4, lat = 43.65, zoom = 13) %>%
    addProviderTiles(streetprovider,
                     options = providerTileOptions(opacity = 0.45)) %>%
    addProviderTiles(labelprovider)
 
  # return a list containing the map, category names, and data
  thelist<-list(map,categories,data)
  return(thelist)
}

# server function
shinyServer(
  function(input,output,session)
  {
    # get the map and categories
    maplist<-makeMap()
    basemap<-maplist[[1]]
    catlist<-maplist[[2]]
    Data<-maplist[[3]]
    # set up the category->colour mapping
    pal<-colorFactor('Set1',domain=levels(Data$category))
    
    # create an input checkboxgroup based on the categories in our data
    output$catGroup<-renderUI(
      checkboxGroupInput
      (
        'categoryList',
        'Cuisine Categories:',
        catlist, # list of categories/choices
        catlist # list of those initially selected (all)
      )
    )
    
    # draw the map
    # add circle markers to it (all cats to start)
    map<-basemap %>%addCircleMarkers(
      data=Data,
      color=~pal(category),
      stroke=FALSE,
      fillOpacity=~rating/5.0,
      group=~category,
      label=~name, 
      popup=~content,
      popupOptions=popupOptions(minWidth=100)
    )
 
    output$map<-renderLeaflet(map)
    
    # Observer
    # This is reflexive. It looks for ui interaction
    # This will show/hide marker groups (categories) if the checkbox input is changed
    # (it depends on nothing else)
    # The leafletproxy means that the entire map is not redrawn, only updated when a checkbox is clicked

    observe(
      {
        proxy <- leafletProxy("map")
        #proxy %>% clearShapes()
        for (groupname in catlist)
        {
          if (groupname %in% input$categoryList)
          {
            proxy %>% showGroup(groupname)
          }
          else
          {
            proxy %>% hideGroup(groupname)
          }
        }

      })
    
    # Ratings Slider
    # Change which markers are shown based on the slider values
    # use observeEvent here, as we only need to invoke this method if slider values change,
    # but it also depends on the currently selected categories (input$categoryList)
    
    observeEvent(input$ratingRange,
      {
        # filter data based on slider
        minrat<-input$ratingRange[1]
        maxrat<-input$ratingRange[2]
        fd<- Data[(Data$rating >= minrat) & (Data$rating <= maxrat) ,]
        # clear/update marker groups
        proxy<-leafletProxy("map", data = fd) %>%
          clearMarkers() %>%
          addCircleMarkers(
            color=~pal(category),
            stroke=FALSE,
            fillOpacity=~rating/5.0,
            group=~category,
            label=~name, #htmlEscape(name)
            popup=~content,
            popupOptions=popupOptions(minWidth=100)
          )
        # go through the categories. Show/Hide groups based on input
        for (groupname in catlist)
        {
          if (groupname %in% input$categoryList)
          {
            proxy %>% showGroup(groupname)
          }
          else
          {
            proxy %>% hideGroup(groupname)
          }
        }
      }
    ) # end observeEvent

    
  } # end ShinyServer block
) # end ShinyServer
