ns = this.VISKOSITY

module "models"

test "default namespaces", ->
	strictEqual ns.namespaces.rdf, "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	strictEqual ns.namespaces.rdfs, "http://www.w3.org/2000/01/rdf-schema#"

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

	node = new ns.Node("foo", "skos:Concept", "Foo")
	strictEqual node.id, "foo"
	strictEqual node.type, "skos:Concept"
	strictEqual node.label, "Foo"
	strictEqual Object.keys(node).length, 3

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
