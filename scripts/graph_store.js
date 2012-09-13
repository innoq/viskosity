/*jslint vars: true, white: true */
/*global jQuery, VISKOSITY */

VISKOSITY.graphStore = (function($) {

"use strict";

var store = {};
store.init = function(nodes, edges) {
	this.nodes = [];
	this.edges = [];
	this.nodeCache = {};

	$.each(nodes || [], $.proxy(this.addNode, this));
	$.each(edges || [], $.proxy(this.addEdge, this));

	return this;
};
store.getNode = function(id) {
	return this.nodeCache[id];
};
store.addNode = function(node) {
	if(!node.id) {
		throw "node lacks ID";
	}
	if(this.nodeCache[node.id]) {
		return false;
	}
	this.nodeCache[node.id] = node;
	return this.nodes.push(node);
};
store.addEdge = function(edge) {
	var index = this.edges.indexOf(edge);
	if(index !== -1) {
		return false;
	}
	return this.edges.push(edge);
};

return store;

}(jQuery));
