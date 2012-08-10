VISKOSITY.skosProvider({ uri: document.location.hash.substr(1) }, null, function(data) {
	var graph = Object.create(VISKOSITY.igraph);
	var win = jQuery(window);
	graph.init("#viz", data, {
		width: win.width() * 0.9,
		height: win.height() * 0.9,
		provider: VISKOSITY.skosProvider
	});
});
