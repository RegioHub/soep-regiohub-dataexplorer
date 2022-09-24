grid_page(
  theme = bs_add_rules(
    bs_theme(version = 5),
    readLines(here::here("www/misc.css"))
  ),
  layout = c(
    "header          header header header header_right            header_right           ",
    "controller_left map    map    map    charts_legend_container charts_toggle_container",
    "controller_left map    map    map    charts_area             charts_area            "
  ),
  row_sizes = c(
    "60px",
    "60px",
    "1fr"
  ),
  col_sizes = c(
    "0.25fr",
    "0.25fr",
    "0.25fr",
    "0.25fr",
    "0.85fr",
    "180px"
  ),
  gap_size = "15px",
  useShinyjs(),
  tags$script(src = "misc.js"),
  grid_card_text(
    area = "header",
    content = "",
    h_align = "start",
    alignment = "start",
    icon = "lwc-logo.svg",
    is_title = TRUE
  ),
  grid_card_text(
    area = "header_right",
    content = "",
    alignment = "end",
    icon = "dgs-kongress-logo.svg"
  ),
  grid_card(
    area = "controller_left",
    item_gap = "12px",
    selectInput(
      inputId = "map_var",
      label = "Indikator",
      choices = var_names,
      selectize = FALSE
    ),
    checkboxInput(
      inputId = "map_show_hospitals",
      label = "Krankenhäuser anzeigen",
      value = FALSE,
      width = "100%"
    ),
    hr(),
    actionButton(
      inputId = "drill_up",
      label = "Bundesländer",
      width = "100%"
    ),
    actionButton(
      inputId = "drill_down",
      label = "Kreise",
      width = "100%"
    ),
    hr(),
    actionButton(
      inputId = "unselect",
      label = "Auswahl aufheben",
      width = "100%"
    )
  ),
  grid_card(
    area = "map",
    item_gap = "12px",
    shinyWidgets::sliderTextInput(
      inputId = "year",
      label = "Jahr",
      choices = "",
      width = "60%"
    ),
    leaflet::leafletOutput("map_drill",
      height = "100%"
    )
  ),
  grid_card(
    area = "charts_legend_container",
    item_gap = "12px",
    class = "echarts-legend-container",
    div(
      id = "echarts-legend",
      class = "echarts-common-legend"
    )
  ),
  grid_card(
    area = "charts_toggle_container",
    item_gap = "12px",
    class = "echarts-toggle-container",
    checkboxInput(
      inputId = "chart_show_avg",
      label = "Bundesdurchschnitt",
      value = TRUE,
      width = "100%"
    )
  ),
  grid_card(
    area = "charts_area",
    item_gap = "12px",
    class = "charts-panel",
    grid_container(
      flag_mismatches = FALSE,
      layout = c(
        "chart1 chart2",
        "chart3 chart4",
        "chart5 chart6",
        "chart7 chart8"
      ),
      row_sizes = c(
        "300px",
        "300px",
        "300px",
        "300px"
      ),
      col_sizes = c(
        "1fr",
        "1fr"
      ),
      gap_size = "0px",
      lapply(seq_along(var_names), \(x) {
        grid_card(
          area = paste0("chart", x),
          item_gap = "12px",
          lineChartUI(var_names[[x]])
        )
      })
    )
  )
)
