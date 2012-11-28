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
	var sparql = "SELECT DISTINCT ?prd ?obj ?otype WHERE { " +
			"<" + this.subject + "> ?prd ?obj . }";
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
		console.log($.map(["prd", "obj"], function(prop) {
			var type = result[prop].type;
			var val = result[prop].value;
			if(type === "uri") {
				return val.replace(rdf, "rdf:").replace(skos, "skos:");
			} else {
				return "[" + type + "]" + val;
			}
		}).join(" ")); // XXX: DEBUG
		self.processResult(result);
	});
};
request.processResult = function(result) {
	this.store.getNode(this.subject);
	var rel = result.prd.value; // always a URI
	var obj = result.obj;

	// node type
	var types = { // TODO: move into translator layer -- TODO: use known namespace prefixes
		"http://www.w3.org/2004/02/skos/core#Concept": "entity",
		"http://www.w3.org/2004/02/skos/core#Collection": "collection"
	};
	if(rel === rdf + "type") {
		var type = types[obj.value];
		if(type) {
			this.store.updateNode(this.subject, { type: type });
		}
		return;
	}

	// captions
	if(rel === rdfs + "label") { // TODO: precedence (e.g. language, skos:prefLabel vs. skos:altLabel)
		this.store.updateNode(this.subject, { name: obj.value });
	}

	// relations
	if(rel === skos + "semanticRelation") { // XXX: ontology-specific
		var object = obj.value;
		this.store.addNode(object);
		this.store.addEdge(this.subject, object);
	}
};

// `endpoint` is the SPARQL URI
return function(endpoint) {
	return function(node, store, callback) {
		request.create(endpoint, node.id, store, callback);
	};
};

}(jQuery));
