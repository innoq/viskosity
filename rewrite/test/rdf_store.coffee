ns = this.VISKOSITY

module "RDF store"

test "adding and retrieving triples", ->
	store = new ns.RDFStore

	triple =
		sbj: { type: "uri", value: "http://example.org/foo" }
		prd: { type: "uri", value: "http://rdf.org/type" }
		obj: { type: "uri", value: "http://skos.org/Concept" }
	store.add(triple)

	strictEqual store.query("http://example.org/foo")["http://rdf.org/type"][0].
			value, "http://skos.org/Concept"
	strictEqual store.query("http://example.org/foo", "http://rdf.org/type")[0].
			value, "http://skos.org/Concept"
	strictEqual store.query("http://example.org/foo",
			"http://skos.org/related"), null
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
	strictEqual results[0].value, "http://skos.org/Concept"
	strictEqual results[1].value, "http://foaf.org/Agent"

	triple =
		sbj: { type: "uri", value: "http://example.org/foo" }
		prd: { type: "uri", value: "http://skos.org/related" }
		obj: { type: "uri", value: "http://example.org/bar" }
	store.add(triple)

	strictEqual store.query("http://example.org/foo",
			"http://skos.org/related")[0].value, "http://example.org/bar"

test "initialization", ->
	store = new ns.RDFStore([{
		sbj: { type: "uri", value: "http://example.org/foo" }
		prd: { type: "uri", value: "http://rdf.org/type" }
		obj: { type: "uri", value: "http://skos.org/Concept" }
	}, {
		sbj: { type: "uri", value: "http://example.org/foo" }
		prd: { type: "uri", value: "http://rdf.org/type" }
		obj: { type: "uri", value: "http://foaf.org/Agent" }
	}, {
		sbj: { type: "uri", value: "http://example.org/foo" }
		prd: { type: "uri", value: "http://skos.org/related" }
		obj: { type: "uri", value: "http://example.org/bar" }
	}])

	results = store.query("http://example.org/foo", "http://rdf.org/type")
	strictEqual results.length, 2
	strictEqual results[0].value, "http://skos.org/Concept"
	strictEqual results[1].value, "http://foaf.org/Agent"
	strictEqual store.query("http://example.org/bar"), null
	strictEqual store.query("http://example.org/foo",
			"http://skos.org/related")[0].value, "http://example.org/bar"
