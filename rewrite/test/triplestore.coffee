ns = this.VISKOSITY

module "triplestore", {
	setup: () ->
		@namespaces = ns.namespaces
		ns.namespaces = {}
	teardown: () ->
		ns.namespaces = @namespaces
}

test "adding and retrieving triples", ->
	store = new ns.Triplestore

	triple =
		sbj: { type: "uri", value: "http://example.org/foo" }
		prd: { type: "uri", value: "http://rdf.org/type" }
		obj: { type: "uri", value: "http://skos.org#Concept" }
	store.add(triple)

	strictEqual store.query("http://example.org/foo")["http://rdf.org/type"][0].
			value, "http://skos.org#Concept"
	strictEqual store.query("http://example.org/foo", "http://rdf.org/type")[0].
			value, "http://skos.org#Concept"
	strictEqual store.query("http://example.org/foo",
			"http://skos.org#related"), null
	strictEqual store.query("http://example.org/bar"), null
	strictEqual store.query("http://example.org/bar", "http://rdf.org/type"),
			null

	triple =
		sbj: { type: "uri", value: "http://example.org/foo" }
		prd: { type: "uri", value: "http://rdf.org/type" }
		obj: { type: "uri", value: "http://foaf.org/Agent" }
	store.add(triple)

	results = store.query("http://example.org/foo", "http://rdf.org/type")
	strictEqual results.length, 2
	strictEqual results[0].value, "http://skos.org#Concept"
	strictEqual results[1].value, "http://foaf.org/Agent"

	triple =
		sbj: { type: "uri", value: "http://example.org/foo" }
		prd: { type: "uri", value: "http://skos.org#related" }
		obj: { type: "uri", value: "http://example.org/bar" }
	store.add(triple)

	strictEqual store.query("http://example.org/foo",
			"http://skos.org#related")[0].value, "http://example.org/bar"

test "initialization", ->
	store = new ns.Triplestore([{
		sbj: { type: "uri", value: "http://example.org/foo" }
		prd: { type: "uri", value: "http://rdf.org/type" }
		obj: { type: "uri", value: "http://skos.org#Concept" }
	}, {
		sbj: { type: "uri", value: "http://example.org/foo" }
		prd: { type: "uri", value: "http://rdf.org/type" }
		obj: { type: "uri", value: "http://foaf.org/Agent" }
	}, {
		sbj: { type: "uri", value: "http://example.org/foo" }
		prd: { type: "uri", value: "http://skos.org#related" }
		obj: { type: "uri", value: "http://example.org/bar" }
	}])

	results = store.query("http://example.org/foo", "http://rdf.org/type")
	strictEqual results.length, 2
	strictEqual results[0].value, "http://skos.org#Concept"
	strictEqual results[1].value, "http://foaf.org/Agent"
	strictEqual store.query("http://example.org/bar"), null
	strictEqual store.query("http://example.org/foo",
			"http://skos.org#related")[0].value, "http://example.org/bar"

test "abbreviating and unabbreviating URIs (prefixed names)", ->
	ns.namespaces["rdf"] = "http://rdf.org/"
	ns.namespaces["skos"] = "http://skos.org#"

	strictEqual ns.Triplestore.shorten("http://rdf.org/type"), "rdf:type"
	strictEqual ns.Triplestore.shorten("http://skos.org#Concept"), "skos:Concept"
	strictEqual ns.Triplestore.shorten("http://example.org/foo"),
			"http://example.org/foo"

	strictEqual ns.Triplestore.expand("rdf:type"), "http://rdf.org/type"
	strictEqual ns.Triplestore.expand("skos:Concept"), "http://skos.org#Concept"
	strictEqual ns.Triplestore.expand("foo"), null
	strictEqual ns.Triplestore.expand("foo:bar"), null

test "prefixed names", ->
	ns.namespaces["rdf"] = "http://rdf.org/"
	ns.namespaces["skos"] = "http://skos.org#"
	ns.namespaces["ex"] = "http://example.org/"
	store = new ns.Triplestore

	triple =
		sbj: { type: "uri", value: "http://example.org/foo" }
		prd: { type: "uri", value: "http://rdf.org/type" }
		obj: { type: "uri", value: "http://skos.org#Concept" }
	store.add(triple)

	#strictEqual store.query("ex:foo", "rdf:type")[0], "http://skos.org#Concept"
	expect 0 # XXX: DEBUG'd
