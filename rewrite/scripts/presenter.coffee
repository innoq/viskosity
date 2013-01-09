ns = this.VISKOSITY


drawLine = (src, tgt) -> "M#{src.x},#{src.y}L#{tgt.x},#{tgt.y}"

drawArc = (src, tgt) ->
	dx = tgt.x - src.x
	dy = tgt.y - src.y
	dr = Math.sqrt(dx * dx + dy * dy)
	return "M#{src.x},#{src.y}A#{dr},#{dr} 0 0,1 #{tgt.x},#{tgt.y}"


# augments "visual" graph data with presentational attributes
class ns.Presenter

	nodeShape:
		default: "circle"
		collection: "diamond" # XXX: not a valid type!?

	nodeColorIndex:
		default: 1
		collection: 2 # XXX: not a valid type!?

	edgePath:
		default: drawLine
		directed: drawArc

	edgeClass:
		default: "undirected"
		directed: "directed"

	edgeWeight:
		default: 1

	# `vgraph` is a map of `Node`s and `Edge`s
	# returns a map of style-augmented `RenderNode`s and `RenderEdge`s
	constructor: (vgraph) ->
		nodes = (@augmentNode(node) for node in vgraph.nodes)
		edges = (@augmentEdge(edge) for edge in vgraph.edges)
		return { nodes, edges }

	augmentNode: (node) ->
		shape = @nodeShape[node.type] or @nodeShape["default"]
		size = (node) -> (node.degree || 1) * 10 + 100 # XXX: arbitrary, does not belong here!?
		#size = Math.sqrt(size); # shape size is in px² -- XXX: does not belong here!?
		color = @nodeColorIndex[node.type] or @nodeColorIndex["default"]
		return new ns.RenderNode(node.id, node.type, node.label, shape, size,
				color)

	augmentEdge: (edge) ->
		className = @edgeClass[if edge.directed then "directed" else "default"]
		path = @edgePath[if edge.directed then "directed" else "default"]
		strength = @edgeWeight[edge.type] or @edgeWeight["default"]
		strength = Math.sqrt(strength * 3) # XXX: arbitrary, does not belong here!?
		return new ns.RenderEdge(edge.source, edge.target, edge.type,
				edge.directed, className, path, strength)
