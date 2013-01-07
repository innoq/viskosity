ns = this.VISKOSITY

module "rationalizer"

test "node extraction", ->
	nodeTypes = ["http://skos.org#Concept"]
	rdfData =
		"http://example.org/foo":
			"http://www.w3.org/1999/02/22-rdf-syntax-ns#type": [
				{ type: "uri", value: "http://skos.org#Concept" }
			]
			"http://skos.org#related": [
				{ type: "uri", value: "http://example.org/bar" }
			]
		"http://example.org/bar":
			"http://www.w3.org/1999/02/22-rdf-syntax-ns#type": [
				{ type: "uri", value: "http://random.org/something" }
			]
		"http://example.org/baz":
			"http://www.w3.org/1999/02/22-rdf-syntax-ns#type": [
				{ type: "uri", value: "http://skos.org#Concept" }
			]
		"http://example.org/foobar":
			"http://random.org/whatever": [
				{ type: "uri", value: "http://skos.org#Concept" }
			]

	vgraph = new ns.Rationalizer(rdfData, nodeTypes)
	nodeIDs = Object.keys(vgraph.nodes)
	strictEqual nodeIDs.length, 2
	strictEqual nodeIDs[0], "http://example.org/foo"
	strictEqual vgraph.nodes["http://example.org/foo"].type,
			"http://skos.org#Concept"
	strictEqual nodeIDs[1], "http://example.org/baz"
	strictEqual vgraph.nodes["http://example.org/baz"].type,
			"http://skos.org#Concept"

test "edge extraction", ->
	nodeTypes = ["http://skos.org#Concept"]

	relTypes =
		directed: ["http://skos.org#narrower"]
		undirected: ["http://skos.org#related"]
	rdfData =
		"http://example.org/foo":
			"http://www.w3.org/1999/02/22-rdf-syntax-ns#type": [
				{ type: "uri", value: "http://skos.org#Concept" }
			]
			"http://skos.org#narrower": [
				{ type: "uri", value: "http://example.org/bar" }
			]
			"http://skos.org#related": [
				{ type: "uri", value: "http://example.org/bar" }
			]
		"http://example.org/bar":
			"http://www.w3.org/1999/02/22-rdf-syntax-ns#type": [
				{ type: "uri", value: "http://skos.org#Concept" }
			]

	vgraph = new ns.Rationalizer(rdfData, nodeTypes, relTypes)
	edgeIDs = Object.keys(vgraph.edges)
	strictEqual edgeIDs.length, 2
	edgeID = "http://example.org/foo http://skos.org#narrower http://example.org/bar"
	strictEqual edgeIDs[0], edgeID
	edge = vgraph.edges[edgeID]
	edge = vgraph.edges["http://example.org/foo http://skos.org#narrower http://example.org/bar"]
	strictEqual edge.source, "http://example.org/foo"
	strictEqual edge.target, "http://example.org/bar"
	strictEqual edge.type, "http://skos.org#narrower"
	strictEqual edge.directed, true
	edgeID = "http://example.org/foo http://skos.org#related http://example.org/bar"
	strictEqual edgeIDs[1], edgeID
	edge = vgraph.edges[edgeID]
	strictEqual edge.source, "http://example.org/foo"
	strictEqual edge.target, "http://example.org/bar"
	strictEqual edge.type, "http://skos.org#related"
	strictEqual edge.directed, false

	relTypes =
		directed: ["http://skos.org#narrower"]
	rdfData =
		"http://example.org/foo":
			"http://www.w3.org/1999/02/22-rdf-syntax-ns#type": [
				{ type: "uri", value: "http://skos.org#Concept" }
			]
			"http://skos.org#narrower": [
				{ type: "uri", value: "http://example.org/bar" }
			]
		"http://example.org/bar":
			"http://www.w3.org/1999/02/22-rdf-syntax-ns#type": [
				{ type: "uri", value: "http://skos.org#Concept" }
			]

	vgraph = new ns.Rationalizer(rdfData, nodeTypes, relTypes)
	edgeIDs = Object.keys(vgraph.edges)
	strictEqual edgeIDs.length, 1
	edgeID = "http://example.org/foo http://skos.org#narrower http://example.org/bar"
	strictEqual edgeIDs[0], edgeID
	edge = vgraph.edges[edgeID]
	strictEqual edge.source, "http://example.org/foo"
	strictEqual edge.target, "http://example.org/bar"
	strictEqual edge.type, "http://skos.org#narrower"
	strictEqual edge.directed, true

test "label assignment", ->
	nodeTypes = ["http://skos.org#Concept"]
	labelTypes = ["http://rdfs.org/label"]

	rdfData =
		"http://example.org/foo":
			"http://random.org/whatever": [
				{ type: "uri", value: "http://random.org/something" }
			]

	vgraph = new ns.Rationalizer(rdfData, nodeTypes, null, labelTypes)
	strictEqual Object.keys(vgraph.nodes).length, 0

	rdfData =
		"http://example.org/foo":
			"http://www.w3.org/1999/02/22-rdf-syntax-ns#type": [
				{ type: "uri", value: "http://skos.org#Concept" }
			]

	vgraph = new ns.Rationalizer(rdfData, nodeTypes, null, labelTypes)
	strictEqual vgraph.nodes["http://example.org/foo"].label, undefined

	rdfData =
		"http://example.org/foo":
			"http://www.w3.org/1999/02/22-rdf-syntax-ns#type": [
				{ type: "uri", value: "http://skos.org#Concept" }
			]
			"http://rdfs.org/label": [
				{ type: "literal", value: "Foo" }
			]

	vgraph = new ns.Rationalizer(rdfData, nodeTypes, null, labelTypes)
	strictEqual vgraph.nodes["http://example.org/foo"].label, "Foo"

test "label precedence", ->
	nodeTypes = ["http://skos.org#Concept"]
	rdfData =
		"http://example.org/foo":
			"http://www.w3.org/1999/02/22-rdf-syntax-ns#type": [
				{ type: "uri", value: "http://skos.org#Concept" }
			]
			"http://rdfs.org/label": [
				{ type: "literal", value: "Alpha" }
			]
			"http://skos.org#label": [
				{ type: "literal", value: "Bravo" }
			]

	labelTypes = ["http://skos.org#label", "http://rdfs.org/label"]

	vgraph = new ns.Rationalizer(rdfData, nodeTypes, null, labelTypes)
	strictEqual vgraph.nodes["http://example.org/foo"].label, "Bravo"

	labelTypes = ["http://rdfs.org/label", "http://skos.org#label"]

	vgraph = new ns.Rationalizer(rdfData, nodeTypes, null, labelTypes)
	strictEqual vgraph.nodes["http://example.org/foo"].label, "Alpha"
