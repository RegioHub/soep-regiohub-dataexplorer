library(shiny)
library(echarts4r)

lineChartUI <- function(id, title = id) {
  ns <- NS(id)
  tagList(
    h4(title),
    echarts4rOutput(ns("chart"), height = "100%")
  )
}

lineChartServer <- function(id, data, leaflet_map) {
  moduleServer(
    id,
    function(input, output, session) {
      output$chart <- renderEcharts4r({
        data()[[id]] |>
          e_charts(year) |>
          e_tooltip(
            order = "valueDesc",
            trigger = "axis",
            appendToBody = TRUE # Shown even when overflowing grid boundaries
          )
      })

      # https://stackoverflow.com/a/41199134
      map_selected_regions <- reactiveValues(current = character(), last = character())

      observe({
        map_selected_regions$last <- map_selected_regions$current
        map_selected_regions$current <- leaflet_map$curr_sel_data()[["name"]]
      }) |>
        bindEvent(leaflet_map$curr_sel_data())

      current_regions <- reactive({
        intersect(map_selected_regions$current, names(data()[[id]]))
      })

      last_regions <- reactive(map_selected_regions$last)

      observe({
        added_regions <- setdiff(current_regions(), last_regions())

        removed_regions <- setdiff(last_regions(), current_regions())

        proxy <- echarts4rProxy(paste0(id, "-chart"), data()[[id]], year)

        if (length(added_regions)) {
          proxy |>
            Reduce(e_line_p_, added_regions, init = _) |>
            e_execute()
        }

        if (length(removed_regions)) {
          proxy |>
            Reduce(e_remove_serie_p, removed_regions, init = _)
        }
      })
    }
  )
}

e_line_p_ <- function(e, serie, bind, name = NULL, legend = TRUE,
                      y_index = 0, x_index = 0, coord_system = "cartesian2d", ...) {
  stopifnot(inherits(e, "echarts4rProxy"))
  stopifnot(is.character(serie) && length(serie) == 1L)
  if (missing(bind)) {
    bd <- NULL
  } else {
    bd <- deparse(substitute(bind))
  }
  e$chart <- e_line_(e$chart, serie, bd, name, legend, y_index, x_index, coord_system, ...)
  e
}
