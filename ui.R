library(gridlayout)
library(shiny)
library(bslib)
library(leaflet)

grid_page(
  theme = bs_add_rules(
    bs_theme(version = 5),
    readLines(here::here("www/misc.css"))
  ),
  layout = c(
    "header header header header header",
    "controller_left map map map profile",
    "controller_bottomleft map map map profile"
  ),
  row_sizes = c(
    "80px",
    "1fr",
    "80px"
  ),
  col_sizes = c(
    "0.25fr",
    "0.25fr",
    "0.25fr",
    "0.25fr",
    "1fr"
  ),
  gap_size = "15px",
  shinyjs::useShinyjs(),
  grid_card_text(
    area = "header",
    content = "LWC RegioHub",
    h_align = "start",
    alignment = "start",
    is_title = TRUE
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
    actionButton(
      inputId = "drill_up",
      label = "↑ NUTS-1"
    ),
    actionButton(
      inputId = "drill_down",
      label = "↓ NUTS-3"
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
      sep = ""
    ),
    leafletOutput("map_drill",
      height = "calc(100vh - 200px)"
    )
  ),
  grid_card(
    area = "profile",
    item_gap = "12px",
    verbatimTextOutput("selected_data")
  ),
  grid_card(
    area = "controller_bottomleft",
    item_gap = "12px",
    actionButton(
      inputId = "unselect",
      label = "Unselect All"
    )
  )
)
