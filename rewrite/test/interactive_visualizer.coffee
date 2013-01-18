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

test "basic initialization", ->
	container = $("<div />").appendTo(@fixtures)
	graph = new ns.InteractiveVisualizer(container, null,
			fetcher: "dummy",
			width: 640,
			height: 480)
	graph.render()
	viz = $("svg", container)

	strictEqual graph.fetcher, "dummy"
	strictEqual viz.length, 1
	strictEqual viz.width(), 640
	strictEqual viz.height(), 480

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
			fetcher: (node, store, callback) -> callback()
			width: 640,
			height: 480)
	graph.render()
	viz = $("svg", container)

	strictEqual $("g.node", viz).length, 3
	strictEqual $("path.edge", viz).length, 2

	node = $("g.node:first", viz)
	fireEvent(node[0], "click")
	strictEqual node.attr("class"), "node active"
