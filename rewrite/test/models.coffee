ns = this.VISKOSITY

module "models"

test "default namespaces", ->
	strictEqual ns.namespaces.rdf, "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	strictEqual ns.namespaces.rdfs, "http://www.w3.org/2000/01/rdf-schema#"

test "bare nodes", ->
	throws (-> node = new ns.Node), TypeError, "ID required"
	throws (-> node = new ns.Node(123)), "ID must be string"

	node = new ns.Node("foo")
	strictEqual node.id, "foo"
	strictEqual node.type, undefined
	strictEqual node.label, undefined
	strictEqual Object.keys(node).length, 3

	node = new ns.Node("foo", "skos:Concept")
	strictEqual node.id, "foo"
	strictEqual node.type, "skos:Concept"
	strictEqual node.label, undefined
	strictEqual Object.keys(node).length, 3

	node = new ns.Node("foo", "skos:Concept", "Foo")
	strictEqual node.id, "foo"
	strictEqual node.type, "skos:Concept"
	strictEqual node.label, "Foo"
	strictEqual Object.keys(node).length, 3

test "render nodes", ->
	throws (-> node = new ns.RenderNode), TypeError, "ID required"
	throws (-> node = new ns.RenderNode(123)), "ID must be string"

	node = new ns.RenderNode("foo")
	strictEqual node.id, "foo"
	strictEqual Object.keys(node).length, 6

	node = new ns.RenderNode("foo", null, null, "circle", ((node) -> 3), 1)
	strictEqual node.id, "foo"
	strictEqual node.shape, "circle"
	strictEqual node.size(), 3
	strictEqual node.color, 1
	strictEqual Object.keys(node).length, 6

test "bare edges", ->
	throws (-> edge = new ns.Edge), "source and target IDs required"
	throws (-> edge = new ns.Edge("foo")), "source and target IDs required"
	throws (-> edge = new ns.Edge(123, "bar")), "IDs must be strings"
	throws (-> edge = new ns.Edge("foo", 456)), "IDs must be strings"

	edge = new ns.Edge("foo", "bar")
	strictEqual edge.source, "foo"
	strictEqual edge.target, "bar"
	strictEqual edge.type, undefined
	strictEqual edge.directed, false
	strictEqual Object.keys(edge).length, 4

	edge = new ns.Edge("foo", "bar", "skos:related")
	strictEqual edge.source, "foo"
	strictEqual edge.target, "bar"
	strictEqual edge.type, "skos:related"
	strictEqual edge.directed, false
	strictEqual Object.keys(edge).length, 4

	edge = new ns.Edge("foo", "bar", null, true)
	strictEqual edge.source, "foo"
	strictEqual edge.target, "bar"
	strictEqual edge.type, null
	strictEqual edge.directed, true
	strictEqual Object.keys(edge).length, 4

test "render edges", ->
	throws (-> edge = new ns.RenderEdge), "source and target IDs required"
	throws (-> edge = new ns.RenderEdge("foo")), "source and target IDs required"
	throws (-> edge = new ns.RenderEdge(123, "bar")), "IDs must be strings"
	throws (-> edge = new ns.RenderEdge("foo", 456)), "IDs must be strings"

	edge = new ns.RenderEdge("foo", "bar")
	strictEqual edge.source, "foo"
	strictEqual edge.target, "bar"
	strictEqual Object.keys(edge).length, 7

	edge = new ns.RenderEdge("foo", "bar", null, null, "alpha bravo", "...", 12)
	strictEqual edge.source, "foo"
	strictEqual edge.target, "bar"
	strictEqual edge.class, "alpha bravo"
	strictEqual edge.path, "..."
	strictEqual edge.strength, 12
	strictEqual Object.keys(edge).length, 7
