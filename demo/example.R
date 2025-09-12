library(shiny)
library(DBI)
library(base64enc)

ui <- fluidPage(
  mosaicDependencies(),
  shiny::actionButton("btn", "Click me")
)

con <- dbConnect(duckdb::duckdb(), dbdir=":memory:")
dbWriteTable(con, "mtcars", mtcars)

server <- function(input, output, session) {

  observeEvent(input$btn, {
    shinyjs::runjs("Mosaic.query({id: 1, text: 'Hello from Shiny!'});")
  })

  con <- duckdb::dbConnect(duckdb::duckdb(), dbdir=":memory:")
  dbWriteTable(con, "mtcars", mtcars)

  mosaicServer("mosaic1", con)
}

shinyApp(ui, server)
