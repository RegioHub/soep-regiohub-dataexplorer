library(shiny)
library(shinyjs)
library(leaflet)
library(echarts4r)
library(dplyr)
library(tidyr)

create_map_labels <- function(data, var) {
  lapply(
    paste0("<div>", data[["name"]], "</div><div><strong>", data[[var]], "</strong></div>"),
    HTML
  )
}

de_maps <- readRDS("data/de_maps.RDS")

# sf::st_bbox(de_nuts1)
de_bbox <- c(xmin = 5.87709, ymin = 47.27011, xmax = 15.03355, ymax = 55.05428)

fake_data_nuts1 <- readRDS("data/fake_data_nuts1.RDS")
fake_data_nuts3 <- readRDS("data/fake_data_nuts3.RDS")

fake_data_nuts1_wide <- fake_data_nuts1 |>
  mutate(year = as.character(year)) |>
  select(-nuts1) |>
  pivot_longer(v1:v4, names_to = "var", values_to = "value") |>
  pivot_wider(names_from = name, values_from = value) |>
  split(~var)

fake_data_nuts3_wide <- fake_data_nuts3 |>
  mutate(year = as.character(year)) |>
  select(-c(nuts3, nuts1)) |>
  pivot_longer(v1:v4, names_to = "var", values_to = "value") |>
  pivot_wider(names_from = name, values_from = value) |>
  split(~var)

colour_pals <- list(fake_data_nuts1, fake_data_nuts3) |>
  lapply(\(d) {
    d[, paste0("v", 1:4)] |>
      lapply(\(x) colorNumeric(
        palette = "BrBG",
        domain = if (min(x) < 0) {
          # Diverging palette
          max(abs(range(x))) * c(-1, 1)
        } else {
          # Sequential palette
          c(min(x) * 2 - max(x), max(x))
        },
        na.color = "#cccccc"
      ))
  })

function(input, output, session) {
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

  curr_map_level <- reactive(map_drill_obj$curr_map_level) |>
    bindEvent(input$drill_down, input$drill_up)

  chart_data <- reactive({
    if (curr_map_level() == 1) {
      fake_data_nuts1_wide
    } else {
      fake_data_nuts3_wide
    }
  })

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

  output$map_drill <- renderLeaflet({
    update_map_drill()

    curr_map_data <- map_drill_obj$curr_data |>
      select(name, starts_with("nuts"))

    data <-
      if (curr_map_level() == 1) {
        left_join(
          curr_map_data,
          fake_data_nuts1[fake_data_nuts1$year == input$year, ],
          by = c("name", "nuts1")
        )
      } else {
        left_join(
          curr_map_data, fake_data_nuts3[fake_data_nuts3$year == input$year, ],
          by = c("name", "nuts3", "nuts1")
        )
      }

    map_drill_obj$add_data(data)

    curr_var <- map_drill_obj$curr_data[[input$map_var]]

    map_drill_obj$draw_leafdown(
      fillColor = colour_pals[[curr_map_level()]][[input$map_var]](curr_var),
      fillOpacity = 1,
      color = "#aaaaaa", weight = .5, opacity = 1,
      label = create_map_labels(data, input$map_var),
      highlight = highlightOptions(
        color = "#444444", weight = 1.5
      )
    ) |>
      map_drill_obj$keep_zoom(input) |>
      addLegend(
        pal = colour_pals[[curr_map_level()]][[input$map_var]],
        values = curr_var,
        opacity = 1,
        title = NULL
      ) |>
      leafem::addHomeButton(de_bbox, "\u21ba", "topleft")
  })

  observe({
    lapply(
      map_drill_obj$curr_sel_ids[[curr_map_level()]],
      map_drill_obj$toggle_shape_select
    )
  }) |>
    bindEvent(input$unselect, input$drill_up)

  lapply(
    1:4,
    \(x) lineChartServer(
      id = paste0("v", x), # id must be name of variable to be plotted
      data = chart_data,
      leaflet_map = map_drill_obj
    )
  )
}
