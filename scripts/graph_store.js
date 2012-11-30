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

	this.cache = { nodes: {}, edges: {} };
	var self = this;
	$.each(this.nodes, function(i, node) {
		self.registerNode(node);
	});

	return this;
};
store.getNode = function(id) {
	return this.cache.nodes[id];
};
store.addNode = function(id, attribs) {
	var node = { id: id };
	var isNew = this.registerNode(node) && this.nodes.push(node);
	if(isNew && attribs) { // XXX: `isNew` condition provokes silent failures
		this.updateNode(id, attribs);
	}
	return isNew && node;
};
store.updateNode = function(id, attribs) {
	var node = this.getNode(id);

	if(!node) {
		throw "invalid node ID";
	}
	if(attribs.id && attribs.id !== node.id) {
		throw "must not modify ID";
	}

	return $.extend(node, attribs);
};
store.registerNode = function(node) {
	if(!node.id) {
		throw "node lacks ID";
	}
	if(!node.id.substr) {
		throw "ID must be a string";
	}
	if(this.cache.nodes[node.id]) {
		return false;
	}

	this.cache.nodes[node.id] = node;
	return true;
};
store.addEdge = function(sourceID, targetID, attribs) {
	this.addNode(sourceID);
	this.addNode(targetID);
	var source = this.getNode(sourceID);
	var target = this.getNode(targetID);
	if(!source || !target) {
		throw "invalid endpoint";
	}
	// TODO: discard dupes / detect modifications?
	var edge = { source: source, target: target };
	if(attribs) {
		if(attribs.source || attribs.target) {
			throw "must not modify source or target";
		}
		$.extend(edge, attribs);
	}
	this.edges.push(edge);
	return edge;
};

return store;

}(jQuery));
