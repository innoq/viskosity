$ = jQuery
ns = this.VISKOSITY


ns.sparqlFetcher = (endpoint) ->
	return (node, callback) ->
		new Request(endpoint, node.id, callback)


class Request

	constructor: (endpoint, subject, callback) ->
		rdfs = ns.namespaces.rdfs
		sparql = """
			SELECT DISTINCT ?prd ?obj ?olabel WHERE {
				<#{subject}> ?prd ?obj .
				OPTIONAL {
					?labelClass <#{rdfs}subPropertyOf> <#{rdfs}label> .
					?obj ?labelClass ?olabel .
				}
			}
		"""
		$.ajax({
			type: "POST"
			url: @endpoint
			data: { query: sparql }
			headers: { Accept: "application/sparql-results+json" }
			dataType: "json"
			success: (data, status, xhr) => callback(@convert(data, subject))
		})

	convert: (sparqlResults, subject) ->
		triples = {}

		register = (subject, predicate, object) ->
			triples[subject] ||= {}
			triples[subject][predicate] ||= []
			triples[subject][predicate].push(object)

		for result in sparqlResults.results.bindings
			predicate = result.prd.value # always a URI
			object = result.obj

			register(subject, predicate, object)

			if result.olabel
				register(object.value, "#{ns.namespaces.rdfs}label",
						type: "literal", value: result.olabel.value)

		return triples
