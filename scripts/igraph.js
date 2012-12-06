/*jslint vars: true, white: true */
/*global jQuery, d3, VISKOSITY */

// interactive graph
VISKOSITY.igraph = (function($) {

"use strict";

var base = VISKOSITY.graph,
	pusher = VISKOSITY.pusher;

var igraph = Object.create(base);
// `settings.provider` is a function which is used to retrieve additional data -
// it is passed the respective node along with the full data set and a callback,
// to which it should pass an object with arrays for `nodes` and `edges`
igraph.init = function() {
	base.init.apply(this, arguments);
	var settings = arguments[arguments.length - 1];
	this.provider = settings.provider;
	this.root.on("mousedown", $.proxy(this, "toggleHighlight"));
	this.root = this.root.
			call(d3.behavior.zoom().scaleExtent([0.5, 8]).
					on("zoom", $.proxy(this, "onZoom"))).
			append("g"); // required for zoom context
};
igraph.onClick = function(item) {
	var self = this.graph;
	self.indicator.classed("hidden", false);
	self.toggleHighlight(this.context);
	var data = { nodes: self.graph.nodes(), edges: self.graph.links() };
	self.provider(item, self.store, $.proxy(self, "render"));
};
igraph.onHover = function(item) {
	var hovering = d3.event.type === "mouseover";
	var el = d3.select(this).classed("hover", hovering);

	var transform = el.attr("transform");
	var scale = "scale(2)";
	if(hovering) {
		transform += "scale(2)";
	} else {
		transform = transform.replace(scale, "");
	}
	el.attr("transform", transform);
};
igraph.onZoom = function() {
	var ev = d3.event;
	this.root.attr("transform",
			"translate(" + ev.translate + ")scale(" + ev.scale + ")");
};
igraph.toggleHighlight = function(el) { // TODO: rename
	this.root.selectAll(".active").classed("active", false);
	if(el) {
		d3.select(el).classed("active", true);
	}
};

return igraph;

}(jQuery));
