ns = this.VISKOSITY

module "visualizer",
	setup: -> @fixtures = $("#qunit-fixture")

capitalize = (str) -> str.charAt(0).toUpperCase() + str.slice(1)

test "basic initialization", ->
	container = $("<div />").appendTo(@fixtures)

	new ns.Visualizer(container, null, { width: 640, height: 480 })

	viz = $("svg", container)
	strictEqual viz.length, 1
	strictEqual viz.width(), 640
	strictEqual viz.height(), 480
	strictEqual viz.children().length, 1
	strictEqual $("text", viz).length, 1

test "graph rendering", ->
	container = $("<div />").appendTo(@fixtures)

	shape = () -> "M 1 1"
	size = () -> 10
	color = "#F00"
	node_ids = ["foo", "bar"]
	data =
		nodes: for id in node_ids
			new ns.RenderNode(id, null, capitalize(id), shape, size, color)

	new ns.Visualizer(container, data, { width: 640, height: 480 })
	viz = $("svg", container)
	strictEqual $("g.node", viz).length, 2
	strictEqual $("g.node text:first", viz).text(), "Foo"
