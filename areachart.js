svg.style("background", "none");

//var height = width
var isMobile = width < 400;

var height = isMobile ? 370 : height;

var margin = isMobile ? { top: 90, right: 10, bottom: 100, left: 45 } : { top: 80, right: 30, bottom: 100, left: 70 },
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

//title wraps only if mobile
var title = svg.append("text")
  .attr("x", width / 2)
  .attr("y",isMobile ? 0 : margin.top / 2)
  .attr("text-anchor", "middle")
  .style("font-size", "16px")
  .style("font-weight", "bold");

if (isMobile) {
  // Manual wrap with multiple tspans for mobile
  title.append("tspan")
    .attr("x", width / 2)
    .attr("dy", "1.2em")
    .text("Historical Fish Released Alive,");

  title.append("tspan")
    .attr("x", width / 2)
    .attr("dy", "1.2em")
    .text("Dead Upon Release,");
    title.append("tspan")
    .attr("x", width / 2)
    .attr("dy", "1.2em")
    .text("and Fish Kept");
} else {
  // Single line title for desktop
  title.text("Historical Fish Released Alive, Dead Upon Release, and Fish Kept");
}

svg.append("text")
  .attr("class", "chart-subtitle")
  .attr("x", width / 2)
  .attr("y", isMobile ? 80 : margin.top / 2 + 18)
  .attr("text-anchor", "middle")
  .style("font-size", "16px")
  .style("font-weight", "bold");

g.append("text")
  .attr("class", "y-label")
  .attr("text-anchor", "middle")
  .attr("transform", `rotate(-90)`)
  .attr("x", -innerHeight / 2)
  .attr("y", -30)
  .style("font-size", "14px")
  .style("font-weight", "bold")
  .text(options.yLabel);

var areaGroup = g.append("g").attr("class", "areas");
var lineGroup = g.append("g").attr("class", "lines");
var legendGroup = svg.append("g").attr("class", "legend");


let prevData = new Map();

// Update-render logic
r2d3.onRender((data, svg, width, height, options) => {
  
  //new mobile stuff
  
  var fullDomain = data.map(d => d.year);
  var x = d3.scalePoint()
    .domain(fullDomain)
    .range([0, innerWidth]);
  
  //set tick years to show
  let tickYears;
  if (isMobile) {
    var step = Math.floor(fullDomain.length / 4);
    tickYears = [fullDomain[0], fullDomain[step], fullDomain[2 * step], fullDomain[3 * step], fullDomain[fullDomain.length - 1]];
  } else {
    tickYears = fullDomain;
  }

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
  

  // Bind data to area paths
  const areaPaths = svg.select(".areas").selectAll("path")
    .data(Array.from(areaSeries.entries()), d => d[0]);


  // Enter + update
  areaPaths.enter()
    .append("path")
    .attr("class", "area-path") //new
    .attr("fill", d => color(d[0]))
    .attr("stroke", d => color(d[0]))
    .attr("stroke-width", 1.5)
    .merge(areaPaths)
    .transition()
    .duration(0)
    .attr("d", d => area(d[1]));
    
  areaPaths.exit()
    .transition()
    .duration(500)
    .style("opacity", 0)
    .remove();
    


  //line chart transition
  var linePaths = lineGroup.selectAll(".line-path")
    .data(Array.from(lineSeries.entries()), d => d[0]);

  linePaths.enter().append("path")
    .attr("class", "line-path")
    .attr("fill", "none")
    .attr("stroke", d => color(d[0]))
    .attr("stroke-width", 4)
    .attr("stroke-dasharray", "0 6")
    .attr("stroke-linecap", "round")
    .attr("d", d => line(d[1].map(p => ({ ...p, value: 0 }))))
    .merge(linePaths)
    .transition().duration(0)
      .attr("d", d => line(d[1]));

  linePaths.exit().remove();

  g.select(".x-axis")
    .transition().duration(1000)
    .call(d3.axisBottom(x).tickSize(0).tickPadding(15).tickValues(tickYears))
    .style("font-size","14px");

  g.select(".y-axis")
    .transition().duration(1000)
    .call(d3.axisLeft(y).ticks(isMobile ? 4 : null))
    .style("font-size","14px");

  //subtitle update
  svg.select(".chart-subtitle").text(options.subtitle || "");
  
  

  //legend
  var seriesNames = [...new Set(data.map(d => d.series))];
  legendGroup.selectAll("*").remove();

  var legendSpacing = isMobile ? 30 : 180;
  var legendXStart = isMobile ? margin.left : (width - legendSpacing * seriesNames.length) / 2 + 20;
  var legendYStart = isMobile ? innerHeight + margin.top + 50 : innerHeight + margin.top + 60;
  
  seriesNames.forEach((name, i) => {
    var xPos = isMobile ? legendXStart : legendXStart + i * legendSpacing;
    var yPos = isMobile ? legendYStart + i * legendSpacing : legendYStart;
  
    if (lineSeries.has(name)) {
      [5, 15, 25].forEach(offset => {
        legendGroup.append("circle")
          .attr("cx", xPos + offset)
          .attr("cy", yPos + 6)
          .attr("r", 4)
          .attr("fill", color(name))
          .attr("stroke", "black")
          .attr("stroke-width", 0.8);
      });
    } else {
      legendGroup.append("rect")
        .attr("x", xPos)
        .attr("y", yPos)
        .attr("width", 30)
        .attr("height", 12)
        .attr("fill", color(name));
    }
    
    legendGroup.append("text")
      .attr("x", xPos + 36)
      .attr("y", yPos + 10)
      .style("font-size", "14px")
      .style("font-weight", "bold")
      .text(name);
  });
  
  
  //tooltip stuff:
  
  var tooltip = svg.append("g")
    .attr("class", "tooltip")
    .style("display", "none");
  
  var tooltipwidth = 220
  
  const tooltipBox = tooltip.append("rect")
  .attr("fill", "white")
  .attr("width", tooltipwidth)
  .attr("height", 90)
  .attr("rx", 4)
  .attr("ry", 4)
  .attr("opacity", 0.9);

  const tooltipText = tooltip.append("text")
    .attr("x", 8)
    .attr("y", 10)
    .style("font-size", "14px")
    .style("font-weight", "bold");
  
  
  // Transparent overlay to capture mouse events
  g.append("rect")
    .attr("class", "overlay")
    .attr("width", innerWidth)
    .attr("height", innerHeight)
    .attr("fill", "transparent")
    .on("mousemove", function (event) {
      var [mouseX] = d3.pointer(event, this);
      var closestYear = x.domain().reduce((a, b) => {
        return Math.abs(x(a) - mouseX) < Math.abs(x(b) - mouseX) ? a : b;
      });
  
      var values = data.filter(d => d.year === closestYear);
  
      if (values.length === 0) return;
  
      // Position the tooltip
      let tooltipX = mouseX + margin.left + 10;
      let tooltipY = margin.top - 10;
      
      if (tooltipX + tooltipwidth + margin.right > width) {
        tooltipX = width - tooltipwidth - margin.right;
      }
      
      if (tooltipX < margin.left) {
        tooltipX = margin.left + 10;
      }
  
      tooltip.attr("transform", `translate(${tooltipX},${tooltipY})`);
  
      //text
      tooltipText.selectAll("*").remove();
      
      tooltipText.append("tspan")
        .text(`${values[0]?.yearnumeric ?? closestYear}`)
        .attr("x", 8)
        .attr("dy", "1.2em")
        .style("font-size", "16px");
  
      values.forEach((d, i) => {
        let format = d3.format(",.1f")
        
        tooltipText.append("tspan")
          .text(`${d.series}: ${format(d.value)} million`)
          .attr("x", 8)
          .attr("dy", "1.2em");
      });
  
  
      tooltip.style("display", null);
    })
    .on("mouseleave", () => {
      tooltip.style("display", "none");
    });
  
});





//r2d3.onResize(function(width, height) {
  // Do nothing – this disables auto-redraw on resize
//});
