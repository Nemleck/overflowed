extends Node2D
class_name Polygon

var turning_state = 0 # 0 to 1 while turning
var draggable: bool = false
var neighbors = {}
var order = 4;
var size = [100, 100]

var to_rotate = 0
var to_flow = {
	"from": 0,
	"percentage": 50
}
var queue = 0

var x
var y

const ROTATE_SPEED = 2
const FLOW_SPEED = 40

var scenes = {
	"triangle": preload("res://textures/polygons/piped_polygon/triangle_texture_rect.tscn"),
	"square": preload("res://textures/polygons/piped_polygon/square_texture_rect.tscn"),
	"hexagon": preload("res://textures/polygons/piped_polygon/hexagon_texture_rect.tscn")
}

@onready
var pipes = self.get_node("pipes")

func flow(n):
	self.pipes.flow(n)

func add_neighbor(node: Polygon, n: int):
	self.neighbors[n] = node
	node.neighbors[(n+3)%node.order] = self
	
	# TODO : get_n_from_angle(node) -> take opposite

func _set_order(order: int):
	self.order = order
	
	var name = "undefined"
	
	if order == 3:
		name = "triangle"
	elif order == 4:
		name = "square"
	elif order == 6:
		name = "hexagon"
	
	var textureRect = scenes[name].instantiate()
	self.add_child(textureRect)
	self.move_child(textureRect, 0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _on_area_2d_mouse_entered():
	draggable = true
	scale = Vector2(1.05, 1.05)

func _on_area_2d_mouse_exited():
	draggable = false
	scale = Vector2(1, 1)

func opposite_side(n):
	return (n+3) % 6

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if self.to_rotate != 0:
		var angle: float = 0
		
		if abs(self.to_rotate) > delta * ROTATE_SPEED:
			angle = delta * ROTATE_SPEED * sign(self.to_rotate)
		else:
			angle = self.to_rotate
		
		self.to_rotate -= angle
		self.rotate(angle)
	
	for pipe in pipes.pipes:
		if pipe["flow"]["flowing"]:
			var diff: float = 0
			
			if 100-pipe["flow"]["percentage"] > delta * FLOW_SPEED:
				diff = delta * FLOW_SPEED # Add delta * Speed
			else:
				diff = pipe["flow"]["percentage"] # Add only what remains
			
			pipe["flow"]["percentage"] += diff # Add here
			
			if pipe["flow"]["percentage"] >= 100: # End flowing
				pipe["flow"]["flowing"] = false
				
				if pipe["flow"]["to"] in self.neighbors.keys():
					self.neighbors[pipe["flow"]["to"]].flow(opposite_side(pipe["flow"]["to"]))
			
			pipes.redraw()
	
	if draggable and Input.is_action_just_pressed("click") and queue < 5:
		#self.queue += 1
		self.pipes.flow(1)
	
	if self.to_rotate == 0 and queue > 0:
		self.queue -= 1
		
		self.to_rotate = 2*PI/self.order
		for key in self.neighbors.keys():
			self.neighbors[key].to_rotate = -2*PI/self.order
			print_debug(key)
