ns = this.VISKOSITY


class ns.InteractiveVisualizer extends ns.Visualizer # XXX: bad name?

	# `settings.provider` is a function which is used to retrieve additional
	# data - it is passed the respective node along with the full data set and
	# a callback, which is invoked passing an object with arrays for `nodes`
	# and `edges`
	constructor: () ->
		super
		settings = arguments[arguments.length - 1]
		@provider = settings.provider
		@root.on("mousedown", (ev) => @toggleHighlight(ev))
		@root = @root.
				call(d3.behavior.zoom().scaleExtent([0.5, 8]).
						on("zoom", => @onZoom())).
				append("g"); # required for zoom context
	
	onClick: (item) ->
		@viz.indicator.classed("hidden", false)
		@viz.toggleHighlight(@eventContext)
		data = nodes: @viz.graph.nodes(), edges: @viz.graph.links()
		@viz.provider(item, @viz.store, () => @viz.render())

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
