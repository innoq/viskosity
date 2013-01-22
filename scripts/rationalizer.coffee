ns = this.VISKOSITY


# condenses an RDF graph of triples into "visual" graph data, with certain
# facts being used as attributes for nodes and edges
class ns.Rationalizer

	# `rdfData` is a map of subject/facts pairs, where facts is a map of
	# predicate/objects pairs:
	#     subject:
	#         predicate: [object, ...]
	# `nodeTypes` and `labelRels` (optional) are ordered lists of URIs
	# representing valid node and label types, respectively
	# `nodeRels` is an optional map with members `directed` and `undirected`,
	# each a list of URIs representing the respective relation type
	# returns a map of `Node`s and `Edge`s
	constructor: (rdfData, @nodeTypes, @nodeRels={}, @labelRels=[]) -> # TODO: move configuration arguments into prototype (cf. Presenter)
		@nodes = {}
		@edges = {}

		for sbj, facts of rdfData
			if nodeType = @nodeType(facts)
				label = @label(facts)
				@nodes[sbj] = new ns.Node(sbj, nodeType, label)

			rels = @determineRelations(sbj, facts)
			for [target, type, directed] in rels
				id = "#{sbj} #{type} #{target}" # XXX: inefficient, memory-wise
				@edges[id] = new ns.Edge(sbj, target, type, directed)

		return { @nodes, @edges }

	label: (facts) ->
		for rel in @labelRels
			label = facts[rel]
			return label[0].value if label?[0]

	determineRelations: (sbj, facts) ->
		rels = []

		for dtype, relTypes of @nodeRels
			for relType in relTypes
				targets = facts[relType] or []
				for target in targets
					rels.push [target.value, relType, dtype == "directed"]

		return rels

	nodeType: (facts) ->
		prd = ns.Triplestore.expand("rdf:type")
		types = facts[prd]
		return null unless types

		for type in types
			type = type.value
			for nodeType in @nodeTypes # NB: first match wins
				return type if type == nodeType
		return null
