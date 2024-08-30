extends Node2D
class_name Polygon

const INSCRIBED_RADIUS: int = 42
const CIRCUMSCRIBED_RADIUS: int = INSCRIBED_RADIUS * 1.21

func scenes():
	return {
	"triangle": preload("res://textures/polygons/piped_polygon/piped_triangle_texture_rect.tscn"),
	"square": preload("res://textures/polygons/piped_polygon/piped_square_texture_rect.tscn"),
	"hexagon": preload("res://textures/polygons/piped_polygon/piped_hexagon_texture_rect.tscn")
}

var neighbors = {}
var order = 4;

var x
var y

func add_neighbor(node: Polygon, n: int):
	self.neighbors[n] = node
	node.neighbors[(n+3)%node.order] = self
	
	# TODO : get_n_from_angle(node) -> take opposite

func flow(n):
	pass

func rotatable():
	return false

func gearable():
	return false

func _set_order(order: int):
	self.order = order
	
	var name = "undefined"
	
	if order == 3:
		name = "triangle"
	elif order == 4:
		name = "square"
	elif order == 6:
		name = "hexagon"
	
	var textureRect = scenes()[name].instantiate()
	self.add_child(textureRect)
	self.move_child(textureRect, 0)

func opposite_side(n):
	return (n+3) % 6

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
