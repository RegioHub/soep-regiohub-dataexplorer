function get_echarts_series(id) {
  Shiny.setInputValue(
    "echarts_series",
    get_e_charts(id).getOption().series.map(x => x.name)
  );
}
