function get_e_charts_series(id) {
  Shiny.setInputValue(
    id + "_series",
    [...new Set(get_e_charts(id).getOption().series.map(x => x.name))]
  );
}
