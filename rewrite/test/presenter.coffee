ns = this.VISKOSITY

module "presenter"

test "node augmentation", ->
	dummyNode = (degree) -> { degree } # pseudo node as augmented by D3

	node = new ns.Node("foo")

	augNode = ns.Presenter.prototype.augmentNode(node)
	strictEqual augNode instanceof ns.RenderNode, true
	strictEqual augNode.shape, "circle"
	strictEqual augNode.size(dummyNode(3)), 130
	strictEqual augNode.color, 1

	node = new ns.Node("foo", "collection") # XXX: invalid type

	augNode = ns.Presenter.prototype.augmentNode(node)
	strictEqual augNode instanceof ns.RenderNode, true
	strictEqual augNode.shape, "diamond"
	strictEqual augNode.size(dummyNode(1)), 110
	strictEqual augNode.color, 2

test "edge augmentation", ->
	# pseudo nodes - normally these are retrieved from the store when the
	# respective attributes (namely `path`) are evaluated
	foo = { x: 0, y: 0 }
	bar = { x: 1, y: 1 }

	edge = new ns.Edge("foo", "bar")

	augEdge = ns.Presenter.prototype.augmentEdge(edge)
	strictEqual augEdge instanceof ns.RenderEdge, true
	strictEqual augEdge.path(foo, bar), "M0,0L1,1"
	strictEqual augEdge.class, "undirected"
	strictEqual augEdge.strength, Math.sqrt(3)

	edge = new ns.Edge("foo", "bar", "dummy", true)

	augEdge = ns.Presenter.prototype.augmentEdge(edge)
	strictEqual augEdge.path(foo, bar),
			"M0,0A1.4142135623730951,1.4142135623730951 0 0,1 1,1"
	strictEqual augEdge.class, "directed"

test "graph augmentation", ->
	vgraph =
		nodes: [new ns.Node("foo"), new ns.Node("bar"), new ns.Node("baz")]
		edges: [new ns.Edge("foo", "bar"), new ns.Edge("bar", "baz")]

	styledGraph = new ns.Presenter(vgraph)

	strictEqual styledGraph.nodes.length, 3
	strictEqual styledGraph.nodes[0] instanceof ns.RenderNode, true
	strictEqual styledGraph.edges.length, 2
	strictEqual styledGraph.edges[0] instanceof ns.RenderEdge, true
