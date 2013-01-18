$ = jQuery
ns = this.VISKOSITY


ns.sparqlFetcher = (endpoint) ->
	return (node, store, callback) ->
		new Request(endpoint, node.id, store, callback)


class Request

	constructor: (@endpoint, @subject, @store, @callback) ->
		rdfs = ns.namespaces.rdfs
		sparql = """
			SELECT DISTINCT ?prd ?obj ?olabel WHERE {
				<#{@subject}> ?prd ?obj .
				OPTIONAL {
					?labelClass <#{rdfs}subPropertyOf> <#{rdfs}label> .
					?obj ?labelClass ?olabel .
				}
			}
		"""
		$.ajax({
			type: "POST",
			url: @endpoint,
			data: { query: sparql },
			headers: { Accept: "application/sparql-results+json" },
			dataType: "json",
			success: => @processResponse.apply(this, arguments)
		})

	processResponse: (data, status, xhr) ->
		triples = {}
		for result in data.results.bindings
			predicate = result.prd.value # always a URI
			object = result.obj

			triples[@subject] ||= {}
			triples[@subject][predicate] ||= []
			triples[@subject][predicate].push(object)

			#triples[object] ||= {}
			#triples[object] ||= {}

		@store.addNode("foo")

		@callback()
