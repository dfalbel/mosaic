library(shiny)
library(DBI)
library(base64enc)

ui <- fluidPage(
  mosaicOutput("myplot")
)

con <- dbConnect(duckdb::duckdb(), dbdir=":memory:")
dbWriteTable(con, "flights", nycflights13::flights)

server <- function(input, output, session) {

  id <- mosaicServer("mosaic1", con)

  output$myplot <- renderMosaic({
    mosaic(
      api = id(),
      spec = list(
        plot = list(
          list(
            mark = "dot",
            data = list(from = "flights"),
            x = "dep_time",
            y = "dep_delay"
          )
        )
      )
    )
  })

}

shinyApp(ui, server)

