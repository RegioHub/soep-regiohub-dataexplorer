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
    "header header header header header_right header_right",
    "controller_left map map map charts_common charts_common",
    "controller_left map map map chart1 chart2",
    "controller_left map map map chart3 chart4"
  ),
  row_sizes = c(
    "60px",
    "50px",
    "1fr",
    "1fr"
  ),
  col_sizes = c(
    "0.25fr",
    "0.25fr",
    "0.25fr",
    "0.25fr",
    "0.5fr",
    "0.5fr"
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
    actionButton(
      inputId = "drill_up",
      label = "↑ NUTS-1"
    ),
    actionButton(
      inputId = "drill_down",
      label = "↓ NUTS-3"
    ),
    hr(),
    actionButton(
      inputId = "unselect",
      label = "Unselect All"
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
      width = "100%",
      sep = ""
    ),
    leaflet::leafletOutput("map_drill",
      height = "100%"
    )
  ),
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
    area = "charts_common",
    item_gap = "12px",
    uiOutput("echarts_legend")
  )
)
