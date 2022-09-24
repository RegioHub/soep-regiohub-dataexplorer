function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

$(function () {
  Shiny.addCustomMessageHandler("update-echarts-legend",
    function (message) {
      sleep(250).then(() => { // Wait 250ms for chart to receive change in map
        const opts = get_e_charts(message).getOption();
        const series_names = opts.series.map(x => x.name);
        const colors = opts.color;
        const legend_items = series_names.map((x, i) => [x, colors[i]]).splice(1);
        const legend_html = legend_items.map(x => `<span style="white-space:nowrap;"><span style="display:inline-block;margin-right:4px;border-radius:10px;width:10px;height:10px;background-color:${x[1]};"></span>${x[0]}</span>`).join("&emsp;");

        document.getElementById("echarts-legend").innerHTML = legend_html;
      });
    }
  );

  Shiny.addCustomMessageHandler("scrollto-and-highlight-echart",
    function (message) {
      const chart_container = document.getElementById(message).parentElement;
      chart_container.scrollIntoView();

      const original_bg = chart_container.style.backgroundColor;
      chart_container.style.backgroundColor = "aliceblue";
      sleep(1000).then(() => {
        chart_container.style.backgroundColor = original_bg;
      });
    }
  );

  Shiny.addCustomMessageHandler("make-map-shapes-transparent",
    function (message) {
      sleep(250).then(() => {
        const map_shapes = document.getElementsByClassName("map-shapes");
        [...map_shapes].forEach(x => x.style.opacity = 0.15);
      });
    }
  );

  Shiny.addCustomMessageHandler("make-map-shapes-opaque",
    function (message) {
      sleep(250).then(() => {
        const map_shapes = document.getElementsByClassName("map-shapes");
        [...map_shapes].forEach(x => x.style.opacity = 1);
      });
    }
  );
});
