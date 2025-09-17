library(shiny)
library(DBI)
library(base64enc)

ui <- fluidPage(
  mosaicOutput("myplot")
)

con <- dbConnect(duckdb::duckdb(), dbdir=":memory:")
dbWriteTable(con, "mtcars", mtcars)

server <- function(input, output, session) {

  con <- duckdb::dbConnect(duckdb::duckdb(), dbdir=":memory:")
  dbWriteTable(con, "mtcars", mtcars)

  id <- mosaicServer("mosaic1", con)

  output$myplot <- renderMosaic({
    mosaic(
      api = id(),
      spec = list(
        plot = list(
          list(
            mark = "dot",
            data = list(from = "mtcars"),
            x = "mpg",
            y = "disp"
          )
        )
      )
    )
  })

}

shinyApp(ui, server)
