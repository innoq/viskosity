$ = jQuery
ns = this.VISKOSITY

rdf = ns.namespaces.rdf
skos = "http://www.w3.org/2004/02/skos/core#"
sparqlResults =
	head:
		vars: ["prd", "obj", "olabel"]
	results:
		bindings: [
			prd: { type: "uri", value: "#{rdf}type" }
			obj: { type: "uri", value: "#{skos}Concept" }
			olabel: { type: "literal", "xml:lang": "en", value: "Foo" }
		]


class MockStore

	constructor: ->
		@nodes=[]
		@edges=[]

	addNode: (node) ->
		@nodes.push(node)


module "SPARQL fetcher"
	setup: ->
		@reqCount = 0
		@data = {}

		env = this
		$.mockjax (request) ->
			env.reqCount++
			env.data.reqMethod = request.type
			env.data.reqHeaders = request.headers
			env.data.reqBody = request.data

			return {
				responseTime: 10
				responseText: JSON.stringify(sparqlResults)
			}

	teardown: -> $.mockjaxClear()

asyncTest "query requests", ->
	fetcher = ns.sparqlFetcher("/sparql")
	store = new MockStore

	fetcher({ id: "http://example.org/foo" }, store, =>
		strictEqual @reqCount, 1
		strictEqual @data.reqMethod, "POST"
		strictEqual @data.reqHeaders.Accept, "application/sparql-results+json"
		strictEqual @data.reqBody.query, """
			SELECT DISTINCT ?prd ?obj ?olabel WHERE {
				<http://example.org/foo> ?prd ?obj .
				OPTIONAL {
					?labelClass <http://www.w3.org/2000/01/rdf-schema#subPropertyOf> <http://www.w3.org/2000/01/rdf-schema#label> .
					?obj ?labelClass ?olabel .
				}
			}
		"""
		start())

asyncTest "store updates", ->
	fetcher = ns.sparqlFetcher("/sparql")
	store = new MockStore

	fetcher({ id: "http://example.org/foo" }, store, ->
		strictEqual store.nodes.length, 1
		node = store.nodes[0]
		strictEqual node.id, "http://example.org/foo"
		strictEqual node.type, "#{skos}Concept"
		strictEqual node.label, "Foo"
		start())
