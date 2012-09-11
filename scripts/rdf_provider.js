/*jslint vars: true, unparam: true, white: true */
/*global jQuery, VISKOSITY */

VISKOSITY.rdfProvider = (function($) { // TODO: rename to SKOS provider

"use strict";

var prop = VISKOSITY.getProp,
	drop = VISKOSITY.dropArgs;

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

var provider = {};
provider.init = function() {
	this.store = Object.create(VISKOSITY.graphStore);
	this.store.init();
	this.ref = $(this); // TODO: rename
};
provider.request = function(node, callback) {
	this.ref.bind("newData", drop(callback)); // TODO: rename event

	$.get(node.toString(), $.proxy(this.processResponse, this), "xml");
};
provider.processResponse = function(doc, status, xhr) {
	this.db = parseRDF(doc);

	var concepts = this.db.where(triple("?concept", "rdf:type", "skos:Concept")).
			map(drop(prop("concept")));
	var nodes = $.map(concepts, $.proxy(this.concept2node, this));
	this.ref.trigger("newData", { nodes: nodes });

	var edges = $.map(relationTypes, $.proxy(this.rel2edges, this));
	this.ref.trigger("newData", { edges: edges });
};
provider.concept2node = function(concept) {
	var labels = this.db.where(triple(concept, "skos:prefLabel", "?label")).
			map(drop(prop("label", "value"))).
			map(drop(fixLiteral));

	var relations = Object.keys(relationTypes);
	relations = this.db.about(concept).filter(function(i, data) {
		return $.inArray(data.property.value.toString(), relations) !== -1;
	});

	var node = generateNode(concept, labels[0], relations.length); // XXX: label handling hacky; should select by locale

	var storedNode = this.store.getNode(node.id);
	if(storedNode) {
		$.extend(storedNode, node); // XXX: side-effecty; bad encapsulation
		return null;
	} else {
		this.store.addNode(node);
		return node;
	}
};
provider.rel2edges = function(weight, relType) {
	var query = triple("?source", relType, "?target");
	var self = this;
	var edges = this.db.where(query).map(function(i, data) {
		var resources = [data.source, data.target];
		var nodeTuple = $.map(resources, function(resource, i) {
			var uri = resourceID(resource);
			var node = self.store.getNode(uri);
			if(!node) { // XXX: breaks encapsulation
				node = VISKOSITY.node.create(uri);
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
};

function generateNode(resource, label, relCount) {
	var node = VISKOSITY.node.create(resourceID(resource));
	if(label) {
		node.name = label;
	}
	if(relCount) {
		node.relations = relCount;
	}
	return node;
}

function parseRDF(doc) {
	var namespaces = determineNamespaces(doc.documentElement); // XXX: irrelevant?
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

return function() { // NB: factory
	var prv = Object.create(provider);
	prv.init();
	return function() { // bind function context -- TODO use Function#bind
		prv.request.apply(prv, arguments);
	};
};

}(jQuery));
