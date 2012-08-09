VISKOSITY.skosProvider({ uri: document.location.hash.substr(1) }, null, function(data) {
	var graph = Object.create(VISKOSITY.graph);
	graph.init("#viz", data, {
		width: jQuery(window).width() * 0.9,
		height: jQuery(window).height() * 0.9,
		provider: VISKOSITY.skosProvider
	});
});
