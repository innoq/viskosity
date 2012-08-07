if(!Object.create) {
	Object.create = function(obj) {
		if(arguments.length > 1) {
			throw new Error("properties parameter is not supported");
		}
		var F = function() {};
		F.prototype = obj;
		return new F();
	};
}

/*
XXX: DEBUG
*/

var data = {
	nodes: [
		{ name: "FND", group: 1 },
		{ name: "cdent", group: 2 },
		{ name: "imexil", group: 1 },
		{ name: "jdlrobson", group: 3 },
		{ name: "zac", group: 3 },
		{ name: "tillsc", group: 1 }
	],
	edges: [
		{ source: 0, target: 1, value: 4 },
		{ source: 0, target: 2, value: 2 },
		{ source: 0, target: 3, value: 1 },
		{ source: 0, target: 5, value: 2 },
		{ source: 1, target: 4, value: 3 }
	]
};

var provider = function(node) {
	var node = { name: "robertg", group: 1 };

	var edges = [
		{ source: 0, target: 6, value: 2 },
		{ source: 5, target: 6, value: 3 }
	];

	return { nodes: [node], edges: edges };
};

var graph = Object.create(VISKOSITY.graph);
graph.init("#viz", data, { height: 500, provider: provider });
