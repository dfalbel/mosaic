#' <Add Title>
#'
#' <Add Description>
#'
#' @import htmlwidgets
#'
#' @export
mosaic <- function(server, spec, width = NULL, height = NULL, elementId = NULL) {

  print("server")
  print(server)

  # forward options using x
  x = list(
    api = paste0(server),
    spec = spec
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


mosaicUI <- function(id) {
  ns <- NS(id)
  tagList(
    
  )
}

#' Adds a mosaic server like infrastructure for a 
#' duckdb connection. The same di can then be used
#' in mosaic plot widgets.
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

