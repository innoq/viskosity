this.VISKOSITY = ns = {}


class ns.Node

	constructor: (@id, type) ->
		@type = type if type

		throw "ID is an obligatory string" unless @id.substr


class ns.Edge

	constructor: (@source, @target, type, directed) ->
		@type = type if type
		@directed = !!directed # XXX: should be inferred from type!?

		throw "source and target are obligatory strings" unless @source and
				@source.substr and @target and @target.substr
