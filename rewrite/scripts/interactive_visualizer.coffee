ns = this.VISKOSITY


class ns.InteractiveVisualizer extends ns.Visualizer # XXX: bad name?

	# `settings.fetcher` is a function which is used to retrieve additional
	# data - it is passed the respective node along with a callback, which is to
	# be invoked passing triples as expected by rationalizer
	constructor: ->
		super
		settings = arguments[arguments.length - 1]
		@fetcher = settings.fetcher
		@root.on("mousedown", (ev) => @toggleHighlight(ev))
		@root = @root.
				call(d3.behavior.zoom().scaleExtent([0.5, 8]). # TODO: configurable values
						on("zoom", => @onZoom())).
				append("g"); # required for zoom context

	onClick: (item) ->
		@viz.indicator.classed("hidden", false)
		@viz.toggleHighlight(@eventContext)
		data = nodes: @viz.graph.nodes(), edges: @viz.graph.links()
		@viz.fetcher(item, => @viz.render())

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
