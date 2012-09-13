/*jslint vars: true, white: true */
/*global jQuery, VISKOSITY */

VISKOSITY.graphStore = (function($) {

"use strict";

var drop = VISKOSITY.dropArgs;

var store = {};
store.init = function(nodes, edges) {
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
store.addEdge = function(sourceID, targetID) { // XXX: API inconsistent with nodes'
	// TODO: validate IDs
	this.addNode(VISKOSITY.node.create(sourceID));
	this.addNode(VISKOSITY.node.create(targetID));
	var source = this.getNode(sourceID);
	var target = this.getNode(targetID);
	// TODO: discard dupes
	return this.edges.push({ source: source, target: target });
};

return store;

}(jQuery));
