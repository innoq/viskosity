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

		@rationalizer = settings.rationalizer || ns.Rationalizer
		@presenter = settings.presenter || ns.Presenter
		@visualizer = settings.visualizer
		unless @visualizer
			@visualizer = if settings.interactive \
					then ns.InteractiveVisualizer else ns.Visualizer

		@nodeTypes = settings.nodeTypes
		@labelTypes = settings.labelTypes
		@relTypes = settings.relTypes

		triples2graph = (data) ->
			data = new @rationalizer(data, @nodeTypes, @relTypes, @labelTypes)
			return new @presenter(data)

		if settings.fetcher
			@provider = (node, callback) ->
				settings.fetcher(node, (triples) ->
					callback(triples2graph(triples)))

		graph = new @visualizer(container, triples2graph(data),
				provider: @provider
				nodeGenerator: ((id) =>
					node = new ns.Node(id)
					@presenter.prototype.augmentNode(node))
				width: settings.width
				height: settings.height)
		graph.render()
