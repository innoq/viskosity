ns = this.VISKOSITY

module "models"

test "nodes", ->
	throws (-> node = new ns.Node), TypeError, "ID required"

	throws (-> node = new ns.Node(123)), "ID must be string"

	node = new ns.Node("foo")
	strictEqual node.id, "foo"
	strictEqual Object.keys(node).length, 1

	node = new ns.Node("foo", "skos:Concept")
	strictEqual node.id, "foo"
	strictEqual node.type, "skos:Concept"
	strictEqual Object.keys(node).length, 2

test "edges", ->
	throws (-> edge = new ns.Edge), "source and target IDs required"
	throws (-> edge = new ns.Edge("foo")), "source and target IDs required"
	throws (-> edge = new ns.Edge(123, "bar")), "IDs must be strings"
	throws (-> edge = new ns.Edge("foo", 456)), "IDs must be strings"

	edge = new ns.Edge("foo", "bar")
	strictEqual edge.directed, false
	strictEqual Object.keys(edge).length, 3

	edge = new ns.Edge("foo", "bar", "skos:related")
	strictEqual edge.type, "skos:related"
	strictEqual edge.directed, false
	strictEqual Object.keys(edge).length, 4
