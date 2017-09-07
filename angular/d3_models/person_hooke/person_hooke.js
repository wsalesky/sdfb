
var svg = d3.select("svg"),
    width = +svg.node().getBoundingClientRect().width,
    height = +svg.node().getBoundingClientRect().height;

// console.log(height)
// console.log(d3.select("svg").node().getBoundingClientRect().height)

var graph,
    degreeSize,
    sourceNode;

var confidenceMin = 60;
var confidenceMax = 100;
var complexity = '2';
var dateMin = 1500;
var dateMax = 1700;

svg.append('rect')
    .attr('width', '100%')
    .attr('height', '100%')
    .attr('fill', '#FFFFFF')
    .on('click', function() {
      if (toggle == 1) {
        // Restore nodes and links to normal opacity. (see toggleClick() below)
        d3.selectAll('.link').style('stroke', '#000');
        d3.selectAll('.node')
          .classed('faded', false)
          .classed('focused', false);
        toggle = 0;
      }
    });

// Call zoom for svg container.
svg.call(d3.zoom().on('zoom', zoomed));//.on("dblclick.zoom", null);

var container = svg.append('g');

// Create form for search (see function below).
var search = d3.select("div#tools").append('form').attr('onsubmit', 'return false;');

var box = search.append('input')
	.attr('type', 'text')
	.attr('id', 'searchTerm')
	.attr('placeholder', 'Type to search...');

var button = search.append('input')
	.attr('type', 'button')
	.attr('value', 'Search')
	.on('click', function () { searchNodes(); });

// Toggle for ego networks on click (below).
var toggle = 0;

var link = container.append("g")
    .attr("class", "links")
  .selectAll(".link"),
    node = container.append("g")
      .attr("class", "nodes")
    .selectAll(".node");

var loading = svg.append("text")
    .attr("dy", "0.35em")
    .attr("text-anchor", "middle")
    .attr('x', width/2)
    .attr('y', height/2)
    .attr("font-family", "sans-serif")
    .attr("font-size", 10)
    .text("Simulating. One moment please…");

d3.json("baconnetwork.json", function(error, json) {
  if (error) throw error;

  var t0 = performance.now();

  graph = json.data.attributes;
  sourceNode = json.included;

  degreeSize = d3.scaleLog()
      .domain([d3.min(graph.nodes, function(d) {return d.degree; }),d3.max(graph.nodes, function(d) {return d.degree; })])
      .range([10,45]);

  var simulation = d3.forceSimulation(graph.nodes)
      // .velocityDecay(.5)
      .force("link", d3.forceLink(graph.links).id(function(d) { return d.id; }))
      .force("charge", d3.forceManyBody().strength([-300]))//.distanceMax([500]))
      .force("center", d3.forceCenter(width / 2, height / 2))
      .force("collide", d3.forceCollide().radius( function (d) { return degreeSize(d.degree) + 1; }))
      .force("x", d3.forceX())
      .force("y", d3.forceY())
      .stop();

  loading.remove();

  for (var i = 0, n=Math.ceil(Math.log(simulation.alphaMin()) / Math.log(1 - simulation.alphaDecay())); i < n; ++i) {
    simulation.tick();
  }

  update(confidenceMin, confidenceMax, dateMin, dateMax, complexity);

  var t1 = performance.now();

  console.log("Graph took " + (t1 - t0) + " milliseconds to load.")

  createConfidenceGraph();
  createDateGraph();

});

	// A slider that removes nodes and edges below the input threshold.
// var confidenceSlider = d3.select('div#tools').append('div').text('Confidence Estimate (1- and 2-degree only): ');
//
// var confidenceSliderLabel = confidenceSlider.append('label')
// 	.attr('for', 'threshold')
//   .attr('id', 'confidenceLabel')
// 	.text('60');
// var confidenceSliderMain = confidenceSlider.append('input')
// 	.attr('type', 'range')
// 	.attr('min', 60)
// 	.attr('max', 100)
// 	.attr('value', 60)
// 	.attr('id', 'threshold')
// 	.style('width', '50%')
// 	.style('display', 'block')
// 	.on('input', function () {
// 		threshold = this.value;
//
// 		d3.select('#confidenceLabel').text(threshold);
//
//     update(threshold, complexity);
//
// 	});


  // Radio buttons for network complexity.

var complexityForm = d3.select('div#tools').append('form')

var complexityLabel = complexityForm.append('label')
    .text('Network Complexity: '+complexity+" ")
    .attr('id', 'complexityLabel');

var complexityButtons = complexityForm.selectAll('input')
    .data(['1','1.5','1.75','2','2.5'])
    .enter().append('input')
    .attr('type', 'radio')
    .attr('name', 'complexity')
    .attr('checked', function(d){
      if (d==complexity){
        return 'checked';
      }
    })
    .attr('value', function(d) {return d;});

complexityButtons.on('change', function () {

    complexity = this.value;

    d3.select("#complexityLabel").text("Network Complexity: "+complexity+" ");

    update(confidenceMin, confidenceMax, dateMin, dateMax, complexity);

});

function countConfidenceFrequency() {
  var confidence = d3.range(60,101);
  frequencies = {}
  confidence.forEach(function(c){
    frequencies[c.toString()] = 0;
  });
  graph.links.forEach(function(l){
    frequencies[l.weight] += 1;
  });
  data = [];
  for (x in frequencies) {
    data.push({'weight': x, 'count':frequencies[x]});
  }
  return data;
}

function countDateFrequency() {
  var years = d3.range(parseInt(sourceNode.birth_year),parseInt(sourceNode.death_year)+1);
  frequencies = {}
  years.forEach(function(y) {
    frequencies[y.toString()] = 0;
  });
  years.forEach(function(y) {
    graph.links.forEach(function(l) {
      if (y >= l.start_year && y <= l.end_year) { frequencies[y.toString()] += 1; }
    });
  });
  data = [];
  for (x in frequencies) {
    data.push({'year': x, 'count':frequencies[x]});
  }
  return data;
}

function createConfidenceGraph() {

  confidenceData = countConfidenceFrequency();
  var confidenceGraph = d3.select('div#tools').append('svg').attr('width', 500).attr('height', 100),
      confidenceMargin = {top: 20, right: 20, bottom: 30, left: 40};
      confidenceWidth = +confidenceGraph.attr("width") - confidenceMargin.left - confidenceMargin.right,
      confidenceHeight = +confidenceGraph.attr("height") - confidenceMargin.top - confidenceMargin.bottom;

  var confidenceX = d3.scaleBand().rangeRound([0, confidenceWidth]).padding(0.1),
      confidenceY = d3.scaleLinear().rangeRound([confidenceHeight, 0]);

  var confidenceG = confidenceGraph.append("g")
      .attr("transform", "translate(" + confidenceMargin.left + "," + confidenceMargin.top + ")");

  confidenceX.domain(confidenceData.map(function(d) { return d.weight; }));
  confidenceY.domain([0, d3.max(confidenceData, function(d) { return d.count; })]);

  var brush = d3.brushX()
    .extent([[0, 0], [confidenceWidth, confidenceHeight]])
    .on("end", brushed);

  confidenceG.append("g")
      .attr("class", "axis axis--x")
      .attr("transform", "translate(0," + confidenceHeight + ")")
      .call(d3.axisBottom(confidenceX).tickValues(["60", "100"]).tickFormat(function(d){return d + "%"}));

  confidenceG.selectAll(".bar")
    .data(confidenceData)
    .enter().append("rect")
      .attr("class", "bar")
      .attr("x", function(d) { return confidenceX(d.weight); })
      .attr("y", function(d) { return confidenceY(d.count); })
      .attr("width", confidenceX.bandwidth())
      .attr("height", function(d) { return confidenceHeight - confidenceY(d.count); });

  confidenceG.append("g")
      .attr("class", "brush")
      .call(brush)
      .call(brush.move, confidenceX.range());

  function brushed() {
    var s = d3.event.selection || confidenceX.range();
    var eachBand = confidenceX.step();
    var marginInterval = confidenceMargin.right/eachBand
    var minIndex = Math.round((s[0] / eachBand) - marginInterval);
    var maxIndex = Math.round((s[1] / eachBand) - marginInterval);
    var confidenceMin = confidenceX.domain()[minIndex] || "60";
    var confidenceMax = confidenceX.domain()[maxIndex] || "100";
    update(confidenceMin, confidenceMax, dateMin, dateMax, complexity)
  }
 }

function createDateGraph() {

   dateData = countDateFrequency();
   var dateGraph = d3.select('div#tools').append('svg').attr('width', 500).attr('height', 100),
       dateMargin = {top: '20', right: '20', bottom: '30', left: '40'};
       dateWidth = +dateGraph.attr("width") - dateMargin.left - dateMargin.right,
       dateHeight = +dateGraph.attr("height") - dateMargin.top - dateMargin.bottom;

   var dateX = d3.scaleBand().rangeRound([0, dateWidth]).padding(0.1),
       dateY = d3.scaleLinear().rangeRound([dateHeight, 0]);

   var dateG = dateGraph.append("g")
       .attr("transform", "translate(" + dateMargin.left + "," + dateMargin.top + ")");

   dateX.domain(dateData.map(function(d) { return d.year; }));
   dateY.domain([0, d3.max(dateData, function(d) { return d.count; })]);

   var brush = d3.brushX()
     .extent([[0, 0], [dateWidth, dateHeight]])
     .on("end", brushed);

   dateG.append("g")
       .attr("class", "axis axis--x")
       .attr("transform", "translate(0," + dateHeight + ")")
       .call(d3.axisBottom(dateX).tickValues([sourceNode.birth_year, sourceNode.death_year]));

   dateG.selectAll(".bar")
     .data(dateData)
     .enter().append("rect")
       .attr("class", "bar")
       .attr("x", function(d) { return dateX(d.year); })
       .attr("y", function(d) { return dateY(d.count); })
       .attr("width", dateX.bandwidth())
       .attr("height", function(d) { return dateHeight - dateY(d.count); });

   dateG.append("g")
       .attr("class", "brush")
       .call(brush)
       .call(brush.move, dateX.range());

   function brushed() {
     var s = d3.event.selection || dateX.range();
     var eachBand = dateX.step();
     var marginInterval = dateMargin.right/eachBand
     var minIndex = Math.round((s[0] / eachBand) - marginInterval);
     var maxIndex = Math.round((s[1] / eachBand) - marginInterval);
     var dateMin = dateX.domain()[minIndex] || sourceNode.birth_year;
     var dateMax = dateX.domain()[maxIndex] || sourceNode.death_year;
     update(confidenceMin, confidenceMax, dateMin, dateMax, complexity)
   }
  }

function parseComplexity(thresholdLinks, complexity) {

  var oneDegreeNodes = [];
  thresholdLinks.forEach(function(l){
    if (l.source.id == sourceNode.id || l.target.id == sourceNode.id ) { oneDegreeNodes.push(l.source); oneDegreeNodes.push(l.target);};
  });

  oneDegreeNodes = Array.from(new Set(oneDegreeNodes));

  var twoDegreeNodes = [];
  thresholdLinks.forEach(function(l) {
    if (oneDegreeNodes.indexOf(l.source) != -1 && oneDegreeNodes.indexOf(l.target) == -1) { twoDegreeNodes.push(l.target); }
    else if (oneDegreeNodes.indexOf(l.target) != -1 && oneDegreeNodes.indexOf(l.source) == -1) {twoDegreeNodes.push(l.source); };
  });

  twoDegreeNodes = Array.from(new Set(twoDegreeNodes));

  var allNodes = oneDegreeNodes.concat(twoDegreeNodes);

  allNodes.forEach(function(d) {
    if (d.id == sourceNode.id) { d.distance = 0; }
    else if (oneDegreeNodes.indexOf(d) != -1) { d.distance = 1; }
    else { d.distance = 2; }
  });

    if (complexity == '1') {
      var newLinks = thresholdLinks.filter(function(l) { if (l.source.id == sourceNode.id || l.target.id == sourceNode.id) { return l; }})
      return [oneDegreeNodes, newLinks];
    }

    if (complexity == '1.5') {

      var newLinks = thresholdLinks.filter(function(l) {if (oneDegreeNodes.indexOf(l.source) != -1 && oneDegreeNodes.indexOf(l.target) != -1) {return l;}});
      return [oneDegreeNodes, newLinks];
    }

    if (complexity == '1.75') {
      // var newLinks = thresholdLinks.filter(function(l) {if (oneDegreeNodes.indexOf(l.source) != -1 || oneDegreeNodes.indexOf(l.target) != -1) {return l;}});
      var newNodes = [];
      twoDegreeNodes.forEach(function(d){
        var count = 0;
        thresholdLinks.forEach(function(l){
          if (l.source == d && oneDegreeNodes.indexOf(l.target) != -1) { count += 1; }
          else if (l.target == d && oneDegreeNodes.indexOf(l.source) != -1 ) { count += 1; }
        });
        if (count >= 2) { newNodes.push(d); }
      });

      // newNodes = Array.from(new Set(newNodes));
      newNodes = oneDegreeNodes.concat(newNodes);
      newLinks = thresholdLinks.filter(function(l) {if (newNodes.indexOf(l.source) != -1 && newNodes.indexOf(l.target) != -1) {return l;}});
      return [newNodes, newLinks];
    }

    if (complexity == '2') {
      newLinks = thresholdLinks.filter(function(l) { if (oneDegreeNodes.indexOf(l.source) != -1 || oneDegreeNodes.indexOf(l.source) != -1) {return l;} });
      return [allNodes, newLinks];
    }

    if (complexity == '2.5') {

      var newLinks = thresholdLinks.filter(function(l) {if (allNodes.indexOf(l.source) != -1 && allNodes.indexOf(l.target) != -1) {return l;}});

      return [allNodes, newLinks];
    }
}

function update(confidenceMin, confidenceMax, dateMin, dateMax, complexity) {

  d3.select('.source-node').remove(); //Get rid of old source node highlight.

  // Find the links and nodes that are at or above the threshold.
  var thresholdLinks = graph.links.filter(function(d) {
    if (d.weight >= confidenceMin && d.weight <= confidenceMax && parseInt(d.start_year) <= dateMax && parseInt(d.end_year) >= dateMin) {
      return d;
    };
  });

  var newData = parseComplexity(thresholdLinks, complexity);
  var newNodes = newData[0];
  var newLinks = newData[1];

  // Data join with only those new links and corresponding nodes.
  link = link.data(newLinks, function(d) {return d.source.id + ', ' + d.target.id;});
  link.exit().remove();
  var linkEnter = link.enter().append('path')
          .attr('class', 'link');

      link = linkEnter.merge(link)
      .attr('class', 'link')
      .attr("d", linkArc)
      .attr('stroke-opacity', function(l) { if (l.altered == true) { return 1;} else {return .35;} });

  // When adding and removing nodes, reassert attributes and behaviors.
  node = node.data(newNodes, function(d) {return d.id;})
    .attr('class', function(d){ return 'node degree'+d.distance });
  // .attr("cx", function(d) { return d.x; })
  // .attr("cy", function(d) { return d.y; });
  node.exit().remove();
  var nodeEnter = node.enter().append('circle');

  node.attr('r', function(d) { return degreeSize(d.degree);});

  node = nodeEnter.merge(node)
    .attr('r', function(d) { return degreeSize(d.degree);})
    // .attr("fill", function(d) { return color(d.distance); })
    .attr('class', function(d){ return 'node degree'+d.distance })
    .attr('id', function(d) { return "n" + d.id.toString(); })
    .attr("cx", function(d) { return d.x; })
    .attr("cy", function(d) { return d.y; })
    // .attr("pulse", false)
    .attr("is_source", function(d) {if (d.id == sourceNode.id) {return 'true';} })
    // On click, toggle ego networks for the selected node. (See function above.)
    .on('click', function(d) { toggleClick(d, newLinks); });

    node.append("title")
        .text(function(d) { return d.person_info.name; });

  // d3.select('.nodes').insert('circle', '[is_source="true"]')
  //   .attr('r', degreeSize(d3.select('[is_source="true"]').data()[0].degree) + 10)
  //   .attr('fill', color(d3.select('[is_source="true"]').data()[0].distance))
  //   .attr('class', 'source-node')
  //   .attr("cx", d3.select('[is_source="true"]').data()[0].x)
  //   .attr("cy", d3.select('[is_source="true"]').data()[0].y);
}

// A function to handle click toggling based on neighboring graph.nodes.
function toggleClick(d, newLinks) {


  // Make object of all neighboring nodes.
   connectedNodes = {};
   connectedNodes[d.id] = true;
   newLinks.forEach(function(l) {
     if (l.source.id == d.id) { connectedNodes[l.target.id] = true; }
     else if (l.target.id == d.id) { connectedNodes[l.source.id] = true; };
   });

      if (toggle == 0) {
        // recursivePulse(d);
        // Ternary operator restyles links and nodes if they are adjacent.
        d3.selectAll('.link').style('stroke', function (l) {
          return l.target == d || l.source == d ? 1 : '#D3D3D3';
        });
        d3.selectAll('.node')
           .classed('faded', function(n){
             if (n.id in connectedNodes) { return false }
             else { return true; };
           })
           .classed('focussed', function(n){
             if (n.id in connectedNodes) { return true }
             else { return false; };
           })

    // Show information when node is clicked
    // d3.select('div#tools').append('span').text("Name: " + d.name + "  |  Historical Significance: " + d.historical_significance + "  |  Lived: " + d.birth_year + "-" + d.death_year);
        toggle = 1;
      }
}

// Zooming function translates the size of the svg container.
function zoomed() {
	  container.attr("transform", "translate(" + d3.event.transform.x + ", " + d3.event.transform.y + ") scale(" + d3.event.transform.k + ")");
}

// Search for graph.nodes by making all unmatched graph.nodes temporarily transparent.
function searchNodes() {
	var term = document.getElementById('searchTerm').value;
	var selected = container.selectAll('.node').filter(function (d, i) {
		return d.person_info.name.toLowerCase().search(term.toLowerCase()) == -1;
	});
	selected.classed('faded', true);
	// var link = container.selectAll('.link');
	// link.style('stroke-opacity', '0');
  // console.log(d3.selectAll('.node'));
	// d3.selectAll('.node').classed('faded', false);
	// d3.selectAll('.link').transition().duration(5000).style('stroke-opacity', '0.6');
}

function linkArc(d) {
  var dx = d.target.x - d.source.x,
      dy = d.target.y - d.source.y,
      dr = Math.sqrt(dx * dx + dy * dy);
  return "M" + d.source.x + "," + d.source.y + "A" + dr + "," + dr + " 0 0,1 " + d.target.x + "," + d.target.y;
}


// function recursivePulse(d) {
//   pulse();
//
//   function pulse() {
//     d3.select('#n' + d.id.toString())
//     .attr('pulse', true)
//     .transition().duration(1500).style('opacity', .5)
//     .transition().duration(1500).style('opacity', 1)
//     .on('end', pulse);
//   }
//
// }
