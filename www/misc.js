$(function () {
  Shiny.addCustomMessageHandler(
    "update-echarts-legend", function (message) {
      var opts = get_e_charts(message).getOption();
      var series_names = opts.series.map(x => x.name);
      var colors = opts.color;
      var legend_items = series_names.map((x, i) => [x, colors[i]]);
      var legend_html = legend_items.map(x => `<span style="white-space:nowrap;"><span style="display:inline-block;margin-right:4px;border-radius:10px;width:10px;height:10px;background-color:${x[1]};"></span>${x[0]}</span>`).join("&emsp;&emsp;");

      $("#echarts-legend").html($.parseHTML(legend_html));
    }
  );
});
