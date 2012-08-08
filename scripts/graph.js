/*jslint vars: true, white: true */
/*global jQuery, d3, VISKOSITY */

VISKOSITY.graph = (function($) {

"use strict";

var prop = VISKOSITY.getProp;
var pusher = VISKOSITY.pusher;
var scale = function(item) { return item.relations / 10 };

var graph = {
	charge: -500,
	linkDistance: 100,
	linkStrength: 0.5,
	colorize: (function(fn) { // TODO: rename
		return function(item) { return fn(item.group); };
	}(d3.scale.category20())), // XXX: bad default?
	identity: function(item) { return item.id; } // XXX: bad expectation?
};
// `container` may be a DOM node, selector or jQuery object
// `data` is the initial data set, an object with arrays for `nodes` and `edges`
// `settings` is an optional set of key-value pairs for width and height
// `settings.provider` is a function which is used to retrieve additional data -
// it is passed the respective node along with the full data set and a callback,
// to which it should pass an object with arrays for `nodes` and `edges`
graph.init = function(container, data, settings) {
	settings = settings || {};

	// XXX: unnecessary jQuery dependency?
	container = container.jquery ? container : $(container);
	this.width = settings.width || container.width();
	this.height = settings.height || container.height();

	this.data = data;
	this.provider = settings.provider;
	this.root = d3.select(container[0]).append("svg").
			attr("width", this.width).attr("height", this.height);
	this.graph = d3.layout.force(). // TODO: (re)calculate settings dynamically to account for graph size
			charge(this.charge).
			linkDistance(this.linkDistance).
			linkStrength(this.linkStrength).
			size([this.width, this.height]);

	this.graph.nodes(this.data.nodes).links(this.data.edges);
	this.render();

	this.graph.on("tick", $.proxy(this.onTick, this));
};
graph.onClick = function(item) {
	if(!this.provider) {
		return;
	}
	this.provider(item, this.data, $.proxy(this.addData, this));
};
graph.onTick = function() {
	this.root.selectAll("line.link").
			attr("x1", prop("source", "x")).
			attr("y1", prop("source", "y")).
			attr("x2", prop("target", "x")).
			attr("y2", prop("target", "y"));
	this.root.selectAll("g.node").attr("transform", function(item) {
		return "translate(" + item.x + "," + item.y + ")";
	});
};
graph.addData = function(data) {
	if(data.nodes.length || data.edges.length) {
		$.each(data.nodes, pusher(this.data.nodes));
		$.each(data.edges, pusher(this.data.edges));
		this.render();
	}
};
graph.render = function() { // TODO: rename?
	this.root.selectAll("line.link").
			data(this.data.edges).
			enter().
			append("line"). // TODO: customizable appearance
				attr("class", "edge link").
				style("stroke-width", function(item) {
					return Math.sqrt(item.value * 3);
				});

	var nodes = this.root.selectAll("g.node").
			data(this.data.nodes, this.identity).
			enter().
			append("g").attr("class", "node").
			on("click", $.proxy(this.onClick, this)).
			call(this.graph.drag); // XXX: ?
	nodes.append("circle"). // TODO: customizable appearance
			attr("r", 15).
			style("fill", this.colorize).
			style("stroke-opacity", scale).
			style("fill-opacity", scale);
	nodes.append("text").
			attr("text-anchor", "middle").
			attr("dx", 0).
			attr("dy", "0.35em").
			text(prop("name"));

	this.graph.start();
};

return graph;

}(jQuery));
