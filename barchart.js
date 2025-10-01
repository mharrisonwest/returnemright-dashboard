svg.style("background", "none");

var isMobile = width < 400;

var height = isMobile ? 350 : 450;

var width = isMobile ? width : 400;

var margin = isMobile ? { top: 80, right: 30, bottom: 30, left: 70 } : { top: 120, right: 30, bottom: 100, left: 70 };

var innerWidth = width - margin.left - margin.right;
var innerHeight = height - margin.top - margin.bottom;

r2d3.onRender(function(data, svg, width, height, options) {


  // Create or select main group
  let g = svg.select("g.main-group");
  if (g.empty()) {
    g = svg.append("g")
      .attr("class", "main-group")
      .attr("transform", `translate(${margin.left},${margin.top})`);

    g.append("g").attr("class", "x-axis").attr("transform", `translate(0,${innerHeight})`);
    g.append("g").attr("class", "y-axis");
    g.append("text")
      .attr("class", "y-axis-label")
      .attr("transform", "rotate(-90)")
      .attr("x", -innerHeight / 2)
      .attr("y",isMobile ? -65 : -65)
      .attr("dy", "1em")
      .style("text-anchor", "middle")
      .style("font-size", "16px")
      .style("font-weight", "bold")
      .text("Millions");
  }

  var x = d3.scaleBand()
    .domain(data.map(d => d.group))
    .range([35, innerWidth])
    .padding(.2);
    
  var y = d3.scaleLinear()
    .domain([0,data[0].value*.5,data[0].value*.95,data[0].value*1.15])
    .range([innerHeight,innerHeight*5/8,innerHeight*3/8,0]);

  var color = d3.scaleOrdinal(["#043D5D", "#6FA0A2"]);

  
  var bars = g.selectAll("rect")
    .data(data, d => d.group);

  bars.enter()
    .append("rect")
    .attr("x", d => x(d.group))
    .attr("width", x.bandwidth())
    .attr("y", y(0)) // Start from bottom
    .attr("height", 0)
    .attr("fill", (d, i) => color(i))
    .merge(bars)
    .transition()
    .duration(800)
    .attr("x", d => x(d.group))
    .attr("width", x.bandwidth())
    .attr("y", d => y(d.value))
    .attr("height", d => innerHeight - y(d.value))
    .attr("fill", (d, i) => color(i));

  bars.exit()
    .transition()
    .duration(400)
    .attr("y", y(0))
    .attr("height", 0)
    .remove();
    
  // Update axes
  let tickLabels = ['Historical',options.scenario];
  
  g.select(".x-axis")
    .transition()
    .duration(500)
    .call(d3.axisBottom(x).tickSize(0).tickPadding(15).tickFormat((d,i) => tickLabels[i]))
    .selectAll("text")
    .style("font-size", "12pt")

  g.select(".x-axis").select("path").remove();

  g.select(".y-axis")
    .transition()
    .duration(500)
    .call(gAxis => {
      const maxY = y.domain()[3];
      gAxis.call(d3.axisLeft(y).ticks(3).tickValues([0, maxY*.5, maxY*.8,maxY]));
      gAxis.selectAll(".tick line")
        .attr("x1", -5)
        .attr("x2", 5)
        .style("stroke", "#000")
        .style("stroke-width", 1);
      gAxis.selectAll("text")
        .style("font-size", "12pt")
    });  
    
  
  const breakY = innerHeight*7/16+4
    const axisX = 0;            
    const size = 8;             
    
  svg.selectAll(".axis-break").remove();
  
  g.append("line")
    .attr("class", "axis-break")
    .attr("x1", axisX)
    .attr("y1", breakY+4)
    .attr("x2", innerWidth)
    .attr("y2", breakY+4)
    .attr("stroke", "#f9f9f9")
    .attr("stroke-width", 8);
    

  g.append("line")
    .attr("class", "axis-break")
    .attr("x1", axisX-size)
    .attr("y1", breakY-size/2)
    .attr("x2", axisX + size)
    .attr("y2", breakY + size/2)
    .attr("stroke", "black");
  
  g.append("line")
    .attr("class", "axis-break")
    .attr("x1", axisX-size)
    .attr("y1", breakY-size/2+8)
    .attr("x2", axisX + size)
    .attr("y2", breakY + size/2+8)
    .attr("stroke", "black");


  //titles
  function updateText(selector, text, dy) {
    let el = svg.select(selector);
    if (el.empty()) {
      el = svg.append("text").attr("class", selector.replace(".", ""));
    }
    el.attr("x", width / 2 + margin.left/2)
      .attr("y", margin.top*1/3 + dy)
      .attr("text-anchor", "middle")
      .style("font-size", "16px")
      .style("font-weight", "bold")
      .text(text || "");
  }

  updateText(".chart-title", options.title, 0);
  updateText(".chart-title2", options.title2, 18);
  svg.select(".chart-title2").style("fill", "#000");
  updateText(".chart-subtitle", options.subtitle, 40);
});

//r2d3.onResize(function(width, height) {
  // Do nothing – this disables auto-redraw on resize
//});
