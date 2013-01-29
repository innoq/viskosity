ns = this.VISKOSITY

module "visualizer",
	setup: -> @fixtures = $("#qunit-fixture")

capitalize = (str) -> str.charAt(0).toUpperCase() + str.slice(1)

test "basic initialization", ->
	container = $("<div />").appendTo(@fixtures)
	graph = new ns.Visualizer(container, null, width: 640, height: 480)
	graph.render()
	viz = $("svg", container)

	strictEqual viz.length, 1
	strictEqual viz.width(), 640
	strictEqual viz.height(), 480
	strictEqual viz.children().length, 1
	strictEqual $("text", viz).length, 1

test "graph rendering", ->
	nodeShape = -> "M 1,1 L1,1 1,1 1,1Z"
	edgePath = -> "M 1,1 L 1,1"
	size = -> 10
	color = "#F00"

	node_ids = ["foo", "bar", "baz"]
	edges = [["foo", "bar"], ["foo", "baz"]]
	data =
		nodes: for id in node_ids
			new ns.RenderNode(id, null, capitalize(id), nodeShape, size, color)
		edges: for [source, target] in edges
			new ns.RenderEdge(source, target, null, null, "link", edgePath, 3)

	container = $("<div />").appendTo(@fixtures)
	graph = new ns.Visualizer(container, data, width: 640, height: 480)
	graph.render()
	viz = $("svg", container)

	strictEqual $("g.node", viz).length, 3
	strictEqual $("g.node text:first", viz).text(), "Foo"
	strictEqual $("path.edge", viz).length, 2

test "placeholder nodes", -> # XXX: this tests the graph store more than the visualization
	nodeShape = -> "M 1,1 L1,1 1,1 1,1Z"
	edgePath = -> "M 1,1 L 1,1"
	size = -> 10
	color = "#F00"

	node_ids = ["foo"]
	edges = [["foo", "bar"]]
	data =
		nodes: for id in node_ids
			new ns.RenderNode(id, null, capitalize(id), nodeShape, size, color)
		edges: for [source, target] in edges
			new ns.RenderEdge(source, target, null, null, "link", edgePath, 3)
	container = $("<div />").appendTo(@fixtures)

	graph = new ns.Visualizer(container, data, width: 640, height: 480)
	strictEqual graph.store.nodes.length, 2
	notStrictEqual graph.store.nodes[0].shape, undefined
	strictEqual graph.store.nodes[1].shape, undefined
	throws (-> graph.render()), /shape/ # unfortunate, but seemingly inevitable

	node_ids = ["foo"]
	edges = [["foo", "bar"]]
	data =
		nodes: for id in node_ids
			new ns.RenderNode(id, null, capitalize(id), nodeShape, size, color)
		edges: for [source, target] in edges
			new ns.RenderEdge(source, target, null, null, "link", edgePath, 3)
	container = $("<div />").appendTo(@fixtures)

	graph = new ns.Visualizer(container, data,
			nodeGenerator: ((id) -> new ns.RenderNode(id, null, null, nodeShape,
					size, color))
			width: 640
			height: 480)
	strictEqual graph.store.nodes.length, 2
	notStrictEqual graph.store.nodes[0].shape, undefined
	notStrictEqual graph.store.nodes[1].shape, undefined
	graph.render()
	viz = $("svg", container)
	strictEqual $("g.node", viz).length, 2
	strictEqual $("g.node text:first", viz).text(), "Foo"
	strictEqual $("g.node text:last", viz).text(), ""
	strictEqual $("path.edge", viz).length, 1
