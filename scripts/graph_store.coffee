ns = this.VISKOSITY


class ns.GraphStore

	constructor: (nodes=[], edges=[], nodeGenerator) ->
		@nodes = []
		@edges = []
		@cache = nodes: {}, edges: {}

		@nodeGenerator = nodeGenerator || (id) -> new ns.Node(id) # TODO: document

		@addNode(node) for node in nodes
		@addEdge(edge) for edge in edges

	getNode: (id) ->
		return @cache.nodes[id]

	addNode: (node) ->
		isNew = @registerNode(node) and @nodes.push(node)
		return isNew && node

	replaceNode: (node) ->
		node = @getNode(node.id)
		throw "invalid node ID" unless node

		index = @nodes.indexOf(node)
		@nodes.splice(index, 1)

		@addNode(node)

		# TODO: update associated edges

	registerNode: (node, force) ->
		throw "invalid node ID" unless node.id
		return false if @cache.nodes[node.id] and not force

		@cache.nodes[node.id] = node
		return true

	getEdge: (id) ->
		return @cache.edges[id]

	addEdge: (edge) ->
		isNew = @registerEdge(edge)
		return false unless isNew

		@edges.push(edge)

	registerEdge: (edge) ->
		throw "invalid edge source" unless edge.source
		throw "invalid edge target" unless edge.target

		id = "#{edge.source} #{edge.type} #{edge.target}" # XXX: inefficient, memory-wise
		return false if @cache.edges[id]

		for endpoint in ["source", "target"]
			nodeID = edge[endpoint]
			node = @getNode(nodeID)

			# make sure endpoint exists
			unless node
				node = @nodeGenerator(nodeID)
				@addNode(node)

			# replace with object reference
			edge[endpoint] = node

		@cache.edges[id] = edge
		return true
