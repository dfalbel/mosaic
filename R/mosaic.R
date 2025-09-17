#' Create a Mosaic Widget
#'
#' Create a Mosaic widget that can be used in R Markdown documents, 
#' Shiny apps, and the R console.
#' 
#' @param spec A list representing the Mosaic specification. See the
#'  [specification format reference](https://idl.uw.edu/mosaic/api/spec/format.html)
#'  for details.
#' @param ... Named data frames to be used in the plot. Each data frame will be
#'  added to the spec in an efficient format so it can be used in the plot.
#' @param api An optional string identifier for a server-side data API. This can be
#'  used to fetch data from a server-side DuckDB database. It's only used in Shiny apps
#'  in combination with [mosaicServer()].
#' @param width The width of the widget (optional). Note that this overrides any
#'  width specified in the spec.
#' @param height The height of the widget (optional). Note that this overrides any
#'  height specified in the spec.
#' @param elementId An optional element ID for the widget.
#'
#' @import htmlwidgets
#'
#' @export
mosaic <- function(spec, ..., api = NULL, width = NULL, height = NULL, elementId = NULL) {

  # Data is passed to the client side in an efficient format 
  # and added inline to the spec so it can be used in the plot.
  # make sure it's named.
  data <- list(...)
  stopifnot(all(sapply(data, is.data.frame)))
  
  # forward options using x
  x <- list(
    api = api,
    spec = spec,
    data = if (length(data)) data else NULL
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'mosaic',
    x,
    width = width,
    height = height,
    package = 'mosaic',
    elementId = elementId
  )
}

#' Shiny bindings for mosaic
#'
#' Output and render functions for using mosaic within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a mosaic
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name mosaic-shiny
#'
#' @export
mosaicOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'mosaic', width, height, package = 'mosaic')
}

#' @rdname mosaic-shiny
#' @export
renderMosaic <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, mosaicOutput, env, quoted = TRUE)
}


#' Mosaic Server
#' 
#' Creates and registers a global mosaic API, coordinator and connector
#' that can be acessed from js using: 
#' 
#' ```js
#' window.[id]
#' window.[id + "_coordinator"]
#' window.[id + "_connector"]
#' ```
#' 
#' This function is intended to be used in Shiny apps in combination with
#' the `api` parameter of the [mosaic()] function. Allowing you to create
#' plots that fetch data from a server-side DuckDB database, so you don't
#' need to send large datasets to the client.
#' 
#' @param id The id of the module.
#' @param connection A DBI connection to a DuckDB database.
#' 
#' @returns A shiny reactive that returns the id of the API.
#' 
#' @export
mosaicServer <- function(id, connection) {
  ns <- NS(id)
  con <- connection
  shiny::moduleServer(id, function(input, output, session) {

    session$sendCustomMessage("register_mosaic_api", list(ns = id))

    observeEvent(input$mosaic_query, {
      query <- input$mosaic_query
      output <- list(id = query$id, query = query)

      tryCatch({
        if (query$type == "arrow") {
          res <- duckdb::duckdb_fetch_arrow(dbSendQuery(connection, query$sql, arrow = TRUE))
          output$result <- base64encode(arrow::write_to_raw(res, format = "stream"))
        } else {
          stop("Not supported yet")
        }
      }, error = function(e) {
        output$error <<- conditionMessage(e)
      })
      
      session$sendCustomMessage(ns("mosaic_reply"), output)
    })

    shiny::reactive(id)
  })
}

