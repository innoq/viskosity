// ViSKOSity sample provider, illustrating data retrieval (using random data)

/*jslint vars: true, white: true */
/*global VISKOSITY */

VISKOSITY.sampleProvider = (function() {

"use strict";

// returns a random number between 1 and `limit`
function rand(limit) {
	var num = Math.floor(Math.random() * limit);
	return num + 1;
}

function generateNode() {
	var id = rand(1000).toString();
	return {
		id: id, // unique ID -- NB: must be a string
		name: "node #" + id, // used as label
		relations: rand(5), // used for visual distinction and to determine extensibility
		group: rand(3) // used for visual categorization
	};
}

// both `source` and `target` are either node object references or the numeric
// index of the respective nodes in the data set
// `value` is used for visual distinction of links
function generateEdge(source, target, value) {
	return {
		source: source,
		target: target,
		value: value
	};
}

// `node` is the point of origin, usually after the user has clicked a node to extend it
// `store` is a graphStore instance representing the current data set
// `callback` signals the completion of the request handling
return function(node, store, callback) {
	var i;

	var nodes = [];
	for(i = 0; i < 10; i++) {
		var newNode = generateNode();
		store.addNode(newNode);
		nodes.push(newNode);
	}

	var edgeCount = rand(nodes.length);
	for(i = 0; i < edgeCount; i++) {
		var source;
		if(node.id) { // non-dummy node
			source = node;
		} else {
			var sourceIndex = rand(nodes.length) - 1;
			source = nodes[sourceIndex];
		}

		var targetIndex = rand(nodes.length) - 1;
		var target = nodes[targetIndex];

		var value = rand(5);

		store.addEdge(source.id, target.id);
	}

	callback();
};

}());
