(function() {
  var $graphArea, $inputForm, $json, $nodeInformationArea, makeGraph;

  makeGraph = function(data) {
    var color, deepSearch, force, graph, groupMap, height, index, indexMap, k, link, node, nodeEnter, prop, svg, v, width, _i, _len, _ref, _ref1, _ref2, _ref3;
    width = $("#graphArea").width();
    height = 800;
    color = d3.scale.category20();
    force = d3.layout.force().charge(function(d) {
      return -100 * d.children.length - 200;
    }).linkDistance(function(d) {
      return 80;
    }).size([width, height]);
    graph = {
      nodes: [],
      links: []
    };
    groupMap = (function() {
      var counter, memo;
      memo = {};
      counter = 1;
      return function(name) {
        if (memo[name]) {
          return memo[name];
        } else {
          return memo[name] = counter++;
        }
      };
    })();
    indexMap = {};
    _ref = data.Resources;
    for (k in _ref) {
      v = _ref[k];
      graph.nodes.push({
        "id": k,
        "type": v.Type,
        "properties": v.Properties,
        "group": groupMap(v.Type),
        "_origin": v,
        "children": [],
        "as": "resource"
      });
      indexMap[k] = graph.nodes.length - 1;
    }
    _ref1 = data.Parameters;
    for (k in _ref1) {
      v = _ref1[k];
      graph.nodes.push({
        "id": k,
        "type": v.Type,
        "group": groupMap(v.Type),
        "_origin": v,
        "children": [],
        "as": "parameter"
      });
      indexMap[k] = graph.nodes.length - 1;
    }
    deepSearch = function(node, target) {
      var index, prop, _i, _len, _results, _results1;
      switch (true) {
        case _.isArray(target):
          _results = [];
          for (_i = 0, _len = target.length; _i < _len; _i++) {
            prop = target[_i];
            _results.push(deepSearch(node, prop));
          }
          return _results;
          break;
        case _.isObject(target):
          _results1 = [];
          for (k in target) {
            prop = target[k];
            _results1.push(deepSearch(node, prop));
          }
          return _results1;
          break;
        case _.isString(target):
          index = indexMap[target] || indexMap[target.replace("-", "")];
          if (index != null) {
            return graph.links.push({
              source: indexMap[node.id],
              target: index
            });
          }
          break;
        default:
          if (indexMap[target] != null) {
            return graph.links.push({
              source: indexMap[node.id],
              target: indexMap[target]
            });
          }
      }
    };
    _ref2 = graph.nodes;
    for (index = _i = 0, _len = _ref2.length; _i < _len; index = ++_i) {
      node = _ref2[index];
      if (node.as === "resource") {
        _ref3 = node.properties;
        for (k in _ref3) {
          prop = _ref3[k];
          deepSearch(node, prop);
        }
      }
    }
    graph.links.forEach(function(link) {
      var source, target;
      source = graph.nodes[link.source];
      target = graph.nodes[link.target];
      return target.children.push(source);
    });
    svg = d3.select("#graphArea").append("svg").attr("width", width).attr("height", height);
    force.nodes(graph.nodes).links(graph.links).start();
    link = svg.selectAll(".link").data(graph.links).enter().append("line").attr("class", "link").style("stroke-width", function(d) {
      return Math.sqrt(2);
    });
    node = svg.selectAll("g.node").data(graph.nodes);
    nodeEnter = node.enter().append("svg:g").attr("class", "node").attr("transform", function(d) {
      return "translate(" + d.x + "," + d.y + ")";
    }).on("click", function(d) {
      return $nodeInformationArea.empty().append($("<h3>").text(d.id)).append($("<pre>").text(JSON.stringify(d._origin, null, 2)));
    }).call(force.drag);
    nodeEnter.filter(function(d) {
      return d.as === "resource";
    }).append("svg:circle").attr("r", function(d) {
      return Math.max(d.children.length, 5);
    }).style("fill", function(d) {
      return color(d.group);
    }).append("svg:title").text(function(d) {
      return d.type;
    });
    nodeEnter.filter(function(d) {
      return d.as === "parameter";
    }).append("svg:rect").attr("width", function(d) {
      return 10;
    }).attr("height", function(d) {
      return 10;
    }).style("fill", function(d) {
      return color(d.group);
    }).append("svg:title").text(function(d) {
      return d.type;
    });
    nodeEnter.append("svg:text").attr("x", 10).attr("dy", ".31em").attr("class", "shadow").style("font-size", "12px").text(function(d) {
      return d.id;
    });
    nodeEnter.append("svg:text").attr("x", 10).attr("dy", ".35em").attr("class", "text").style("font-size", "12px").text(function(d) {
      return d.id;
    });
    return force.on("tick", function() {
      link.attr("x1", function(d) {
        return d.source.x;
      }).attr("y1", function(d) {
        return d.source.y;
      }).attr("x2", function(d) {
        return d.target.x;
      }).attr("y2", function(d) {
        return d.target.y;
      });
      return node.attr("transform", function(d) {
        return "translate(" + d.x + "," + d.y + ")";
      });
    });
  };

  $json = $("#json");

  $graphArea = $("#graphArea");

  $inputForm = $("#inputForm");

  $nodeInformationArea = $("#nodeInformationArea");

  $("#visualizeBtn").click(function() {
    var data, e;
    try {
      data = JSON.parse($json.val());
      $graphArea.empty();
      makeGraph(data);
    } catch (_error) {
      e = _error;
      console.log(e);
    }
    return false;
  });

  $.ajax("scripts/temp.json").then(function(val) {
    return $json.val(JSON.stringify(val, null, 2));
  });

}).call(this);
