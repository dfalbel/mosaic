mosaicDependencies <- function() {
  shiny::tagList(
    htmltools::htmlDependency(
      name = "mosaic-assets", 
      version = "0.1",
      package = "mosaic",
      src = "assets",
      script = list(
        src = "js/mosaic.js",
        type = "module"
      )
    )
  )
}

