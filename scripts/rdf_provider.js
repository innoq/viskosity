/*jslint vars: true, white: true */
/*global jQuery, VISKOSITY */

VISKOSITY.rdfProvider = (function($) { // TODO: rename to SKOS provider

"use strict";

var prop = VISKOSITY.getProp,
	drop = VISKOSITY.dropArgs;

// mapping of relation types to connection weightings
var relationTypes = { // TODO: review values -- XXX: SKOS URLs must also take into account http://www.w3.org/2009/08/skos-reference/skos.html#
	"http://www.w3.org/2004/02/skos/core#related": 1,
	"http://www.w3.org/2004/02/skos/core#broader": 2,
	"http://www.w3.org/2004/02/skos/core#narrower": 2
};

var provider = {};
provider.init = function() {
	this.store = Object.create(VISKOSITY.graphStore);
	this.store.init();
	this.ref = $(this); // TODO: rename
};
provider.request = function(node, data, callback) { // XXX: `data` obsolete due to store!?
	if(!node.uri) { throw "missing URI"; } // XXX: DEBUG?

	this.ref.bind("newData", drop(callback)); // TODO: rename event

	$.get(node.uri, $.proxy(this.processResponse, this)); // TODO: specify Accept header, error handling
};
provider.processResponse = function(doc, status, xhr) {
	this.db = parseRDF(doc);
	var store = this.store;

	// XXX: hard-coded namespace prefixes; these are theoretically arbitrary (read from incoming data)
	var concepts = this.db.where("?concept rdf:type skos:Concept").
			map(drop(prop("concept")));
	var nodes = $.map(concepts, $.proxy(this.concept2node, this));
	this.ref.trigger("newData", { nodes: nodes });

	var edges = $.map(relationTypes, $.proxy(this.rel2edges, this));
	this.ref.trigger("newData", { edges: edges });
};
provider.concept2node = function(concept) {
	var labels = this.db.where(concept + " skos:prefLabel ?label").
			map(drop(prop("label", "value"))).
			map(drop(fixLiteral));

	var relations = Object.keys(relationTypes);
	relations = this.db.about(concept).filter(function(i, data) {
		return $.inArray(data.property.value.toString(), relations) !== -1;
	});

	var node = generateNode(concept, labels[0], relations.length); // XXX: label handling hacky; should select by locale
	this.store.addNode(node);
	return node;
};
provider.rel2edges = function(weight, relType) {
	var query = "?source <" + relType + "> ?target";
	var self = this;
	var edges = this.db.where(query).map(function(i, data) {
		var resources = [data.source, data.target];
		var nodeTuple = $.map(resources, function(resource, i) {
			var uri = resourceID(resource);
			var node = self.store.getNode(uri);
			if(!node) { // XXX: breaks encapsulation
				node = { id: uri, uri: uri }; // XXX: redundant
				self.store.addNode(node);
				self.ref.trigger("newData", { nodes: [node] });
			}
			return node;
		});

		var edge = {
			source: nodeTuple[0],
			target: nodeTuple[1],
			value: weight
		};

		self.store.addEdge(edge);
		return edge;
	});
	return Array.prototype.slice.call(edges, 0); // required for flattening
}

function generateNode(resource, label, relCount) {
	var node = {
		id: resourceID(resource),
		uri: resource.value.toString()
	};
	if(label) {
		node.name = label;
	}
	if(relCount) {
		node.relations = relCount;
	}
	return node;
}

function parseRDF(doc) {
	var namespaces = determineNamespaces(doc.documentElement);
	var base = delete namespaces["default"];

	var db = $.rdf({ base: base, namespaces: namespaces });
	db.load(doc);
	return db;
}

// returns a mapping of namespaces to URIs based on XML attributes, including a
// "default" namespace
function determineNamespaces(node) {
	var attribs = node.attributes;
	var namespaces = {};
	var i;
	for(i = 0; i < attribs.length; i++) {
		var attr = attribs[i];
		if(attr.name === "xmlns") {
			namespaces["default"] = attr.value;
		} else if(attr.name.indexOf("xmlns:") !== -1) {
			var name = attr.name.substr(6);
			namespaces[name] = attr.value;
		}
	}
	return namespaces;
}

function resourceID(resource) {
	return resource.toString().replace(/^<(.*)>$/, "$1");
}

// workaround: rdfQuery mistakenly includes literal quotation marks
// cf. http://code.google.com/p/rdfquery/issues/detail?id=39
function fixLiteral(str) {
	return str.replace(/^"(.*)"$/, "$1");
}

return function() { // NB: factory
	var prv = Object.create(provider);
	prv.init();
	return function() { // bind function context -- TODO use Function#bind
		prv.request.apply(prv, arguments);
	};
};

}(jQuery));
