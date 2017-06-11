library(shiny)


# load the data in this environment
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

data$category <- as.factor(data$category)
# subset data
categories<-levels(data$category)
catlist<-lapply(categories,function(x) { data[data$category==x,]})
names(catlist)<-categories


basemap<-leaflet()
shinyServer(
  function(input,output)
  {
    output$Map<-renderLeaflet()
  },
)
