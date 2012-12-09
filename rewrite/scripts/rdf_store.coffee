ns = this.VISKOSITY

class ns.RDFStore

	constructor: (triples) ->
		@cache = {}
		if triples
			@add(triple) for triple in triples

	# `triple` is an object with members `sbj`, `prd` and `obj`, each in turn an
	# object with members `value` and `type`
	add: (triple) ->
		# subject and predicate are always URIs -- XXX: blank nodes?
		sbj = (@cache[triple.sbj.value] ||= {})
		prd = (sbj[triple.prd.value] ||= [])
		prd.push(triple.obj)
		# TODO: store as prefixed names?

	# arguments are strings representing subject and predicate, respectively
	# if `prd` is supplied, a list of objects is returned - otherwise all known
	# facts about the subject (a map of predicate/objects pairs) are returned
	query: (sbj, prd) ->
		_sbj = @cache[sbj]
		if prd
			if _sbj
				return _sbj[prd] or null
			else
				return null
		else
			return _sbj or null

	@shorten: (uri) -> # XXX: does not belong here!?
		for prefix, iri of ns.namespaces
			if uri.indexOf(iri) == 0
				return uri.replace(iri, "#{prefix}:")
		return uri

	@expand: (prefixedName) -> # XXX: does not belong here!?
		[prefix, localPart] = prefixedName.split(":")
		return null unless localPart

		for namespace, iri of ns.namespaces
			if namespace == prefix
				return prefixedName.replace("#{prefix}:", iri)
		return null
