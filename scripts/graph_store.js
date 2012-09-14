/*jslint vars: true, white: true */
/*global jQuery, VISKOSITY */

// keeps track of nodes and edges
// each node is an object with an `id` property
// each edge is an object with `source` and `target` properties, referencing
// node objects
VISKOSITY.graphStore = (function($) {

"use strict";

var store = {};
store.init = function(nodes, edges) {
	this.nodes = nodes || [];
	this.edges = edges || [];

	this.nodeCache = {};
	var self = this;
	$.each(this.nodes, function(i, node) {
		self.registerNode(node);
	});

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
store.addEdge = function(sourceID, targetID) { // XXX: API inconsistent with nodes'
	// TODO: validate IDs
	this.addNode({ id: sourceID });
	this.addNode({ id: targetID });
	var source = this.getNode(sourceID);
	var target = this.getNode(targetID);
	// TODO: discard dupes
	return this.edges.push({ source: source, target: target });
};

return store;

}(jQuery));
