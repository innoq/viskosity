this.VISKOSITY = ns = {}
ns.namespaces = # XXX: should not be a global, but an instance (e.g. `Context`?)
	rdf: "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	rdfs: "http://www.w3.org/2000/01/rdf-schema#"


class ns.Node

	constructor: (@id, @type, @label) ->
		throw "ID is an obligatory string" unless @id.substr


class ns.Edge

	constructor: (@source, @target, @type, directed) ->
		throw "source and target are obligatory strings" unless @source and
				@source.substr and @target and @target.substr

		@directed = !!directed # XXX: presentational; should be inferred from type
