ns = this.VISKOSITY
expand = ns.RDFStore.expand

# condenses an RDF graph into "visual" graph data, with certain RDF facts being
# used as attributes for nodes and edges
class ns.Rationalizer # XXX: should just be a function

	# `rdfData` is a map of subject/facts pairs, where facts is a map of
	# predicate/objects pairs:
	#     subject:
	#         predicate: [object, ...]
	# `nodeTypes` and `labelRels` (optional) are ordered lists of URIs
	# representing valid node and label types, respectively
	constructor: (rdfData, @nodeTypes, @labelRels=[]) ->
		@nodes = {}
		@edges = {}

		for sbj, facts of rdfData
			type = @nodeType(facts)
			if type
				label = @label(facts)
				@nodes[sbj] = new ns.Node(sbj, type, label)

		return { @nodes, @edges }

	label: (facts) ->
		for rel in @labelRels
			label = facts[rel]
			return label[0].value if label?[0]

	nodeType: (facts) ->
		prd = expand("rdf:type")
		types = facts[prd]
		return null unless types

		for type in types
			type = type.value
			for nodeType in @nodeTypes # NB: first match wins
				return type if type == nodeType
		return null
