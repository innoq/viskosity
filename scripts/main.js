/*jslint vars: true, browser: true, white: true */
/*global jQuery, VISKOSITY */

(function($) {

"use strict";

var endpoint = "http://store.led.innoq.com/demo";
var provider = VISKOSITY.sparqlProvider(endpoint);
var uri = "http://localhost.localdomain:3000/model_building";

var graph = Object.create(VISKOSITY.igraph);
var win = $(window);
graph.init("#viz", {}, {
	width: win.width() * 0.9,
	height: win.height() * 0.9,
	provider: provider
});

provider({ id: uri }, graph.store, $.proxy(graph, "render")); // XXX: should be encapsulated in `graph`

}(jQuery));
