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
	this.observer = $(this);
};
provider.request = function(node, callback) {
	this.observer.bind("incoming", drop(callback));

	$.get(node.toString(), $.proxy(this.processResponse, this), "xml");
};
provider.processResponse = function(doc, status, xhr) {
	this.db = $.rdf().load(doc);

	var concepts = this.db.where(triple("?concept", "rdf:type", "skos:Concept")).
			map(drop(prop("concept")));
	var nodes = $.map(concepts, $.proxy(this.concept2node, this));
	this.observer.trigger("incoming", { nodes: nodes });

	var edges = $.map(relationTypes, $.proxy(this.rel2edges, this));
	this.observer.trigger("incoming", { edges: edges });
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
				self.observer.trigger("incoming", { nodes: [node] });
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
