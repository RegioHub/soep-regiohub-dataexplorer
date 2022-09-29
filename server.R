map_colour_pals <- list(data_long_nuts1, data_long_nuts3) |>
  lapply(\(level) {
    lapply(level, create_map_pal)
  })

function(input, output, session) {

  ## Startup ----

  hideElement("map_show_hospitals")

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

  ### Reactive time slider ----

  observe({
    years <- data_wide_nuts1[[input$map_var]]$year

    shinyWidgets::updateSliderTextInput("year",
      session = session,
      choices = years,
      selected = years[which.min(abs(map_year() - as.integer(years)))]
    )
  }) |>
    bindEvent(input$map_var)

  ### Leafdown boilerplate ----

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

  observe({
    n_selected <- nrow(map_drill_obj$curr_sel_data())
    if (n_selected) enable("unselect") else disable("unselect")
  }) |>
    bindEvent(map_drill_obj$curr_sel_data())

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

    map_drill_obj$draw_leafdown(map_colour_pals, input$map_var, input$map_log_scale, de_bbox) |>
      map_drill_obj$keep_zoom(input)
  })

  ### Show points for hospitals ----

  observe({
    if (input$map_var == "hospital_beds") {
      showElement("map_show_hospitals")
    } else {
      hideElement("map_show_hospitals")
    }
  }) |>
    bindEvent(input$map_var)

  observe({
    updateCheckboxInput("map_show_hospitals", session = session, value = FALSE)
  }) |>
    bindEvent(input$drill_up, input$drill_down, input$map_var, input$map_log_scale)

  observe({
    req(hospitals[[input$year]]$long)

    if (input$map_show_hospitals) {
      session$sendCustomMessage(type = "make-map-shapes-transparent", message = "")

      map_drill_obj$map_proxy |>
        addCircleMarkers(
          group = "hospitals",
          lng = hospitals[[input$year]]$long,
          lat = hospitals[[input$year]]$lat,
          radius = sqrt(hospitals[[input$year]]$value) / 5,
          fillColor = "#0d6efd",
          fillOpacity = 0.4,
          weight = 1,
          color = "#0d6efd",
          opacity = 1,
          label = create_map_labels(hospitals[[input$year]], prefix = "Krankenhaus: ", suffix = " Betten")
        )
    } else {
      map_drill_obj$map_proxy |>
        clearGroup("hospitals")

      session$sendCustomMessage(type = "make-map-shapes-opaque", message = "")
    }
  }) |>
    bindEvent(input$year, input$map_show_hospitals)

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

  ### Year range ----

  observe({
    lapply(var_names, \(x) {
      echarts4rProxy(paste0(x, "-chart")) |>
        e_dispatch_action_p(
          "dataZoom",
          startValue = input$charts_years[1],
          endValue = input$charts_years[2]
        )
    })
  }) |>
    bindEvent(input$charts_years)

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
        name = "(Durchschnitt)"
      )
  }) |>
    bindEvent(input$chart_show_avg)

  ### Scroll and highlight at variable selection ----

  observe({
    highlight_selected_echart(paste0(input$map_var, "-chart"))
  }) |>
    bindEvent(input$map_var)

  ## Information, descriptions etc. ----

  output$map_var_info <- renderText({
    curr_metadata <- metadata[metadata$id == input$map_var, ]

    paste0(curr_metadata$title, " (", curr_metadata$subtitle, ")")
  })
}
