ns = this.VISKOSITY

module "visualizer"

test "initialization", ->
	fixtures = $("#qunit-fixture")
	container = $("<div />").appendTo(fixtures)

	ns.Visualizer(container, { width: 640, height: 480 })

	viz = $("svg", container)
	strictEqual viz.length, 1
	strictEqual viz.width(), 640
	strictEqual viz.height(), 480
	strictEqual viz.children().length, 1
	strictEqual $("text", viz).length, 1
