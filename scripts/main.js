VISKOSITY.skosProvider({ uri: document.location.hash.substr(1) }, null, function(data) {
	var graph = Object.create(VISKOSITY.graph);
	graph.init("#viz", data, { height: 500, provider: VISKOSITY.skosProvider });
});
