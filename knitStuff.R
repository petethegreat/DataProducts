#!/usr/bin/Rscript

# library(knitr)
library(rmarkdown)
#knit('StatsNotes.Rmd')
#pandoc('StatsNotes.md',format='latex')
#markdownToHTML('StatsNotes.md','StatsNotes.html')
# render('StatsNotes.Rmd',output_format='all')
render('Restaurants.Rmd',output_format='html_document')
render('movies.Rmd',output_format='html_document')
# change output to all once things are looking good.
# knit('MachineLearning.Rmd')
# pandoc('MachineLearning.md',format='latex')
# markdownToHTML('MachineLearning.md','MachineLearning.html')
# knit2html('PA1_template.Rmd','PA1_template.html')


