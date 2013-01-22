ns = this.VISKOSITY

module "interactive visualizer",
	setup: -> @fixtures = $("#qunit-fixture")

# adapted from KooiInc (http://stackoverflow.com/a/2706236)
fireEvent = (node, evName) ->
	if node.fireEvent
		node.fireEvent("on#{evName}")
	else
		ev = document.createEvent("Events")
		ev.initEvent(evName, true, true)
		node.dispatchEvent(ev)

TRIPLES = [{
	"http://example.org/foo":
		"http://www.w3.org/1999/02/22-rdf-syntax-ns#type": [
			type: "uri", value: "http://skos.org#Concept"
		]
		"http://rdfs.org/label": [
			type: "literal", value: "Foo"
		]
}, {
	"http://example.org/foo":
		"http://skos.org#related": [
			type: "uri", value: "http://example.org/bar"
		]
	"http://example.org/bar":
		"http://www.w3.org/1999/02/22-rdf-syntax-ns#type": [
			type: "uri", value: "http://skos.org#Concept"
		]
		"http://rdfs.org/label": [
			type: "literal", value: "Bar"
		]
}]

test "basic initialization", ->
	container = $("<div />").appendTo(@fixtures)
	graph = new ns.InteractiveVisualizer(container, null,
			fetcher: "dummy"
			width: 640
			height: 480)
	graph.render()
	viz = $("svg", container)

	strictEqual graph.fetcher, "dummy"
	strictEqual viz.length, 1
	strictEqual viz.width(), 640
	strictEqual viz.height(), 480

test "dynamic/interactive extension", ->
	container = $("<div />").appendTo(@fixtures)

	nodeTypes = ["http://skos.org#Concept"]
	labelTypes = ["http://rdfs.org/label"]
	relTypes = { undirected: ["http://skos.org#related"] }
	triples2graph = (data) ->
		data = new ns.Rationalizer(data, nodeTypes, relTypes, labelTypes)
		return new ns.Presenter(data)

	graph = new ns.InteractiveVisualizer(container, triples2graph(TRIPLES[0]),
			fetcher: (node, callback) -> callback(TRIPLES[1])
			converter: triples2graph
			width: 640
			height: 480)
	graph.render()

	viz = $("svg", container)
	strictEqual $("g.node", viz).length, 1

	node = $("g.node:first", viz)
	fireEvent(node[0], "click")

	strictEqual $("g.node", viz).length, 2

test "highlight active node", ->
	nodeShape = -> "M 1,1 L1,1 1,1 1,1Z"
	edgePath = -> "M 1,1 L 1,1"
	size = -> 10
	color = "#F00"
	node_ids = ["foo", "bar", "baz"]
	edges = [["foo", "bar"], ["foo", "baz"]]
	data =
		nodes: for id in node_ids
			new ns.RenderNode(id, null, id, nodeShape, size, color)
		edges: for [source, target] in edges
			new ns.RenderEdge(source, target, null, null, "link", edgePath, 3)

	container = $("<div />").appendTo(@fixtures)
	graph = new ns.InteractiveVisualizer(container, data,
			fetcher: (node, callback) -> callback({})
			converter: (triples) -> nodes: [], edges: []
			width: 640
			height: 480)
	graph.render()
	viz = $("svg", container)

	strictEqual $("g.node", viz).length, 3
	strictEqual $("path.edge", viz).length, 2

	node = $("g.node:first", viz)
	fireEvent(node[0], "click")
	strictEqual node.attr("class"), "node active"
