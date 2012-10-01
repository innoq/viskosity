/*jslint vars: true, unparam: true, white: true */
/*global jQuery, VISKOSITY */

VISKOSITY.rdfProvider = (function($) { // TODO: rename to SKOS provider

"use strict";

var namespaces = {
	rdf: "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
	skos: "http://www.w3.org/2004/02/skos/core#"
};

// mapping of node and relation types to corresponding category
var nodeTypes = {
	"skos:Concept": "default",
	"skos:Collection": "collection"
};
var relationTypes = {
	"skos:related": "default",
	"skos:broader": "broader",
	"skos:narrower": "narrower" // XXX: redundant?
};

var labelTypes = ["skos:prefLabel", "skos:altLabel"]; // sorted by preference

var request = {};
request.create = function(uri, store, callback) {
	var self = Object.create(this);
	self.store = store;
	self.callback = callback;
	$.get(uri, $.proxy(self, "processResponse"), "xml");
	return self;
};
request.processResponse = function(doc, status, xhr) {
	var db = $.rdf().load(doc);
	var store = this.store;

	$.each(nodeTypes, function(type, category) {
		var resources = db.where(triple("?resource", "rdf:type", type));
		resources.each(function(i, item) {
			var id = resourceID(item.resource);
			store.addNode(id, { type: category });
		});
	});

	$.each(relationTypes, function(relType, relCat) {
		var relations = db.where(triple("?source", relType, "?target"));
		relations.each(function(i, item) {
			var sourceID = resourceID(item.source);
			var targetID = resourceID(item.target);
			store.addEdge(sourceID, targetID, { type: relCat });
			// inference: both ends are SKOS concepts
			var nodeCat = nodeTypes["skos:Concept"];
			store.updateNode(sourceID, { type: nodeCat });
			store.updateNode(targetID, { type: nodeCat });
		});
	});

	$.each(labelTypes.reverse(), function(i, labelType) {
		var labels = db.where(triple("?entity", labelType, "?label"));
		labels.each(function(i, item) {
			var id = resourceID(item.entity); // SKOS concept or collection
			if(!store.getNode(id)) {
				store.addNode(id, { type: "unknown" }); // XXX: special-casing
			}
			store.updateNode(id, { name: fixLiteral(item.label.value) });
		});
	});

	// TODO: node property `degree`

	this.callback();
};

function resourceID(resource) {
	return resource.value.toString();
}

function triple(s, p, o) {
	return $.map(arguments, function(item, i) {
		if(!item.indexOf) {
			return item.toString();
		} else if(item.indexOf("<") === 0 || item.indexOf(":") === -1) {
			return item;
		} else { // resolve namespace prefix
			item = item.split(":");
			item[0] = namespaces[item[0]];
			return ["<"].concat(item).concat(">").join("");
		}
	}).join(" ");
}

// workaround: rdfQuery mistakenly includes literal quotation marks
// cf. http://code.google.com/p/rdfquery/issues/detail?id=39
function fixLiteral(str) {
	return str.replace(/^"(.*)"$/, "$1");
}

return function(node, store, callback) {
	request.create(node.id, store, callback);
};

}(jQuery));
