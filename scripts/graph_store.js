/*jslint vars: true, white: true */
/*global jQuery, VISKOSITY */

VISKOSITY.graphStore = (function($) {

"use strict";

var drop = VISKOSITY.dropArgs;

var store = {};
store.init = function(nodes, edges) {
	// NB: intentionally retaining object identity for arguments
	this.nodes = nodes || [];
	this.edges = edges || [];

	this.nodeCache = {};
	$.each(this.nodes, drop($.proxy(this, "registerNode")));

	return this;
};
store.getNode = function(id) {
	return this.nodeCache[id];
};
store.addNode = function(node) {
	return this.registerNode(node) && this.nodes.push(node);
};
store.registerNode = function(node) {
	if(!node.id) {
		throw "node lacks ID";
	}
	if(this.nodeCache[node.id]) {
		return false;
	}
	this.nodeCache[node.id] = node;
	return true;
};
store.addEdge = function(edge) {
	var index = this.edges.indexOf(edge); // XXX: relies on object identity
	if(index !== -1) {
		return false;
	}
	return this.edges.push(edge);
};

return store;

}(jQuery));
