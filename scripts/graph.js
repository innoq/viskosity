/*jslint vars: true, white: true */
/*global jQuery, d3 */

var VISKOSITY = VISKOSITY || {};

VISKOSITY.Graph = (function($) {

"use strict";

var prop;

// container may be a DOM node or jQuery selector
// settings is an optional set of key-value pairs
function Graph(container, settings) {
	settings = settings || {};

	// XXX: unnecessary jQuery dependency?
	this.container = container.jquery ? container : $(container);
	this.width = settings.width || this.container.width();
	this.height = settings.height || this.container.height();

	this.root = d3.select("#viz").append("svg").
			attr("width", this.width).attr("height", this.height);
	this.graph = d3.layout.force().
			charge(this.charge).linkDistance(this.linkDistance). // TODO: (re)calculate dynamically to account for graph size
			size([this.width, this.height]).
			on("tick", $.proxy(this.onTick, this));
}
Graph.prototype = {
	charge: -120,
	linkDistance: 30,
	colorize: (function(fn) { // TODO: rename
		return function(item) { return fn(item.group); };
	}(d3.scale.category20())) // XXX: bad default?
};
Graph.prototype.onTick = function() { // XXX: arguments?
	this.root.selectAll("line.link").
			attr("x1", prop("source", "x")).
			attr("y1", prop("source", "y")).
			attr("x2", prop("target", "x")).
			attr("y2", prop("target", "y"));
	this.root.selectAll("circle.node").
			attr("cx", prop("x")).
			attr("cy", prop("y"));
};
Graph.prototype.render = function(data) {
	this.graph.nodes(data.nodes).links(data.edges).start();

	this.root.selectAll("line.link").
			data(data.edges).
			enter().
			append("line").attr("class", "edge link").style("stroke-width",
					function(item) { return Math.sqrt(item.value * 3); });

	var nodes = this.root.selectAll("circle.node").
			data(data.nodes).
			enter().
			append("circle").attr("class", "node").attr("r", 15).
					style("fill", this.colorize).
			call(this.graph.drag); // XXX: ?
	nodes.append("title").text(prop("name")); // XXX: when is this executed; why not chained above?
};

// convenience wrapper
// returns a property getter for arbitrary objects
// if multiple arguments are supplied, the respective sub-property is returned
prop = function() { // TODO: memoize
	var args = arguments;
	return function(obj) {
		var res = obj;
		var i, prop;
		for(i = 0; i < args.length; i++) { // TODO: use `reduce`
			prop = args[i];
			res = res[prop];
		}
		return res;
	};
};

return Graph;

}(jQuery));


/*
XXX: DEBUG
*/

var data = {
	nodes: [
		{ name: "FND", group: 1 },
		{ name: "cdent", group: 2 },
		{ name: "imexil", group: 1 },
		{ name: "jdlrobson", group: 3 },
		{ name: "zac", group: 3 },
		{ name: "tillsc", group: 1 }
	],
	edges: [
		{ source: 0, target: 1, value: 4 },
		{ source: 0, target: 2, value: 2 },
		{ source: 0, target: 3, value: 1 },
		{ source: 0, target: 5, value: 2 },
		{ source: 1, target: 4, value: 3 }
	]
};

(new VISKOSITY.Graph("#viz", { height: 500 })).render(data);
