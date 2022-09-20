library(shiny)
library(shinyjs)
library(leaflet)
library(echarts4r)
library(dplyr)

map_colour_pals <- list(data_long_nuts1, data_long_nuts3) |>
  lapply(\(level) {
    lapply(level, create_map_pal)
  })

function(input, output, session) {

  ## Startup ----

  disable("drill_up")

  map_drill_obj <- Leafdown2$new(
    spdfs_list = de_maps,
    map_output_id = "map_drill",
    drill_down_button_id = "drill_down",
    drill_up_button_id = "drill_up",
    input = input,
    join_map_levels_by = c("nuts1" = "nuts1")
  )

  update_map_drill <- reactiveVal(0)

  ## Monitor state of data selection ----

  map_level <- reactive(map_drill_obj$curr_map_level) |>
    bindEvent(input$drill_down, input$drill_up)

  map_year <- reactive(as.integer(input$year))

  chart_data <- reactive({
    if (map_level() == 1) {
      data_wide_nuts1
    } else {
      data_wide_nuts3
    }
  })

  ## Map ----

  observe({
    years <- data_wide_nuts1[[input$map_var]]$year

    shinyWidgets::updateSliderTextInput("year",
      session = session,
      choices = years,
      selected = years[which.min(abs(map_year() - as.integer(years)))]
    )
  }) |>
    bindEvent(input$map_var)

  observe({
    map_drill_obj$drill_down()
    update_map_drill(update_map_drill() + 1)
  }) |>
    bindEvent(input$drill_down)

  observe({
    map_drill_obj$drill_up()
    update_map_drill(update_map_drill() + 1)
  }) |>
    bindEvent(input$drill_up)

  observe({
    map_drill_obj$unselect_all()
  }) |>
    bindEvent(input$unselect)

  output$map_drill <- renderLeaflet({
    update_map_drill()

    curr_map_data <- map_drill_obj$curr_data |>
      select(name, starts_with("nuts"))

    map_drill_obj$add_data(
      if (map_level() == 1) {
        req(!"nuts3" %in% names(curr_map_data))
        left_join(
          curr_map_data,
          data_long_nuts1[[input$map_var]] |>
            filter(year == input$year),
          by = c("nuts1", "name")
        )
      } else {
        req("nuts3" %in% names(curr_map_data))
        left_join(
          curr_map_data,
          data_long_nuts3[[input$map_var]] |>
            filter(year == input$year),
          by = c("nuts1", "nuts3", "name")
        )
      }
    )

    map_drill_obj$draw_leafdown(map_colour_pals, input$map_var, de_bbox) |>
      map_drill_obj$keep_zoom(input)
  })

  ## Line charts ----

  ### Draw charts ----

  lapply(
    var_names,
    \(x) lineChartServer(
      id = x, # id must be name of variable to be plotted
      data = chart_data,
      leaflet_map = map_drill_obj
    )
  )

  ### Update legend ----

  observe({
    update_echarts_legend(paste0(var_names[[1]], "-chart"))
  }) |>
    bindEvent(map_drill_obj$curr_sel_data())

  ### Toggle national average ----

  observe({
    paste0(var_names, "-chart") |>
      lapply(echarts4rProxy) |>
      lapply(
        e_dispatch_action_p,
        if (input$chart_show_avg) "legendSelect" else "legendUnSelect",
        name = "_Nat. Avg._"
      )
  }) |>
    bindEvent(input$chart_show_avg)

  ### Scroll and highlight at variable selection ----

  observe({
    highlight_selected_echart(paste0(input$map_var, "-chart"))
  }) |>
    bindEvent(input$map_var)
}
