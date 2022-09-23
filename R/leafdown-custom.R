Leafdown2 <- R6::R6Class("Leafdown2",
  inherit = leafdown::Leafdown,
  private = list( #<<
    .drill_down_button_id = NULL,
    .drill_up_button_id = NULL,
    .parent_spdf = NULL,

    # Prevent selecting more than 5 regions
    .toggle_shape_select = function(shape_id) {
      checkmate::assert_character(shape_id, min.chars = 1)

      if (!shape_id %in% private$.curr_poly_ids) {
        stop("Please make sure the selected shape_id is in the current level")
      }

      curr_sel_ids <- private$.curr_sel_ids[[private$.curr_map_level]]

      if (shape_id %in% curr_sel_ids) {
        private$.map_proxy |>
          leaflet::hideGroup(shape_id)

        curr_sel_ids <- curr_sel_ids[!curr_sel_ids == shape_id]
      } else {
        private$.map_proxy |>
          leaflet::showGroup(shape_id)

        curr_sel_ids <- c(curr_sel_ids, shape_id)
      }

      if (length(curr_sel_ids) > 5) { #<<
        private$.map_proxy |>
          leaflet::hideGroup(shape_id)

        shinyjs::alert("Cannot select more than five regions")

        shiny::req(FALSE)
      }

      curr_sel_data <- private$.curr_data[private$.curr_poly_ids %in% curr_sel_ids, ]

      private$.curr_sel_ids[[private$.curr_map_level]] <- curr_sel_ids
      private$.curr_sel_data(curr_sel_data)
    }
  ),
  public = list(
    # Pass IDs of actionButtons to object (for shinyjs disable/enable)
    initialize = function(spdfs_list, map_output_id,
                          drill_down_button_id, drill_up_button_id, #<<
                          input, join_map_levels_by = NULL) {
      leafdown:::assert_spdf_list(spdfs_list)
      checkmate::assert_character(map_output_id, min.chars = 1)

      if (!shiny::is.reactivevalues(input)) {
        stop("The given 'input' argument must be the 'input' from the shiny app")
      }

      if (is.null(join_map_levels_by) & length(spdfs_list) > 1) {
        join_map_levels_by <- paste0("GID_", seq_len(length(spdfs_list) - 1))
        names(join_map_levels_by) <- join_map_levels_by
      }

      private$.drill_down_button_id <- drill_down_button_id #<<
      private$.drill_up_button_id <- drill_up_button_id

      private$.parent_spdf <- list(c())

      private$.curr_map_level <- 1
      private$.curr_sel_ids <- list(c())
      private$.selected_parents <- list(c())
      private$.unselected_parents <- list(c())
      private$.spdfs_list <- spdfs_list
      private$.map_output_id <- map_output_id
      private$.join_map_levels_by <- leafdown:::assert_join_map_levels_by(join_map_levels_by, spdfs_list)
      private$.curr_spdf <- private$.spdfs_list[[private$.curr_map_level]]
      private$.curr_poly_ids <- sapply(private$.curr_spdf@polygons, slot, "ID")
      private$.curr_data <- private$.curr_spdf@data
      private$.curr_sel_data <- shiny::reactiveVal(data.frame())
      private$init_click_observer(input, map_output_id)
    },

    # Finer grained zooming
    # New highlighting style of selected regions
    draw_leafdown = function(map_colour_pals, var, default_bbox) {
      curr_spdf <- private$.curr_spdf
      if (!is.null(private$.curr_data)) {
        curr_spdf@data <- private$.curr_data
      }

      private$.map_proxy <- leaflet::leafletProxy(private$.map_output_id)

      all_poly_ids <- private$.curr_poly_ids

      map <- leaflet::leaflet(
        curr_spdf,
        options = leaflet::leafletOptions(zoomDelta = .25, zoomSnap = .25) #<<
      ) |>
        leaflet::addPolygons( #<<
          layerId = ~all_poly_ids,
          fillColor = map_colour_pals[[private$.curr_map_level]][[var]][["fn"]](private$.curr_data[["value"]]),
          fillOpacity = 1,
          weight = if (private$.curr_map_level == 1) 2 else 1,
          color = if (private$.curr_map_level == 1) "#fff" else "#dee2e6",
          opacity = 1,
          label = create_map_labels(private$.curr_data),
          highlight = leaflet::highlightOptions(fillColor = "#fcce25")
        ) |>
        leaflet::addPolylines(
          group = all_poly_ids,
          stroke = TRUE,
          weight = 3,
          color = "#fcce25", #<<
          opacity = 1,
          highlightOptions = leaflet::highlightOptions(bringToFront = TRUE, weight = 4)
        ) |>
        leaflet::addLegend(
          pal = map_colour_pals[[private$.curr_map_level]][[var]][["fn_rev"]],
          values = map_colour_pals[[private$.curr_map_level]][[var]][["rng"]],
          labFormat = labelFormat(transform = rev),
          opacity = 1,
          title = NULL
        ) |>
        leafem::addHomeButton(default_bbox, "\u21ba", "topleft")

      if (private$.curr_map_level != 1) { #<<
        map <- map |>
          leaflet::addPolylines(
            data = private$.parent_spdf,
            weight = 2,
            color = "#fff",
            opacity = 1
          )
      }

      private$.map_proxy |>
        leaflet::hideGroup(all_poly_ids) |>
        leaflet::showGroup(private$.curr_sel_ids[[private$.curr_map_level]])

      map
    },

    # Disable drill_down button when lowest level is reached
    # Show all lower-level regions (not only regions in selected parents)
    # Selecting no polygon == selecting all polygons
    drill_down = function() {
      # if (!length(private$.curr_sel_ids[[private$.curr_map_level]])) {
      #   private$.curr_sel_ids[[private$.curr_map_level]] <- private$.curr_poly_ids #<<
      # }

      private$.parent_spdf <- private$.curr_spdf

      spdf_new <- private$.spdfs_list[[private$.curr_map_level + 1]]

      private$.curr_spdf <- spdf_new
      private$.curr_poly_ids <- sapply(private$.curr_spdf@polygons, slot, "ID")
      private$.curr_map_level <- private$.curr_map_level + 1
      private$.curr_sel_ids[[private$.curr_map_level]] <- character(0)
      private$.curr_data <- private$.curr_spdf@data

      if (private$.curr_map_level == length(private$.spdfs_list)) { #<<
        shinyjs::disable(private$.drill_down_button_id)
      }

      shinyjs::enable(private$.drill_up_button_id)
    },

    # Disable drill_up button when highest level is reached
    drill_up = function() {
      spdf_new <- private$.spdfs_list[[private$.curr_map_level - 1]]

      private$.curr_spdf <- spdf_new

      private$.curr_poly_ids <- sapply(private$.curr_spdf@polygons, slot, "ID")
      private$.curr_map_level <- private$.curr_map_level - 1
      private$.curr_sel_ids[[private$.curr_map_level]] <- character(0) #<<
      private$.curr_data <- private$.curr_spdf@data

      if (private$.curr_map_level <= 1) { #<<
        shinyjs::disable(private$.drill_up_button_id)
      }

      shinyjs::enable(private$.drill_down_button_id)
    },

    # New public method to unselect all regions
    unselect_all = function() { #<<
      private$.map_proxy |>
        leaflet::hideGroup(private$.curr_poly_ids)

      private$.curr_sel_ids[[private$.curr_map_level]] <- character()
      private$.curr_sel_data(data.frame())
    }
  )
)

# Utils -------------------------------------------------------------------

create_map_labels <- function(data) {
  lapply(
    paste0("<div>", data[["name"]], "</div><div><strong>", data[["value"]], "</strong></div>"),
    shiny::HTML
  )
}

create_map_pal <- function(data) {
  list(
    fn = map_pal_creator(data[["value"]]),
    fn_rev = map_pal_creator(data[["value"]], reverse = TRUE), # For legend
    rng = expand_range(data[["value"]])
  )
}

map_pal_creator <- function(x, reverse = FALSE) {
  if (min(x, na.rm = TRUE) < 0) {
    colours <- colorspace::divergingx_hcl(7, "Geyser", rev = TRUE)
  } else {
    colours <- viridisLite::mako(7, direction = -1)
  }

  leaflet::colorNumeric(
    palette = colours,
    domain = expand_range(x),
    na.color = "#eaecef",
    reverse = reverse
  )
}

expand_range <- function(x) {
  x <- x[!is.na(x)]

  if (min(x) < 0) {
    # Diverging palette
    max(abs(range(x))) * c(-1, 1)
  } else {
    # Sequential palette
    range(x)
  }
}
