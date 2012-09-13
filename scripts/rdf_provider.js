/*jslint vars: true, unparam: true, white: true */
/*global jQuery, VISKOSITY */

VISKOSITY.rdfProvider = (function($) { // TODO: rename to SKOS provider

"use strict";

var namespaces = {
	rdf: "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
	skos: "http://www.w3.org/2004/02/skos/core#"
};

// mapping of relation types to connection weightings
var relationTypes = { // TODO: review values
	"skos:related": 1,
	"skos:broader": 2,
	"skos:narrower": 2
};

var request = {}; // TODO: rename?
request.create = function(uri, store, callback) {
	var self = Object.create(this);
	self.store = store;
	self.callback = callback;
	$.get(uri, $.proxy(self, "processResponse"), "xml");
	return self;
};
request.processResponse = function(doc, status, xhr) {
	var self = this;
	var db = $.rdf().load(doc);

	var concepts = db.where(triple("?concept", "rdf:type", "skos:Concept"));
	concepts.each(function(i, item) {
		var node = VISKOSITY.node.create(resourceID(item.concept));
		self.store.addNode(node);
	});

	$.each(relationTypes, function(relType, weight) {
		var relations = db.where(triple("?source", relType, "?target"));
		relations.each(function(i, item) {
			var source = resourceID(item.source);
			var target = resourceID(item.target);
			self.store.addEdge(source, target);
		});
	});

	this.callback();
};

function concept2node(concept) {
	return VISKOSITY.node.create(resourceID(concept));
}

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
	request.create(node.toString(), store, callback);
};

}(jQuery));
