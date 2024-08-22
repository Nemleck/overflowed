extends Node2D

var pipes: Array = []
var POLYGON;

const CENTER = Vector2(0, 0)
const POINTS_AMOUNT = 10

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

func _get_bezier_points(startpoint, endpoint):
	var result = []
	for i in range(POINTS_AMOUNT+1):
		var t = i*1.0/POINTS_AMOUNT
		
		var q0 = startpoint.lerp(CENTER, t)
		var q1 = CENTER.lerp(endpoint, t)
		result.append(q0.lerp(q1, t))
	
	return result

func flow(n):
	for pipe in pipes:
		if n in pipe["entries"]:
			var n2 = n
			for entry in pipe["entries"]:
				if n != entry:
					n2 = entry
			print_debug(n, n2)
			pipe["flow"] = {"flowing": true, "percentage": 0, "from": n, "to": n2}

func _generate_pipe(order: int, pipe_JSON):
	var n1 = pipe_JSON["entries"][0]
	var n2 = pipe_JSON["entries"][1]
	
	var startpoint: Vector2 = self._get_middle_coord(order, n1)
	var endpoint: Vector2 = self._get_middle_coord(order, n2)
	
	var points: PackedVector2Array = self._get_bezier_points(startpoint, endpoint)
	var colors: PackedColorArray = []
	
	for i in range(len(points)):
		if ( pipe_JSON["flow"]["from"] == n1 and i*100/len(points) < pipe_JSON["flow"]["percentage"] ) or\
		   ( pipe_JSON["flow"]["from"] == n2 and i*100/len(points) > 100-pipe_JSON["flow"]["percentage"] ):
			colors.append(Color.CYAN)
		else:
			colors.append(Color(0, 0, 0))
	
	draw_polyline_colors(points, colors, 10)

const ARIAL = preload("res://arial.ttf")
func _draw():
	for pipe in pipes:
		_generate_pipe(POLYGON.order, pipe)
	
	for i in range(POLYGON.order):
		draw_line(self._get_vertex_coord(POLYGON.order, i), self._get_vertex_coord(POLYGON.order, i+1), Color(), 3)
		#draw_line(self._get_middle_coord(6, i), self._get_middle_coord(6, i+1), Color(), 3)
	
	#draw_string(ARIAL, CENTER, str([POLYGON.x, POLYGON.y]), HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color(255, 255, 255))

func redraw():
	queue_redraw()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	POLYGON = self.get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
