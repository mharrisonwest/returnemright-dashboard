//Set some initial values
var margin = options.margin,
    barPadding = options.barPadding,
    width = width-(2*margin),
    height = height-(2*margin),
    barWidth = Math.floor(width/data.length),
    xmax = d3.max(data, function(d) { return d.group; }),
    xmin = d3.min(data, function(d) { 0; }),
    ymax = d3.max(data, function(d) { return d.value+.2; })
    color = d3.scaleOrdinal(["#043D5D", "#6FA0A2"]); //new set colors
svg.style("background","none")
//Create the chart
svg.selectAll('rect')
   .data(data)
   .enter()
   .append('rect')
   .attr('height', function(d) { return d.value/ymax * height; })
   .attr('width', barWidth-barPadding)
   .attr('x', function(d, i) { return (margin+(i * barWidth)); })
   .attr('y', function(d) { return (height+margin-(d.value/ymax * height)); })
   .attr('fill', function(d, i) {
    return color(i);
  })


//Create the x axis
var x = d3.scaleBand()
          .domain(data.map(function(d) { return d.group; }))
          .range([0, width+margin*2/3-barPadding]);
svg.append("g")
  .attr("transform", "translate(" + margin*2/3 + "," + (height+margin) + ")")
  .call(d3.axisBottom(x).tickSize(0).tickPadding(15))
  .style("font-size", "14pt");
svg.append("text")             
  .attr("transform", "translate(" + (width/2) + " ," + (height+2*margin) + ")")
  //.attr("dx", "1em")
  .attr("dx", "20")
  .style("text-anchor", "middle")
  .style("font-weight", "bold")
  .style("font-size", "20pt")
  .text(options.xLabel);

//Create the y axis
var y = d3.scaleLinear()
          .range([height, 0])
          .domain([0, ymax]);
svg.append("g")
  .attr("transform", "translate(" + margin*2/3 + ", " + margin + ")")
  .call(d3.axisLeft(y))
  .style("font-size", "12pt");
svg.append("text")
  .attr("transform", "translate(" + 0 + " ," + ((height+2*margin)/2) + ") rotate(-90)")
  .attr("dy", "1em")
  .style("text-anchor", "middle")
  .style("font-family", "Tahoma, Geneva, sans-serif")
  .style("font-size", "14pt")
  .text(options.yLabel);
  
//chart title
svg.append("text")
  .attr("x", (width / 2+margin*2/3))             
  .attr("y", (margin/2))
  .attr("text-anchor", "middle")
  .style("font-size", "16pt")
  .style("font-weight", "bold")
  .text(options.title);
  

svg.append("text")
  .attr("x", (width / 2+margin*2/3))             
  .attr("y", (margin/2))
  .attr("text-anchor", "middle")
  .style("font-size", "16pt")
  .style("font-weight", "bold")
  .text(options.title);
