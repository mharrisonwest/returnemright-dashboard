svg.style("background", "none");

var margin = { top: 80, right: 30, bottom: 100, left: 70 },
    innerWidth = width - margin.left - margin.right,
    innerHeight = height - margin.top - margin.bottom,
    color = d3.scaleOrdinal()
      .domain(["dead","alive","kept"])
      .range(["#043D5D", "#6FA0A2","#DBE5F0"]);

var g = svg.append("g")
  .attr("transform", `translate(${margin.left},${margin.top})`);


var x = d3.scalePoint()
  .domain(data.map(d => d.year))
  .range([1, innerWidth]);

var y = d3.scaleLinear()
  .domain([0, d3.max(data, d => d.value)])
  .range([innerHeight, 0]);


//actual chart
//split
var areaData = data.filter(d => d.type === "area");
var lineData = data.filter(d => d.type === "line");

var areaSeries = d3.group(areaData, d => d.series);
var lineSeries = d3.group(lineData, d => d.series);

var seriesNest = d3.group(data, d => d.series);

var area = d3.area()
  .x(d => x(d.year))
  .y0(innerHeight)
  .y1(d => y(d.value));

var line = d3.line()
  .x(d => x(d.year))
  .y(d => y(d.value));

//area for each
for (var [series, values] of areaSeries.entries()) {
  g.append("path")
    .datum(values)
    .attr("fill", color(series))
    .attr("stroke", color(series))
    .attr("stroke-width", 1.5)
    .attr("d", area);
}

//line for each
for (var [series, values] of lineSeries.entries()) {
  g.append("path")
    .datum(values)
    .attr("fill","none")
    .attr("stroke", color(series))
    .attr("stroke-width", 2.5)
    .attr("stroke-dasharray", "0 4")
    .attr("stroke-linecap","round")
    .attr("d", line);
}

//x axis
g.append("g")
  .attr("transform", `translate(0,${innerHeight})`)
  .call(d3.axisBottom(x).tickSize(0).tickPadding(15))
  .style("font-size", "12pt");


//y axis
g.append("g")
  .call(d3.axisLeft(y))
  .style("font-size", "12pt");

g.selectAll(".domain, .tick line")
  .attr("stroke", "#aaa");

g.append("text")
  .attr("text-anchor", "middle")
  .attr("transform", `rotate(-90)`)
  .attr("x", -innerHeight / 2)
  .attr("y", -45)
  .style("font-size", "14px")
  .text("Millions");
  
  
//legend
var seriesNames = [...new Set(data.map(d => d.series))];

const legendSpacing = 180;
const legendItemHeight = 16;

// Create legend group
const legend = svg.append("g");

// Compute legend position
const totalLegendWidth = seriesNames.length * legendSpacing;
const legendXStart = (width - totalLegendWidth) / 2 +20;
const legendY = innerHeight + margin.top + 60;

// Add each item
seriesNames.forEach((name, i) => {
  const xPos = legendXStart + i * legendSpacing;
  
  if (lineSeries.has(name)) {
  // Draw three small dots for line legend
  [0, 10, 20].forEach(offset => {
    legend.append("circle")
      .attr("cx", xPos + offset)
      .attr("cy", legendY + 6)
      .attr("r", 4)
      .attr("fill", color(name))
      .attr("stroke", "black")
      .attr("stroke-width", 0.8);
  });
  } else {
    // Area: regular box
    legend.append("rect")
      .attr("x", xPos)
      .attr("y", legendY)
      .attr("width", 30)
      .attr("height", 12)
      .attr("fill", color(name));
  }

  // Label
  legend.append("text")
    .attr("x", xPos + 36)
    .attr("y", legendY + 10)
    .style("font-size", "14px")
    .style("font-weight", "bold")
    .text(name);
  
});


//chart title
svg.append("text")
  .attr("x", width / 2)
  .attr("y", margin.top / 2)
  .attr("text-anchor", "middle")
  .style("font-size", "16px")
  .style("font-weight", "bold")
  .text("Historical Fish Released Alive, Dead Upon Release, and Fish Kept");
  
svg.append("text")
  .attr("x", width / 2)
  .attr("y", margin.top / 2 + 18)
  .attr("text-anchor", "middle")
  .style("font-size", "16px")
  .style("font-weight", "bold")
  .text(options.subtitle);

