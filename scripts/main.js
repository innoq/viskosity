VISKOSITY.skosProvider({ uri: "data/model_building.json" }, null, function(data) {
	var graph = Object.create(VISKOSITY.graph);
	graph.init("#viz", data, { height: 500, provider: VISKOSITY.skosProvider });
});
