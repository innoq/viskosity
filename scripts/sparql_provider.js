/*jslint vars: true, white: true */
/*global VISKOSITY, jQuery */

VISKOSITY.sparqlProvider = (function($) {

"use strict";

var rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
var rdfs = "http://www.w3.org/2000/01/rdf-schema#";
var skos = "http://www.w3.org/2004/02/skos/core#";

var request = {};
request.create = function(endpoint, resource, store, callback) {
	var self = Object.create(this);
	self.subject = resource;
	self.endpoint = endpoint;
	self.store = store;
	self.callback = callback;
	self.query();
	return self;
};
request.query = function() {
	var sparql = "SELECT DISTINCT ?prd ?obj ?otype ?olabel WHERE {\n" +
			"<" + this.subject + "> ?prd ?obj .\n" +
			"OPTIONAL {\n" +
			"?labelClass <" + rdfs + "subPropertyOf> <" + rdfs + "label> .\n" +
			"?obj ?labelClass ?olabel .\n" +
			"}\n}";
	$.ajax({
		type: "POST",
		url: this.endpoint,
		data: { query: sparql },
		headers: { Accept: "application/sparql-results+json" },
		dataType: "json",
		success: $.proxy(this, "processResponse")
	});
};
request.processResponse = function(data, status, xhr) {
	data = data.results.bindings;
	if(data.length) {
		this.store.addNode(this.subject);
		this.translate(data);
	}
	this.callback();
};
request.translate = function(results) {
	var self = this;
	$.each(results, function(i, result) {
		self.processResult(result);
	});
};
request.olabelMap = {}; // XXX: does not belong here / should not be necessary
request.processResult = function(result) { // TODO: move into translator layer
	this.store.getNode(this.subject);
	var rel = result.prd.value; // always a URI
	var obj = result.obj;

	// node type
	var types = { // TODO: use known namespace prefixes
		"http://www.w3.org/2004/02/skos/core#Concept": "entity",
		"http://www.w3.org/2004/02/skos/core#Collection": "collection"
	};
	if(rel === rdf + "type") {
		var type = types[obj.value];
		if(type) {
			this.store.updateNode(this.subject, { type: type });
		}
	}

	// captions
	else if(rel === rdfs + "label") { // TODO: precedence (e.g. language, skos:prefLabel vs. skos:altLabel)
		this.store.updateNode(this.subject, { name: obj.value });
	}

	// relations
	else if(rel === skos + "narrower" || rel === skos + "broader" ||
			rel === skos + "related") { // XXX: ontology-specific
		var object = obj.value;
		this.store.addNode(object);

		var source = this.subject;
		var target = object;
		var attrs;
		if(rel === skos + "broader") {
			attrs = { type: "directed" };
		} else if(rel === skos + "narrower") {
			attrs = { type: "directed" };
			var _source = source;
			source = target;
			target = _source;
		}
		this.store.addEdge(source, target, attrs);

		// XXX: duplicates caption processing
		var objectLabel = this.olabelMap[object];
		if(objectLabel) {
			this.store.updateNode(object, { name: objectLabel });
		}
	}

	// object labels -- XXX: largely duplicates caption processing
	else if(result.olabel) {
		var object = obj.value;
		var registered = this.store.getNode(object);
		var olabel = result.olabel.value;
		// TODO: precedence (cf. caption processing)
		if(registered) {
			this.store.updateNode(object, { name: olabel });
		} else {
			this.olabelMap[object] = olabel;
		}
	}
};

// `endpoint` is the SPARQL URI
return function(endpoint) {
	return function(node, store, callback) {
		request.create(endpoint, node.id, store, callback);
	};
};

}(jQuery));
