extends Node2D

var pipes: Array = []
var POLYGON;

const CENTER = Vector2(0, 0)

func _init_pipes(pipes_entries):
	self.pipes = []
	for pipe_entries in pipes_entries:
		var pipe = Pipe.new(pipe_entries)
		self.pipes.append(pipe)

func _get_vertex_coord(polygon_order: int, n: int):
	var base = 0
	if polygon_order != 6:
		base = - PI/4
	
	var gap: float = 2 * PI / polygon_order
	var x = cos(n*gap + base) * POLYGON.CIRCUMSCRIBED_RADIUS
	var y = sin(n*gap + base) * POLYGON.CIRCUMSCRIBED_RADIUS
	
	return Vector2(x, y)

func _get_middle_coord(polygon_order: int, n: int):
	var base = 0
	if polygon_order != 6:
		base = - PI/4
		
	var gap: float = 2 * PI / polygon_order
	var x = cos((n+0.5)*gap + base) * POLYGON.INSCRIBED_RADIUS
	var y = sin((n+0.5)*gap + base) * POLYGON.INSCRIBED_RADIUS
	
	return Vector2(x, y)

func _get_bezier_points(startpoint, endpoint, amount):
	var result = []
	for i in range(amount):
		var t = i*1.0/(amount-1)
		
		var q0 = startpoint.lerp(CENTER, t)
		var q1 = CENTER.lerp(endpoint, t)
		result.append(q0.lerp(q1, t))
	
	return result

func flow(n, color):
	for pipe in pipes:
		if n in pipe.entries:
			pipe.flow(n, color)
	self.redraw()

func get_pipes_from_entry(n):
	var result = []
	for pipe in pipes:
		if n in pipe.entries:
			result.append(pipe)
	
	return result # TODO : Optimization (called every tick) by indexing

func _generate_pipe(order: int, pipe):
	var n1 = pipe.entries[0]
	var n2 = pipe.entries[1]
	
	var startpoint: Vector2 = self._get_middle_coord(order, n1)
	var endpoint: Vector2 = self._get_middle_coord(order, n2)
	
	var points: PackedVector2Array = self._get_bezier_points(startpoint, endpoint, len(pipe.fragments))
	var colors: PackedColorArray = []
	
	for i in range(len(points)):
		if pipe.fragments[i] != null:
			colors.append(pipe.fragments[i].content["color"])
		else:
			colors.append(Color(0, 0, 0))
	
	draw_polyline_colors(points, colors, 10)

const ARIAL = preload("res://arial.ttf")
func _draw():
	for pipe in pipes:
		_generate_pipe(POLYGON.order, pipe)
	
	if not POLYGON.gearable():
		for i in range(POLYGON.order):
			draw_line(self._get_vertex_coord(POLYGON.order, i), self._get_vertex_coord(POLYGON.order, i+1), Color(), 3)
			#draw_line(self._get_middle_coord(6, i), self._get_middle_coord(6, i+1), Color(), 3)
	
	#draw_string(ARIAL, CENTER, str([POLYGON.x, POLYGON.y]), HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color(255, 255, 255))

func redraw():
	queue_redraw()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	POLYGON = self.get_parent()
