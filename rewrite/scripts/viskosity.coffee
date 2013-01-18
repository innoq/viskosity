class this.VISKOSITY

	# `container` may be a DOM node, selector or jQuery object
	# `data` is the initial set of triples (as expected by rationalizer)
	# `settings` includes the following members:
	# * fetcher (optional)
	# * rationalizer (optional)
	# * presenter (optional)
	# * visualizer (optional)
	# * interactive (optional) - irrelevant if visualizer is provided
	# * nodeTypes (as used by rationalizer)
	# * labelTypes (as used by rationalizer)
	# * relTypes (as used by rationalizer)
	# * width (optional)
	# * height (optional)
	constructor:  (container, data, settings) ->
		ns = VISKOSITY # XXX: redundant and hacky

		@fetcher = settings.fetcher
		@rationalizer = settings.rationalizer || ns.Rationalizer
		@presenter = settings.presenter || ns.Presenter
		@visualizer = settings.visualizer
		unless @visualizer
			@visualizer = if settings.interactive \
					then ns.InteractiveVisualizer else ns.Visualizer

		@nodeTypes = settings.nodeTypes
		@labelTypes = settings.labelTypes
		@relTypes = settings.relTypes

		data = new @rationalizer(data, @nodeTypes, @relTypes, @labelTypes)
		data = new @presenter(data)

		graph = new @visualizer(container, data,
				fetcher: @fetcher
				width: settings.width
				height: settings.height)
		graph.render()
