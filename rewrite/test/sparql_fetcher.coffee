$ = jQuery
ns = this.VISKOSITY

rdf = ns.namespaces.rdf
rdfs = ns.namespaces.rdfs
skos = "http://www.w3.org/2004/02/skos/core#"
sparqlResults =
	head:
		vars: ["prd", "obj", "olabel"]
	results:
		bindings: [{
			prd: { type: "uri", value: "#{rdf}type" }
			obj: { type: "uri", value: "#{skos}Concept" }
		}, {
			prd: { type: "uri", value: "#{skos}prefLabel" }
			obj: { type: "literal", value: "Foo" }
		}, {
			prd: { type: "uri", value: "#{skos}narrower" }
			obj: { type: "uri", value: "http://example.org/bar" }
			olabel: { type: "literal", "xml:lang": "en", value: "Bar" }
		}]


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

	fetcher({ id: "http://example.org/foo" }, =>
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

	fetcher({ id: "http://example.org/foo" }, (triples) ->
		strictEqual Object.keys(triples).length, 2
		strictEqual triples["http://example.org/foo"]["#{rdf}type"].length, 1
		strictEqual triples["http://example.org/foo"]["#{skos}prefLabel"].length, 1
		strictEqual triples["http://example.org/foo"]["#{skos}prefLabel"][0].type, "literal"
		strictEqual triples["http://example.org/foo"]["#{skos}prefLabel"][0].value, "Foo"
		strictEqual triples["http://example.org/foo"]["#{skos}narrower"].length, 1
		strictEqual triples["http://example.org/foo"]["#{skos}narrower"][0].type, "uri"
		strictEqual triples["http://example.org/foo"]["#{skos}narrower"][0].value, "http://example.org/bar"
		strictEqual triples["http://example.org/bar"]["#{rdfs}label"].length, 1
		strictEqual triples["http://example.org/bar"]["#{rdfs}label"][0].type, "literal"
		strictEqual triples["http://example.org/bar"]["#{rdfs}label"][0].value, "Bar"
		start())
