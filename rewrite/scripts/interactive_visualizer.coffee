ns = this.VISKOSITY


class ns.InteractiveVisualizer extends ns.Visualizer # XXX: bad name?

	# `settings.fetcher` is a function which is used to retrieve additional
	# data - it is passed the respective node along with a callback, which is to
	# be invoked passing triples as expected by rationalizer
	# `settings.converter` is a function which is used to turn these triples
	# into a graph of nodes and edges
	constructor: ->
		super
		settings = arguments[arguments.length - 1]
		@fetcher = settings.fetcher
		@converter = settings.converter # XXX: combine with fetcher into "provider"?
		@root.on("mousedown", (ev) => @toggleHighlight(ev))
		@root = @root.
				call(d3.behavior.zoom().scaleExtent([0.5, 8]). # TODO: configurable values
						on("zoom", => @onZoom())).
				append("g"); # required for zoom context

	onClick: (item) ->
		@viz.indicator.classed("hidden", false)
		@viz.toggleHighlight(@eventContext)
		@viz.fetcher(item, (triples) => @viz.processTriples(triples))

	onHover: (item) -> # XXX: unused / buggy (`this` confusion)?
		hovering = d3.event.type == "mouseover"
		d3.select(this).classed("hover", hovering)

	onZoom: ->
		ev = d3.event
		@root.attr("transform", "translate(#{ev.translate}) scale(#{ev.scale})")

	# doubles as event handler and function operating on a given element
	toggleHighlight: (el) -> # TODO: rename?
		@root.selectAll(".active").classed("active", false)
		if el
			d3.select(el).classed("active", true)

	processTriples: (triples) ->
		data = @converter(triples)

		@store.addNode(node) for node in data.nodes
		@store.addEdge(edge) for edge in data.edges

		@render()
