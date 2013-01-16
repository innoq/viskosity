$ = jQuery
ns = this.VISKOSITY


class ns.Visualizer

	charge: -500
	nodeIdentity: (node) -> node.id
	linkDistance: (edge) -> (edge.directed ? 100 : 200) + edge.source.weight # XXX: weight adjustment insufficient? -- TODO: move into presenter
	linkStrength: (edge) -> edge.directed ? 0.5 : 0.25 # TODO: move into presenter
	nodeSelector: "g.node"
	edgeSelector: "path.edge"

	# `container` may be a DOM node, selector or jQuery object
	# `data` is the initial data set, a map of `nodes` and `edges` arrays
	constructor: (container, data={}, settings={}) ->
		container = if container.jquery then container else $(container) # XXX: unnecessary jQuery dependency?
		container.addClass("viz")
		width = settings.width or container.width()
		height = settings.height or container.height()

		data.nodes ||= []
		data.edges ||= []
		# turn edges' node IDs into object references -- FIXME: must be reusable outside the initialization
		nodeIndex = {}
		for node in data.nodes
			nodeIndex[node.id] = node
		for edge in data.edges
			edge.source = nodeIndex[edge.source]
			edge.target = nodeIndex[edge.target]

		@root = d3.select(container[0]).append("svg").
				attr("width", width).attr("height", height)
		@graph = d3.layout.force().size([width, height]).charge(@charge).
				linkDistance(@linkDistance).linkStrength(@linkStrength)

		@graph.nodes(data.nodes).links(data.edges)

		@indicator = @root.append("text").text("loading…").
				attr("x", width / 2).attr("y", height / 2).
				attr("dy", ".35em").attr("text-anchor", "middle")

		@graph.on("tick", => @onTick())

	onTick: (ev) ->
		# collision detection; avoids label overlap -- XXX: ineffective?
		nodes = @graph.nodes()
		q = d3.geom.quadtree(nodes)
		i = 0
		l = nodes.length
		while ++i < l
			q.visit(collide(nodes[i]))

		@root.selectAll(@edgeSelector).attr("d", (edge) -> edge.path())

		@root.selectAll(@nodeSelector).attr("transform",
				(node) -> "translate(#{node.x},#{node.y})")

	render: ->
		@indicator.classed("hidden", true)
		getter = (prop) -> return (obj) -> obj[prop]

		edges = @root.selectAll(@edgeSelector).data(@graph.links())
		edges.exit().remove() # TODO: animate
		edges.enter().append("path").
				attr("class", (edge) -> "edge #{edge.class}").
				style("stroke-width", getter("weight"))

		nodes = @root.selectAll(@nodeSelector).
				data(@graph.nodes(), @nodeIdentity)
		nodes.exit().remove() # TODO: animate
		newNodes = nodes.enter().append("g").attr("class", "node"). # TODO: move class into presenter
				call(@graph.drag) # XXX: unnecessary!?
		newNodes.append("path").attr("d", (node) -> node.shape()).
				style("fill", getter("color"))
		newNodes.append("a").attr("xlink:href", getter("url")). # XXX: `.url` unused/undocumented
				append("text").text(getter("label"))
		nodes.select("text").text(getter("label")); # update existing nodes -- XXX: redundant!?

		# extensiblity hooks
		if @onClick
			viz = this
			newNodes.on("click", (ev) ->
				ctx = eventContext: this, viz: viz
				viz.onClick.apply(ctx, arguments))
		if @onHover
			newNodes.on("mouseover mouseout", @onHover)

		@graph.start()

		@root.selectAll(@nodeSelector).classed("extensible",
				(node) -> node.weight < node.degree) # XXX: obsolete & undocumented

# adapted from http://mbostock.github.com/d3/talk/20110921/collision.html
collide = (node) ->
	s = node.size + 16 # TODO: use `getBBox` for actual dimensions
	nx1 = node.x - s
	nx2 = node.x + s
	ny1 = node.y - s
	ny2 = node.y + s
	return (quad, x1, y1, x2, y2) ->
		if quad.point and quad.point != node
			x = node.x - quad.point.x
			y = node.y - quad.point.y
			l = Math.sqrt(x * x + y * y)
			s = node.size + quad.point.size
			if l < s
				l = (l - s) / l * 0.5
				node.x -= x *= l
				node.y -= y *= l
				quad.point.x += x
				quad.point.y += y
		return x1 > nx2 or x2 < nx1 or y1 > ny2 or y2 < ny1
