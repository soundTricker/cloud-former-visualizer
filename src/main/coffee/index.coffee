makeGraph = (data)->
  width = $("#graphArea").width()
  height = 800
  color = d3.scale.category20()
  force = d3.layout
    .force()
    .charge((d)-> -100 * d.children.length - 200)
    .linkDistance((d)-> 80
    )
    .size([
      width
      height
    ])
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
      "as" : "resource"
    indexMap[k] = graph.nodes.length - 1

  for k, v of data.Parameters
    graph.nodes.push 
      "id" : k
      "type" : v.Type
      "group" : groupMap(v.Type)
      "_origin" : v
      "children" : []
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


  svg = d3.select("#graphArea").append("svg").attr("width", width).attr("height", height)
  force.nodes(graph.nodes).links(graph.links).start()
  link = svg.selectAll(".link")
        .data(graph.links)
        .enter()
        .append("line")
          .attr("class", "link")
          .style("stroke-width", (d) -> Math.sqrt 2)

  node = svg.selectAll("g.node").data(graph.nodes)

  nodeEnter = node.enter()
        .append("svg:g")
          .attr("class", "node")
          .attr("transform", (d)-> "translate(" + d.x + "," + d.y + ")")
        .on("click", (d)-> 
          $nodeInformationArea
            .empty()
            .append($("<h3>").text(d.id))
            .append($("<pre>").text(JSON.stringify(d._origin, null, 2)))
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

$("#visualizeBtn").click ()->

  try
    data = JSON.parse($json.val())
    $graphArea.empty()
    makeGraph data
  catch e
    console.log e

  return false
    
  
$.ajax("scripts/temp.json").then (val)->
  $json.val JSON.stringify(val, null , 2)

