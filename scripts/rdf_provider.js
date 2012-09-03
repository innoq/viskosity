/*jslint vars: true, white: true */
/*global jQuery, VISKOSITY */

VISKOSITY.rdfProvider = (function($) { // TODO: rename to SKOS provider

"use strict";

var prop = VISKOSITY.getProp,
	drop = VISKOSITY.dropArgs;

var store = Object.create(VISKOSITY.graphStore); // XXX: singleton
store.init();

// mapping of relation types to connection weightings
var relationTypes = { // TODO: review values -- XXX: SKOS URLs must also take into account http://www.w3.org/2009/08/skos-reference/skos.html#
	"http://www.w3.org/2004/02/skos/core#related": 1,
	"http://www.w3.org/2004/02/skos/core#broader": 2,
	"http://www.w3.org/2004/02/skos/core#narrower": 2
};

var provider = function(node, data, callback) {
	if(!node.uri) { throw "missing URI"; } // XXX: DEBUG?
	$.get(node.uri, function(doc, status, xhr) { // TODO: specify Accept header
		var db = parseRDF(doc);

		// XXX: hard-coded namespace prefixes; these are theoretically arbitrary (read from incoming data)
		var concepts = db.where("?concept rdf:type skos:Concept").
				map(drop(prop("concept")));
		var nodes = $.map(concepts, function(concept) {
			var labels = db.where(concept + " skos:prefLabel ?label").
					map(drop(prop("label", "value"))).
					map(drop(fixLiteral));

			var relations = Object.keys(relationTypes);
			relations = db.about(concept).filter(function(i, data) {
				return $.inArray(data.property.value.toString(), relations) !== -1;
			});

			var node = concept2node(concept, labels[0], relations.length); // XXX: label handling hacky; should select by locale
			store.addNode(node);

			return node;
		});

		var edges = $.map(relationTypes, function(value, type) {
			var query = "?source <" + type + "> ?target";
			var edges = db.where(query).map(function(i, data) {
				var resources = [data.source, data.target];
				var _nodes = $.map(resources, function(resource, i) {
					var uri = resourceID(resource);
					var node = store.getNode(uri);
					if(!node) { // XXX: breaks encapsulation
						node = { id: uri, uri: uri }; // XXX: redundant
						store.addNode(node);
						nodes.push(node);
					}
					return node;
				});

				var edge = {
					source: _nodes[0],
					target: _nodes[1],
					value: value
				};

				store.addEdge(edge);
				return edge;
			});
			return Array.prototype.slice.call(edges, 0); // ensures flattening
		});
		callback({ nodes: nodes, edges: edges });
	});
};

function concept2node(resource, label, relCount) {
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

	var db = $.rdf({ base: base, namespaces: namespaces }); // TODO: s/db/store/
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

// workaround: rdfQuery mistakenly includes literal quotation marks -- TODO: create MTC and bug report
function fixLiteral(str) {
	return str.replace(/^"(.*)"$/, "$1");
}

return provider;

}(jQuery));
