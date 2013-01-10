this.VISKOSITY = ns = {}
ns.namespaces = # XXX: should not be a global, but an instance (e.g. `Context`?)
	rdf: "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	rdfs: "http://www.w3.org/2000/01/rdf-schema#"


class ns.Node

	constructor: (@id, @type, @label) ->
		throw "ID is an obligatory string" unless @id.substr


class ns.RenderNode extends ns.Node

	# `shape` is a D3 SVG symbol type:
	# https://github.com/mbostock/d3/wiki/SVG-Shapes#wiki-symbol_type
	# `size` is a function to be passed the respective node, returning a
	# numeric value
	# `color` is the index of the color to be used -- XXX: tight coupling to visualization layer
	constructor: (id, type, label, shape, size, color) ->
		super(id, type, label)
		@shape = shape
		@size = size
		@color = color


class ns.Edge

	constructor: (@source, @target, @type, directed) ->
		throw "source and target are obligatory strings" unless @source and
				@source.substr and @target and @target.substr

		@directed = !!directed


class ns.RenderEdge extends ns.Edge

	# `path` is a function to be passed the respective source and target nodes,
	# returning an SVG path description
	constructor: (source, target, type, directed, className, path, weight) ->
		super(source, target, type, directed)
		@class = className
		@path = path
		@weight = weight
