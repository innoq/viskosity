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
		default: "link undirected"
		directed: "link directed"

	edgeWeight:
		default: 1

	symbolGen: d3.svg.symbol()
	colorGen: d3.scale.category20()

	# `vgraph` is a map with members `nodes` and `edges`, each a map of
	# `Node`s/`Edge`s indexed by ID
	# returns a map of style-augmented `RenderNode`s and `RenderEdge`s
	constructor: (vgraph) ->
		nodes = (@augmentNode(node) for id, node of vgraph.nodes)
		edges = (@augmentEdge(edge) for id, edge of vgraph.edges)
		return { nodes, edges }

	augmentNode: (node) ->
		size = () ->
			size = (@degree || 1) * 10 + 100 # XXX: arbitrary
			return Math.sqrt(size) # shape size is in px²
		_shape = @nodeShape[node.type] or @nodeShape["default"]
		_shape = @symbolGen.type(_shape)
		shape = () -> _shape.size(@size())()
		color = @nodeColorIndex[node.type] or @nodeColorIndex["default"]
		color = @colorGen(color)
		return new ns.RenderNode(node.id, node.type, node.label, shape, size,
				color)

	augmentEdge: (edge) ->
		className = @edgeClass[if edge.directed then "directed" else "default"]
		_path = @edgePath[if edge.directed then "directed" else "default"]
		path = () -> _path(@source, @target)
		weight = @edgeWeight[edge.type] or @edgeWeight["default"]
		weight = Math.sqrt(weight * 3) # XXX: arbitrary
		return new ns.RenderEdge(edge.source, edge.target, edge.type,
				edge.directed, className, path, weight)
