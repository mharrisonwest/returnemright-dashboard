svg.style("background", "none");

var margin = { top: 120, right: 30, bottom: 100, left: 70 },
    innerWidth = width - margin.left - margin.right,
    innerHeight = height - margin.top - margin.bottom,
    barWidth = Math.floor(innerWidth/data.length),
    xmax = d3.max(data, function(d) { return d.group; }),
    xmin = d3.min(data, function(d) { 0; }),
    ymax = d3.max(data, function(d) { return d.value; })
    color = d3.scaleOrdinal(["#043D5D", "#6FA0A2"]); //new set colors


var g = svg.append("g")
  .attr("transform", `translate(${margin.left},${margin.top})`);

//Create the x axis
var x = d3.scaleBand()
          .domain(data.map(function(d) { return d.group; }))
          .range([0, innerWidth])
          .padding(0.5);
          
g.append("g")
  .attr("transform", `translate(0,${innerHeight})`)
  .call(d3.axisBottom(x).tickSize(0).tickPadding(15))
  .style("font-size", "14pt");
  
g.append("text")             
  .attr("transform", `translate(0,${innerHeight+margin.bottom / 2})`)
  //.attr("dx", "20")
  .style("text-anchor", "middle")
  .style("font-weight", "bold")
  .style("font-size", "20pt")
  .text(options.xLabel);

//Create the y axis
var y = d3.scaleLinear()
          .range([innerHeight, 0])
          .domain([0, ymax]);

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
  

//chart
g.selectAll('rect')
   .data(data)
   .enter()
   .append('rect')
   .attr("x", function(d) { return x(d.group); })
   .attr("y", function(d) { return y(d.value); })
   .attr("width", x.bandwidth())
   .attr("height", function(d) { return innerHeight - y(d.value); })
   .attr('fill', function(d, i) {
    return color(i);
  })
  
  
//chart title
svg.append("text")
  .attr("x", width / 2)
  .attr("y", margin.top / 2)
  .attr("text-anchor", "middle")
  .style("font-size", "16px")
  .style("font-weight", "bold")
  .text(options.title);
  
svg.append("text")
  .attr("x", width / 2)
  .attr("y", margin.top / 2 + 18)
  .attr("text-anchor", "middle")
  .style("font-size", "16px")
  .style("font-weight", "bold")
  .text(options.title2);

svg.append("text")
  .attr("x", width / 2)
  .attr("y", margin.top / 2 + 40)
  .attr("text-anchor", "middle")
  .style("font-size", "16px")
  .style("font-weight", "bold")
  .style("fill","#94989D")
  .text(options.subtitle);
