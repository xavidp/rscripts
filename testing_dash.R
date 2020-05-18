if (F) {
  install.packages(c("fiery", "routr", "reqres", "htmltools", "base64enc", "plotly", "mime", "crayon", "devtools"))
  library(devtools)
  install_github("plotly/dash-html-components")
  install_github("plotly/dash-core-components")
  install_github("plotly/dash-table")
  install_github("plotly/dashR")
}
library(dash)
library(dashHtmlComponents)
library(dashCoreComponents)
app <- Dash$new()

app$layout(
  dccInput(id = "graphTitle", 
           value = "Let's Dance!", 
           type = "text"),
  htmlDiv(id = "outputID"),
  dccGraph(id = "giraffe",
           figure = list(
             data = list(x = c(1,2,3), y = c(3,2,8), type = 'bar'),
             layout = list(title = "Let's Dance!")
           )
  )
)

app$callback(output = list(id = "giraffe", property = "figure"), 
             params = list(input("graphTitle", "value")),     
             function(newTitle) {
               
               rand1 <- sample(1:10, 1)
               
               rand2 <- sample(1:10, 1)
               rand3 <- sample(1:10, 1)
               rand4 <- sample(1:10, 1)
               
               x <- c(1,2,3)
               y <- c(3,6,rand1)
               y2 <- c(rand2,rand3,rand4)
               
               df = data.frame(x, y, y2)
               
               list(
                 data = 
                   list(            
                     list(
                       x = df$x, 
                       y = df$y, 
                       type = 'bar'
                     ),
                     list(
                       x = df$x, 
                       y = df$y2, 
                       type = 'scatter',
                       mode = 'lines+markers',
                       line = list(width = 4)
                     )                
                   ),
                 layout = list(title = newTitle)
               )
             }
)

app$callback(output = list(id = "outputID", property = "children"), 
             params = list(input("graphTitle", "value"),
                           state("graphTitle", "type")), 
             function(x, y) {
               sprintf("You've entered: '%s' into a '%s' input control", x, y)
             }
)

app$run_server(showcase = TRUE)

