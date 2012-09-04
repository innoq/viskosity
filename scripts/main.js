/*jslint vars: true, browser: true, white: true */
/*global jQuery, VISKOSITY */

(function($) {

"use strict";

var provider = VISKOSITY.rdfProvider();
var uri = document.location.hash.substr(1);

var graph = Object.create(VISKOSITY.igraph);
var win = $(window);
graph.init("#viz", {}, {
	width: win.width() * 0.9,
	height: win.height() * 0.9,
	provider: provider
});

provider({ uri: uri }, null, $.proxy(graph.addData, graph));

}(jQuery));
