Leafdown2 <- R6::R6Class("Leafdown2",
  inherit = leafdown::Leafdown,
  private = list(
    .drill_down_button_id = NULL, #<<
    .drill_up_button_id = NULL
  ),
  active = list(
    # Add active binding for curr_sel_ids (for unselect all)
    curr_sel_ids = function(value) {
      if (missing(value)) {
        private$.curr_sel_ids
      } else {
        stop("`$curr_sel_ids` is read only", call. = FALSE)
      }
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

    # Disable drill_down button when lowest level is reached
    # Selecting no polygon == selecting all polygons
    drill_down = function() {
      if (!length(private$.curr_sel_ids[[private$.curr_map_level]])) {
        private$.curr_sel_ids[[private$.curr_map_level]] <- private$.curr_poly_ids #<<
      }

      parents <- private$.curr_spdf
      all_parents_poly_ids <- sapply(parents@polygons, slot, "ID")
      curr_sel_parent_poly_ids <- private$.curr_sel_ids[[private$.curr_map_level]]
      mask_sel_parents_poly_ids <- all_parents_poly_ids %in% curr_sel_parent_poly_ids
      curr_sel_parents <- parents[mask_sel_parents_poly_ids, ]
      private$.selected_parents[[private$.curr_map_level]] <- curr_sel_parents
      private$.unselected_parents[[private$.curr_map_level]] <- parents[!mask_sel_parents_poly_ids, ]

      spdf_new <- private$.spdfs_list[[private$.curr_map_level + 1]]
      rhs <- private$.join_map_levels_by[private$.curr_map_level]
      lhs <- names(private$.join_map_levels_by[private$.curr_map_level])
      is_child_of_selected_parents <- spdf_new@data[, rhs] %in% curr_sel_parents@data[, lhs]
      spdf_new <- spdf_new[is_child_of_selected_parents, ]

      private$.curr_spdf <- spdf_new
      private$.curr_poly_ids <- sapply(private$.curr_spdf@polygons, slot, "ID")
      private$.curr_map_level <- private$.curr_map_level + 1
      private$.curr_sel_ids[[private$.curr_map_level]] <- character(0)
      private$.curr_data <- private$.curr_spdf@data

      if (TRUE) {
        # if (private$.curr_map_level == length(private$.spdfs_list)) {
        shinyjs::disable(private$.drill_down_button_id) #<<
        shinyjs::enable(private$.drill_up_button_id)
        shiny::req(FALSE)
      }
    },

    # Disable drill_up button when highest level is reached
    drill_up = function() {
      spdf_new <- private$.spdfs_list[[private$.curr_map_level - 1]]

      # check if there are grandparents and only select shapes where the grandparents are selected
      # if we drill up to the highest level, we do not need this check as there are no grandparents
      if ((private$.curr_map_level - 1) > 1) {
        rhs <- private$.join_map_levels_by[private$.curr_map_level - 1]
        lhs <- names(private$.join_map_levels_by[private$.curr_map_level - 1])
        selected_grandparents_data <- private$.selected_parents[[private$.curr_map_level - 1]]@data
        unselected_grandparents_data <- private$.unselected_parents[[private$.curr_map_level - 1]]@data
        all_grandparents_data <- rbind(selected_grandparents_data, unselected_grandparents_data)
        is_child_of_selected_grandparents <- spdf_new@data[, rhs] %in% all_grandparents_data[, lhs]
        spdf_new <- spdf_new[is_child_of_selected_grandparents, ]
      }

      private$.curr_spdf <- spdf_new

      private$.curr_poly_ids <- sapply(private$.curr_spdf@polygons, slot, "ID")
      private$.curr_map_level <- private$.curr_map_level - 1
      private$.unselected_parents <- private$.unselected_parents[seq_len(private$.curr_map_level - 1)]
      private$.curr_data <- private$.curr_spdf@data

      if (TRUE) {
        # if (private$.curr_map_level <= 1) {
        shinyjs::enable(private$.drill_down_button_id) #<<
        shinyjs::disable(private$.drill_up_button_id) #<<
        shiny::req(FALSE)
      }
    }
  )
)
