makeGraphData = (data)->
  graph = 
    nodes : []
    links : []


  groupMap = do()->
    memo = {}
    counter = 1
    return (name)->
      return if memo[name] then memo[name] else memo[name] = counter++

  indexMap = {}

  for k, v of data.Resources
    graph.nodes.push 
      "id" : k
      "type" : v.Type
      "properties" : v.Properties
      "group" : groupMap(v.Type)
      "_origin" : v
      "children" : []
      "dependencies" : []
      "as" : "resource"
    indexMap[k] = graph.nodes.length - 1

  for k, v of data.Parameters
    graph.nodes.push 
      "id" : k
      "type" : v.Type
      "group" : groupMap(v.Type)
      "_origin" : v
      "children" : []
      "dependencies" : []
      "as" : "parameter"

    indexMap[k] = graph.nodes.length - 1
  

  deepSearch = (node, target)->
    switch true
      when _.isArray target then deepSearch(node, prop) for prop in target
      when _.isObject target then deepSearch(node, prop) for k, prop of target
      when _.isString target
        index = indexMap[target] || indexMap[target.replace("-", "")]
        if index?
          graph.links.push
            source : indexMap[node.id]
            target : index
      else
        if indexMap[target]?
          graph.links.push
            source : indexMap[node.id]
            target : indexMap[target]

  for node, index in graph.nodes when node.as is "resource"
    for k, prop of node.properties
      deepSearch(node, prop) 

  graph.links.forEach (link)->
    source = graph.nodes[link.source]
    target = graph.nodes[link.target]

    target.children.push source
    source.dependencies.push target

  return graph

makeGraph = (svg, graph, init)->

  force
    .nodes(graph.nodes)
    .links(graph.links)
    .start()

  link = svg.selectAll(".link").data(graph.links)
  link
      .enter()
      .append("line")
        .attr("class", "link")
        .style("stroke-width", (d) -> Math.sqrt 2)

  link
      .exit().remove()

  node = svg.selectAll("g.node").data(graph.nodes, (d)-> d.id)

  nodeEnter = node
        .enter()
        .append("svg:g")
          .attr("id", (d)-> d.id)
          .attr("class", "node")
          .attr("transform", (d)-> "translate(" + d.x + "," + d.y + ")")
        .on("click", (d)-> 
          svg
            .select(".current")
            .classed current : false
          svg
            .select("##{d.id}")
            .classed current : true
          $nodeInformationArea
            .empty()
            .append($("<h3>").text(d.id))
            .append($("<pre>").text(JSON.stringify(d._origin, null, 2)))
        )
        .on("dblclick",
          do(origin=graph)-> 
            filtered = off
            return (d)->
              d3.event.stopPropagation()
              if filtered
                makeGraph svg, origin, filtered
              else
                filteredGraph = {}
                filteredGraph.nodes = origin.nodes.filter (nodeData)-> d is nodeData or d.children.indexOf(nodeData) >= 0 or d.dependencies.indexOf(nodeData) >= 0
                filteredGraph.links = origin.links.filter (linkData)-> d is linkData.source or d is linkData.target
                makeGraph svg, filteredGraph, filtered
              filtered = !filtered
              return false
        )
        .call(force.drag)

  nodeEnter
        .filter((d)-> d.as is "resource")
        .append("svg:circle")
          .attr("r", (d)-> Math.max(d.children.length,5))
          .style("fill", (d) -> color d.group)
        .append("svg:title")
          .text((d)-> d.type)
  nodeEnter
        .filter((d)-> d.as is "parameter")
        .append("svg:rect")
          .attr("width", (d)-> 10)
          .attr("height", (d)-> 10)
          .style("fill", (d) -> color d.group)
        .append("svg:title")
          .text((d)-> d.type)

  nodeEnter.append("svg:text")
        .attr("x", 10)
        .attr("dy", ".31em")
        .attr("class", "shadow")
        .style("font-size", "12px")
        .text((d)-> d.id)

  nodeEnter.append("svg:text")
        .attr("x", 10)
        .attr("dy", ".35em")
        .attr("class", "text")
        .style("font-size", "12px")
        .text((d)-> d.id)

  node.exit().remove()



  force.on "tick", ->
    link
      .attr("x1", (d) -> d.source.x)
      .attr("y1", (d) -> d.source.y)
      .attr("x2", (d) -> d.target.x)
      .attr "y2", (d) -> d.target.y

    node
      .attr("transform", (d) -> "translate(" + d.x + "," + d.y + ")")

$json = $("#json")
$graphArea = $("#graphArea")
$inputForm = $("#inputForm")
$nodeInformationArea = $("#nodeInformationArea")

width = $graphArea.width()
height = 800
color = d3.scale.category20()
force = d3.layout
  .force()
  .charge((d)-> -100 * d.children.length - 200)
  .linkDistance((d)-> 80)
  .size(
    [
      width
      height
    ]
  )

$("#visualizeBtn").click ()->

  try
    data = JSON.parse($json.val())
    $graphArea.empty()

    redraw = ()->
      svg.attr("transform" , "translate(#{d3.event.translate}) scale(#{d3.event.scale})")
      svg.selectAll("text")
          .style("font-size" , (12 / d3.event.scale) + "px")
      svg.selectAll("text.text")
          .style("stroke-width" , (0.8 / d3.event.scale) + "px")
      svg.selectAll("text.shadow")
          .style("stroke-width" , (3 / d3.event.scale) + "px")

      return false

    svg = d3.select("#graphArea")
          .append("svg")
            .attr("width", width)
            .attr("height", height)
          .append("svg:g")
            .call(d3.behavior.zoom().on("zoom", redraw))
          .append("svg:g")

    graph = makeGraphData(data)
    makeGraph svg, graph, yes
  catch e
    console.log e

  return false
    
  
$.ajax("scripts/temp.json").then (val)->
  $json.val JSON.stringify(val, null , 2)

