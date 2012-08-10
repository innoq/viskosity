/*jslint vars: true, white: true */
/*global jQuery, d3, VISKOSITY */

VISKOSITY.graph = (function($) {

"use strict";

var prop = VISKOSITY.getProp;
var setContext = function(fn, ctx) {
	return function() {
		var context = $.extend({ context: this }, ctx);
		fn.apply(context, arguments);
	};
};

var graph = {
	charge: -500,
	linkDistance: 100,
	linkStrength: 0.5,
	colorize: (function(fn) { // TODO: rename
		return function(item) { return fn(item.group || 0); };
	}(d3.scale.category20())), // XXX: bad default?
	identity: function(item) { return item.id; } // XXX: bad expectation?
};
// `container` may be a DOM node, selector or jQuery object
// `data` is the initial data set, an object with arrays for `nodes` and `edges`
// `settings` is an optional set of key-value pairs for width and height
graph.init = function(container, data, settings) {
	settings = settings || {};

	// XXX: unnecessary jQuery dependency?
	container = container.jquery ? container : $(container);
	this.width = settings.width || container.width();
	this.height = settings.height || container.height();

	this.root = d3.select(container[0]).append("svg").
			attr("width", this.width).attr("height", this.height);
	this.graph = d3.layout.force(). // TODO: (re)calculate settings dynamically to account for graph size
			charge(this.charge).
			linkDistance(this.linkDistance).
			linkStrength(this.linkStrength).
			size([this.width, this.height]);

	this.graph.nodes(data.nodes).links(data.edges);
	this.render();

	this.graph.on("tick", $.proxy(this.onTick, this));
};
graph.onTick = function() {
	var self = this;
	this.root.selectAll("line.link").
			attr("x1", prop("source", "x")).
			attr("y1", prop("source", "y")).
			attr("x2", prop("target", "x")).
			attr("y2", prop("target", "y"));
	this.root.selectAll("g.node").attr("transform", function(item) {
		item.x = Math.max(item.size, Math.min(self.width - item.size, item.x));
		item.y = Math.max(item.size, Math.min(self.height - item.size, item.y));
		return "translate(" + item.x + "," + item.y + ")";
	});
};
graph.render = function() { // TODO: rename?
	var edges = this.root.selectAll("line.link").
			data(this.graph.links());
	edges.exit().remove(); // TODO: animate
	edges.enter().
			append("line"). // TODO: customizable appearance
				attr("class", "edge link").
				style("stroke-width", function(item) {
					var value = item.value || 0;
					return Math.sqrt(value * 3);
				});

	var nodes = this.root.selectAll("g.node").
			data(this.graph.nodes(), this.identity);
	nodes.exit().remove(); // TODO: animate
	var newNodes = nodes.enter().
			append("g").attr("class", "node").
			call(this.graph.drag); // XXX: unnecessary!?
	newNodes.append("path").
			attr("d", this.shape()).
			style("fill", this.colorize);
	newNodes.append("text").text(prop("name"));
	if(this.onClick) {
		newNodes.on("click", setContext(this.onClick, { graph: this }));
	}

	this.graph.start();

	this.root.selectAll("g.node").classed("extensible", function(item) {
		return item.weight < item.relations;
	});
};
graph.shape = function() { // TODO: rename
	return d3.svg.symbol().
			type(function(item) { return item.type || "circle"; }).
			size(function(item) {
				var size = (item.relations || 1) * 10;
				item.size = Math.sqrt(size); // shape size is in px²
				return size;
			});
};

return graph;

}(jQuery));
