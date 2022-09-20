library(shiny)
library(gridlayout)
library(bslib)
library(shinyjs)

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
    "160px"
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
      label = "Variable",
      choices = var_names,
      selectize = FALSE
    ),
    hr(),
    span("Aggregate level"),
    div(
      actionButton(
        inputId = "drill_up",
        label = "↑"
      ),
      actionButton(
        inputId = "drill_down",
        label = "↓"
      )
    ),
    hr(),
    actionButton(
      inputId = "unselect",
      label = "Unselect all regions"
    )
  ),
  grid_card(
    area = "map",
    item_gap = "12px",
    shinyWidgets::sliderTextInput(
      inputId = "year",
      label = "Year",
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
      label = "National average",
      value = TRUE,
      width = "100%"
    )
  ),
  grid_card(
    area = "charts_area",
    item_gap = "12px",
    class = "charts-panel",
    grid_container(
      layout = c(
        "chart1 chart2",
        "chart3 chart4"
      ),
      row_sizes = c(
        "300px",
        "300px"
      ),
      col_sizes = c(
        "1fr",
        "1fr"
      ),
      gap_size = "0px",
      grid_card(
        area = "chart1",
        item_gap = "12px",
        lineChartUI("Wahlbeteiligung")
      ),
      grid_card(
        area = "chart2",
        item_gap = "12px",
        lineChartUI("Binnenwanderungssaldo")
      ),
      grid_card(
        area = "chart3",
        item_gap = "12px",
        lineChartUI("networking")
      ),
      grid_card(
        area = "chart4",
        item_gap = "12px",
        lineChartUI("life_sat")
      )
    )
  )
)
