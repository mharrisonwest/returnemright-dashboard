svg.style("background", "none");

var margin = { top: 80, right: 30, bottom: 100, left: 70 },
    innerWidth = width - margin.left - margin.right,
    innerHeight = height - margin.top - margin.bottom,
    color = d3.scaleOrdinal()
      .domain(["dead","alive","kept"])
      .range(["#043D5D", "#6FA0A2","#DBE5F0"]);

var g = svg.append("g")
  .attr("transform", `translate(${margin.left},${margin.top})`);

g.append("g").attr("class", "x-axis")
  .attr("transform", `translate(0,${innerHeight})`);

g.append("g").attr("class", "y-axis");

svg.append("text")
  .attr("x", width / 2)
  .attr("y", margin.top / 2)
  .attr("text-anchor", "middle")
  .style("font-size", "16px")
  .style("font-weight", "bold")
  .text("Historical Fish Released Alive, Dead Upon Release, and Fish Kept");

svg.append("text")
  .attr("class", "chart-subtitle")
  .attr("x", width / 2)
  .attr("y", margin.top / 2 + 18)
  .attr("text-anchor", "middle")
  .style("font-size", "16px")
  .style("font-weight", "bold");

g.append("text")
  .attr("class", "y-label")
  .attr("text-anchor", "middle")
  .attr("transform", `rotate(-90)`)
  .attr("x", -innerHeight / 2)
  .attr("y", -45)
  .style("font-size", "14px")
  .text("Millions");

var areaGroup = g.append("g").attr("class", "areas");
var lineGroup = g.append("g").attr("class", "lines");
var legendGroup = svg.append("g").attr("class", "legend");

// Update-render logic
r2d3.onRender((data, svg, width, height, options) => {
  

  var x = d3.scalePoint()
    .domain(data.map(d => d.year))
    .range([1, innerWidth]);

  var y = d3.scaleLinear()
    .domain([0, d3.max(data, d => d.value)])
    .range([innerHeight, 0]);

  var color = d3.scaleOrdinal()
    .domain(["dead", "alive", "kept"])
    .range(["#043D5D", "#6FA0A2", "#DBE5F0"]);

  var area = d3.area()
    .x(d => x(d.year))
    .y0(innerHeight)
    .y1(d => y(d.value));

  var line = d3.line()
    .x(d => x(d.year))
    .y(d => y(d.value));

  var areaSeries = d3.group(data.filter(d => d.type === "area"), d => d.series);
  var lineSeries = d3.group(data.filter(d => d.type === "line"), d => d.series);
  
  var years = Array.from(new Set(data.map(d => d.year))).sort();

  // Bind data to area paths
  const areaPaths = svg.select(".areas").selectAll("path")
    .data(Array.from(areaSeries.entries()), d => d[0]);

  // Enter + update
  areaPaths.enter()
    .append("path")
    .attr("fill", d => color(d[0]))
    .attr("stroke", d => color(d[0]))
    .attr("stroke-width", 1.5)
    .attr("d", d => {
      // Start flat at bottom for transition in
      return d3.area()
        .x(d => x(d.year))
        .y0(innerHeight)
        .y1(innerHeight)(d[1]);
    })
    .merge(areaPaths)
    .transition()
    .duration(1000)
    .attr("d", d => area(d[1]));
    
  // Remove exit
  areaPaths.exit()
    .transition()
    .duration(500)
    .attr("opacity", 0)
    .remove();
  

  //line chart transition
  var linePaths = lineGroup.selectAll(".line-path")
    .data(Array.from(lineSeries.entries()), d => d[0]);

  linePaths.enter().append("path")
    .attr("class", "line-path")
    .attr("fill", "none")
    .attr("stroke", d => color(d[0]))
    .attr("stroke-width", 2.5)
    .attr("stroke-dasharray", "0 4")
    .attr("stroke-linecap", "round")
    .attr("d", d => line(d[1].map(p => ({ ...p, value: 0 }))))
    .merge(linePaths)
    .transition().duration(1000)
      .attr("d", d => line(d[1]));

  linePaths.exit().remove();

  //axis transition
  g.select(".x-axis")
    .transition().duration(1000)
    .call(d3.axisBottom(x).tickSize(0).tickPadding(15));

  g.select(".y-axis")
    .transition().duration(1000)
    .call(d3.axisLeft(y));

  //subtitle update
  svg.select(".chart-subtitle").text(options.subtitle || "");

  //legend
  var seriesNames = [...new Set(data.map(d => d.series))];
  legendGroup.selectAll("*").remove();

  var legendSpacing = 180;
  var totalLegendWidth = seriesNames.length * legendSpacing;
  var legendXStart = (width - totalLegendWidth) / 2 + 20;
  var legendY = innerHeight + margin.top + 60;

  seriesNames.forEach((name, i) => {
    var xPos = legendXStart + i * legendSpacing;
    if (lineSeries.has(name)) {
      [0, 10, 20].forEach(offset => {
        legendGroup.append("circle")
          .attr("cx", xPos + offset)
          .attr("cy", legendY + 6)
          .attr("r", 4)
          .attr("fill", color(name))
          .attr("stroke", "black")
          .attr("stroke-width", 0.8);
      });
    } else {
      legendGroup.append("rect")
        .attr("x", xPos)
        .attr("y", legendY)
        .attr("width", 30)
        .attr("height", 12)
        .attr("fill", color(name));
    }
    legendGroup.append("text")
      .attr("x", xPos + 36)
      .attr("y", legendY + 10)
      .style("font-size", "14px")
      .style("font-weight", "bold")
      .text(name);
  });

});
