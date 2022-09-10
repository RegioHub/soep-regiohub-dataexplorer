library(shiny)
library(shinyjs)
library(echarts4r)

lineChartUI <- function(id) {
  ns <- NS(id)
  tagList(
    echarts4rOutput(ns("chart"), height = "100%")
  )
}

lineChartServer <- function(id, varname, dataset, leaflet_map, charted_lines) {
  moduleServer(
    id,
    function(input, output, session) {
      output$chart <- renderEcharts4r({
        dataset()[[varname]] |>
          e_charts(year)
      })

      chart_id <- paste0(id, "-chart")

      observe({
        runjs(paste0("get_e_charts_series('", chart_id, "')"))

        charted_regions <- charted_lines()

        map_selected_regions <- leaflet_map$curr_sel_data()[["name"]]

        added_regions <- setdiff(map_selected_regions, charted_regions)

        removed_regions <- setdiff(charted_regions, map_selected_regions)

        proxy <- echarts4rProxy(chart_id, dataset()[[varname]], year)

        if (length(added_regions)) {
          proxy |>
            Reduce(e_line_p_, added_regions, init = _) |>
            e_execute()
        }

        if (length(removed_regions)) {
          proxy |>
            Reduce(e_remove_serie_p, removed_regions, init = _)
        }
      }) |>
        bindEvent(leaflet_map$curr_sel_data())
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
