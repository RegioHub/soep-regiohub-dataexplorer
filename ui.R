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
    "0.15fr"
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
      choices = paste0(
        "v",
        1:4
      )
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
    sliderInput(
      inputId = "year",
      label = "Year",
      min = 2016L,
      max = 2019L,
      value = 2016L,
      step = 1L,
      ticks = FALSE,
      width = "60%",
      sep = ""
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
    actionButton(
      inputId = "chart_show_avg",
      label = HTML("National<br>average"),
      class = "echarts-legend-button"
    )
  ),
  grid_card(
    area = "charts_area",
    item_gap = "12px",
    class = "charts-panel",
    grid_container(
      layout = c(
        "chart1 chart2",
        "chart3 chart4",
        "chart5 chart6"
      ),
      row_sizes = c(
        "300px",
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
        lineChartUI("v1")
      ),
      grid_card(
        area = "chart2",
        item_gap = "12px",
        lineChartUI("v2")
      ),
      grid_card(
        area = "chart3",
        item_gap = "12px",
        lineChartUI("v3")
      ),
      grid_card(
        area = "chart4",
        item_gap = "12px",
        lineChartUI("v4")
      ),
      grid_card(
        area = "chart5",
        item_gap = "12px"
      ),
      grid_card(
        area = "chart6",
        item_gap = "12px"
      )
    )
  )
)
