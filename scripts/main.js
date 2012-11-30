/*jslint vars: true, browser: true, white: true */
/*global jQuery, VISKOSITY */

(function($) {

"use strict";

var endpoint = "http://store.led.innoq.com/demo";
var provider = VISKOSITY.sparqlProvider(endpoint);
var resource = document.location.hash.substr(1);

// XXX: DEBUG
var presets = {
	"Model building": "http://localhost.localdomain:3000/model_building",
	"Achievement hobbies": "http://localhost.localdomain:3000/achievement_hobbies",
	"Bundesrepublik Deutschland": "http://localhost:8080/umt/_00100129"
};
var links = $.map(presets, function(uri, label) {
	var link = $("<a />").text(label).
			attr("href", document.location.toString().split("#")[0] + "#" + uri);
	return $("<li />").append(link);
});
$("<ul />").append(links).prependTo(document.body);

var graph = Object.create(VISKOSITY.igraph);
var win = $(window);
graph.init("#viz", {}, {
	width: win.width() * 0.9,
	height: win.height() * 0.9,
	provider: provider
});

window.onhashchange = function() {
	document.location.reload(); // XXX: crude
};

provider({ id: resource }, graph.store, $.proxy(graph, "render")); // XXX: should be encapsulated in `graph`

}(jQuery));
