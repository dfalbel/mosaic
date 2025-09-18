# mosaic

<!-- badges: start -->
[![R-CMD-check](https://github.com/dfalbel/mosaic/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/dfalbel/mosaic/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The **mosaic** package integrates R with the [Mosaic data visualization framework](https://uwdata.github.io/mosaic/) from UW Data, enabling scalable and interactive data visualization in R applications and documents.

## What is Mosaic?

[Mosaic](https://idl.uw.edu/mosaic/what-is-mosaic/) is a framework for linking databases and interactive views that enables:

- **Scalable visualizations** that handle millions of data points efficiently
- **Interactive dashboards** with client-side interactions
- **Database integration** with optimized query processing
- **Grammar of graphics** approach to visualization specification

## Installation

You can install the development version of mosaic from [GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pkg_install("dfalbel/mosaic")
```

## Quick Start

### Static Documents

For R Markdown documents or standalone HTML widgets:

```r
library(mosaic)

# Create a scatter plot specification
spec <- list(
  plot = list(
    mark = "dot",
    data = list(from = "cars"),
    x = "speed",
    y = "dist"
  )
)

# Generate the visualization
mosaic(spec, cars = cars)
```

### Shiny Applications

For interactive Shiny apps with server-side data processing:

```r
library(shiny)
library(mosaic)
library(DBI)

ui <- fluidPage(
  mosaicOutput("plot")
)

server <- function(input, output, session) {
  # Connect to database
  con <- dbConnect(duckdb::duckdb(), ":memory:")
  dbWriteTable(con, "mtcars", mtcars)

  # Register mosaic server
  api_id <- mosaicServer("mosaic_api", con)

  # Create plot
  output$plot <- renderMosaic({
    mosaic(
      api = api_id(),
      spec = list(
        plot = list(
          mark = "dot",
          data = list(from = "mtcars"),
          x = "mpg",
          y = "disp"
        )
      )
    )
  })
}

shinyApp(ui, server)
```

## Key Features

- **HTML Widget Integration**: Works in R Markdown, Jupyter notebooks, and standalone HTML
- **Shiny Support**: Full integration with Shiny applications
- **Database Backend**: Efficient data processing with DuckDB
- **Arrow Format**: Optimized data transfer using Apache Arrow

## Examples and Documentation

For complete examples, tutorials, and API documentation, visit the package website:

**🌐 [https://dfalbel.github.io/mosaic/](https://dfalbel.github.io/mosaic/)**

## Related Projects

- [Mosaic Framework](https://uwdata.github.io/mosaic/) - Core JavaScript visualization framework
- [Observable Plot](https://observablehq.com/plot/) - Grammar of graphics for web

## License

MIT © [Daniel Falbel](https://github.com/dfalbel)